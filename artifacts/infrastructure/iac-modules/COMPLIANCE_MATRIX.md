# Compliance Matrix - IaC Wrapper Modules

**Purpose**: Detailed compliance traceability for all 8 wrapper modules against platform specs  
**Status**: Active  
**Version**: 2.1.0  
**Last Updated**: 2026-02-09  

---

## Overview

This matrix documents how each of the 8 IaC wrapper modules enforces compliance with the 5 platform specifications:

1. **cost-001**: Cost Reduction Targets (infrastructure/001-cost-optimized-compute-modules)
2. **dp-001**: Data Protection Requirements (security/001-cost-constrained-policies)
3. **ac-001**: Access Control Requirements (security/001-cost-constrained-policies)
4. **comp-001**: Compliance Requirements (security/001-cost-constrained-policies)
5. **lint-001**: Linting and Quality Requirements (platform/001-application-artifact-organization)

---

## Compliance Specifications Summary

### cost-001: Cost Reduction Targets (v2.0.0)
- **Objective**: Reduce infrastructure costs by 40% through SKU optimization and instance type selection
- **Requirements**:
  - VM SKUs limited to cost-optimized tiers (B-series for Regular, D-series for Spot)
  - **NEW (v2.1.0)**: Spot instance support for 84-87% dev/test cost savings
  - MySQL SKUs limited to Burstable/GeneralPurpose tiers
  - Storage account limited to Standard_LRS/ZRS
  - No premium resources in dev environments

### dp-001: Data Protection Requirements
- **Objective**: Protect data at rest and in transit
- **Requirements**:
  - Encryption at rest enabled for all storage (VMs, disks, database)
  - TLS 1.2+ minimum for all network connections
  - Key Vault for secrets management
  - Backup retention: 7+ days dev, 30+ days prod
  - Blob soft delete for accidental deletion protection

### ac-001: Access Control Requirements
- **Objective**: Secure access to resources
- **Requirements**:
  - SSH key authentication only (no password)
  - VNet integration for databases (no public endpoints)
  - Network Security Groups with minimal necessary rules
  - Azure RBAC for authorization
  - Managed identities for service-to-service

### comp-001: Compliance Requirements
- **Objective**: Meet NIST 800-171 compliance
- **Requirements**:
  - US regions only (centralus, eastus)
  - Automatic NIST 800-171 compliance tagging
  - Compliance controls enforced via policy

### lint-001: Linting and Quality Requirements
- **Objective**: Ensure code quality and consistency
- **Requirements**:
  - All Bicep modules pass `bicep build` validation
  - Comprehensive README.md documentation
  - Example parameters.json with dev/prod configurations
  - Consistent parameter naming patterns

---

## Compliance Matrix by Module

### Module 1: avm-wrapper-vnet

| Spec | Requirement | Implementation | Enforcement Mechanism |
|------|-------------|----------------|----------------------|
| **cost-001** | Optimize network costs | VNet is free, no NSG flow logs by default | Default configuration |
| **dp-001** | Network isolation | Subnets for network segmentation | Required parameter |
| **ac-001** | Network access control | Subnets with NSG association | Integration with NSG module |
| **comp-001** | US regions only | `@allowed(['centralus', 'eastus'])` on `location` parameter | Parameter constraint |
| **comp-001** | NIST 800-171 tagging | `Compliance: 'NIST-800-171'` tag automatically applied | Default tag merge |
| **lint-001** | Bicep validation | Module passes `bicep build` | Build-time validation |
| **lint-001** | Documentation | README.md (400+ lines), parameters.json | Files included |

**Audit Trail**: All deployments include VNet ID, subnet IDs, location, and compliance tags in outputs

---

### Module 2: avm-wrapper-nsg

