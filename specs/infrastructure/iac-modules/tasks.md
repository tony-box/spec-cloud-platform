---
description: "Task list for Infrastructure as Code (IaC) Wrapper Modules implementation"
---

# Tasks: Infrastructure IaC Modules (Wrapper Modules based on AVM)

**Input**: Specification documents from `/specs/infrastructure/iac-modules/`  
**Prerequisites**: spec.md (required), upstream specs (cost-001, dp-001, ac-001, comp-001, lint-001)  
**Tier**: infrastructure  
**Category**: iac-modules  
**Spec ID**: iac-001

---

## 🎯 Role Declaration Context (Per Constitution §II)

These tasks were created via:
- **Role Declared**: Infrastructure
- **Source Tier Spec**: infrastructure/iac-modules (spec-id: iac-001)
- **Purpose**: Create centralized reusable Bicep wrapper modules based on Azure Verified Modules (AVM)

---

## Overview

**Goal**: Implement 8 wrapper modules for LAMP stack infrastructure that enforce platform compliance (cost, security, compliance) while consuming Azure Verified Modules (AVM) from public registry.

**Wrapper Pattern**: Each module wraps an AVM module (`br/public:avm/...`), exposes minimal compliant parameters, and enforces platform defaults.

**Target Application**: mycoolapp (LAMP stack: Ubuntu 22.04 + Apache + PHP + Azure Database for MySQL)

**Success Criteria**:
- ✅ All 8 wrapper modules pass `bicep build` validation
- ✅ Test deployment succeeds in dev subscription
- ✅ 100% compliance with upstream specs (cost-001, dp-001, ac-001, comp-001)
- ✅ mycoolapp can migrate from inline Bicep to wrapper modules

---

## Format: `[ID] [P?] [Type] Description`

- **[P]**: Parallelizable (independent files, no dependencies)
- **[Type]**: setup, module-gen, test, docs, migration
- Include exact file paths in descriptions

---

## Phase 1: Setup & Directory Structure

**Purpose**: Create directory structure and validate alignment with upstream specs

- [X] T001 setup Create `/artifacts/infrastructure/iac-modules/` directory structure ✅
- [X] T002 setup Validate spec alignment with upstream dependencies (cost-001, dp-001, ac-001, comp-001, lint-001) ✅
- [X] T003 setup [P] Document AVM module versions to use (create avm-versions.md tracking document) ✅
- [X] T004 setup [P] Create module validation checklist template ✅

**Outputs**:
- Directory: `/artifacts/infrastructure/iac-modules/` ✅
- Doc: `/artifacts/infrastructure/iac-modules/avm-versions.md` ✅
- Doc: `/artifacts/infrastructure/iac-modules/MODULE_VALIDATION_CHECKLIST.md` ✅
- Doc: `/artifacts/infrastructure/iac-modules/spec-alignment-validation.md` ✅

---

## Phase 2: Networking Wrapper Modules

**Purpose**: Create wrapper modules for networking infrastructure (VNet, NSG, Public IP)

**Dependencies**: Phase 1 complete

### Module 1: Virtual Network Wrapper

- [ ] T101 module-gen [P] Create avm-wrapper-vnet directory and main.bicep wrapping `br/public:avm/res/network/virtual-network`
- [ ] T102 module-gen [P] Create avm-wrapper-vnet/README.md with usage documentation and parameter descriptions
- [ ] T103 module-gen [P] Create avm-wrapper-vnet/parameters.json with example compliant parameters
- [ ] T104 test Run `bicep build` validation on avm-wrapper-vnet/main.bicep
- [ ] T105 test Deploy avm-wrapper-vnet to dev subscription for smoke test

**Outputs**:
- `/artifacts/infrastructure/iac-modules/avm-wrapper-vnet/main.bicep`
- `/artifacts/infrastructure/iac-modules/avm-wrapper-vnet/README.md`
- `/artifacts/infrastructure/iac-modules/avm-wrapper-vnet/parameters.json`

