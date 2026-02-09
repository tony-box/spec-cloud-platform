# Azure Database for MySQL Flexible Server Wrapper Module

**Purpose**: Compliant Azure MySQL Flexible Server wrapper around Azure Verified Module  
**AVM Source**: `br/public:avm/res/db-for-my-sql/flexible-server:0.4.2`  
**Spec**: infrastructure/iac-modules (iac-001)  
**Version**: 1.0.0  
**Status**: Ready for use

---

## Overview

This wrapper module provides a compliant Azure Database for MySQL Flexible Server with cost-optimized SKUs, zone-redundant HA for production, and VNet-only access. It wraps the official Azure Verified Module (AVM) while enforcing platform standards.

**Key Features**:
- ✅ MySQL 8.0 LTS (long-term support)
- ✅ Cost-optimized SKUs (Burstable_B1ms dev, GeneralPurpose_D2ds_v4 prod)
- ✅ Zone-redundant HA for production (99.99% SLA)
- ✅ VNet integration only (no public access per ac-001)
- ✅ SSL/TLS required for connections (dp-001)
- ✅ 30-day backup retention for production (dp-001)
- ✅ US regions only per compliance-framework-001

---

## Compliance

| Spec | Requirement | Implementation |
|------|-------------|----------------|
| cost-001 | Cost-optimized database | Burstable_B1ms (dev), GeneralPurpose_D2ds_v4 (prod) |
| dp-001 | Encryption and backups | SSL/TLS required, 30-day backup retention prod |
| ac-001 | VNet-only access | Delegated subnet, private DNS zone, no public access |
| comp-001 | US regions only | `@allowed(['centralus', 'eastus'])` |
| lint-001 | Code quality | Passes `bicep build` validation |

---

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `serverName` | string | Name of MySQL server (globally unique) |
| `environment` | string | Environment: `dev` or `prod` |
| `administratorPassword` | string (secure) | Admin password (min 8 chars) |
| `delegatedSubnetId` | string | Subnet resource ID for VNet integration |
| `privateDnsZoneId` | string | Private DNS zone for MySQL |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | `centralus` | Azure region (`centralus` or `eastus`) |
| `sku` | string | `Burstable_B1ms` (dev), `GeneralPurpose_D2ds_v4` (prod) | MySQL SKU |
| `mysqlVersion` | string | `8.0.21` | MySQL version |
| `administratorLogin` | string | `mysqladmin` | Admin username |
| `storageSizeGB` | int | `20` (dev), `100` (prod) | Storage size (20-16384 GB) |
| `storageIops` | int | `360` (dev), `3000` (prod) | Storage IOPS (360-20000) |
| `storageAutogrow` | bool | `true` (prod), `false` (dev) | Auto-grow storage |
| `backupRetentionDays` | int | `30` (prod), `7` (dev) | Backup retention (1-35 days) |
| `geoRedundantBackup` | bool | `false` | Geo-redundant backup (disabled for cost) |
| `highAvailability` | bool | `true` (prod), `false` (dev) | Zone-redundant HA |
| `standbyAvailabilityZone` | string | `2` (if HA), `''` (no HA) | Standby zone for HA |
| `additionalTags` | object | `{}` | Additional tags |

---

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `serverId` | string | Resource ID of the MySQL server |
| `serverName` | string | Name of the MySQL server |
| `fqdn` | string | Fully qualified domain name (e.g., `mycoolapp-dev-mysql.mysql.database.azure.com`) |
| `location` | string | Location of the MySQL server |
| `sku` | string | SKU of the MySQL server |
| `mysqlVersion` | string | MySQL version |
| `backupRetentionDays` | int | Backup retention days |
| `highAvailabilityEnabled` | bool | High availability enabled |
| `resourceGroupName` | string | Resource group name |

---

## Usage Examples

### Example 1: Basic Dev MySQL Server