| Spec | Requirement | Implementation | Enforcement Mechanism |
|------|-------------|----------------|----------------------|
| **cost-001** | Optimize network costs | NSG is free, no flow logs by default | Default configuration |
| **dp-001** | N/A | Not applicable for NSG | — |
| **ac-001** | Minimal necessary rules | Default rules allow HTTP/HTTPS only, deny SSH from internet | Default security rules |
| **ac-001** | Secure SSH access | `sshSourceAddressPrefix` parameter controls SSH source (empty = deny all) | Parameter control |
| **comp-001** | US regions only | `@allowed(['centralus', 'eastus'])` on `location` parameter | Parameter constraint |
| **comp-001** | NIST 800-171 tagging | `Compliance: 'NIST-800-171'` tag automatically applied | Default tag merge |
| **lint-001** | Bicep validation | Module passes `bicep build` | Build-time validation |
| **lint-001** | Documentation | README.md (350+ lines), parameters.json | Files included |

**Audit Trail**: All deployments include NSG ID, security rules list, location, and compliance tags in outputs

---

### Module 3: avm-wrapper-public-ip

| Spec | Requirement | Implementation | Enforcement Mechanism |
|------|-------------|----------------|----------------------|
| **cost-001** | Optimize IP costs | Standard SKU ($3.65/month), no premium features | Fixed SKU configuration |
| **dp-001** | N/A | Not applicable for Public IP | — |
| **ac-001** | N/A | Public IPs are internet-facing by design | — |
| **comp-001** | US regions only | `@allowed(['centralus', 'eastus'])` on `location` parameter | Parameter constraint |
| **comp-001** | NIST 800-171 tagging | `Compliance: 'NIST-800-171'` tag automatically applied | Default tag merge |
| **lint-001** | Bicep validation | Module passes `bicep build` | Build-time validation |
| **lint-001** | Documentation | README.md (350+ lines), parameters.json | Files included |

**Audit Trail**: All deployments include Public IP ID, IP address, FQDN, availability zones, and compliance tags in outputs

---

### Module 4: avm-wrapper-linux-vm (v2.1.0 - Spot Instance Support Added)

| Spec | Requirement | Implementation | Enforcement Mechanism |
|------|-------------|----------------|----------------------|
| **cost-001** | B-series SKUs for Regular | `@allowed(['Standard_B2s', 'Standard_B4ms', 'Standard_D2s_v5', 'Standard_D4s_v5'])` on `vmSize` parameter | Parameter constraint |
| **cost-001** | **NEW: Spot instance support** | `vmPriority: 'Regular' \| 'Spot'` parameter (84-87% savings for dev/test) | Optional parameter (defaults to 'Regular') |
| **cost-001** | Spot eviction control | `spotEvictionPolicy: 'Deallocate' \| 'Delete'` parameter | Conditional (only when vmPriority='Spot') |
| **cost-001** | Spot price control | `spotMaxPrice: string` parameter (default '-1' = no limit) | Conditional (only when vmPriority='Spot') |
| **cost-001** | Cost-optimized disks | StandardSSD_LRS default for dev, Premium_LRS for prod | Environment-based default |
| **dp-001** | Encryption at rest | `encryptionAtHost: true` for prod environment | Environment-based conditional |
| **dp-001** | N/A (VM has no backup in module) | Backup is separate Azure Backup service | Out of scope |
| **ac-001** | SSH keys only | `disablePasswordAuthentication: true`, `sshPublicKey` required parameter | Fixed configuration + required param |
| **ac-001** | Managed identity | `enableSystemManagedIdentity: true` | Fixed configuration |
| **ac-001** | VNet integration | `subnetId` required parameter, no public IP by default | Required parameter |
| **comp-001** | US regions only | `@allowed(['centralus', 'eastus'])` on `location` parameter | Parameter constraint |
| **comp-001** | NIST 800-171 tagging | `Compliance: 'NIST-800-171'` tag automatically applied | Default tag merge |
| **lint-001** | Bicep validation | Module passes `bicep build` | Build-time validation |
| **lint-001** | Documentation | README.md (600+ lines with Spot guidance), parameters.json + parameters-spot-example.json | Files included |

