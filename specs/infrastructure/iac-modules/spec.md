---
# YAML Frontmatter - Category-Based Spec System
tier: infrastructure
category: iac-modules
spec-id: iac-001
version: 1.0.0-draft
status: draft
created: 2026-02-07
description: "Centralized reusable IaC wrapper modules based on Azure Verified Modules"

# Dependencies
depends-on:
  - tier: business
    category: cost
    spec-id: cost-001
    reason: "Wrapper modules must enforce cost-optimized SKU defaults"
  - tier: security
    category: data-protection
    spec-id: dp-001
    reason: "Wrapper modules must enforce encryption and key management standards"
  - tier: security
    category: access-control
    spec-id: ac-001
    reason: "Wrapper modules must enforce SSH key-based access (no passwords)"
  - tier: business
    category: compliance-framework
    spec-id: comp-001
    reason: "Wrapper modules must enforce data residency (US regions only)"
  - tier: platform
    category: iac-linting
    spec-id: lint-001
    reason: "Wrapper modules must follow Bicep code quality standards"

# Precedence rules
precedence:
  note: "IaC modules implement upstream constraints from business/security/platform tiers"
  loses-to:
    - tier: business
      category: cost
      spec-id: cost-001
    - tier: security
      category: data-protection
      spec-id: dp-001
    - tier: security
      category: access-control
      spec-id: ac-001

# Relationships
adhered-by:
  - app-id: mycoolapp
    version: "1.0.0"
    compliance: "planned"
    note: "Will migrate to wrapper modules from inline Bicep resources"
---

# Specification: Infrastructure as Code (IaC) Modules

**Tier**: infrastructure  
**Category**: iac-modules  
**Spec ID**: iac-001  
**Created**: 2026-02-07  
**Status**: Draft  

## Executive Summary

**Problem**: Without centralized IaC modules:
- Application teams deploy non-compliant infrastructure (wrong SKUs, missing encryption, non-US regions)
- Security policies and cost constraints are not enforced at deployment time
- Code duplication across applications leads to drift and maintenance burden
- No standardization of Azure resource configurations

**Solution**: Provide centralized, reusable Bicep wrapper modules based on Azure Verified Modules (AVM) that expose only compliant parameters and enforce platform defaults.

**Impact**: Application teams can only deploy infrastructure that satisfies business cost targets, security policies, compliance requirements, and platform standards.

## Requirements

### Functional Requirements

#### REQ-001: Azure Verified Module Foundation
All infrastructure modules MUST be **wrappers** around publicly published Azure Verified Modules (AVM) from the official Bicep Registry:
- **Source**: https://github.com/Azure/bicep-registry-modules/tree/main/avm/res
- **Pattern**: Wrapper modules consume AVM modules via `br/public:` registry reference
- **Versioning**: Pin to specific AVM module versions as documented in each AVM module's CHANGELOG.md file (semantic versioning)
- **Updates**: Review AVM module CHANGELOG.md files quarterly for security patches and new features

**Rationale**: AVM modules are Microsoft-maintained, well-tested, and follow Azure best practices. Wrapping them allows us to enforce platform-specific constraints while benefiting from upstream maintenance. Version pinning via CHANGELOG.md ensures consistency and easy version tracking.

#### REQ-002: Minimal Parameter Exposure
Wrapper modules MUST expose only parameters necessary for application teams to customize their deployments while remaining compliant:
- **Allowed Parameters**: Application name, environment (dev/prod), resource-specific sizing within approved SKU ranges
- **Hidden Parameters**: Security settings (encryption enabled by default), compliance settings (US regions only), prohibited SKU options
- **Validation**: Use Bicep `@allowed` decorators to restrict parameter values to compliant options

**Example**: VM wrapper module exposes `vmSku` parameter but restricts choices to `['Standard_B2s', 'Standard_B4ms']` per cost-001.