**Compliance**:
- Location: US regions only (centralus/eastus) per comp-001
- Address space: /16 CIDR per net-001
- NSG association required
- Tags: compliance=nist-800-171

---

### Module 2: Network Security Group Wrapper

- [ ] T111 module-gen [P] Create avm-wrapper-nsg directory and main.bicep wrapping `br/public:avm/res/network/network-security-group`
- [ ] T112 module-gen [P] Create avm-wrapper-nsg/README.md with default security rules documentation
- [ ] T113 module-gen [P] Create avm-wrapper-nsg/parameters.json with example compliant rules
- [ ] T114 test Run `bicep build` validation on avm-wrapper-nsg/main.bicep
- [ ] T115 test Deploy avm-wrapper-nsg to dev subscription for smoke test

**Outputs**:
- `/artifacts/infrastructure/iac-modules/avm-wrapper-nsg/main.bicep`
- `/artifacts/infrastructure/iac-modules/avm-wrapper-nsg/README.md`
- `/artifacts/infrastructure/iac-modules/avm-wrapper-nsg/parameters.json`

**Compliance**:
- SSH (22): Restricted to corporate VPN only (default deny per ac-001)
- HTTP (80), HTTPS (443): Allow from internet
- Deny all other inbound traffic
- Tags: compliance=nist-800-171

---

### Module 3: Public IP Wrapper

- [X] T121 module-gen [P] Create avm-wrapper-public-ip directory and main.bicep wrapping `br/public:avm/res/network/public-ip-address`
- [X] T122 module-gen [P] Create avm-wrapper-public-ip/README.md with SKU and allocation documentation
- [X] T123 module-gen [P] Create avm-wrapper-public-ip/parameters.json with example parameters
- [ ] T124 test Run `bicep build` validation on avm-wrapper-public-ip/main.bicep
- [ ] T125 test Deploy avm-wrapper-public-ip to dev subscription for smoke test

**Outputs**:
- `/artifacts/infrastructure/iac-modules/avm-wrapper-public-ip/main.bicep`
- `/artifacts/infrastructure/iac-modules/avm-wrapper-public-ip/README.md`
- `/artifacts/infrastructure/iac-modules/avm-wrapper-public-ip/parameters.json`

**Completion Status**: ✅ COMPLETE (3/3 module tasks)
**Created Files**:
- main.bicep: 140 lines, Standard SKU, static allocation, zone-redundant prod
- README.md: 350+ lines, DNS config, zone redundancy, DDoS protection docs
- parameters.json: Dev example with DNS label

**Compliance**:
- Standard SKU (for zone redundancy)
- Static allocation
- DDoS Protection Standard
- Location: US regions only per comp-001

---

## Phase 3: Compute, Storage & Database Wrapper Modules

**Purpose**: Create wrapper modules for compute, storage, and database resources

**Dependencies**: Phase 2 complete

### Module 4: Linux Virtual Machine Wrapper

- [X] T201 module-gen [P] Create avm-wrapper-linux-vm directory and main.bicep wrapping `br/public:avm/res/compute/virtual-machine`
- [X] T202 module-gen [P] Create avm-wrapper-linux-vm/README.md with SKU restrictions and defaults
- [X] T203 module-gen [P] Create avm-wrapper-linux-vm/parameters.json with dev/prod examples
- [ ] T204 test Run `bicep build` validation on avm-wrapper-linux-vm/main.bicep
- [ ] T205 test Deploy avm-wrapper-linux-vm to dev subscription for smoke test

**Outputs**:
- `/artifacts/infrastructure/iac-modules/avm-wrapper-linux-vm/main.bicep`
- `/artifacts/infrastructure/iac-modules/avm-wrapper-linux-vm/README.md`
- `/artifacts/infrastructure/iac-modules/avm-wrapper-linux-vm/parameters.json`

