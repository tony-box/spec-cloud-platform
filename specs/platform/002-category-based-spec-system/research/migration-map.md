# Phase 0 Research: Migration Map

**Task**: T005 - Map existing specs to proposed categories  
**Created**: 2026-02-07  
**Status**: Research Document

---

## Overview

This document maps existing spec files to proposed category structure, showing the migration path from current state to new category-based organization.

---

## Migration Mappings

### Business Tier

| Current | New Category | New Location | Notes |
|---------|---|---|---|
| business/001-cost-reduction-targets/ | Cost | business/cost/ | Direct migration; add frontmatter |
| *(none)* | Governance | business/governance/ | **NEW**: Extract governance requirements |
| *(none)* | Compliance-Framework | business/compliance-framework/ | **NEW**: Extract strategic compliance |

**Details**:
- **business/001-cost-reduction-targets** → **business/cost**
  - Current: specs/business/001-cost-reduction-targets/spec.md
  - Future: specs/business/cost/spec.md
  - Action: Migrate as-is, add frontmatter (tier: business, category: cost, spec-id: cost-001, version: 1.0.0)
  - Archive old: specs/_archive/business/001-cost-reduction-targets/

- **business/governance** (NEW)
  - Current: Governance requirements scattered in business/001
  - Future: specs/business/governance/spec.md
  - Action: Create new spec with governance content (approval workflows, SLAs, etc.)
  - Frontmatter: tier: business, category: governance, spec-id: gov-001, version: 1.0.0-draft

- **business/compliance-framework** (NEW)
  - Current: Compliance requirements currently in business/001 or business/security/001
  - Future: specs/business/compliance-framework/spec.md
  - Action: Create new spec for strategic compliance (NIST 800-171 applicability, regulations)
  - Frontmatter: tier: business, category: compliance-framework, spec-id: comp-001, version: 1.0.0-draft

---

### Security Tier

| Current | New Category | New Location | Notes |
|---------|---|---|---|
| security/001-cost-constrained-policies/ | Data-Protection (partial) | security/data-protection/ | SPLIT: Extract data protection parts |
| *(scattered in 001)* | Access-Control | security/access-control/ | **NEW**: Centralize access control |
| *(scattered in 001)* | Audit-Logging | security/audit-logging/ | **NEW**: Centralize audit/monitoring |

**Details**:
- **security/data-protection** (MIGRATED + EXTRACTED)
  - Current: specs/security/001-cost-constrained-policies/spec.md (contains multiple concerns)
  - Future: specs/security/data-protection/spec.md
  - Action: Extract data protection requirements (encryption, TLS, key mgmt) from security/001
  - Frontmatter: tier: security, category: data-protection, spec-id: dp-001, version: 1.0.0
  - Archive old: specs/_archive/security/001-cost-constrained-policies/

- **security/access-control** (NEW)
  - Current: Access control scattered in security/001
  - Future: specs/security/access-control/spec.md
  - Action: Create new spec consolidating access control (SSH keys, RBAC, MFA)
  - Frontmatter: tier: security, category: access-control, spec-id: ac-001, version: 1.0.0-draft

- **security/audit-logging** (NEW)
  - Current: Audit requirements scattered in security/001
  - Future: specs/security/audit-logging/spec.md
  - Action: Create new spec for audit and logging (auditd, Azure Monitor, retention)
  - Frontmatter: tier: security, category: audit-logging, spec-id: audit-001, version: 1.0.0-draft

---

### Infrastructure Tier

| Current | New Category | New Location | Notes |
|---------|---|---|---|
| infrastructure/001-cost-optimized-compute-modules/ | Compute | infrastructure/compute/ | SPLIT: Extract compute parts |
| *(none)* | Networking | infrastructure/networking/ | **NEW**: Centralize networking |
| *(none)* | Storage | infrastructure/storage/ | **NEW**: Centralize storage |
| *(none)* | CI/CD-Pipeline | infrastructure/cicd-pipeline/ | **NEW**: Centralize deployment automation |

**Details**:
- **infrastructure/compute** (MIGRATED + EXTRACTED)
  - Current: specs/infrastructure/001-cost-optimized-compute-modules/spec.md (covers compute + modules)
  - Future: specs/infrastructure/compute/spec.md
  - Action: Extract compute specifications (SKUs, autoscaling, reserved instances)
  - Frontmatter: tier: infrastructure, category: compute, spec-id: compute-001, version: 1.0.0
  - Archive old: specs/_archive/infrastructure/001-cost-optimized-compute-modules/

- **infrastructure/networking** (NEW)
  - Current: Networking requirements in infrastructure/001
  - Future: specs/infrastructure/networking/spec.md
  - Action: Create new spec for networking (VNets, NSGs, load balancing, connectivity)
  - Frontmatter: tier: infrastructure, category: networking, spec-id: net-001, version: 1.0.0-draft

- **infrastructure/storage** (NEW)
  - Current: Storage requirements in infrastructure/001
  - Future: specs/infrastructure/storage/spec.md
  - Action: Create new spec for storage (disk types, replication, backup)
  - Frontmatter: tier: infrastructure, category: storage, spec-id: stor-001, version: 1.0.0-draft

