# Getting Started with IaC Wrapper Modules

**Purpose**: Quickstart guide for application teams to deploy LAMP stack infrastructure using compliant wrapper modules  
**Audience**: Application developers, DevOps engineers  
**Estimated Time**: 30-60 minutes (dev environment)  
**Prerequisites**: Azure subscription, Bicep CLI installed, SSH keys generated  

---

## What Are These Modules?

The IaC wrapper modules are **pre-built, compliance-enforced** infrastructure templates that wrap Azure Verified Modules (AVM). They make it **easy to deploy LAMP stack infrastructure** without worrying about security, cost optimization, or networking configuration.

**Key Benefits**:
- ✅ **Compliance enforced**: Cost, security, and regulatory requirements built-in
- ✅ **Simple interface**: Only specify what you need, defaults handle the rest
- ✅ **Production-ready**: Tested patterns for dev and prod environments
- ✅ **No manual configuration**: No need to configure NSG rules, encryption, or backup policies

---

## Quick Start: Deploy Dev LAMP Stack (15 minutes)

### Step 1: Prerequisites

1. **Install Bicep CLI**:
   ```powershell
   az bicep install
   bicep --version
   ```

2. **Generate SSH Key** (if you don't have one):
   ```powershell
   ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
   # Saves to: ~/.ssh/id_rsa (private), ~/.ssh/id_rsa.pub (public)
   ```

3. **Login to Azure**:
   ```powershell
   az login
   az account set --subscription "<your-subscription-id>"
   ```

4. **Create Resource Group**:
   ```powershell
   az group create --name rg-mycoolapp-dev --location centralus
   ```

### Step 2: Create Deployment Template

Create a file `deploy-lamp-dev.bicep`:

```bicep
// ============================================================================
// LAMP Stack Dev Environment
// ============================================================================

targetScope = 'resourceGroup'

param appName string = 'mycoolapp'
param environment string = 'dev'
param location string = 'centralus'
param sshPublicKey string
param mysqlAdminPassword string

// ============================================================================
// 1. Virtual Network
// ============================================================================

module vnet '../infrastructure/iac-modules/avm-wrapper-vnet/main.bicep' = {
  name: 'vnet-deployment'
  params: {
    vnetName: '${appName}-${environment}-vnet'
    environment: environment
    location: location
    addressPrefix: '10.0.0.0/16'
    subnets: [
      {
        name: 'app-subnet'
        addressPrefix: '10.0.1.0/24'
      }
      {
        name: 'mysql-subnet'
        addressPrefix: '10.0.3.0/24'
        delegations: [
          {
            name: 'mysql-delegation'
            properties: {
              serviceName: 'Microsoft.DBforMySQL/flexibleServers'
            }
          }
        ]
      }
    ]
  }
}

// ============================================================================
// 2. Network Security Group
// ============================================================================

module nsg '../infrastructure/iac-modules/avm-wrapper-nsg/main.bicep' = {
  name: 'nsg-deployment'
  params: {
    nsgName: '${appName}-${environment}-nsg'
    environment: environment
    location: location
    sshSourceAddressPrefix: '' // Deny SSH from internet (use bastion or VPN)
    customRules: [
      {
        name: 'AllowMySQL'
        priority: 2000
        direction: 'Inbound'
        access: 'Allow'
        protocol: 'Tcp'
        sourcePortRange: '*'
        destinationPortRange: '3306'
        sourceAddressPrefix: '10.0.1.0/24' // App subnet
        destinationAddressPrefix: '10.0.3.0/24' // MySQL subnet
      }
    ]
  }
}

// ============================================================================
// 3. Public IP (for internet access)
// ============================================================================

module publicIp '../infrastructure/iac-modules/avm-wrapper-public-ip/main.bicep' = {
  name: 'pip-deployment'
  params: {
    publicIpName: '${appName}-${environment}-pip'
    environment: environment
    location: location
    dnsLabel: '${appName}-${environment}'
  }
}

// ============================================================================
// 4. Key Vault (for MySQL password)
// ============================================================================

module keyVault '../infrastructure/iac-modules/avm-wrapper-key-vault/main.bicep' = {
  name: 'kv-deployment'
  params: {
    keyVaultName: '${appName}-${environment}-kv'
    environment: environment
    location: location
  }
}

// ============================================================================
// 5. Private DNS Zone for MySQL
// ============================================================================

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.mysql.database.azure.com'
  location: 'global'
}

resource dnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: 'mysql-dns-link'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnet.outputs.vnetId
    }
    registrationEnabled: false
  }
}

// ============================================================================
// 6. MySQL Flexible Server
// ============================================================================

module mysql '../infrastructure/iac-modules/avm-wrapper-mysql-flexibleserver/main.bicep' = {
  name: 'mysql-deployment'
  params: {
    serverName: '${appName}-${environment}-mysql'
    environment: environment
    location: location
    administratorPassword: mysqlAdminPassword
    delegatedSubnetId: vnet.outputs.subnetIds[1] // mysql-subnet
    privateDnsZoneId: privateDnsZone.id
  }
  dependsOn: [dnsZoneLink]
}

// ============================================================================
// 7. Linux VM with LAMP Stack
// ============================================================================

var lampCloudInit = '''
#cloud-config
package_update: true
package_upgrade: true

packages:
  - apache2
  - mysql-client
  - php8.1
  - libapache2-mod-php8.1
  - php8.1-mysql
  - php8.1-cli

runcmd:
  - systemctl start apache2
  - systemctl enable apache2
  - echo "<?php phpinfo(); ?>" > /var/www/html/info.php
  - chown -R www-data:www-data /var/www/html
  - chmod -R 755 /var/www/html
'''

module vm '../infrastructure/iac-modules/avm-wrapper-linux-vm/main.bicep' = {
  name: 'vm-deployment'
  params: {
    vmName: '${appName}-${environment}-vm'
    environment: environment
    location: location
    sshPublicKey: sshPublicKey
    subnetId: vnet.outputs.subnetIds[0] // app-subnet
    publicIpId: publicIp.outputs.publicIpId
    nsgId: nsg.outputs.nsgId
    customData: lampCloudInit
  }
}

// ============================================================================
// 8. Storage Account (for uploads)
// ============================================================================

module storage '../infrastructure/iac-modules/avm-wrapper-storage-account/main.bicep' = {
  name: 'storage-deployment'
  params: {
    storageAccountName: '${appName}${environment}storage'
    environment: environment
    location: location
  }
}

// ============================================================================
// Outputs
// ============================================================================

output vnetId string = vnet.outputs.vnetId
output vmPublicIp string = publicIp.outputs.ipAddress
output vmFqdn string = publicIp.outputs.fqdn
output mysqlServerFqdn string = mysql.outputs.fqdn
output keyVaultUri string = keyVault.outputs.keyVaultUri
output storageAccountName string = storage.outputs.storageAccountName

output connectionInfo object = {
  websiteUrl: 'http://${publicIp.outputs.ipAddress}'
  phpInfo: 'http://${publicIp.outputs.ipAddress}/info.php'
  sshCommand: 'ssh azureuser@${publicIp.outputs.ipAddress}'
  mysqlConnection: 'mysql -h ${mysql.outputs.fqdn} -u mysqladmin -p (from VM)'
}
```

### Step 3: Create Parameters File

Create `deploy-lamp-dev.parameters.json`:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "appName": {
      "value": "mycoolapp"
    },
    "environment": {
      "value": "dev"
    },
    "location": {
      "value": "centralus"
    },
    "sshPublicKey": {
      "value": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC... (paste your SSH public key)"
    },
    "mysqlAdminPassword": {
      "value": "ChangeThisPassword123!"
    }
  }
}
```

### Step 4: Deploy

```powershell
# Deploy LAMP stack
az deployment group create `
  --resource-group rg-mycoolapp-dev `
  --template-file deploy-lamp-dev.bicep `
  --parameters deploy-lamp-dev.parameters.json

# Deployment takes ~10-15 minutes
# Output shows website URL, SSH command, MySQL connection
```