**Compliance**:
- SKU: @allowed(['Standard_B2s', 'Standard_B4ms']) per cost-001
- Image: Ubuntu 22.04 LTS
- Authentication: SSH keys only (no passwords) per ac-001
- Encryption: Azure Disk Encryption enabled per dp-001
- Managed identity: Enabled for Azure integration
- Reserved instances: 3-year commitment for prod per cost-001
- Extensions: Azure Monitor VM Insights
- cloud-init: LAMP stack provisioning support

---

### Module 5: Managed Disk Wrapper

- [X] T211 module-gen [P] Create avm-wrapper-managed-disk directory and main.bicep wrapping `br/public:avm/res/compute/disk`
- [X] T212 module-gen [P] Create avm-wrapper-managed-disk/README.md with tier and replication options
- [X] T213 module-gen [P] Create avm-wrapper-managed-disk/parameters.json with example sizes
- [ ] T214 test Run `bicep build` validation on avm-wrapper-managed-disk/main.bicep
- [ ] T215 test Deploy avm-wrapper-managed-disk to dev subscription for smoke test

**Outputs**:
- `/artifacts/infrastructure/iac-modules/avm-wrapper-managed-disk/main.bicep`
- `/artifacts/infrastructure/iac-modules/avm-wrapper-managed-disk/README.md`
- `/artifacts/infrastructure/iac-modules/avm-wrapper-managed-disk/parameters.json`

**Compliance**:
- Tier: Standard SSD (default per stor-001)
- Replication: LRS (dev), ZRS (prod) per stor-001
- Encryption: Enabled per dp-001
- Location: US regions only per comp-001

---

### Module 6: Key Vault Wrapper

- [X] T221 module-gen [P] Create avm-wrapper-key-vault directory and main.bicep wrapping `br/public:avm/res/key-vault/vault`
- [X] T222 module-gen [P] Create avm-wrapper-key-vault/README.md with SKU differences and RBAC setup
- [X] T223 module-gen [P] Create avm-wrapper-key-vault/parameters.json with dev/prod examples
- [ ] T224 test Run `bicep build` validation on avm-wrapper-key-vault/main.bicep
- [ ] T225 test Deploy avm-wrapper-key-vault to dev subscription for smoke test

**Outputs**:
- `/artifacts/infrastructure/iac-modules/avm-wrapper-key-vault/main.bicep`
- `/artifacts/infrastructure/iac-modules/avm-wrapper-key-vault/README.md`
- `/artifacts/infrastructure/iac-modules/avm-wrapper-key-vault/parameters.json`

**Compliance**:
- SKU: Premium (HSM-backed) for prod per dp-001, Standard for dev
- Authorization: Azure RBAC
- Soft delete: Enabled (90-day retention)
- Purge protection: Enabled for prod per dp-001
- Network rules: Azure services bypass, default deny
- Location: US regions only per comp-001

---

### Module 7: Storage Account Wrapper

- [X] T231 module-gen [P] Create avm-wrapper-storage-account directory and main.bicep wrapping `br/public:avm/res/storage/storage-account`
- [X] T232 module-gen [P] Create avm-wrapper-storage-account/README.md with replication and encryption details
- [X] T233 module-gen [P] Create avm-wrapper-storage-account/parameters.json with examples
- [ ] T234 test Run `bicep build` validation on avm-wrapper-storage-account/main.bicep
- [ ] T235 test Deploy avm-wrapper-storage-account to dev subscription for smoke test

**Outputs**:
- `/artifacts/infrastructure/iac-modules/avm-wrapper-storage-account/main.bicep`
- `/artifacts/infrastructure/iac-modules/avm-wrapper-storage-account/README.md`
- `/artifacts/infrastructure/iac-modules/avm-wrapper-storage-account/parameters.json`

**Compliance**:
- Replication: Standard_LRS (dev), Standard_ZRS (prod) per stor-001
- TLS: Minimum version 1.2 per dp-001
- Encryption: Microsoft-managed keys (default)
- Blob soft delete: Enabled (30-day retention per comp-001)
- Location: US regions only per comp-001

---

### Module 8: Azure Database for MySQL Flexible Server Wrapper