**Key Updates (v2.1.0)**:
- Added `vmPriority`, `spotEvictionPolicy`, `spotMaxPrice` parameters for Spot instance support
- Expanded VM SKU options to include D-series (required for Spot; B-series doesn't support Spot)
- Maintains backward compatibility (vmPriority defaults to 'Regular')
- See [reserved-instance-vm-migration.md](./reserved-instance-vm-migration.md) for deprecated template migration

**Audit Trail**: All deployments include VM ID, private IP, managed identity principal ID, vmSize, vmPriority (if Spot), osDiskId, and compliance tags in outputs

---

### Module 5: avm-wrapper-managed-disk

| Spec | Requirement | Implementation | Enforcement Mechanism |
|------|-------------|----------------|----------------------|
| **cost-001** | Standard/Premium SKUs only | `@allowed(['Standard_LRS', 'StandardSSD_LRS', 'StandardSSD_ZRS', 'Premium_LRS', 'Premium_ZRS'])` on `diskSku` parameter | Parameter constraint |
| **cost-001** | Cost-optimized defaults | StandardSSD_LRS for dev, Premium_LRS for prod | Environment-based default |
| **dp-001** | Encryption at rest | `encryptionSettingsCollection` enabled for prod environment | Environment-based conditional |
| **dp-001** | Secure network access | `publicNetworkAccess: Disabled`, `networkAccessPolicy: DenyAll` | Fixed configuration |
| **ac-001** | No public access | `publicNetworkAccess: Disabled` | Fixed configuration |
| **comp-001** | US regions only | `@allowed(['centralus', 'eastus'])` on `location` parameter | Parameter constraint |
| **comp-001** | NIST 800-171 tagging | `Compliance: 'NIST-800-171'` tag automatically applied | Default tag merge |
| **lint-001** | Bicep validation | Module passes `bicep build` | Build-time validation |
| **lint-001** | Documentation | README.md (450+ lines), parameters.json | Files included |

**Audit Trail**: All deployments include disk ID, diskSizeGB, diskSku, availabilityZone, and compliance tags in outputs

---

### Module 6: avm-wrapper-key-vault

| Spec | Requirement | Implementation | Enforcement Mechanism |
|------|-------------|----------------|----------------------|
| **cost-001** | Standard SKU for dev | Standard SKU default for dev, Premium for prod | Environment-based default |
| **dp-001** | Secure secrets storage | `enableRbacAuthorization: true` (no legacy access policies) | Fixed configuration |
| **dp-001** | Soft delete protection | `enableSoftDelete: true`, 7-90 day retention | Required feature + parameter constraint |
| **dp-001** | Purge protection | `enablePurgeProtection: true` for prod environment | Environment-based conditional |
| **ac-001** | RBAC authorization | `enableRbacAuthorization: true`, `accessPolicies: []` | Fixed configuration |
| **ac-001** | Private network access | `publicNetworkAccess: Disabled` for prod, VNet integration support | Environment-based conditional |
| **comp-001** | US regions only | `@allowed(['centralus', 'eastus'])` on `location` parameter | Parameter constraint |
| **comp-001** | NIST 800-171 tagging | `Compliance: 'NIST-800-171'` tag automatically applied | Default tag merge |
| **lint-001** | Bicep validation | Module passes `bicep build` | Build-time validation |
| **lint-001** | Documentation | README.md (500+ lines), parameters.json | Files included |

**Audit Trail**: All deployments include Key Vault ID, URI, SKU, soft delete status, purge protection status, and compliance tags in outputs

---

### Module 7: avm-wrapper-storage-account

| Spec | Requirement | Implementation | Enforcement Mechanism |
|------|-------------|----------------|----------------------|
| **cost-001** | Standard_LRS/ZRS only | `@allowed(['Standard_LRS', 'Standard_ZRS'])` on `sku` parameter | Parameter constraint |
| **cost-001** | Cost-optimized defaults | Standard_LRS for dev, Standard_ZRS for prod | Environment-based default |
| **dp-001** | Encryption at rest | `requireInfrastructureEncryption: true` for prod (double encryption) | Environment-based conditional |
| **dp-001** | TLS 1.2+ minimum | `minimumTlsVersion: TLS1_2` | Default parameter value |
| **dp-001** | Blob soft delete | `enableBlobSoftDelete: true` for prod, 30-day retention | Environment-based conditional |
| **ac-001** | No public blob access | `allowBlobPublicAccess: false` | Fixed configuration |
| **ac-001** | HTTPS only | `supportsHttpsTrafficOnly: true` | Fixed configuration |
| **ac-001** | VNet integration | `networkAclsDefaultAction: Deny` for prod, `subnetIds` parameter | Environment-based conditional |
| **comp-001** | US regions only | `@allowed(['centralus', 'eastus'])` on `location` parameter | Parameter constraint |
| **comp-001** | NIST 800-171 tagging | `Compliance: 'NIST-800-171'` tag automatically applied | Default tag merge |
| **lint-001** | Bicep validation | Module passes `bicep build` | Build-time validation |
| **lint-001** | Documentation | README.md (550+ lines), parameters.json | Files included |

**Audit Trail**: All deployments include Storage Account ID, primaryBlobEndpoint, SKU, accessTier, and compliance tags in outputs

---

### Module 8: avm-wrapper-mysql-flexibleserver

| Spec | Requirement | Implementation | Enforcement Mechanism |
|------|-------------|----------------|----------------------|
| **cost-001** | Burstable/GeneralPurpose only | `@allowed(['Burstable_B1ms', 'GeneralPurpose_D2ds_v4'])` on `sku` parameter | Parameter constraint |
| **cost-001** | Cost-optimized defaults | Burstable_B1ms for dev, GeneralPurpose_D2ds_v4 for prod | Environment-based default |
| **dp-001** | Encryption at rest | Platform-managed encryption enabled by default | AVM default configuration |
| **dp-001** | TLS/SSL required | `require_secure_transport: ON` server parameter | Fixed configuration |
| **dp-001** | Backup retention | 7 days dev, 30 days prod | Environment-based default |
| **ac-001** | VNet integration only | `delegatedSubnetId` and `privateDnsZoneId` required parameters, no public access | Required parameters |
| **ac-001** | Secure authentication | `administratorPassword` required (secure string) | Parameter type constraint |
| **comp-001** | US regions only | `@allowed(['centralus', 'eastus'])` on `location` parameter | Parameter constraint |
| **comp-001** | NIST 800-171 tagging | `Compliance: 'NIST-800-171'` tag automatically applied | Default tag merge |
| **lint-001** | Bicep validation | Module passes `bicep build` | Build-time validation |
| **lint-001** | Documentation | README.md (700+ lines), parameters.json | Files included |

**Audit Trail**: All deployments include MySQL Server ID, FQDN, SKU, MySQL version, backup retention, HA status, and compliance tags in outputs

---

## Enforcement Mechanism Types

### 1. Parameter Constraints
- **`@allowed` decorator**: Restricts parameter values to compliant options (e.g., `@allowed(['centralus', 'eastus'])`)
- **`@minValue/@maxValue` decorator**: Enforces numeric constraints (e.g., `@minValue(7) @maxValue(35)` for backup retention)
- **`@secure` decorator**: Requires secure handling of sensitive parameters (e.g., SSH keys, passwords)
- **Required parameters**: Forces user to provide critical values (e.g., `sshPublicKey`, `subnetId`)

### 2. Fixed Configuration
- **Hardcoded values**: Non-negotiable settings in module code (e.g., `disablePasswordAuthentication: true`, `allowBlobPublicAccess: false`)
- **Cannot be overridden**: Application teams cannot bypass these settings

### 3. Environment-Based Conditionals
- **Conditional expressions**: Different values for dev vs prod (e.g., `environment == 'prod' ? true : false` for encryption)
- **Environment parameter**: Required `environment` parameter drives compliance behavior

### 4. Default Parameters
- **Cost-optimized defaults**: Lowest compliant SKU for dev, higher for prod (e.g., Standard_B2s dev, Standard_B4ms prod)
- **User can override**: Within `@allowed` constraints

### 5. Build-Time Validation
- **Bicep linter**: `bicep build` validates syntax, parameter types, resource schemas
- **Pre-deployment**: Errors caught before Azure deployment

### 6. Default Tag Merge
- **Automatic tagging**: Platform adds `Compliance: 'NIST-800-171'` tag to all resources
- **User tags preserved**: `additionalTags` parameter merged with platform tags

---

## Compliance Validation Methods

### 1. Pre-Deployment Validation

**Bicep Build Validation**:
```bash
# Validate all modules pass bicep build
bicep build ./avm-wrapper-vnet/main.bicep
bicep build ./avm-wrapper-nsg/main.bicep
bicep build ./avm-wrapper-public-ip/main.bicep
bicep build ./avm-wrapper-linux-vm/main.bicep
bicep build ./avm-wrapper-managed-disk/main.bicep
bicep build ./avm-wrapper-key-vault/main.bicep
bicep build ./avm-wrapper-storage-account/main.bicep
bicep build ./avm-wrapper-mysql-flexibleserver/main.bicep
```

**What-If Deployment**:
```bash
# Preview deployment changes without deploying
az deployment group what-if \
  --resource-group rg-test \
  --template-file deploy-lamp-dev.bicep \
  --parameters deploy-lamp-dev.parameters.json
```

### 2. Post-Deployment Validation

**Resource Compliance Check**:
```bash
# Verify VM SKU is compliant
az vm show --name mycoolapp-dev-vm --resource-group rg-mycoolapp-dev --query hardwareProfile.vmSize
# Expected: "Standard_B2s" or "Standard_B4ms"

# Verify MySQL SKU is compliant
az mysql flexible-server show --name mycoolapp-dev-mysql --resource-group rg-mycoolapp-dev --query sku.name
# Expected: "Burstable_B1ms" or "GeneralPurpose_D2ds_v4"

# Verify Storage SKU is compliant
az storage account show --name mycoolappdevstorage --query sku.name
# Expected: "Standard_LRS" or "Standard_ZRS"

# Verify region compliance
az resource list --resource-group rg-mycoolapp-dev --query "[].location" -o tsv | sort -u
# Expected: "centralus" or "eastus"

# Verify NIST tagging
az resource list --resource-group rg-mycoolapp-dev --query "[].tags.Compliance"
# Expected: "NIST-800-171" for all resources
```

**Security Compliance Check**:
```bash
# Verify VM SSH authentication
az vm show --name mycoolapp-dev-vm --resource-group rg-mycoolapp-dev --query "osProfile.linuxConfiguration.disablePasswordAuthentication"
# Expected: true

# Verify MySQL SSL enforcement
az mysql flexible-server parameter show --name require_secure_transport --server-name mycoolapp-dev-mysql --resource-group rg-mycoolapp-dev --query value
# Expected: "ON"

# Verify Storage Account HTTPS-only
az storage account show --name mycoolappdevstorage --query supportsHttpsTrafficOnly
# Expected: true

# Verify Storage Account blob public access
az storage account show --name mycoolappdevstorage --query allowBlobPublicAccess
# Expected: false
```

**Data Protection Compliance Check**:
```bash
# Verify Key Vault soft delete
az keyvault show --name mycoolapp-dev-kv --query "properties.enableSoftDelete"
# Expected: true

# Verify MySQL backup retention
az mysql flexible-server show --name mycoolapp-dev-mysql --resource-group rg-mycoolapp-dev --query backup.backupRetentionDays
# Expected: 7 (dev) or 30 (prod)

# Verify Storage Account blob soft delete (prod only)
az storage account blob-service-properties show --account-name mycoolappprodstorage --query deleteRetentionPolicy.days
# Expected: 30 (prod), null (dev)
```

### 3. Continuous Compliance Monitoring

**Azure Policy Assignment** (recommended):
- Assign built-in policies for continuous compliance monitoring:
  - "Allowed locations" policy (centralus, eastus only)
  - "Allowed virtual machine size SKUs" policy (Standard_B2s, Standard_B4ms only)
  - "Azure Defender for SQL servers should be enabled"
  - "Storage accounts should use customer-managed key for encryption"

**Azure Monitor Alerts**:
- Alert on non-compliant resource creation
- Alert on policy violations

---

## Compliance Audit Report

### Sample Audit Report

**Deployment**: `rg-mycoolapp-dev`  
**Date**: 2026-02-07  
**Environment**: dev  

| Spec | Requirement | Status | Evidence |
|------|-------------|--------|----------|
| **cost-001** | VM SKU: B-series only | ✅ PASS | `az vm show` → hardwareProfile.vmSize = "Standard_B2s" |
| **cost-001** | MySQL SKU: Burstable/GP only | ✅ PASS | `az mysql flexible-server show` → sku.name = "Burstable_B1ms" |
| **cost-001** | Storage SKU: Standard only | ✅ PASS | `az storage account show` → sku.name = "Standard_LRS" |
| **dp-001** | VM encryption at rest | ⚠️ SKIP | Dev environment (not required) |
| **dp-001** | TLS 1.2+ minimum | ✅ PASS | `az storage account show` → minimumTlsVersion = "TLS1_2" |
| **dp-001** | MySQL SSL required | ✅ PASS | `az mysql flexible-server parameter show` → require_secure_transport = "ON" |
| **dp-001** | Key Vault soft delete | ✅ PASS | `az keyvault show` → enableSoftDelete = true, softDeleteRetentionDays = 7 |
| **dp-001** | MySQL backup retention | ✅ PASS | `az mysql flexible-server show` → backupRetentionDays = 7 |
| **ac-001** | SSH keys only | ✅ PASS | `az vm show` → disablePasswordAuthentication = true |
| **ac-001** | MySQL VNet integration | ✅ PASS | `az mysql flexible-server show` → network.delegatedSubnetResourceId exists, publicNetworkAccess = null |
| **ac-001** | Storage HTTPS-only | ✅ PASS | `az storage account show` → supportsHttpsTrafficOnly = true |
| **ac-001** | Storage no public blob access | ✅ PASS | `az storage account show` → allowBlobPublicAccess = false |
| **comp-001** | US regions only | ✅ PASS | All resources in "centralus" |
| **comp-001** | NIST 800-171 tagging | ✅ PASS | All resources have tag Compliance = "NIST-800-171" |

**Overall Compliance**: ✅ **PASS** (13/13 applicable requirements, 1 skipped for dev environment)

---

## Non-Compliance Remediation

### If Compliance Check Fails

**Issue**: VM SKU is not compliant (e.g., "Standard_D4s_v3")  
**Root Cause**: Deployment used custom Bicep template instead of wrapper module  
**Remediation**:
1. Stop the non-compliant VM
2. Redeploy using wrapper module with compliant SKU
3. Migrate data to new VM
4. Delete old VM

**Issue**: MySQL has public endpoint enabled  
**Root Cause**: Deployment used AVM directly instead of wrapper module  
**Remediation**:
1. Create delegated subnet and private DNS zone
2. Redeploy using wrapper module with VNet integration
3. Update connection strings to use private FQDN
4. Delete old MySQL server

**Issue**: Storage Account allows public blob access  
**Root Cause**: Manual configuration change after deployment  
**Remediation**:
1. Run: `az storage account update --name <account> --allow-blob-public-access false`
2. Verify: `az storage account show --name <account> --query allowBlobPublicAccess`

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-02-07 | Initial compliance matrix for all 8 wrapper modules |

---

**Maintained By**: Infrastructure Engineering Team  
**Review Frequency**: Quarterly  
**Last Review**: 2026-02-07
