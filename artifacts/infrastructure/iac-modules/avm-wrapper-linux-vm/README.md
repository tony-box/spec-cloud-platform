# Azure Linux Virtual Machine Wrapper Module

**Purpose**: Compliant Azure Linux VM wrapper around Azure Verified Module  
**AVM Source**: `br/public:avm/res/compute/virtual-machine:0.7.3`  
**Spec**: infrastructure/iac-modules (iac-001)  
**Version**: 1.0.0  
**Status**: Ready for use

---

## Overview

This wrapper module provides a compliant Azure Linux Virtual Machine with cost-optimized SKUs, SSH-only authentication, and Azure Disk Encryption for production. It wraps the official Azure Verified Module (AVM) while enforcing platform standards.

**Key Features**:
- ✅ Cost-optimized VM SKUs (Standard_B2s dev, Standard_B4ms prod)
- ✅ SSH key authentication only (no passwords per ac-001)
- ✅ Ubuntu 22.04 LTS (5-year support)
- ✅ Azure Disk Encryption for production (dp-001)
- ✅ System-assigned managed identity (Azure RBAC)
- ✅ Cloud-init support for LAMP stack provisioning
- ✅ US regions only per compliance-framework-001

---

## Compliance

| Spec | Requirement | Implementation |
|------|-------------|----------------|
| cost-001 | Cost-optimized VMs | `@allowed(['Standard_B2s', 'Standard_B4ms'])` |
| dp-001 | Encryption at rest | Azure Disk Encryption enabled for production |
| ac-001 | SSH keys only | `disablePasswordAuthentication: true` |
| comp-001 | US regions only | `@allowed(['centralus', 'eastus'])` |
| lint-001 | Code quality | Passes `bicep build` validation |

---

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vmName` | string | Name of the VM (e.g., `mycoolapp-prod-vm`) |
| `environment` | string | Environment: `dev` or `prod` |
| `sshPublicKey` | string (secure) | SSH public key for admin user (required) |
| `subnetId` | string | Resource ID of subnet for VM NIC |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | `centralus` | Azure region (`centralus` or `eastus`) |
| `vmSize` | string | `Standard_B2s` (dev), `Standard_B4ms` (prod) | VM SKU |
| `adminUsername` | string | `azureuser` | Admin username for SSH |
| `publicIpId` | string | `''` (none) | Public IP resource ID to associate |
| `nsgId` | string | `''` (none) | NSG resource ID for NIC |
| `enableAcceleratedNetworking` | bool | `true` (B4ms+), `false` (B2s) | Accelerated networking |
| `osDiskSizeGB` | int | `64` | OS disk size (30-1024 GB) |
| `osDiskType` | string | `Premium_LRS` (prod), `StandardSSD_LRS` (dev) | OS disk type |
| `enableDiskEncryption` | bool | `true` (prod), `false` (dev) | Azure Disk Encryption |
| `customData` | string | `''` (none) | Cloud-init script for provisioning |
| `additionalTags` | object | `{}` | Additional tags |

---

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `vmId` | string | Resource ID of the VM |
| `vmName` | string | Name of the VM |
| `privateIpAddress` | string | Private IP address |
| `nicId` | string | Network interface resource ID |
| `identityPrincipalId` | string | Managed identity principal ID |
| `location` | string | Location of the VM |
| `vmSize` | string | VM SKU |
| `osDiskId` | string | OS disk resource ID |
| `resourceGroupName` | string | Resource group name |

---

## Usage Examples

### Example 1: Basic Development VM

```bicep
module vm '../../../infrastructure/iac-modules/avm-wrapper-linux-vm/main.bicep' = {
  name: 'vm-deployment'
  params: {
    vmName: 'mycoolapp-dev-vm'
    environment: 'dev'
    sshPublicKey: loadTextContent('~/.ssh/id_rsa.pub')
    subnetId: vnet.outputs.subnetIds[0] // App subnet
  }
}