###Step 5: Verify Deployment

```powershell
# Get deployment outputs
az deployment group show --resource-group rg-mycoolapp-dev --name deploy-lamp-dev --query properties.outputs

# Output example:
# {
#   "connectionInfo": {
#     "value": {
#       "websiteUrl": "http://20.12.34.56",
#       "phpInfo": "http://20.12.34.56/info.php",
#       "sshCommand": "ssh azureuser@20.12.34.56",
#       "mysqlConnection": "mysql -h mycoolapp-dev-mysql.mysql.database.azure.com -u mysqladmin -p (from VM)"
#     }
#   }
# }
```

### Step 6: Test Your LAMP Stack

1. **Test Apache**:
   - Open browser: `http://<VM-PUBLIC-IP>`
   - Should see Apache default page

2. **Test PHP**:
   - Open browser: `http://<VM-PUBLIC-IP>/info.php`
   - Should see PHP info page with version, modules

3. **Test MySQL Connection**:
   ```bash
   # SSH into VM
   ssh azureuser@<VM-PUBLIC-IP>
   
   # Connect to MySQL
   mysql -h mycoolapp-dev-mysql.mysql.database.azure.com -u mysqladmin -p
   # Enter password: ChangeThisPassword123!
   
   # Create database and test
   CREATE DATABASE mycoolapp;
   USE mycoolapp;
   CREATE TABLE test (id INT, name VARCHAR(50));
   INSERT INTO test VALUES (1, 'Hello LAMP Stack!');
   SELECT * FROM test;
   ```