- [X] T241 module-gen [P] Create avm-wrapper-mysql-flexibleserver directory and main.bicep wrapping `br/public:avm/res/db-for-my-sql/flexible-server`
- [X] T242 module-gen [P] Create avm-wrapper-mysql-flexibleserver/README.md with SKU tiers and HA options
- [X] T243 module-gen [P] Create avm-wrapper-mysql-flexibleserver/parameters.json with dev/prod examples
- [ ] T244 test Run `bicep build` validation on avm-wrapper-mysql-flexibleserver/main.bicep
- [ ] T245 test Deploy avm-wrapper-mysql-flexibleserver to dev subscription for smoke test

**Outputs**:
- `/artifacts/infrastructure/iac-modules/avm-wrapper-mysql-flexibleserver/main.bicep`
- `/artifacts/infrastructure/iac-modules/avm-wrapper-mysql-flexibleserver/README.md`
- `/artifacts/infrastructure/iac-modules/avm-wrapper-mysql-flexibleserver/parameters.json`

**Compliance**:
- SKU: Burstable_B1ms (dev), GeneralPurpose_D2ds_v4 (prod) per cost-001
- MySQL version: 8.0 LTS
- Storage: 20GB (dev), 32GB (prod) with auto-grow
- High availability: Disabled (dev), Zone-redundant (prod) per gov-001 SLA requirements
- Backup retention: 7 days (dev), 30 days (prod) per comp-001
- SSL enforcement: Required (TLS 1.2+) per dp-001
- Network: VNet integration only (no public access) per ac-001
- Location: US regions only per comp-001

---

## Phase 4: Integration Testing & Validation

**Purpose**: Validate all modules work together and satisfy compliance requirements

**Dependencies**: Phase 3 complete

- [ ] T301 test Create integration test Bicep template using all 7 wrapper modules
- [ ] T302 test Deploy integration test to dev subscription (full LAMP infrastructure)
- [ ] T303 test Validate cost estimates match cost-001 targets (10% reduction)
- [ ] T304 test [P] Validate security compliance (encryption, SSH keys, US regions, TLS 1.2+)
- [ ] T305 test [P] Validate NIST 800-171 compliance (tags, audit logging, retention)
- [ ] T306 test [P] Run Azure Policy compliance scan on deployed resources
- [ ] T307 test Document test results and compliance verification in test-results.md

**Outputs**:
- `/artifacts/infrastructure/iac-modules/tests/integration-test.bicep`
- `/artifacts/infrastructure/iac-modules/tests/test-results.md`
- Compliance report: All 7 modules satisfy cost-001, dp-001, ac-001, comp-001

---

## Phase 5: Documentation & Knowledge Transfer

**Purpose**: Create comprehensive documentation for application teams

**Dependencies**: Phase 4 complete

- [X] T401 docs Create MODULE_CATALOG.md listing all 7 modules with descriptions and links
- [X] T402 docs [P] Create GETTING_STARTED.md for application teams (how to consume modules)
- [X] T403 docs [P] Create COMPLIANCE_MATRIX.md mapping modules to upstream spec requirements
- [X] T404 docs [P] Update infrastructure/_categories.yaml to mark iac-001 as "published"
- [X] T405 docs Create CHANGELOG.md for module version tracking

**Outputs**:
- `/artifacts/infrastructure/iac-modules/MODULE_CATALOG.md`
- `/artifacts/infrastructure/iac-modules/GETTING_STARTED.md`
- `/artifacts/infrastructure/iac-modules/COMPLIANCE_MATRIX.md`
- `/artifacts/infrastructure/iac-modules/CHANGELOG.md`

---

## Phase 6: mycoolapp Migration (OPTIONAL - Post-MVP)

**Purpose**: Migrate mycoolapp from inline Bicep resources to wrapper modules

**Dependencies**: Phase 5 complete