// Output: Standard_B2s, 2 vCPU, 4 GiB RAM, ~$30/month
```

### Example 2: Production VM with Public IP

```bicep
module vm '../../../infrastructure/iac-modules/avm-wrapper-linux-vm/main.bicep' = {
  name: 'vm-deployment'
  params: {
    vmName: 'mycoolapp-prod-vm'
    environment: 'prod'
    vmSize: 'Standard_B4ms'
    sshPublicKey: loadTextContent('~/.ssh/id_rsa.pub')
    subnetId: vnet.outputs.subnetIds[0]
    publicIpId: publicIp.outputs.publicIpId
    nsgId: nsg.outputs.nsgId
    enableDiskEncryption: true
    osDiskType: 'Premium_LRS'
    osDiskSizeGB: 128
  }
}

// Output: Standard_B4ms, 4 vCPU, 16 GiB RAM, Premium SSD, disk encryption, ~$120/month
```

### Example 3: LAMP Stack VM with Cloud-Init

```bicep
var lampCloudInit = '''
#cloud-config
package_update: true
package_upgrade: true
packages:
  - apache2
  - mysql-server
  - php
  - libapache2-mod-php
  - php-mysql
runcmd:
  - systemctl start apache2
  - systemctl enable apache2
  - systemctl start mysql
  - systemctl enable mysql
  - echo "<?php phpinfo(); ?>" > /var/www/html/info.php
'''

module vm '../../../infrastructure/iac-modules/avm-wrapper-linux-vm/main.bicep' = {
  name: 'vm-deployment'
  params: {
    vmName: 'mycoolapp-dev-lamp'
    environment: 'dev'
    sshPublicKey: loadTextContent('~/.ssh/id_rsa.pub')
    subnetId: vnet.outputs.subnetIds[0]
    customData: lampCloudInit
  }
}

// After deployment: http://<VM-IP>/info.php shows PHP info
```

### Example 4: VM with Managed Identity and Key Vault Access

```bicep
module vm '../../../infrastructure/iac-modules/avm-wrapper-linux-vm/main.bicep' = {
  name: 'vm-deployment'
  params: {
    vmName: 'mycoolapp-prod-vm'
    environment: 'prod'
    sshPublicKey: loadTextContent('~/.ssh/id_rsa.pub')
    subnetId: vnet.outputs.subnetIds[0]
  }
}

// Grant VM managed identity access to Key Vault
resource keyVaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, vm.outputs.identityPrincipalId, 'Key Vault Secrets User')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6') // Key Vault Secrets User
    principalId: vm.outputs.identityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// VM can now access secrets: az keyvault secret show --vault-name <vault> --name <secret> (no credentials needed)
```

---

## VM SKU Comparison

| SKU | vCPU | RAM | Temp Storage | Max Data Disks | Cost/Month (US Central) | Use Case |
|-----|------|-----|--------------|----------------|-------------------------|----------|
| **Standard_B2s** | 2 | 4 GiB | 8 GiB | 4 | ~$30 | Dev/test, low traffic |
| **Standard_B4ms** | 4 | 16 GiB | 32 GiB | 8 | ~$120 | Production, moderate traffic |

**B-Series Benefits**:
- **Burstable**: CPU credits for burst performance
- **Cost-optimized**: ~70% cheaper than D-series for similar performance
- **Ideal for**: Web servers, small databases, dev environments

**When to use Standard_B4ms**:
- Production workloads
- 4+ concurrent users
- Database hosting
- CI/CD runners

---

## SSH Key Setup

### Generate SSH Key (if you don't have one)

```bash
ssh-keygen -t rsa -b 4096 -C "vm-admin@mycoolapp.com"
# Generates: ~/.ssh/id_rsa (private), ~/.ssh/id_rsa.pub (public)
```

### Use SSH Key in Bicep

```bicep
// Option 1: Load from file
sshPublicKey: loadTextContent('~/.ssh/id_rsa.pub')

// Option 2: Pass as parameter
param sshKey string
sshPublicKey: sshKey
```

### Deploy with SSH Key

```powershell
# Load SSH public key from file
$sshKey = Get-Content "$env:USERPROFILE\.ssh\id_rsa.pub" -Raw