#### REQ-003: Compliant Default Parameters
Wrapper modules MUST include default parameters that satisfy all upstream specifications:
- **Cost Defaults** (from business/cost-001):
  - VM SKUs: `Standard_B2s` (dev), `Standard_B4ms` (prod)
  - Storage: `Standard_LRS` replication
  - Reserved instances: 3-year commitment for production VMs
- **Security Defaults** (from security/data-protection-001, security/access-control-001):
  - Encryption at rest: Enabled (Azure Disk Encryption or server-side encryption)
  - Encryption in transit: TLS 1.2+ required
  - Authentication: SSH keys only (no password authentication)
  - Key Vault: Azure Key Vault Premium (HSM-backed) for production secrets
- **Compliance Defaults** (from business/compliance-framework-001):
  - Location: `centralus` or `eastus` only (US data residency)
  - Tagging: `compliance: nist-800-171` tag mandatory
  - Diagnostics: Azure Monitor integration enabled
- **Platform Defaults** (from platform/iac-linting-001):
  - Code quality: Pass `bicep build` validation
  - Naming conventions: `<appname>-<environment>-<resourcetype>`

#### REQ-004: Module Catalog for LAMP Stack
Initial module catalog MUST support mycoolapp LAMP stack deployment (Ubuntu 22.04 + Apache + PHP + Azure Database for MySQL):

1. **Virtual Network Module** (`avm-wrapper-vnet`)
   - **AVM Source**: `br/public:avm/res/network/virtual-network:X.Y.Z`
   - **Exposed Parameters**: `vnetName`, `addressPrefix` (default: `10.0.0.0/16`)
   - **Enforced Defaults**: Location (US regions only), NSG association required, DDoS protection standard
   - **Outputs**: `vnetId`, `subnetIds`

2. **Network Security Group Module** (`avm-wrapper-nsg`)
   - **AVM Source**: `br/public:avm/res/network/network-security-group:X.Y.Z`
   - **Exposed Parameters**: `nsgName`, `securityRules` (for application-specific ports)
   - **Enforced Defaults**: SSH (port 22) restricted to corporate VPN, HTTP/HTTPS allowed, deny-all rule for other inbound traffic
   - **Outputs**: `nsgId`

3. **Public IP Module** (`avm-wrapper-public-ip`)
   - **AVM Source**: `br/public:avm/res/network/public-ip-address:X.Y.Z`
   - **Exposed Parameters**: `publicIpName`, `environment`
   - **Enforced Defaults**: Standard SKU (for zone redundancy), Static allocation, DDoS Protection Standard
   - **Outputs**: `publicIpId`, `ipAddress`

4. **Virtual Machine Module** (`avm-wrapper-linux-vm`)
   - **AVM Source**: `br/public:avm/res/compute/virtual-machine:X.Y.Z`
   - **Exposed Parameters**: `vmName`, `vmSku` (restricted to `['Standard_B2s', 'Standard_B4ms']`), `sshPublicKey`, `adminUsername`
   - **Enforced Defaults**: 
     - Ubuntu 22.04 LTS image
     - Managed identity enabled
     - Azure Disk Encryption enabled (data-protection-001)
     - SSH authentication only (access-control-001)
     - Reserved instance pricing mode for production
     - Azure Monitor VM Insights extension installed
     - cloud-init for LAMP stack provisioning
   - **Outputs**: `vmId`, `privateIpAddress`, `managedIdentityPrincipalId`

5. **Managed Disk Module** (`avm-wrapper-managed-disk`)
   - **AVM Source**: `br/public:avm/res/compute/disk:X.Y.Z`
   - **Exposed Parameters**: `diskName`, `diskSizeGB`, `environment`
   - **Enforced Defaults**: Standard SSD, LRS replication (dev), ZRS (prod), encryption enabled, US regions only
   - **Outputs**: `diskId`