4. **Test Storage Account**:
   ```bash
   # From VM (using managed identity):
   az storage blob upload --account-name mycoolappdevstorage --container-name uploads --name test.txt --file ~/test.txt --auth-mode login
   ```

---

## Understanding the Deployment

### What Was Created?

| Resource | Purpose | Cost/Month |
|----------|---------|------------|
| **VNet** | Isolated network for resources | $0 |
| **NSG** | Firewall rules (HTTP/HTTPS allow, SSH deny) | $0 |
| **Public IP** | Static IP for internet access | $3.65 |
| **Key Vault** | Stores secrets (MySQL password) | <$1 |
| **MySQL** | MySQL 8.0 database (Burstable_B1ms) | $17 |
| **Linux VM** | Apache + PHP server (Standard_B2s) | $30 |
| **Storage** | Blob storage for uploads (100 GB) | $3 |
| **TOTAL** | | **~$55/month** |

### Resource Locations

- **VNet**: `10.0.0.0/16` with 2 subnets (app-subnet, mysql-subnet)
- **VM**: app-subnet (`10.0.1.0/24`), has public IP
- **MySQL**: mysql-subnet (`10.0.3.0/24`), private only
- **NSG**: Attached to app-subnet, allows HTTP/HTTPS, denies SSH from internet
- **Public IP**: Associated with VM NIC
- **Storage**: Accessible from VM via managed identity

---

## Next Steps

### 1. Secure MySQL Access

**Store password in Key Vault instead of parameters file**:

```bash
# Store MySQL password in Key Vault
az keyvault secret set --vault-name mycoolapp-dev-kv --name mysql-admin-password --value "ChangeThisPassword123!"

# Grant deployment principal access
az keyvault set-policy --name mycoolapp-dev-kv --upn <your-email> --secret-permissions get

# Update Bicep to retrieve from Key Vault:
# param mysqlAdminPassword string = keyVault.getSecret('mysql-admin-password')
```

### 2. Create Application Database User