az deployment group create `
  --resource-group rg-mycoolapp-dev `
  --template-file main.bicep `
  --parameters sshPublicKey="$sshKey"
```

### Connect to VM

```bash
ssh azureuser@<VM-PUBLIC-IP>
# Or with private IP from bastion/VPN:
ssh azureuser@<VM-PRIVATE-IP>
```

---

## Cloud-Init LAMP Stack

### Full LAMP Installation Script

Save as `lamp-cloud-init.yaml`:

```yaml
#cloud-config
package_update: true
package_upgrade: true

packages:
  - apache2
  - mysql-server
  - php8.1
  - libapache2-mod-php8.1
  - php8.1-mysql
  - php8.1-cli
  - php8.1-curl
  - php8.1-mbstring
  - php8.1-xml

runcmd:
  # Start and enable Apache
  - systemctl start apache2
  - systemctl enable apache2
  
  # Start and enable MySQL
  - systemctl start mysql
  - systemctl enable mysql
  
  # Secure MySQL (basic setup)
  - mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'ChangeThisPassword123!';"
  - mysql -e "DELETE FROM mysql.user WHERE User='';"
  - mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
  - mysql -e "DROP DATABASE IF EXISTS test;"
  - mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
  - mysql -e "FLUSH PRIVILEGES;"
  
  # Create sample database
  - mysql -u root -pChangeThisPassword123! -e "CREATE DATABASE IF NOT EXISTS mycoolapp;"
  
  # Create PHP info page
  - echo "<?php phpinfo(); ?>" > /var/www/html/info.php
  
  # Create sample PHP/MySQL connection test
  - |
    cat > /var/www/html/dbtest.php << 'EOF'
    <?php
    $conn = new mysqli("localhost", "root", "ChangeThisPassword123!", "mycoolapp");
    if ($conn->connect_error) {
      die("Connection failed: " . $conn->connect_error);
    }
    echo "Connected to MySQL successfully!";
    ?>
    EOF
  
  # Set permissions
  - chown -R www-data:www-data /var/www/html
  - chmod -R 755 /var/www/html

write_files:
  - path: /var/www/html/index.html
    content: |
      <html>
      <head><title>LAMP Stack Ready</title></head>
      <body>
        <h1>LAMP Stack Deployed Successfully!</h1>
        <p>Check <a href="/info.php">PHP Info</a> and <a href="/dbtest.php">Database Connection</a></p>
      </body>
      </html>
```

### Use in Bicep

```bicep
var lampCloudInit = loadTextContent('./lamp-cloud-init.yaml')

module vm '../../../infrastructure/iac-modules/avm-wrapper-linux-vm/main.bicep' = {
  params: {
    customData: lampCloudInit
    // ... other params
  }
}
```

### Verify Installation

```bash
# SSH into VM
ssh azureuser@<VM-IP>

# Check Apache status
sudo systemctl status apache2

# Check MySQL status
sudo systemctl status mysql

# Check PHP version
php -v

# Test web server
curl http://localhost
```

---

## Azure Disk Encryption

### How It Works
- **Encryption**: BitLocker (Windows), DM-Crypt (Linux)
- **Key Storage**: Azure Key Vault (optional, or platform-managed keys)
- **Performance**: Minimal impact (<5% overhead)
- **Cost**: No additional cost

### When Encryption is Enabled
- **Production**: Always enabled (`environment: prod`)
- **Development**: Disabled by default (can override)

### Manually Enable Encryption

```bicep
enableDiskEncryption: true
```

### Verify Encryption

```powershell
az vm encryption show --name mycoolapp-prod-vm --resource-group rg-mycoolapp-prod
# Output: "encryptionSettings": { "enabled": true }
```

---

## Managed Identity

### What is Managed Identity?
- **System-assigned**: Created automatically with VM
- **No credentials**: No passwords/keys to manage
- **Azure RBAC**: Grant access to Azure resources (Key Vault, Storage, SQL)

### Common Use Cases