- **infrastructure/cicd-pipeline** (NEW)
  - Current: CI/CD scattered in platform/001
  - Future: specs/infrastructure/cicd-pipeline/spec.md
  - Action: Create new spec for deployment automation, testing, validation
  - Frontmatter: tier: infrastructure, category: cicd-pipeline, spec-id: cicd-001, version: 1.0.0-draft

---

### Platform Tier

| Current | New Category | New Location | Notes |
|---------|---|---|---|
| platform/001-application-artifact-organization/ | Artifact-Org | platform/artifact-org/ | Direct migration; add frontmatter |
| *(none)* | IaC-Linting | platform/iac-linting/ | **NEW**: Code quality standards |
| *(none)* | Policy-as-Code | platform/policy-as-code/ | **NEW**: Governance automation |
| *(none)* | Spec-System | platform/spec-system/ | **NEW**: Meta-specifications |

**Details**:
- **platform/artifact-org** (MIGRATED)
  - Current: specs/platform/001-application-artifact-organization/spec.md
  - Future: specs/platform/artifact-org/spec.md
  - Action: Migrate as-is, add frontmatter (tier: platform, category: artifact-org, spec-id: artifact-001, version: 1.0.0)
  - Archive old: specs/_archive/platform/001-application-artifact-organization/

- **platform/iac-linting** (NEW)
  - Current: IaC linting currently in platform/001 (partially)
  - Future: specs/platform/iac-linting/spec.md
  - Action: Create new spec for Bicep, Terraform, PowerShell linting standards
  - Frontmatter: tier: platform, category: iac-linting, spec-id: lint-001, version: 1.0.0-draft

- **platform/policy-as-code** (NEW)
  - Current: Azure Policy mentioned in infrastructure/001
  - Future: specs/platform/policy-as-code/spec.md
  - Action: Create new spec for policy definitions, enforcement, remediation
  - Frontmatter: tier: platform, category: policy-as-code, spec-id: pac-001, version: 1.0.0-draft

- **platform/spec-system** (NEW)
  - Current: No existing spec (this is the meta-spec we're creating)
  - Future: specs/platform/spec-system/spec.md
  - Action: Create meta-specification for spec format, versioning, hierarchy, precedence
  - Frontmatter: tier: platform, category: spec-system, spec-id: spec-001, version: 1.0.0-draft

---

### Application Tier

| Current | New Category | New Location | Notes |
|---------|---|---|---|
| application/mycoolapp/ | (Application spec) | specs/application/mycoolapp/ | Update references; add adheres-to |

**Details**:
- **application/mycoolapp/spec.md** (UPDATED NOT MIGRATED)
  - Current: specs/application/mycoolapp/spec.md
  - Future: specs/application/mycoolapp/spec.md (same location)
  - Action: Update to reference upstream category specs
  - Add `adheres-to` field listing:
    - business/cost (must reduce costs by 10%)
    - security/data-protection (TLS 1.2+, AES-256)
    - security/access-control (SSH keys only)
    - security/audit-logging (auditd, Azure Monitor)
    - infrastructure/compute (Standard_B2s/B4ms)
    - infrastructure/networking (NSG on 22,80,443)
    - infrastructure/storage (StandardSSD replication)
    - platform/artifact-org (follows iac/, scripts/, docs/ structure)

---

## Summary Statistics

| Tier | Current Specs | New Categories | New Specs | Split Specs | Archive |
|---|---|---|---|---|---|
| Business | 1 | 3 | 2 (new) | 0 | 0 |
| Security | 1 | 3 | 2 (new) | 1 (split) | 1 |
| Infrastructure | 1 | 4 | 3 (new) | 1 (split) | 1 |
| Platform | 1 | 4 | 3 (new) | 0 | 1 |
| Application | 1 | - | 0 (update only) | 0 | 0 |
| **TOTAL** | **5** | **14** | **10 new** | **2 split** | **3 archived** |

---

## Migration Plan Steps

1. **Phase 1**: Create manifests (specs.yaml, _categories.yaml for each tier)
2. **Phase 2a**: Migrate existing specs (copy + add frontmatter, then archive old)
3. **Phase 2b**: Create new specs from split content
4. **Phase 3**: Validate all references and dependencies
5. **Phase 4**: Test and rollout

---

## Validation

- [X] All 5 existing specs have migration path
- [X] 10 new categories covered by new specs
- [X] 2 specs require splitting (security/001, infrastructure/001)
- [X] Application mycoolapp will reference 8+ upstream categories
- [X] Total: 5 existing → 15 new (3x expansion due to specialization)

---

## Risks & Mitigation

| Risk | Impact | Mitigation |
|---|---|---|
| Lost content during split | Data loss | Review split content with domain experts |
| Circular dependencies | Validation fails | Design dependencies during Phase 0 |
| References not updated | Broken links | Central validation script (Phase 3) |

---

## Next Steps

1. Validate migration plan with stakeholders
2. Execute Phase 1 (create manifests)
3. Execute Phase 2 (migrate and create new specs)
4. Run T006 (Conflict Analysis) in parallel with migration