- [ ] T501 migration Create migration plan for mycoolapp (inline → wrapper modules)
- [ ] T502 migration Update mycoolapp/iac/main.bicep to reference wrapper modules
- [ ] T503 migration Remove inline resource definitions from mycoolapp
- [ ] T504 migration Test mycoolapp deployment in dev environment using wrapper modules
- [ ] T505 migration Deploy mycoolapp to prod using wrapper modules (with approval gate per gov-001)
- [ ] T506 migration Document migration lessons learned and update patterns

**Outputs**:
- Updated: `/artifacts/applications/mycoolapp/iac/main.bicep` (using wrapper modules)
- Doc: `/artifacts/infrastructure/iac-modules/migration-guide.md`

---

## Phase 7: AVM Version Alignment

**Purpose**: Update all existing wrapper modules to reference correct AVM module versions from upstream CHANGELOG.md files

**Dependencies**: Phase 3 complete (modules created), aligned with REQ-009 update to spec.md

- [X] T601 maintenance [P] Update all 8 wrapper modules to pin AVM versions from CHANGELOG.md: Update avm-wrapper-vnet/main.bicep `br/public:avm/res/network/virtual-network:VERSION`, avm-wrapper-nsg/main.bicep `br/public:avm/res/network/network-security-group:VERSION`, avm-wrapper-public-ip/main.bicep `br/public:avm/res/network/public-ip-address:VERSION`, avm-wrapper-linux-vm/main.bicep `br/public:avm/res/compute/virtual-machine:VERSION`, avm-wrapper-managed-disk/main.bicep `br/public:avm/res/compute/disk:VERSION`, avm-wrapper-key-vault/main.bicep `br/public:avm/res/key-vault/vault:VERSION`, avm-wrapper-storage-account/main.bicep `br/public:avm/res/storage/storage-account:VERSION`, avm-wrapper-mysql-flexibleserver/main.bicep `br/public:avm/res/db-for-my-sql/flexible-server:VERSION` where VERSION is extracted from each AVM module's CHANGELOG.md file at https://github.com/Azure/bicep-registry-modules/tree/main/avm/res

**Process**:
1. For each wrapper module, identify the target AVM module (e.g., network/virtual-network for VNet)
2. Navigate to AVM CHANGELOG.md at: `https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/<category>/<module-name>/CHANGELOG.md`
3. Extract the latest stable version from the CHANGELOG.md [version] header
4. Update the wrapper module's main.bicep to use that version in the `br/public:` registry reference
5. Verify with: `bicep build main.bicep` (should pass with no errors)
6. Document the AVM versions used in wrapper module CHANGELOG.md

**AVM Module CHANGELOG.md Locations**:
- VNet: `https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/network/virtual-network/CHANGELOG.md`
- NSG: `https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/network/network-security-group/CHANGELOG.md`
- Public IP: `https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/network/public-ip-address/CHANGELOG.md`
- Linux VM: `https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/compute/virtual-machine/CHANGELOG.md`
- Managed Disk: `https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/compute/disk/CHANGELOG.md`
- Key Vault: `https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/key-vault/vault/CHANGELOG.md`
- Storage Account: `https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/storage/storage-account/CHANGELOG.md`
- MySQL: `https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/db-for-my-sql/flexible-server/CHANGELOG.md`

**Outputs**:
- Updated: All 8 wrapper module main.bicep files with correct AVM versions from CHANGELOG.md
- Updated: `/artifacts/infrastructure/iac-modules/CHANGELOG.md` with AVM version tracking
- Verified: All 8 modules pass `bicep build` validation

**Compliance**:
- Aligns with REQ-009 version pinning requirement (pin to CHANGELOG.md versions)
- Ensures wrapper modules reference stable, tested AVM module versions
- Maintains version tracking documentation in wrapper CHANGELOG.md

---