6. **Key Vault Module** (`avm-wrapper-key-vault`)
   - **AVM Source**: `br/public:avm/res/key-vault/vault:X.Y.Z`
   - **Exposed Parameters**: `keyVaultName`, `environment`
   - **Enforced Defaults**: 
     - Premium SKU for production (HSM-backed keys per data-protection-001)
     - Standard SKU for dev
     - Azure RBAC authorization
     - Soft delete enabled (90-day retention)
     - Purge protection enabled for production
     - Network rules: Azure services bypass, default deny
   - **Outputs**: `keyVaultId`, `keyVaultUri`

7. **Storage Account Module** (`avm-wrapper-storage-account`)
   - **AVM Source**: `br/public:avm/res/storage/storage-account:X.Y.Z`
   - **Exposed Parameters**: `storageAccountName`, `environment`
   - **Enforced Defaults**: 
     - Standard_LRS replication (dev), Standard_ZRS (prod)
     - TLS 1.2 minimum version
     - Encryption enabled (Microsoft-managed keys)
     - Blob soft delete enabled (30-day retention per compliance-001)
     - US regions only
   - **Outputs**: `storageAccountId`, `primaryEndpoints`

8. **Azure Database for MySQL Flexible Server Module** (`avm-wrapper-mysql-flexibleserver`)
   - **AVM Source**: `br/public:avm/res/db-for-my-sql/flexible-server:X.Y.Z`
   - **Exposed Parameters**: `serverName`, `environment`, `administratorLogin`, `storageGB` (restricted to cost-optimized tiers)
   - **Enforced Defaults**:
     - SKU: Burstable_B1ms (dev), GeneralPurpose_D2ds_v4 (prod) per cost-001
     - MySQL version: 8.0 (latest LTS)
     - Storage: 20GB (dev), 32GB (prod) auto-grow enabled
     - High availability: Disabled (dev), Zone-redundant (prod) per governance-001 SLA
     - Backup retention: 7 days (dev), 30 days (prod) per compliance-001
     - SSL enforcement: Required (TLS 1.2+) per dp-001
     - Encryption: Microsoft-managed keys
     - Public network access: Disabled (VNet integration only) per ac-001
     - Location: US regions only per comp-001
     - Firewall rules: Azure services allowed, specific VNet subnet access only
   - **Outputs**: `serverId`, `fqdn`, `administratorLogin`

#### REQ-005: Module Directory Structure
Centralized wrapper modules MUST reside in the artifacts infrastructure directory:
```
/artifacts/
  /infrastructure/
    /iac-modules/
      /avm-wrapper-vnet/
        main.bicep           # Wrapper module (calls AVM via br/public)
        README.md            # Usage documentation
        parameters.json      # Example parameter file
      /avm-wrapper-nsg/
        main.bicep
        README.md
        parameters.json
      /avm-wrapper-public-ip/
        main.bicep
        README.md
        parameters.json
      /avm-wrapper-linux-vm/
        main.bicep
        README.md
        parameters.json
      /avm-wrapper-managed-disk/
        main.bicep
        README.md
        parameters.json
      /avm-wrapper-key-vault/
        main.bicep
        README.md
        parameters.json
      /avm-wrapper-storage-account/
        main.bicep
        README.md
        parameters.json
      /avm-wrapper-mysql-flexibleserver/
        main.bicep
        README.md
        parameters.json
```

**Rationale**: Centralized infrastructure modules in `/artifacts/infrastructure/iac-modules/` enables reuse across all applications, clear versioning, and single source of truth for platform-compliant infrastructure patterns.

#### REQ-006: Application Team Consumption Pattern
Application teams MUST consume wrapper modules from the centralized `/artifacts/infrastructure/iac-modules/` directory:

**Application Bicep (`/artifacts/applications/mycoolapp/iac/main.bicep`)**:
```bicep
targetScope = 'resourceGroup'

// Reference centralized wrapper modules
module vnet '../../../infrastructure/iac-modules/avm-wrapper-vnet/main.bicep' = {
  name: 'vnet-deployment'
  params: {
    vnetName: 'mycoolapp-prod-vnet'
    addressPrefix: '10.0.0.0/16'
    location: 'centralus'  // Enforced by wrapper to US regions only
    environment: 'prod'
  }
}

module vm '../../../infrastructure/iac-modules/avm-wrapper-linux-vm/main.bicep' = {
  name: 'vm-deployment'
  params: {
    vmName: 'mycoolapp-prod-vm'
    vmSku: 'Standard_B4ms'  // Only allowed options per cost-001
    sshPublicKey: keyVault.outputs.sshPublicKey
    adminUsername: 'azureuser'
    environment: 'prod'
  }
}

module mysql '../../../infrastructure/iac-modules/avm-wrapper-mysql-flexibleserver/main.bicep' = {
  name: 'mysql-deployment'
  params: {
    serverName: 'mycoolapp-prod-mysql'
    environment: 'prod'
    administratorLogin: 'mysqladmin'
    vnetId: vnet.outputs.vnetId
    subnetId: vnet.outputs.subnetIds[1]  // Dedicated database subnet
  }
}
```

**Benefits**:
- Application teams cannot deploy non-compliant SKUs (wrapper enforces `@allowed` restrictions)
- Security defaults applied automatically (encryption, SSH keys, US regions)
- Cost defaults applied automatically (reserved instances, Standard LRS)
- Compliance tags applied automatically (NIST 800-171)

### Non-Functional Requirements

#### REQ-007: Wrapper Module Maintenance
- **Upstream Sync**: Review AVM module CHANGELOG.md files monthly; apply security patches within 7 days
  - **AVM CHANGELOG.md Location**: Each AVM module in https://github.com/Azure/bicep-registry-modules/tree/main/avm/res contains a CHANGELOG.md file
  - **Example Paths**: 
    - `/avm/res/network/virtual-network/CHANGELOG.md`
    - `/avm/res/compute/virtual-machine/CHANGELOG.md`
    - `/avm/res/storage/storage-account/CHANGELOG.md`
    - `/avm/res/db-for-my-sql/flexible-server/CHANGELOG.md`
  - **Version Format**: Extract the latest stable version from the AVM CHANGELOG.md and use it in the wrapper module reference (e.g., `0.7.3`)
- **Breaking Changes**: When AVM CHANGELOG.md indicates a MAJOR version bump, test wrapper modules against new AVM version in test subscription before production
- **Wrapper Changelog**: Maintain wrapper module CHANGELOG.md that tracks upstream AVM version dependencies and wrapper updates
- **Deprecation**: Provide 90-day migration notice before deprecating wrapper module versions

#### REQ-008: Module Testing
All wrapper modules MUST include:
- **Validation Tests**: Bicep build validation (no errors/warnings)
- **Deployment Tests**: Test deployment in dev subscription with sample parameters
- **Compliance Tests**: Verify deployed resources satisfy cost/security/compliance constraints
- **Documentation Tests**: README includes usage examples, parameter descriptions, outputs

#### REQ-009: Version Pinning
- **AVM Version Source of Truth**: Wrapper modules MUST pin to AVM semantic versions based on the CHANGELOG.md file within each AVM module repository
  - **AVM Repository**: https://github.com/Azure/bicep-registry-modules/tree/main/avm/res
  - **Location**: Each AVM module contains a CHANGELOG.md file (e.g., `/avm/res/compute/virtual-machine/CHANGELOG.md`)
  - **Process**: Before creating or updating a wrapper module, check the target AVM module's CHANGELOG.md to determine the latest stable version
  - **Version Format**: Use the version format specified in the AVM CHANGELOG.md (e.g., `br/public:avm/res/compute/virtual-machine:0.7.3`)
  - **Never Use Latest Tag**: Wrapper modules MUST NOT use `latest` or unversioned registry references; always pin to a specific semantic version from the AVM CHANGELOG.md