```bicep
// Create delegated subnet for MySQL
module vnet '../../../infrastructure/iac-modules/avm-wrapper-vnet/main.bicep' = {
  params: {
    vnetName: 'mycoolapp-dev-vnet'
    environment: 'dev'
    subnets: [
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

// Create private DNS zone
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.mysql.database.azure.com'
  location: 'global'
}

// Link DNS zone to VNet
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

// Create MySQL server
module mysql '../../../infrastructure/iac-modules/avm-wrapper-mysql-flexibleserver/main.bicep' = {
  name: 'mysql-deployment'
  params: {
    serverName: 'mycoolapp-dev-mysql'
    environment: 'dev'
    administratorPassword: 'ChangeThisPassword123!' // Use Key Vault in production
    delegatedSubnetId: vnet.outputs.subnetIds[2] // mysql-subnet
    privateDnsZoneId: privateDnsZone.id
  }
}

// Output: Burstable_B1ms, 20 GB, 7-day backup, ~$15/month
```

### Example 2: Production MySQL with Zone-Redundant HA

```bicep
module mysql '../../../infrastructure/iac-modules/avm-wrapper-mysql-flexibleserver/main.bicep' = {
  name: 'mysql-deployment'
  params: {
    serverName: 'mycoolapp-prod-mysql'
    environment: 'prod'
    sku: 'GeneralPurpose_D2ds_v4'
    administratorPassword: keyVault.getSecret('mysql-admin-password') // From Key Vault
    delegatedSubnetId: vnet.outputs.subnetIds[2]
    privateDnsZoneId: privateDnsZone.id
    storageSizeGB: 100
    storageIops: 3000
    storageAutogrow: true
    backupRetentionDays: 30
    highAvailability: true
    standbyAvailabilityZone: '2' // Primary zone 1, standby zone 2
  }
}

// Output: GeneralPurpose_D2ds_v4, 2 vCPU, 100 GB, zone-redundant HA, 30-day backup, ~$150/month
```

### Example 3: Create Database and Grant Access

```bicep
module mysql '../../../infrastructure/iac-modules/avm-wrapper-mysql-flexibleserver/main.bicep' = {
  params: {
    serverName: 'mycoolapp-dev-mysql'
    environment: 'dev'
    administratorPassword: 'ChangeThisPassword123!'
    delegatedSubnetId: vnet.outputs.subnetIds[2]
    privateDnsZoneId: privateDnsZone.id
  }
}

// Create database (must be done after server deployment)
resource database 'Microsoft.DBforMySQL/flexibleServers/databases@2023-06-30' = {
  name: '${mysql.outputs.serverName}/mycoolapp'
  properties: {
    charset: 'utf8mb4'
    collation: 'utf8mb4_unicode_ci'
  }
}

// Connect from VM and create application user:
// mysql -h mycoolapp-dev-mysql.mysql.database.azure.com -u mysqladmin -p
// CREATE USER 'appuser'@'%' IDENTIFIED BY 'AppPassword123!';
// GRANT ALL PRIVILEGES ON mycoolapp.* TO 'appuser'@'%';
// FLUSH PRIVILEGES;
```

### Example 4: Connection String for Application

```bicep
// Store connection string in Key Vault
resource connectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'mysql-connection-string'
  properties: {
    value: 'Server=${mysql.outputs.fqdn};Port=3306;Database=mycoolapp;Uid=appuser;Pwd=AppPassword123!;SslMode=Required;'
  }
}

// PHP connection example:
// $conn = new mysqli("mycoolapp-dev-mysql.mysql.database.azure.com", "appuser", "AppPassword123!", "mycoolapp", 3306, null, MYSQLI_CLIENT_SSL);
// if ($conn->connect_error) {
//   die("Connection failed: " . $conn->connect_error);
// }
// echo "Connected successfully!";
```

---

## SKU Comparison

### Burstable Tier (Dev Default)

| SKU | vCPU | RAM | IOPS | Max Connections | Cost/Month (US Central) | Use Case |
|-----|------|-----|------|-----------------|-------------------------|----------|
| **Burstable_B1ms** | 1 | 2 GiB | 360 | 50 | ~$15 | Dev, test, small apps |
| **Burstable_B2s** | 2 | 4 GiB | 640 | 100 | ~$30 | Medium dev workloads |

### GeneralPurpose Tier (Prod Default)