**1. Access Key Vault Secrets**
```bash
# From VM (no credentials needed):
az keyvault secret show --vault-name mycoolapp-kv --name db-password
```

**2. Access Storage Account**
```bash
# From VM:
az storage blob list --account-name mycoolappstore --container-name uploads --auth-mode login
```

**3. Access Azure SQL**
```bash
# Use managed identity for SQL authentication (no password)
sqlcmd -S mycoolapp-sql.database.windows.net -d mycoolapp -G
```

### Grant Access to Resources

See Example 4 above for RBAC role assignment example.

---

## Cost Considerations

### Development Environment
- **VM**: Standard_B2s (~$30/month)
- **OS Disk**: StandardSSD_LRS 64 GB (~$5/month)
- **Total**: ~$35/month

### Production Environment
- **VM**: Standard_B4ms (~$120/month)
- **OS Disk**: Premium_LRS 128 GB (~$20/month)
- **Disk Encryption**: $0 (included)
- **Managed Identity**: $0 (included)
- **Total**: ~$140/month

**Cost Optimization**:
- Use **Reserved Instances**: Save 40-60% (1-year or 3-year commitment)
- **Deallocate** VMs when not in use (dev environments)
- Use **Azure Hybrid Benefit** if you have Windows Server licenses (not applicable for Linux)

---

## Deployment Validation

### Validate Bicep

```powershell
bicep build main.bicep
```

### Deploy to Dev

```powershell
$sshKey = Get-Content "$env:USERPROFILE\.ssh\id_rsa.pub" -Raw

az deployment group create `
  --resource-group rg-mycoolapp-dev `
  --template-file main.bicep `
  --parameters vmName=mycoolapp-dev-vm environment=dev sshPublicKey="$sshKey" subnetId="/subscriptions/.../subnets/app-subnet"
```

### Verify VM Running

```powershell
az vm show --name mycoolapp-dev-vm --resource-group rg-mycoolapp-dev --query "provisioningState"
# Output: "Succeeded"
```

### Get Private IP

```powershell
az vm show --name mycoolapp-dev-vm --resource-group rg-mycoolapp-dev --show-details --query "privateIps" --output tsv
```

---

## Troubleshooting

### Issue: "SSH public key invalid"
**Cause**: SSH key format incorrect or contains extra whitespace  
**Solution**: Ensure key starts with `ssh-rsa` and has no line breaks

```powershell
# Correct format:
$sshKey = (Get-Content "$env:USERPROFILE\.ssh\id_rsa.pub" -Raw).Trim()
```

### Issue: "VM size not available in region"
**Cause**: Standard_B4ms not available in selected region  
**Solution**: Use `centralus` or `eastus` (both support B-series)

### Issue: "Cannot connect via SSH"
**Cause**: NSG blocking port 22 or VM has no public IP  
**Solution**: 
- Check NSG rules allow SSH from your IP
- Verify VM has public IP or connect via VPN/Bastion

### Issue: "Disk encryption failed"
**Cause**: Managed identity not created or Key Vault access denied  
**Solution**: Ensure `enableSystemManagedIdentity: true` and check Key Vault RBAC

---

## Related Modules

- **avm-wrapper-vnet**: Create VNet and subnet for VM
- **avm-wrapper-nsg**: Control network access to VM
- **avm-wrapper-public-ip**: Assign public IP to VM
- **avm-wrapper-managed-disk**: Attach additional data disks
- **avm-wrapper-key-vault**: Store secrets for VM applications

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-02-07 | Initial release wrapping AVM VM module v0.7.3 |

---

## Upstream Specs

- **infrastructure/iac-modules** (iac-001): Wrapper module specification
- **business/cost** (cost-001): Cost optimization (B-series SKUs)
- **security/data-protection** (dp-001): Disk encryption requirements
- **security/access-control** (ac-001): SSH keys only, managed identity
- **business/compliance-framework** (comp-001): US regions and tagging
- **platform/iac-linting** (lint-001): Code quality standards

---

**Module Owner**: Infrastructure Engineering Team  
**Support**: platform-team@company.com  
**License**: Internal use only
