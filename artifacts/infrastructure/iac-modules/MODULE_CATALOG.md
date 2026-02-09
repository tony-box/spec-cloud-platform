# IaC Module Catalog

**Purpose**: Complete catalog of Azure Verified Module (AVM) wrapper modules for LAMP stack infrastructure  
**Version**: 2.1.0  
**Last Updated**: 2026-02-09  
**Owner**: Infrastructure Engineering Team

---

## Overview

This catalog contains 8 wrapper modules organized into 3 categories: **Networking**, **Compute & Storage**, and **Database**. All modules wrap official Azure Verified Modules (AVM) from the Bicep public registry, enforce platform compliance standards, and provide simplified, cost-optimized interfaces for application teams.

**Module Count**: 8 total  
**AVM Registry**: https://github.com/Azure/bicep-registry-modules/tree/main/avm/res  
**Module Location**: `/artifacts/infrastructure/iac-modules/`  
**Compliance Specs**: cost-001, dp-001, ac-001, comp-001, lint-001  

---

## Quick Reference

| # | Module Name | Category | Purpose | Cost (Dev) | Cost (Prod) |
|---|-------------|----------|---------|------------|-------------|
| 1 | [avm-wrapper-vnet](#1-avm-wrapper-vnet) | Networking | Virtual Network | $0 | $0-2944* |
| 2 | [avm-wrapper-nsg](#2-avm-wrapper-nsg) | Networking | Network Security Group | $0 | $0 |
| 3 | [avm-wrapper-public-ip](#3-avm-wrapper-public-ip) | Networking | Public IP Address | $3.65/mo | $3.65/mo |
| 4 | [avm-wrapper-linux-vm](#4-avm-wrapper-linux-vm) | Compute | Linux VM (Regular or Spot*) | $10-35/mo | $140/mo |
| 5 | [avm-wrapper-managed-disk](#5-avm-wrapper-managed-disk) | Storage | Managed Disk | $10/mo | $82/mo (512GB) |
| 6 | [avm-wrapper-key-vault](#6-avm-wrapper-key-vault) | Security | Key Vault | <$1/mo | $5-10/mo |
| 7 | [avm-wrapper-storage-account](#7-avm-wrapper-storage-account) | Storage | Storage Account | $3/mo | $30-35/mo |
| 8 | [avm-wrapper-mysql-flexibleserver](#8-avm-wrapper-mysql-flexibleserver) | Database | Azure MySQL Flexible Server | $17/mo | $160/mo |
| | **TOTAL LAMP Stack** | | | **~$70/mo** | **~$420-680/mo** |

_*DDoS Protection Standard for production VNets adds ~$2944/month if enabled_  
_*Spot VM (dev/test only) saves up to 84-87% on compute costs; requires D-series SKU_

---

## Networking Modules

### 1. avm-wrapper-vnet

**Azure Virtual Network Wrapper**

| Property | Value |
|----------|-------|
| **Purpose** | Isolated network for VMs, databases, and services |
| **AVM Module** | `br/public:avm/res/network/virtual-network:0.5.1` |
| **README** | [avm-wrapper-vnet/README.md](./avm-wrapper-vnet/README.md) |
| **Parameters** | [parameters.json](./avm-wrapper-vnet/parameters.json) |
| **Compliance** | US regions, /16 CIDR default, NSG association support, NIST tagging |
| **Cost (Dev)** | $0/month (VNet itself is free) |
| **Cost (Prod)** | $0/month (or ~$2944/month if DDoS Protection Standard enabled) |

**Key Features**:
- Default address space: 10.0.0.0/16 (65,536 IPs)
- Subnet support with NSG association
- DDoS Protection Standard for production (optional)
- Zone redundancy (multi-zone deployment)

**Common Use Cases**:
- LAMP stack VNet with app, db, and bastion subnets
- Multi-tier application isolation
- VPN/ExpressRoute gateway integration

**Example**:
```bicep
module vnet './avm-wrapper-vnet/main.bicep' = {
  params: {
    vnetName: 'mycoolapp-dev-vnet'
    environment: 'dev'
    addressPrefix: '10.0.0.0/16'
    subnets: [
      { name: 'app-subnet', addressPrefix: '10.0.1.0/24' }
      { name: 'db-subnet', addressPrefix: '10.0.2.0/24' }
    ]
  }
}
```

---

### 2. avm-wrapper-nsg

**Network Security Group Wrapper**

| Property | Value |
|----------|-------|
| **Purpose** | Control inbound/outbound network traffic to resources |
| **AVM Module** | `br/public:avm/res/network/network-security-group:0.3.2` |
| **README** | [avm-wrapper-nsg/README.md](./avm-wrapper-nsg/README.md) |
| **Parameters** | [parameters.json](./avm-wrapper-nsg/parameters.json) |
| **Compliance** | SSH denied by default, HTTP/HTTPS allowed, default deny all inbound |
| **Cost (Dev)** | $0/month (NSG is free) |
| **Cost (Prod)** | $0/month |

**Key Features**:
- Baseline rules: AllowSSH (restricted/denied), AllowHTTP, AllowHTTPS, DenyAllInbound
- Custom application rules (priority 2000-3999)
- SSH access restricted (default deny, can enable from specific IPs)

**Common Use Cases**:
- Restrict VM access to SSH from corporate VPN only
- Allow HTTP/HTTPS traffic for web servers
- Custom database port rules (MySQL 3306, PostgreSQL 5432)

**Example**:
```bicep
module nsg './avm-wrapper-nsg/main.bicep' = {
  params: {
    nsgName: 'mycoolapp-dev-nsg'
    environment: 'dev'
    sshSourceAddressPrefix: '' // Deny SSH entirely
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
        destinationAddressPrefix: '10.0.2.0/24' // DB subnet
      }
    ]
  }
}
```

---

### 3. avm-wrapper-public-ip

**Public IP Address Wrapper**

| Property | Value |
|----------|-------|
| **Purpose** | Static public IP for internet-facing resources |
| **AVM Module** | `br/public:avm/res/network/public-ip-address:0.4.0` |
| **README** | [avm-wrapper-public-ip/README.md](./avm-wrapper-public-ip/README.md) |
| **Parameters** | [parameters.json](./avm-wrapper-public-ip/parameters.json) |
| **Compliance** | Standard SKU (zone-redundant), static allocation, DDoS Basic included |
| **Cost (Dev)** | ~$3.65/month |
| **Cost (Prod)** | ~$3.65/month (same, zone redundancy included) |

**Key Features**:
- Standard SKU (zone-redundant, DDoS Protection Basic included)
- Static allocation (no dynamic IPs)
- Optional DNS label (`mycoolapp-prod.centralus.cloudapp.azure.com`)
- Zone redundancy for production (zones 1, 2, 3)

**Common Use Cases**:
- Assign public IP to VM for internet access
- Load balancer frontend IP
- Application Gateway public endpoint

**Example**:
```bicep
module publicIp './avm-wrapper-public-ip/main.bicep' = {
  params: {
    publicIpName: 'mycoolapp-dev-pip'
    environment: 'dev'
    dnsLabel: 'mycoolapp-dev' // Creates mycoolapp-dev.centralus.cloudapp.azure.com
  }
}
```

---

## Compute & Storage Modules

### 4. avm-wrapper-linux-vm

**Linux Virtual Machine Wrapper** (v2.1.0 - Now with Spot Instance Support!)

| Property | Value |
|----------|-------|
| **Purpose** | Cost-optimized Ubuntu 22.04 LTS VM for LAMP stack (Regular or Spot) |
| **AVM Module** | `br/public:avm/res/compute/virtual-machine:0.21.0` |
| **README** | [avm-wrapper-linux-vm/README.md](./avm-wrapper-linux-vm/README.md) |
| **Parameters** | [parameters.json](./avm-wrapper-linux-vm/parameters.json) · [Spot Example](./avm-wrapper-linux-vm/parameters-spot-example.json) |
| **Compliance** | SKU restricted to Standard_B2s/B4ms (D-series for Spot), SSH keys only, disk encryption prod |
| **Cost (Dev)** | ~$35/mo Regular OR ~$10-15/mo Spot |
| **Cost (Prod)** | ~$140/mo Regular + RI discounts OR N/A Spot (use Regular) |

**Key Features** (v2.1.0):
- ✅ **NEW: Spot instance support** (up to 90% cost savings for dev/test!)
- Ubuntu 22.04 LTS (5-year support)
- SSH key authentication only (no passwords)
- Azure Disk Encryption for production
- System-assigned managed identity (Azure RBAC)
- Cloud-init support for LAMP stack provisioning
- Accelerated networking (Standard_B4ms+)
- Reserved Instance eligible for production workloads

**New Instance Type Parameters (v2.1.0)**:
```bicep
vmPriority: 'Regular' | 'Spot'          // Choose instance type
spotEvictionPolicy: 'Deallocate' | 'Delete'  // Eviction behavior (Spot only)
spotMaxPrice: '-1'                      // Max hourly price $ (Spot only)
```

**Common Use Cases**:
- Regular: Production LAMP stack, critical applications, Reserved Instance eligible
- Spot: Dev/test environments, CI/CD agents, batch jobs, ephemeral workloads

**Cost Optimization Strategy**:
- **Production**: Regular + 3-year RI purchase (37-50% savings)
- **Dev/Test**: Spot on D-series (84-87% savings)

**Example (Regular)**:
```bicep
module vm './avm-wrapper-linux-vm/main.bicep' = {
  params: {
    vmName: 'mycoolapp-prod-vm'
    environment: 'prod'
    vmSize: 'Standard_B4ms'
    // vmPriority defaults to 'Regular' - no additional params needed
    sshPublicKey: loadTextContent('~/.ssh/id_rsa.pub')
    subnetId: vnet.outputs.subnetIds[0]
  }
}
```

**Example (Spot)**: See [parameters-spot-example.json](./avm-wrapper-linux-vm/parameters-spot-example.json)

**⚠️ DEPRECATION**: `reserved-instance-vm.bicep` has been retired. See [Migration Guide](./reserved-instance-vm-migration.md)

---
```bicep
module vm './avm-wrapper-linux-vm/main.bicep' = {
  params: {
    vmName: 'mycoolapp-dev-vm'
    environment: 'dev'
    sshPublicKey: loadTextContent('~/.ssh/id_rsa.pub')
    subnetId: vnet.outputs.subnetIds[0]
    customData: loadTextContent('./lamp-cloud-init.yaml') // LAMP install script
  }
}
```

---

### 5. avm-wrapper-managed-disk

**Managed Disk Wrapper**

| Property | Value |
|----------|-------|
| **Purpose** | Additional data storage for VMs (databases, logs, uploads) |
| **AVM Module** | `br/public:avm/res/compute/disk:0.3.1` |
| **README** | [avm-wrapper-managed-disk/README.md](./avm-wrapper-managed-disk/README.md) |
| **Parameters** | [parameters.json](./avm-wrapper-managed-disk/parameters.json) |
| **Compliance** | StandardSSD/Premium only, LRS dev/ZRS prod, encryption enabled, no public access |
| **Cost (Dev)** | ~$10/month (StandardSSD_LRS 128 GB) |
| **Cost (Prod)** | ~$20/month (Premium_LRS 128 GB) or ~$82/month (Premium_LRS 512 GB) |

**Key Features**:
- StandardSSD_LRS (dev), Premium_LRS (prod)
- Zone-redundant storage (ZRS) for HA
- Encryption at rest (platform-managed keys)
- Snapshot and restore support
- Public network access disabled

**Common Use Cases**:
- Attach additional storage to VM for MySQL data directory
- Separate disk for application logs (/var/log)
- Archive storage for backups

**Example**:
```bicep
module dataDisk './avm-wrapper-managed-disk/main.bicep' = {
  params: {
    diskName: 'mycoolapp-dev-data-disk'
    environment: 'dev'
    diskSizeGB: 128
  }
}
```

---

### 6. avm-wrapper-key-vault

**Key Vault Wrapper**

| Property | Value |
|----------|-------|
| **Purpose** | Secure storage for secrets, keys, and certificates |
| **AVM Module** | `br/public:avm/res/key-vault/vault:0.9.0` |
| **README** | [avm-wrapper-key-vault/README.md](./avm-wrapper-key-vault/README.md) |
| **Parameters** | [parameters.json](./avm-wrapper-key-vault/parameters.json) |
| **Compliance** | Standard dev/Premium prod, RBAC authorization, 90-day soft delete, purge protection prod |
| **Cost (Dev)** | <$1/month (Standard SKU, secrets only) |
| **Cost (Prod)** | ~$5-10/month (Premium SKU, HSM-protected keys) |

**Key Features**:
- Standard SKU (dev), Premium HSM-backed (prod)
- Azure RBAC authorization (no legacy access policies)
- Soft delete with 90-day retention (production)
- Purge protection (prevents accidental permanent deletion)
- Private endpoints for production (no public access)

**Common Use Cases**:
- Store MySQL admin password
- Store application secrets (API keys, connection strings)
- HSM-protected encryption keys for databases

**Example**:
```bicep
module keyVault './avm-wrapper-key-vault/main.bicep' = {
  params: {
    keyVaultName: 'mycoolapp-dev-kv'
    environment: 'dev'
  }
}

// Grant VM access
resource secretsUserRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  properties: {
    roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User
    principalId: vm.outputs.identityPrincipalId
  }
}
```

---

### 7. avm-wrapper-storage-account

**Storage Account Wrapper**

| Property | Value |
|----------|-------|
| **Purpose** | Blob storage for user uploads, backups, and static websites |
| **AVM Module** | `br/public:avm/res/storage/storage-account:0.14.3` |
| **README** | [avm-wrapper-storage-account/README.md](./avm-wrapper-storage-account/README.md) |
| **Parameters** | [parameters.json](./avm-wrapper-storage-account/parameters.json) |
| **Compliance** | Standard_LRS dev/ZRS prod, TLS 1.2+, blob soft delete 30-day prod, no public blob access |
| **Cost (Dev)** | ~$3/month (Standard_LRS 100 GB, Hot tier) |
| **Cost (Prod)** | ~$30-35/month (Standard_ZRS 1 TB, Hot tier, 30-day soft delete) |

**Key Features**:
- Standard_LRS (dev), Standard_ZRS (prod)
- Hot tier (frequently accessed data), Cool tier (archives)
- TLS 1.2 minimum
- Blob soft delete with 30-day retention (production)
- HTTPS-only traffic, no anonymous blob access
- VNet integration for production

**Common Use Cases**:
- User-uploaded photos and documents
- Database backups (mysqldump)
- Static website hosting ($web container)
- Application logs

**Example**:
```bicep
module storage './avm-wrapper-storage-account/main.bicep' = {
  params: {
    storageAccountName: 'mycoolappdevstorage'
    environment: 'dev'
  }
}

// Create blob container
resource uploadsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storage.outputs.storageAccountName}/default/uploads'
  properties: {
    publicAccess: 'None'
  }
}
```

---

## Database Module

### 8. avm-wrapper-mysql-flexibleserver

**Azure Database for MySQL Flexible Server Wrapper**

| Property | Value |
|----------|-------|
| **Purpose** | Managed MySQL 8.0 database for LAMP stack (PaaS) |
| **AVM Module** | `br/public:avm/res/db-for-my-sql/flexible-server:0.4.2` |
| **README** | [avm-wrapper-mysql-flexibleserver/README.md](./avm-wrapper-mysql-flexibleserver/README.md) |
| **Parameters** | [parameters.json](./avm-wrapper-mysql-flexibleserver/parameters.json) |
| **Compliance** | Burstable dev/GeneralPurpose prod, VNet-only, SSL required, 30-day backup prod, zone-redundant HA prod |
| **Cost (Dev)** | ~$17/month (Burstable_B1ms, 1 vCPU, 2 GB RAM, 20 GB storage, 7-day backup) |
| **Cost (Prod)** | ~$160/month (GeneralPurpose_D2ds_v4, 2 vCPU, 8 GB RAM, 100 GB storage, zone-redundant HA, 30-day backup) |

**Key Features**:
- MySQL 8.0 LTS (long-term support)
- Burstable_B1ms (dev), GeneralPurpose_D2ds_v4 (prod)
- Zone-redundant HA for production (99.99% SLA)
- VNet integration only (no public access)
- SSL/TLS required for connections
- 30-day backup retention for production
- Storage auto-grow
- Point-in-time restore

**Common Use Cases**:
- LAMP stack database (WordPress, Drupal, custom PHP apps)
- Application backend database
- High-availability production MySQL with automatic failover

**Example**:
```bicep
module mysql './avm-wrapper-mysql-flexibleserver/main.bicep' = {
  params: {
    serverName: 'mycoolapp-dev-mysql'
    environment: 'dev'
    administratorPassword: keyVault.getSecret('mysql-admin-password')
    delegatedSubnetId: vnet.outputs.subnetIds[2] // mysql-subnet
    privateDnsZoneId: privateDnsZone.id
  }
}

// Connection string:
// Server=mycoolapp-dev-mysql.mysql.database.azure.com;Port=3306;Database=mycoolapp;Uid=appuser;Pwd=password;SslMode=Required;
```

---

## Module Dependencies

### Dependency Graph

```
VNet (Module 1)
├─→ NSG (Module 2) [Optional but recommended]
├─→ Public IP (Module 3) [Optional for internet-facing VMs]
├─→ Linux VM (Module 4) [Requires subnet, optionally publicIp + NSG]
│   ├─→ Managed Disk (Module 5) [Optional data disk]
│   ├─→ Key Vault (Module 6) [Access via managed identity]
│   └─→ Storage Account (Module 7) [Access via managed identity]
└─→ MySQL Flexible Server (Module 8) [Requires delegated subnet, private DNS zone]
```

### Typical LAMP Stack Deployment Order

1. **VNet** (Module 1): Create network with app-subnet, db-subnet, mysql-subnet
2. **NSG** (Module 2): Create security group for app-subnet
3. **Public IP** (Module 3): Create static IP for VM (if needed)
4. **Key Vault** (Module 6): Store MySQL admin password
5. **MySQL** (Module 8): Deploy database to mysql-subnet
6. **Linux VM** (Module 4): Deploy web server to app-subnet with cloud-init LAMP installation
7. **Managed Disk** (Module 5): Attach data disk to VM (if needed)
8. **Storage Account** (Module 7): Create blob storage for user uploads

---

## Compliance Matrix

All modules enforce the following platform compliance standards:

| Spec ID | Requirement | Enforcement Mechanism |
|---------|-------------|----------------------|
| **cost-001** | Cost optimization | @allowed decorators restrict SKUs to B-series VMs, Standard_LRS/ZRS storage, Burstable/GeneralPurpose MySQL |
| **dp-001** | Data protection | Encryption at rest enabled, TLS 1.2+ required, backup retention 7/30 days, soft delete 30 days prod |
| **ac-001** | Access control | SSH keys only, no public blob access, VNet integration for MySQL, RBAC authorization for Key Vault |
| **comp-001** | Compliance framework | @allowed(['centralus', 'eastus']) on all location params, NIST 800-171 tags automatic |
| **lint-001** | Code quality | All modules pass `bicep build` validation, README + parameters.json included |

---

## Usage Guidelines

### For Application Teams

**1. Deploy LAMP Stack**:
```bicep
// 1. VNet
module vnet './avm-wrapper-vnet/main.bicep' = { ... }

// 2. MySQL
module mysql './avm-wrapper-mysql-flexibleserver/main.bicep' = { ... }

// 3. VM with LAMP cloud-init
module vm './avm-wrapper-linux-vm/main.bicep' = { ... }
```

**2. Access Modules**:
- All modules located in `/artifacts/infrastructure/iac-modules/`
- Reference via relative path: `../../../infrastructure/iac-modules/<module-name>/main.bicep`

**3. Get Help**:
- Check module README.md for detailed parameters and examples
- Review parameters.json for dev/prod examples
- Contact: platform-team@company.com

### For Infrastructure Team

**1. Module Maintenance**:
- Monthly AVM version check (see [avm-versions.md](./avm-versions.md))
- Validate modules with [MODULE_VALIDATION_CHECKLIST.md](./MODULE_VALIDATION_CHECKLIST.md)
- Update compliance tracking in [spec-alignment-validation.md](./spec-alignment-validation.md)

**2. Adding New Modules**:
- Follow wrapper pattern: minimal params, compliant defaults, AVM integration
- Include main.bicep, README.md, parameters.json
- Pass `bicep build` validation
- Update this catalog

---

## Cost Summary

### Development Environment (Full LAMP Stack)

| Resource | Cost/Month |
|----------|------------|
| VNet | $0 |
| NSG | $0 |
| Public IP | $3.65 |
| Linux VM (Standard_B2s) | $30 |
| Managed Disk (128 GB StandardSSD_LRS) | $10 (if needed) |
| Key Vault (Standard) | <$1 |
| Storage Account (100 GB Standard_LRS) | $3 |
| MySQL (Burstable_B1ms) | $17 |
| **TOTAL (without data disk)** | **~$55/month** |
| **TOTAL (with data disk)** | **~$65/month** |

### Production Environment (Full LAMP Stack with HA)

| Resource | Cost/Month |
|----------|------------|
| VNet (no DDoS Protection Standard) | $0 |
| NSG | $0 |
| Public IP | $3.65 |
| Linux VM (Standard_B4ms) | $120 |
| Managed Disk (512 GB Premium_LRS) | $82 (if needed) |
| Key Vault (Premium, 3 HSM keys) | $5-10 |
| Storage Account (1 TB Standard_ZRS) | $30-35 |
| MySQL (GeneralPurpose_D2ds_v4, zone-redundant HA) | $160 |
| **TOTAL (without data disk)** | **~$320-330/month** |
| **TOTAL (with data disk)** | **~$400-410/month** |

**Reserved Instance Savings**: 40-60% on VM and MySQL with 1-year or 3-year commitment

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-02-07 | Initial catalog with 8 wrapper modules for LAMP stack |

---

**Catalog Owner**: Infrastructure Engineering Team  
**Support**: platform-team@company.com  
**License**: Internal use only