| SKU | vCPU | RAM | IOPS | Max Connections | Cost/Month (US Central) | Use Case |
|-----|------|-----|------|-----------------|-------------------------|----------|
| **GeneralPurpose_D2ds_v4** | 2 | 8 GiB | 3000 | 200 | ~$75 (no HA), ~$150 (HA) | Production, moderate traffic |
| **GeneralPurpose_D4ds_v4** | 4 | 16 GiB | 6000 | 400 | ~$150 (no HA), ~$300 (HA) | High-traffic production |

**B-Series (Burstable) Benefits**:
- **CPU Credits**: Burst to 100% CPU for short periods
- **Cost-Optimized**: ~80% cheaper than GeneralPurpose for low-traffic workloads
- **Ideal for**: Dev/test, small applications (<100 concurrent users)

**D-Series (GeneralPurpose) Benefits**:
- **Consistent Performance**: No CPU credit system
- **Higher IOPS**: 3000+ IOPS for database-heavy workloads
- **Ideal for**: Production, e-commerce, APIs

---

## High Availability (Zone-Redundant)

### How It Works
- **Primary Server**: Zone 1
- **Standby Server**: Zone 2 (synchronous replication)
- **Failover**: Automatic in 60-120 seconds
- **SLA**: 99.99% (vs 99.9% without HA)

### When to Use
- **Production**: Always enable HA for critical workloads
- **Development**: Disable HA to save cost (50% reduction)

### Cost Impact
- **Without HA**: ~$75/month (GeneralPurpose_D2ds_v4)
- **With HA**: ~$150/month (2× cost for standby server)

### Manual Failover (Testing)

```powershell
# Trigger manual failover (for testing HA)
az mysql flexible-server failover --name mycoolapp-prod-mysql --resource-group rg-mycoolapp-prod
# Downtime: 60-120 seconds
```

---

## Backup and Restore

### Automatic Backups
- **Frequency**: Daily full backup + continuous transaction logs
- **Retention**: 7 days (dev), 30 days (prod)
- **Cost**: Included in server cost (up to 100% of storage size)
- **Storage**: Locally redundant (LRS) or geo-redundant (GRS, +cost)

### Point-in-Time Restore

```powershell
# Restore to specific time (within retention period)
az mysql flexible-server restore --name mycoolapp-restored-mysql --resource-group rg-mycoolapp-prod --source-server mycoolapp-prod-mysql --restore-time "2026-02-06T10:30:00Z"
# Creates new server from backup at specified time
```

### Geo-Redundant Backup
- **Default**: Disabled (per cost-001)
- **When to enable**: Disaster recovery across regions
- **Cost Impact**: 2× backup storage cost

---

## VNet Integration

### Prerequisites
1. **Delegated Subnet**: Must delegate subnet to `Microsoft.DBforMySQL/flexibleServers`
2. **Private DNS Zone**: `privatelink.mysql.database.azure.com`
3. **DNS Zone Link**: Link DNS zone to VNet

### Why VNet Integration?
- **Security**: No public endpoint (ac-001 compliance)
- **Performance**: Low latency within VNet
- **Access Control**: Only VMs/apps in VNet can connect

### Subnet Delegation Example

```bicep
subnets: [
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
```

**Important**: Delegated subnet cannot be used for VMs or other resources.

---

## SSL/TLS Connections

### Enforcement
- **Required**: SSL/TLS enabled by default (cannot disable)
- **Minimum Version**: TLS 1.2 (dp-001 compliance)
- **Certificate**: Azure-provided CA certificate

### Connection Strings

#### PHP (mysqli)
```php
$conn = new mysqli("mycoolapp-dev-mysql.mysql.database.azure.com", "appuser", "password", "mycoolapp", 3306, null, MYSQLI_CLIENT_SSL);
```

#### Python (mysql-connector)
```python
import mysql.connector
conn = mysql.connector.connect(
  host="mycoolapp-dev-mysql.mysql.database.azure.com",
  user="appuser",
  password="password",
  database="mycoolapp",
  ssl_disabled=False
)
```

#### MySQL CLI
```bash
mysql -h mycoolapp-dev-mysql.mysql.database.azure.com -u appuser -p --ssl-mode=REQUIRED
```

---

## Performance Tuning

### Server Parameters

