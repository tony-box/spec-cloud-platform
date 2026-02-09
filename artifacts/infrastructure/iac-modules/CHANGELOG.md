# Changelog - IaC Wrapper Modules

**Purpose**: Version tracking for all 8 wrapper modules and upstream AVM dependencies  
**Format**: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)  
**Versioning**: [Semantic Versioning](https://semver.org/spec/v2.0.0.html)  

---

## Overview

This changelog tracks version history for all wrapper modules and their underlying Azure Verified Module (AVM) dependencies. Each wrapper module follows semantic versioning:

- **MAJOR** version: Breaking changes to parameter interface or outputs
- **MINOR** version: New features, non-breaking parameter additions
- **PATCH** version: Bug fixes, documentation updates, AVM version updates (non-breaking)

---

## Current Module Versions

| Wrapper Module | Version | AVM Module | AVM Version | Status |
|----------------|---------|------------|-------------|--------|
| **avm-wrapper-vnet** | 1.0.0 | avm/res/network/virtual-network | 0.7.2 | Published |
| **avm-wrapper-nsg** | 1.0.0 | avm/res/network/network-security-group | 0.5.2 | Published |
| **avm-wrapper-public-ip** | 1.0.0 | avm/res/network/public-ip-address | 0.12.0 | Published |
| **avm-wrapper-linux-vm** | 1.0.0 | avm/res/compute/virtual-machine | 0.21.0 | Published |
| **avm-wrapper-managed-disk** | 1.0.0 | avm/res/compute/disk | 0.6.0 | Published |
| **avm-wrapper-key-vault** | 1.0.0 | avm/res/key-vault/vault | 0.13.3 | Published |
| **avm-wrapper-storage-account** | 1.0.0 | avm/res/storage/storage-account | 0.31.0 | Published |
| **avm-wrapper-mysql-flexibleserver** | 1.0.0 | avm/res/db-for-my-sql/flexible-server | 0.10.1 | Published |

**Last Updated**: 2026-02-08

---

## Unreleased

### Changed
- Updated AVM module references to latest stable versions (Phase 7 alignment)

---

## [1.0.0] - 2026-02-07

### Added - All 8 Wrapper Modules

#### avm-wrapper-vnet (1.0.0)
- Initial release
- **Features**: VNet with configurable subnets, DDoS Protection optional, subnet delegation support
- **Parameters**: vnetName, environment, location, addressPrefix, subnets[], additionalTags
- **Compliance**: US regions only, NIST 800-171 tagging
- **AVM Version**: avm/res/network/virtual-network:0.5.1
- **Files**: main.bicep (150 lines), README.md (400+ lines), parameters.json

#### avm-wrapper-nsg (1.0.0)
- Initial release
- **Features**: NSG with HTTP/HTTPS allowed by default, SSH source-controlled, custom rule support
- **Parameters**: nsgName, environment, location, sshSourceAddressPrefix, customRules[], additionalTags
- **Defaults**: Allow HTTP/HTTPS (ports 80, 443), deny SSH from internet (priority 100)
- **Compliance**: US regions only, NIST 800-171 tagging
- **AVM Version**: avm/res/network/network-security-group:0.3.2
- **Files**: main.bicep (135 lines), README.md (350+ lines), parameters.json

#### avm-wrapper-public-ip (1.0.0)
- Initial release
- **Features**: Static Public IP (Standard SKU), zone-redundant for prod, DNS label support
- **Parameters**: publicIpName, environment, location, dnsLabel, zones[], additionalTags
- **Defaults**: Standard SKU, static allocation, zones [1,2,3] for prod
- **Compliance**: US regions only, NIST 800-171 tagging, DDoS Protection Basic included
- **AVM Version**: avm/res/network/public-ip-address:0.4.0
- **Files**: main.bicep (140 lines), README.md (350+ lines), parameters.json
- **Cost**: $3.65/month (dev and prod)

#### avm-wrapper-linux-vm (1.0.0)
- Initial release
- **Features**: Ubuntu 22.04 LTS, SSH keys only, managed identity, cloud-init support, Azure Disk Encryption
- **Parameters**: vmName, environment, sshPublicKey (required), subnetId (required), location, vmSize, adminUsername, publicIpId, nsgId, enableAcceleratedNetworking, osDiskSizeGB, osDiskType, enableDiskEncryption, customData
- **Defaults**: Standard_B2s (dev), Standard_B4ms (prod), 64 GB StandardSSD_LRS disk, azureuser admin, encryption enabled prod
- **Authentication**: SSH keys only (disablePasswordAuthentication: true)
- **Compliance**: US regions only, B-series SKUs (@allowed), NIST 800-171 tagging
- **AVM Version**: avm/res/compute/virtual-machine:0.7.3
- **Files**: main.bicep (200 lines), README.md (600+ lines with LAMP cloud-init example), parameters.json
- **Cost**: $35/month dev (B2s), $140/month prod (B4ms)

#### avm-wrapper-managed-disk (1.0.0)
- Initial release
- **Features**: Additional data storage disk, StandardSSD/Premium/ZRS support, encryption, snapshot copy
- **Parameters**: diskName, environment, location, diskSizeGB (4-32767), diskSku, createOption, sourceResourceId, enableEncryption, zone, additionalTags
- **Defaults**: 128 GB, StandardSSD_LRS (dev), Premium_LRS (prod)
- **Security**: publicNetworkAccess: Disabled, networkAccessPolicy: DenyAll
- **Compliance**: US regions only, Standard/Premium SKUs (@allowed), NIST 800-171 tagging
- **AVM Version**: avm/res/compute/disk:0.3.1
- **Files**: main.bicep (145 lines), README.md (450+ lines), parameters.json
- **Cost**: $10/month dev (128 GB StandardSSD_LRS), $82/month prod (512 GB Premium_LRS)

#### avm-wrapper-key-vault (1.0.0)
- Initial release
- **Features**: Secure secrets/keys/certificates, Standard/Premium SKU, RBAC authorization, soft delete, purge protection
- **Parameters**: keyVaultName (3-24 chars), environment, location, sku, enableSoftDelete, softDeleteRetentionDays (7-90), enablePurgeProtection, enableRbacAuthorization, publicNetworkAccess, subnetIds[], additionalTags
- **Defaults**: Standard (dev), Premium (prod), enableRbacAuthorization: true, accessPolicies: [] (no legacy), soft delete 7 days (dev) 90 days (prod), purge protection enabled prod
- **Compliance**: US regions only, Standard/Premium SKUs (@allowed), NIST 800-171 tagging
- **AVM Version**: avm/res/key-vault/vault:0.9.0
- **Files**: main.bicep (140 lines), README.md (500+ lines with RBAC roles), parameters.json
- **Cost**: <$1/month dev, $5-10/month prod

#### avm-wrapper-storage-account (1.0.0)
- Initial release
- **Features**: Blob storage, Hot/Cool tier, TLS 1.2+, blob soft delete, VNet integration, double encryption
- **Parameters**: storageAccountName (3-24 chars), environment, location, sku, kind, accessTier, minimumTlsVersion, enableBlobSoftDelete, blobSoftDeleteRetentionDays (1-365), supportsHttpsTrafficOnly, publicNetworkAccess, networkAclsBypass, networkAclsDefaultAction, subnetIds[], additionalTags
- **Defaults**: Standard_LRS (dev), Standard_ZRS (prod), StorageV2, Hot tier, TLS1_2, soft delete 30 days prod
- **Security**: allowBlobPublicAccess: false, supportsHttpsTrafficOnly: true, requireInfrastructureEncryption: true (prod)
- **Compliance**: US regions only, Standard_LRS/ZRS SKUs (@allowed), NIST 800-171 tagging
- **AVM Version**: avm/res/storage/storage-account:0.14.3
- **Files**: main.bicep (150 lines), README.md (550+ lines), parameters.json
- **Cost**: $3/month dev (100 GB Hot LRS), $30-35/month prod (1 TB Hot ZRS)

#### avm-wrapper-mysql-flexibleserver (1.0.0)
- Initial release
- **Features**: Azure Database for MySQL Flexible Server, VNet integration, zone-redundant HA, SSL required, backup/restore
- **Parameters**: serverName, environment, location, sku, mysqlVersion, administratorLogin, administratorPassword (secure required), delegatedSubnetId (required), privateDnsZoneId (required), storageSizeGB (20-16384), storageIops, storageAutogrow, backupRetentionDays (1-35), geoRedundantBackup, highAvailability, standbyAvailabilityZone, additionalTags
- **Defaults**: Burstable_B1ms (dev), GeneralPurpose_D2ds_v4 (prod), MySQL 8.0.21, 20 GB storage (dev) 100 GB (prod), backup 7 days (dev) 30 days (prod), HA zone-redundant enabled prod (standby zone 2)
- **Network**: VNet integration only (no public access), delegatedSubnetResourceId + privateDnsZoneResourceId required
- **SSL**: require_secure_transport: ON (enforced)
- **Compliance**: US regions only, Burstable/GeneralPurpose SKUs (@allowed), NIST 800-171 tagging
- **AVM Version**: avm/res/db-for-my-sql/flexible-server:0.4.2
- **Files**: main.bicep (160 lines), README.md (700+ lines with SSL connection strings), parameters.json
- **Cost**: $17/month dev (Burstable_B1ms, 20 GB, no HA), $160/month prod (GeneralPurpose_D2ds_v4, 100 GB, HA)

### Added - Documentation

- **MODULE_CATALOG.md** (580+ lines): Comprehensive catalog with:
  - Quick reference table for all 8 modules with costs
  - Detailed module sections (8 × properties tables, key features, use cases, examples)
  - Module dependencies diagram
  - LAMP stack deployment order
  - Compliance matrix summary
  - Usage guidelines (application teams + infrastructure team)
  - Cost summary (dev $55-65/month, prod $320-410/month)

- **GETTING_STARTED.md** (580+ lines): Quickstart guide with:
  - 15-minute dev LAMP stack deployment walkthrough
  - Prerequisites (Bicep CLI, SSH keys, Azure login)
  - Complete deployment template (deploy-lamp-dev.bicep with all 8 modules)
  - Parameters file example
  - Verification steps (test Apache, PHP, MySQL, Storage)
  - Dev vs prod deployment differences
  - Troubleshooting guide
  - Best practices (Key Vault secrets, managed identity, cost optimization)

- **COMPLIANCE_MATRIX.md** (670+ lines): Detailed compliance traceability with:
  - All 5 spec requirements (cost-001, dp-001, ac-001, comp-001, lint-001)
  - Compliance matrix for all 8 modules (8 × 5 specs = 40 compliance cells)
  - Enforcement mechanism types (parameter constraints, fixed config, conditionals, defaults)
  - Pre-deployment validation (bicep build, what-if)
  - Post-deployment validation (Azure CLI compliance checks)
  - Sample audit report
  - Non-compliance remediation procedures

- **avm-versions.md**: AVM upstream version tracking
- **MODULE_VALIDATION_CHECKLIST.md**: Module quality checklist
- **spec-alignment-validation.md**: Spec alignment validation

### Changed
- specs/infrastructure/_categories.yaml: Added iac-modules category (category-count: 5 → 6), status: published
- specs/specs.yaml: Updated infrastructure categories count (5 → 6), iac-001 version (1.0.0-draft → 1.0.0)

---

## Version Guidelines

### When to Bump Versions

#### PATCH (x.y.Z+1)
- Bug fixes in module code
- Documentation improvements in README.md or parameters.json
- **AVM version updates (non-breaking)**: e.g., avm/res/compute/virtual-machine:0.7.3 → 0.7.4
- Typo corrections
- Examples updated
- No impact on existing deployments

**Example**: avm-wrapper-linux-vm 1.0.0 → 1.0.1 (updated AVM from 0.7.3 to 0.7.4, no parameter changes)

#### MINOR (x.Y+1.0)
- New optional parameters added (backward compatible)
- New features that don't break existing deployments
- **AVM minor version updates that add new features**: e.g., avm/res/compute/virtual-machine:0.7.3 → 0.8.0
- New output added
- Default values changed (non-breaking)

**Example**: avm-wrapper-linux-vm 1.0.0 → 1.1.0 (added optional `enableBootDiagnostics` parameter)

#### MAJOR (X+1.0.0)
- Breaking changes to parameter interface (renamed, removed, or changed type)
- Breaking changes to outputs
- **AVM major version updates with breaking changes**: e.g., avm/res/compute/virtual-machine:0.7.3 → 1.0.0
- Required parameter added
- Removed functionality
- **Important**: Requires migration guide

**Example**: avm-wrapper-linux-vm 1.0.0 → 2.0.0 (changed `vmSize` parameter to `vmSku`, breaking change)

### AVM Dependency Updates

**Process**:
1. Monitor AVM releases: https://github.com/Azure/bicep-registry-modules/releases
2. Test AVM update in dev environment
3. If breaking changes: MAJOR version bump + migration guide
4. If new features: MINOR version bump + README update
5. If bug fixes only: PATCH version bump
6. Update all module references and documentation

**AVM Update Cadence**: Quarterly review (January, April, July, October)

---

## Upstream AVM Version Tracking

**Links**:
- **AVM Registry**: https://github.com/Azure/bicep-registry-modules/tree/main/avm/res
- **VNet (network/virtual-network)**: https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/network/virtual-network
- **NSG (network/network-security-group)**: https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/network/network-security-group
- **Public IP (network/public-ip-address)**: https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/network/public-ip-address
- **VM (compute/virtual-machine)**: https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/compute/virtual-machine
- **Disk (compute/disk)**: https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/compute/disk
- **Key Vault (key-vault/vault)**: https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/key-vault/vault
- **Storage Account (storage/storage-account)**: https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/storage/storage-account
- **MySQL Flexible Server (db-for-my-sql/flexible-server)**: https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/db-for-my-sql/flexible-server

---

## Migration Guides

### None (Initial Release)

When a MAJOR version is released with breaking changes, a migration guide will be added here with instructions for upgrading from previous versions.

**Example format**:
```
## avm-wrapper-linux-vm 1.x → 2.0.0

**Breaking Changes**:
- Parameter `vmSize` renamed to `vmSku`
- Output `nicId` renamed to `networkInterfaceId`

**Migration Steps**:
1. Update parameter `vmSize` to `vmSku` in all parameter files
2. Update output references from `nicId` to `networkInterfaceId` in dependent modules
3. Test deployment in dev environment before prod
```

---

## Rollback Procedures

### Rollback to Previous Module Version

If a module update causes issues, roll back to the previous version:

**Option 1: Pin AVM Version in Wrapper Module**
```bicep
// In main.bicep, change:
module avmModule 'br/public:avm/res/compute/virtual-machine:0.8.0' = {
// Back to:
module avmModule 'br/public:avm/res/compute/virtual-machine:0.7.3' = {
```

**Option 2: Use Previous Wrapper Module Commit**
```bash
# Check git history
git log --oneline -- avm-wrapper-linux-vm/main.bicep

# Restore previous version
git checkout <commit-hash> -- avm-wrapper-linux-vm/
```

---

## Testing Process for Updates

Before releasing any module version:

1. **Build Validation**: `bicep build main.bicep` passes
2. **Dev Deployment**: Deploy to dev environment, verify resources created
3. **Compliance Check**: Run compliance validation (see COMPLIANCE_MATRIX.md)
4. **Integration Test**: Deploy full LAMP stack (all 8 modules together)
5. **Regression Test**: Verify existing deployments still work
6. **Documentation**: Update README.md examples, parameters.json
7. **Changelog**: Add entry to this changelog
8. **Version Bump**: Update version in module metadata (if applicable)
9. **Tag Release**: `git tag -a avm-wrapper-linux-vm-v1.1.0 -m "Release 1.1.0"`

---

## Planned Updates

**Q2 2026**:
- Add `avm-wrapper-app-service` for web app hosting
- Add `avm-wrapper-cosmos-db` for NoSQL database
- Quarterly AVM version review (April 2026)

**Q3 2026**:
- Add `avm-wrapper-postgresql-flexibleserver` for PostgreSQL
- Quarterly AVM version review (July 2026)

**Q4 2026**:
- Quarterly AVM version review (October 2026)
- Annual module audit and compliance review

---

**Maintained By**: Infrastructure Engineering Team  
**Review Frequency**: Quarterly  
**Last Review**: 2026-02-07  

---

**Version**: 1.0.0  
**Last Updated**: 2026-02-07