```bash
# SSH into VM
ssh azureuser@<VM-PUBLIC-IP>

# Connect to MySQL
mysql -h mycoolapp-dev-mysql.mysql.database.azure.com -u mysqladmin -p

# Create application user
CREATE USER 'appuser'@'%' IDENTIFIED BY 'AppPassword123!';
GRANT ALL PRIVILEGES ON mycoolapp.* TO 'appuser'@'%';
FLUSH PRIVILEGES;
```

### 3. Deploy Your Application

```bash
# SSH into VM
ssh azureuser@<VM-PUBLIC-IP>

# Clone your application code
cd /var/www/html
sudo rm index.html
sudo git clone https://github.com/your-repo/your-app.git .

# Configure database connection
# Edit config.php:
# $conn = new mysqli("mycoolapp-dev-mysql.mysql.database.azure.com", "appuser", "AppPassword123!", "mycoolapp", 3306, null, MYSQLI_CLIENT_SSL);
```

### 4. Set Up Storage Container

```bash
# Create blob container for user uploads
az storage container create --account-name mycoolappdevstorage --name uploads --auth-mode login

# Grant VM "Storage Blob Data Contributor" role
$vmPrincipalId = (az vm show --name mycoolapp-dev-vm --resource-group rg-mycoolapp-dev --query identity.principalId -o tsv)
az role assignment create --role "Storage Blob Data Contributor" --assignee $vmPrincipalId --scope "/subscriptions/<subscription-id>/resourceGroups/rg-mycoolapp-dev/providers/Microsoft.Storage/storageAccounts/mycoolappdevstorage"
```

---

## Production Deployment

### Key Differences: Dev vs Prod

| Feature | Dev | Prod |
|---------|-----|------|
| **VM SKU** | Standard_B2s (2 vCPU, 4 GB) | Standard_B4ms (4 vCPU, 16 GB) |
| **MySQL SKU** | Burstable_B1ms | GeneralPurpose_D2ds_v4 |
| **MySQL HA** | Disabled | Zone-redundant (zones 1, 2) |
| **MySQL Backup** | 7 days | 30 days |
| **Disk Encryption** | Disabled | Enabled (Azure Disk Encryption) |
| **Storage SKU** | Standard_LRS | Standard_ZRS |
| **Blob Soft Delete** | Disabled | 30 days |
| **Key Vault SKU** | Standard | Premium (HSM-backed keys) |
| **Public Access** | Allowed | Disabled (VNet/private endpoints only) |
| **Cost** | ~$55/month | ~$320-410/month |

### Prod Deployment Template

```bicep
// Change environment to 'prod'
param environment string = 'prod'

// MySQL with HA
module mysql '../infrastructure/iac-modules/avm-wrapper-mysql-flexibleserver/main.bicep' = {
  params: {
    serverName: '${appName}-prod-mysql'
    environment: 'prod'
    sku: 'GeneralPurpose_D2ds_v4'
    highAvailability: true
    standbyAvailabilityZone: '2'
    backupRetentionDays: 30
    // ... other params
  }
}

// VM with larger SKU and encryption
module vm '../infrastructure/iac-modules/avm-wrapper-linux-vm/main.bicep' = {
  params: {
    vmName: '${appName}-prod-vm'
    environment: 'prod'
    vmSize: 'Standard_B4ms'
    enableDiskEncryption: true
    osDiskSizeGB: 128
    osDiskType: 'Premium_LRS'
    // ... other params
  }
}
```

---

## Troubleshooting

### Issue: "Deployment failed - location not allowed"
**Solution**: Ensure `location` parameter is set to `centralus` or `eastus` (US regions only per comp-001)