| Parameter | Default | Recommended (Dev) | Recommended (Prod) | Description |
|-----------|---------|-------------------|-------------------|-------------|
| `max_connections` | 151 | 50 | 200 | Max concurrent connections |
| `innodb_buffer_pool_size` | 50-75% RAM | Auto | Auto | InnoDB cache size |
| `slow_query_log` | OFF | OFF | ON | Log slow queries (>2s) |
| `long_query_time` | 10 | N/A | 2 | Slow query threshold (seconds) |

### Set Parameter

```powershell
az mysql flexible-server parameter set --name max_connections --value 200 --resource-name mycoolapp-prod-mysql --resource-group rg-mycoolapp-prod
```

### Monitor Performance

```powershell
# Query statistics
az mysql flexible-server show-connection-string --server-name mycoolapp-prod-mysql
# Use Azure Monitor for CPU, memory, IOPS metrics
```

---

## Cost Considerations

### Development Environment
- **Server**: Burstable_B1ms (~$15/month)
- **Storage**: 20 GB (~$2/month)
- **Backup**: 7 days (included)
- **Total**: ~$17/month

### Production Environment
- **Server**: GeneralPurpose_D2ds_v4 (~$75/month)
- **High Availability**: +100% (~$75/month standby)
- **Storage**: 100 GB (~$10/month)
- **Backup**: 30 days (included up to 100 GB)
- **Total**: ~$160/month

**Cost Optimization**:
- **Use Burstable for dev**: 80% cheaper than GeneralPurpose
- **Disable HA for dev**: 50% cost reduction
- **Right-size storage**: Start with 20-50 GB, enable auto-grow
- **Reserved Instances**: Save 40-60% (1-year or 3-year commitment)

---

## Deployment Validation

### Validate Bicep

```powershell
bicep build main.bicep
```

### Deploy to Dev

```powershell
az deployment group create `
  --resource-group rg-mycoolapp-dev `
  --template-file main.bicep `
  --parameters parameters.json
```

### Verify Server Running

```powershell
az mysql flexible-server show --name mycoolapp-dev-mysql --resource-group rg-mycoolapp-dev --query "state"
# Output: "Ready"
```

### Test Connection

```bash
mysql -h mycoolapp-dev-mysql.mysql.database.azure.com -u mysqladmin -p --ssl-mode=REQUIRED
# Enter password, should connect successfully
```

---

## Troubleshooting

### Issue: "Cannot connect to MySQL server"
**Cause**: VM not in VNet or subnet not allowed  
**Solution**: Ensure VM is in same VNet as MySQL delegated subnet, check NSG rules

### Issue: "SSL connection error"
**Cause**: Client not using SSL/TLS  
**Solution**: Add `--ssl-mode=REQUIRED` to mysql CLI or `MYSQLI_CLIENT_SSL` in PHP

### Issue: "Too many connections"
**Cause**: `max_connections` limit reached  
**Solution**: Increase `max_connections` parameter or upgrade SKU

```powershell
az mysql flexible-server parameter set --name max_connections --value 200 --resource-name mycoolapp-prod-mysql --resource-group rg-mycoolapp-prod
```

### Issue: "Storage full"
**Cause**: Database size exceeds storage allocation  
**Solution**: Enable `storageAutogrow` or manually increase storage size

```powershell
az mysql flexible-server update --name mycoolapp-prod-mysql --resource-group rg-mycoolapp-prod --storage-size 200
```

---

## Related Modules

- **avm-wrapper-vnet**: Create VNet with delegated subnet for MySQL
- **avm-wrapper-linux-vm**: Connect VM to MySQL server
- **avm-wrapper-key-vault**: Store MySQL admin password in Key Vault

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-02-07 | Initial release wrapping AVM MySQL module v0.4.2 |

---

## Upstream Specs

- **infrastructure/iac-modules** (iac-001): Wrapper module specification
- **business/cost** (cost-001): Cost optimization (Burstable dev, GeneralPurpose prod)
- **security/data-protection** (dp-001): SSL/TLS required, 30-day backup retention
- **security/access-control** (ac-001): VNet integration only, no public access
- **business/compliance-framework** (comp-001): US regions and tagging
- **platform/iac-linting** (lint-001): Code quality standards

---

**Module Owner**: Infrastructure Engineering Team  
**Support**: platform-team@company.com  
**License**: Internal use only
