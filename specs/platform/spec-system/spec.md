---
# YAML Frontmatter - Category-Based Spec System
tier: platform
category: spec-system
spec-id: spec-001
version: 1.0.0-draft
status: draft
created: 2026-02-07
description: "Meta-specifications defining spec format, versioning, hierarchy, precedence rules, tooling"
is-meta: true

# Dependencies
depends-on: []

# Precedence rules
precedence:
  note: "Spec-System is meta (specs about specs); defines framework for all category specs"

# Relationships
defines:
  - "All category-based spec frontmatter structure"
  - "Tier hierarchy and precedence rules"
  - "Category definitions and boundaries"
  - "Validation and discovery tooling requirements"
---

# Specification: Category-Based Specification System

**Tier**: platform  
**Category**: spec-system  
**Spec ID**: spec-001  
**Created**: 2026-02-07  
**Status**: Draft  
**Is Meta**: true (this spec defines the spec system itself)

## Executive Summary

**Problem**: The original flat-hierarchical spec structure (business/001, security/001, etc.) cannot support:
- Granular versioning (change cost without touching governance)
- Independent category decisions (cost vs governance vs compliance)
- Scalable spec management (adding new categories requires restructuring)
- Explicit conflict resolution (which spec wins when they conflict?)

**Solution**: Category-based spec system with tier-specific categories enabling:
- **Granular versioning**: Change business/cost without affecting business/governance
- **Explicit hierarchy**: business > security > infrastructure > platform > application
- **Category-aware precedence**: Within tiers, categories have documented precedence rules
- **Scalability**: Add new categories without restructuring existing ones

**Impact**: Platform can scale from 5 monolithic specs to 15+ granular category specs with clear precedence and conflict resolution.

## Spec System Architecture

### Tier Hierarchy (5 tiers)

**Tier precedence** (highest to lowest):
1. **business** (priority 0): Cost, Governance, Compliance-Framework
2. **security** (priority 1): Data-Protection, Access-Control, Audit-Logging
3. **infrastructure** (priority 2): Compute, Networking, Storage, CI/CD-Pipeline
4. **platform** (priority 3): Spec-System, IaC-Linting, Artifact-Org, Policy-as-Code
5. **application** (priority 4): Individual applications adopting upstream specs

**Tier precedence rule**: Higher tier ALWAYS wins unless explicit exception documented.

### Category Structure (14 categories across 4 tiers)

**Business Tier (3 categories)**:
- **compliance-framework** (comp-001): Regulatory requirements, standards, data residency
- **governance** (gov-001): Approval workflows, SLAs, change management
- **cost** (cost-001): Budget targets, cost optimization, spending constraints

**Security Tier (3 categories)**:
- **data-protection** (dp-001): Encryption, key management, TLS requirements
- **access-control** (ac-001): Authentication, authorization, RBAC, SSH keys
- **audit-logging** (audit-001): Audit trails, monitoring, log retention

**Infrastructure Tier (4 categories)**:
- **compute** (compute-001): VM SKUs, autoscaling, reserved instances
- **networking** (net-001): VNets, NSGs, load balancing, DNS
- **storage** (stor-001): Disk types, replication, backup, retention
- **cicd-pipeline** (cicd-001): Deployment automation, approval gates, rollback

**Platform Tier (4 categories)**:
- **spec-system** (spec-001): THIS SPEC - meta-specification framework
- **iac-linting** (lint-001): Code quality standards (Bicep, PowerShell, YAML)
- **artifact-org** (artifact-001): Directory structure, naming conventions
- **policy-as-code** (pac-001): Azure Policy definitions, enforcement, remediation

**Application Tier (registry)**:
- Individual applications (e.g., mycoolapp) that adopt upstream category specs

### Frontmatter Structure

All category specs MUST include YAML frontmatter with these fields:

```yaml
---
# Required fields
tier: business | security | infrastructure | platform | application
category: cost | governance | ... (see category list above)
spec-id: unique-id (e.g., cost-001, dp-001)
version: semver (e.g., 1.0.0, 1.0.0-draft)
status: draft | published | deprecated
created: YYYY-MM-DD
description: "Brief description (1 sentence)"

# Optional fields
last-updated: YYYY-MM-DD
is-meta: true (for spec-system only)

# Dependencies
depends-on:
  - tier: business
    category: cost
    spec-id: cost-001
    reason: "Explanation of dependency"

# Precedence rules
precedence:
  wins-over:
    - tier: infrastructure
      category: compute
      spec-id: compute-001
      reason: "Explanation of why this spec wins"
  
  loses-to:
    - tier: security
      category: data-protection
      spec-id: dp-001
      reason: "Explanation of why this spec loses"
  
  overrides:
    - tier: business
      category: cost
      spec-id: cost-001
      reason: "Security overrides cost for encryption"

# Relationships
adhered-by:
  - app-id: mycoolapp
    version: "1.0.0"
    compliance: "Compliance status or notes"
---
```

### Precedence Resolution Logic

**Step 1: Check tier precedence**
- If specs are at different tiers: Higher tier wins (business > security > infrastructure > platform > application)
- Example: business/cost beats infrastructure/compute (business tier > infrastructure tier)

**Step 2: Check explicit overrides**
- If winning spec has `precedence.overrides` targeting losing spec: Override wins
- Example: security/data-protection overrides business/cost (encryption non-negotiable)

**Step 3: Check category precedence within tier**
- Within same tier, use category precedence rules (documented in tier _categories.yaml)
- Example: business/compliance-framework > business/governance > business/cost

**Step 4: Check dependency order**
- If spec A depends-on spec B: B must be satisfied before A
- Dependencies form directed acyclic graph (DAG) - no circular dependencies

**Step 5: If still ambiguous**
- Escalate to manual review (document exception in both specs)
- Update precedence rules to prevent future ambiguity

### Validation Rules

**Required Validations**:
- All specs have valid frontmatter (required fields present)
- All `depends-on` references are resolvable (target specs exist)
- No circular dependencies (DAG validation)
- All `spec-id` values are unique
- Version format is semver (X.Y.Z with optional -draft|-alpha|-beta|-rc)
- All tier/category combinations are valid (per specs.yaml)

**Tooling**:
- `specs-validate.ps1`: Validate all specs in tree
- `specs-hierarchy.ps1`: Resolve precedence between two specs
- `specs-discovery.ps1`: Query specs by tier, category, dependency

## Spec System Files

**Root Manifest**:
- `specs/specs.yaml`: Defines all tiers, categories, precedence rules, conflicts

**Category Indexes**:
- `specs/business/_categories.yaml`: Business tier categories
- `specs/security/_categories.yaml`: Security tier categories
- `specs/infrastructure/_categories.yaml`: Infrastructure tier categories  
- `specs/platform/_categories.yaml`: Platform tier categories
- `specs/application/_index.yaml`: Application registry

**Category Specs**:
- `specs/<tier>/<category>/spec.md`: Individual category specifications
- Example: `specs/business/cost/spec.md`

**Documentation**:
- `specs/HIERARCHY.md`: Explains precedence rules with examples
- `specs/CATEGORY_SYSTEM_README.md`: Getting started guide
- `specs/MIGRATION_GUIDE.md`: Migration from old to new structure

**Tooling**:
- `specs/specs-validate.ps1`: Validation script
- `specs/specs-hierarchy.ps1`: Precedence resolution script
- `specs/specs-discovery.ps1`: Discovery/query script

## Success Criteria

- **SC-001**: All 14 category specs created with valid frontmatter
- **SC-002**: Precedence rules documented for all 7 major conflicts
- **SC-003**: Validation tooling passes on all specs (zero errors)
- **SC-004**: Hierarchy documentation complete with 10+ examples
- **SC-005**: All applications migrated to reference category specs

## Change Log

| Version | Date | Change | Approved By |
|---------|------|--------|------------|
| 1.0.0-draft | 2026-02-07 | Initial meta-spec for category-based system | Platform Team |

---

**Spec Version**: 1.0.0-draft  
**Created**: 2026-02-07  
**Is Meta**: true  
**Defines**: The entire category-based spec system