- **AVM Update Cadence**: Review AVM CHANGELOG.md files quarterly (Jan, Apr, Jul, Oct) for security patches and new features
- **Breaking Changes**: When AVM module introduces breaking changes (major version bump in CHANGELOG.md), create new wrapper module version with migration guide
- **Wrapper Versions**: Wrapper modules MUST use semantic versioning (MAJOR.MINOR.PATCH)
- **Application References**: Application teams SHOULD reference specific wrapper module versions (future enhancement: version tags)

## Rationale

### Why Wrapper Modules (Not Direct AVM Consumption)?
1. **Compliance Enforcement**: AVM modules expose all Azure parameters; wrapper modules restrict to compliant subset
2. **Default Management**: Centralized defaults (cost-optimized SKUs, security settings) reduce configuration burden
3. **Change Control**: Platform team controls which AVM versions are approved (security/compliance review)
4. **Future Flexibility**: Can swap underlying AVM modules or add custom logic without breaking application code

### Why Start with LAMP Stack Modules?
- **Immediate Value**: Supports existing mycoolapp deployment (migration path from inline Bicep)
- **Common Pattern**: VM-based workloads are common across applications (reusable foundation)
- **Incremental Expansion**: Add PaaS modules (App Service, SQL Database, etc.) as application needs evolve

## Success Criteria

- [ ] All 8 wrapper modules created for LAMP stack infrastructure
- [ ] Each wrapper module passes `bicep build` validation
- [ ] Test deployment of all modules succeeds in dev subscription
- [ ] mycoolapp migrated from inline Bicep resources to wrapper modules (cost/effort: ~4 hours)
- [ ] Application teams can deploy LAMP infrastructure using wrapper modules without manual compliance checks
- [ ] 100% of deployed resources satisfy cost-001, dp-001, ac-001, comp-001 constraints

## Migration Path

### Phase 1: Create Wrapper Modules (Current)
1. Create `/artifacts/infrastructure/iac-modules/` directory structure
2. Implement 8 wrapper modules for LAMP stack (7 IaaS + 1 PaaS database)
3. Document usage patterns and examples
4. Test in dev subscription

### Phase 2: Migrate mycoolapp
1. Update `mycoolapp/iac/main.bicep` to reference wrapper modules
2. Remove inline resource definitions
3. Test deployment in dev environment
4. Deploy to production with approval gate (governance-001)

### Phase 3: Expand Module Catalog
1. Add PaaS wrapper modules (App Service, SQL Database, Cosmos DB)
2. Add networking wrapper modules (Application Gateway, Front Door)
3. Add observability wrapper modules (Log Analytics, Application Insights)

## Related Specifications

- **Upstream Dependencies**:
  - business/cost-001 (SKU restrictions and cost optimization)
  - security/data-protection-001 (encryption and key management)
  - security/access-control-001 (authentication and RBAC)
  - business/compliance-framework-001 (data residency and retention)
  - platform/iac-linting-001 (code quality standards)

- **Downstream Consumers**:
  - application/mycoolapp (LAMP stack deployment)
  - Future applications requiring IaaS infrastructure

## Open Questions

1. **Module Versioning Strategy**: Should wrapper modules use Git tags, separate registry, or directory versioning?  
   *Recommendation*: Start with Git tags (e.g., `v1.0.0`), migrate to Azure Bicep Registry when stable

2. **Parameter Override Mechanism**: Should wrapper modules allow "break-glass" parameter overrides for exceptional cases?  
   *Recommendation*: No overrides initially; escalate exceptions through governance approval workflow (governance-001)

3. **PaaS Module Timeline**: When should we add PaaS wrapper modules (App Service, SQL Database)?  
   *Recommendation*: After mycoolapp migration completes and pattern is validated (Phase 3)

---

**Document Version**: 1.0.0-draft  
**Last Updated**: 2026-02-07  
**Owner**: Infrastructure Engineering Team  
**Status**: Draft (pending review and wrapper module implementation)