### Issue: "Cannot connect to VM via SSH"
**Solution**: 
1. Check NSG allows SSH from your IP: `az network nsg rule create --name AllowSSH-MyIP --nsg-name mycoolapp-dev-nsg --priority 1001 --source-address-prefix <your-ip> --destination-port-range 22`
2. Verify VM has public IP: `az vm show --name mycoolapp-dev-vm --resource-group rg-mycoolapp-dev --show-details --query publicIps`

### Issue: "Cannot connect to MySQL from VM"
**Solution**:
1. Ensure VM is in app-subnet and MySQL is in mysql-subnet (same VNet)
2. Verify private DNS zone linked to VNet: `az network private-dns link vnet list --zone-name privatelink.mysql.database.azure.com --resource-group rg-mycoolapp-dev`
3. Test DNS resolution from VM: `nslookup mycoolapp-dev-mysql.mysql.database.azure.com` (should resolve to private IP 10.0.3.x)

### Issue: "PHP cannot connect to MySQL - SSL error"
**Solution**: Add `MYSQLI_CLIENT_SSL` flag:
```php
$conn = new mysqli("mycoolapp-dev-mysql.mysql.database.azure.com", "appuser", "password", "mycoolapp", 3306, null, MYSQLI_CLIENT_SSL);
```

---

## Best Practices

### 1. Use Key Vault for Secrets
- **Never** hardcode passwords in Bicep parameter files
- Store all secrets (MySQL passwords, API keys) in Key Vault
- Reference secrets in Bicep using `keyVault.getSecret()`

### 2. Use Managed Identity
- Grant VM managed identity access to Key Vault, Storage Account
- No need to store credentials in VM
- Azure handles authentication automatically

### 3. Separate Dev and Prod

**Separate Resource Groups**:
- Dev: `rg-mycoolapp-dev`
- Prod: `rg-mycoolapp-prod`

**Separate VNets**:
- Dev: `10.0.0.0/16`
- Prod: `10.1.0.0/16`

**Separate Subscriptions** (if possible):
- Better cost tracking and isolation

### 4. Cost Optimization
- **Deallocate dev VMs** when not in use: `az vm deallocate --name mycoolapp-dev-vm --resource-group rg-mycoolapp-dev`
- **Delete unused resources**: Public IPs, disks, snapshots
- **Use Cool tier** for blob storage archives (45% cheaper than Hot)

### 5. Backup and Disaster Recovery
- **MySQL backups**: Automatic with 7/30-day retention
- **VM backups**: Use Azure Backup (separate service, ~$10/month per VM)
- **Snapshot disks**: Before major changes
- **Test restores**: Verify backups work

---

## Additional Resources

- **Module Catalog**: [MODULE_CATALOG.md](./MODULE_CATALOG.md) - Full list of all 8 wrapper modules
- **Compliance Matrix**: [COMPLIANCE_MATRIX.md](./COMPLIANCE_MATRIX.md) - Detailed compliance requirements
- **AVM Versions**: [avm-versions.md](./avm-versions.md) - Upstream module version tracking
- **Validation Checklist**: [MODULE_VALIDATION_CHECKLIST.md](./MODULE_VALIDATION_CHECKLIST.md) - Module quality checklist

- **Individual Module READMEs**:
  - [VNet](./avm-wrapper-vnet/README.md) | [NSG](./avm-wrapper-nsg/README.md) | [Public IP](./avm-wrapper-public-ip/README.md)
  - [Linux VM](./avm-wrapper-linux-vm/README.md) | [Managed Disk](./avm-wrapper-managed-disk/README.md)
  - [Key Vault](./avm-wrapper-key-vault/README.md) | [Storage Account](./avm-wrapper-storage-account/README.md) | [MySQL](./avm-wrapper-mysql-flexibleserver/README.md)

---

## Support

**Need Help?**
- Email: platform-team@company.com
- Slack: #platform-support
- Documentation: Spec infrastructure/iac-modules (iac-001)

---

**Version**: 1.0.0  
**Last Updated**: 2026-02-07  
**Owner**: Infrastructure Engineering Team