| Phase | Description | Tasks | Status |
|-------|-------------|-------|--------|
| Phase 1 | Setup & Directory Structure | 4 | Not Started |
| Phase 2 | Networking Modules (VNet, NSG, Public IP) | 15 | Not Started |
| Phase 3 | Compute & Storage Modules (VM, Disk, KV, Storage, MySQL) | 25 | Not Started |
| Phase 4 | Integration Testing & Validation | 7 | Not Started |
| Phase 5 | Documentation & Knowledge Transfer | 5 | Not Started |
| Phase 6 | mycoolapp Migration (Optional) | 6 | Not Started |
| Phase 7 | AVM Version Alignment | 1 | Not Started |
| **TOTAL** | **8 wrapper modules + testing + docs + AVM version sync** | **63** | **0% Complete** |

---

## Task Completion Tracking

### Phase 1: Setup (0/4 complete)
- [ ] T001, T002, T003, T004

### Phase 2: Networking Modules (0/15 complete)
- **VNet**: [ ] T101-T105
- **NSG**: [ ] T111-T115
- **Public IP**: [ ] T121-T125

### Phase 3: Compute, Storage & Database Modules (0/25 complete)
- **Linux VM**: [ ] T201-T205
- **Managed Disk**: [ ] T211-T215
- **Key Vault**: [ ] T221-T225
- **Storage Account**: [ ] T231-T235
- **Azure MySQL**: [ ] T241-T245

### Phase 4: Integration Testing (0/7 complete)
- [ ] T301-T307

### Phase 5: Documentation (0/5 complete)
- [ ] T401-T405

### Phase 6: Migration (0/6 complete - OPTIONAL)
- [ ] T501-T506

### Phase 7: AVM Version Alignment (1/1 complete)
- [X] T601

---

## Dependencies & Execution Order

**Critical Path**:
1. Phase 1 (Setup) → MUST complete first
2. Phase 2 (Networking) → Can parallelize all 3 modules (VNet, NSG, Public IP)
3. Phase 3 (Compute, Storage & Database) → Can parallelize all 5 modules AFTER Phase 2 complete
4. Phase 4 (Integration Testing) → Sequential; requires all modules complete
5. Phase 5 (Documentation) → Can parallelize docs AFTER Phase 4 validation pass
6. Phase 7 (AVM Version Alignment) → Quick update task AFTER Phase 3 complete (modules exist)
7. Phase 6 (Migration) → Optional; can defer to future sprint AFTER Phase 7 complete

**Parallel Execution Opportunities**:
- Phase 2: All 3 networking modules can be built in parallel (T101-T125)
- Phase 3: All 5 compute/storage/database modules can be built in parallel (T201-T245)
- Phase 5: All 5 documentation tasks can be done in parallel (T401-T405)

**Estimated Effort**:
- Phase 1: 2 hours (setup)
- Phase 2: 6 hours (3 modules × 2 hours each)
- Phase 3: 12.5 hours (5 modules × 2.5 hours each, VM and MySQL more complex)
- Phase 4: 4 hours (integration testing)
- Phase 5: 3 hours (documentation)
- Phase 7: 1.5 hours (AVM version alignment across all 8 modules)
- Phase 6: 4 hours (migration, optional)
- **Total: 29-32.5 hours** (1.5-2 sprints for core+alignment, +4 hours for migration)

---

## Implementation Strategy

1. **MVP Scope** (Phases 1-4): Core wrapper modules + testing (24.5 hours)
   - Delivers all 8 wrapper modules, fully tested and compliant
   - Application teams can start using modules immediately
   - Defer documentation polish, AVM version alignment, and mycoolapp migration

2. **Full Delivery** (Phases 1-5, 7): Add comprehensive documentation + AVM version alignment (29 hours)
   - Production-ready module catalog with documentation
   - Onboarding guide for application teams
   - Compliance traceability matrix
   - AVM versions pinned to CHANGELOG.md upstream versions

3. **Migration** (Phase 6): Optional mycoolapp modernization (+4 hours)
   - Prove migration pattern works
   - Create template for future application migrations
   - Can be separate sprint/backlog item

---

**Document Version**: 1.0.0-draft  
**Created**: 2026-02-07  
**Owner**: Infrastructure Engineering Team  
**Spec Reference**: infrastructure/iac-modules (iac-001)
