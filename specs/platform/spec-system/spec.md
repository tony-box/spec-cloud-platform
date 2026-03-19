---
# YAML Frontmatter - Category-Based Spec System
tier: platform
category: spec-system
spec-id: spec
version: 1.0.0-draft
status: draft
created: 2026-02-07
description: "Meta-specifications defining spec format, versioning, hierarchy, precedence rules, tooling"
is-meta: true

# Version compliance
compliance-state: current
version-history:
  - version: "1.0.0-draft"
    date: "2026-02-07"
    git-tag: spec/spec/1.0.0-draft
    summary: "Initial draft. Meta-specification framework defining tier hierarchy, category structure, frontmatter schema, version-history tracking, git tag convention, validation tooling, and full spec lifecycle workflows (create, maintain, upgrade, deprecate)."

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
**Spec ID**: spec  
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
- **Explicit hierarchy**: platform > business > security > infrastructure > devops > application
- **Category-aware precedence**: Within tiers, categories have documented precedence rules
- **Scalability**: Add new categories without restructuring existing ones

**Impact**: Platform can scale from 5 monolithic specs to 18+ granular category specs with clear precedence and conflict resolution.

## Spec System Architecture

### Tier Hierarchy (6 tiers)

**Tier precedence** (highest to lowest):
1. **platform** (priority 0): Spec-System, IaC-Linting, Artifact-Org, Policy-as-Code
2. **business** (priority 1): Cost, Governance, Compliance-Framework
3. **security** (priority 2): Data-Protection, Access-Control, Audit-Logging
4. **infrastructure** (priority 3): Compute, Networking, Storage, CI/CD-Pipeline, IaC-Modules
5. **devops** (priority 4): Deployment-Automation, Observability, Environment-Management, CI/CD-Orchestration
6. **application** (priority 5): Individual applications adopting upstream specs

**Tier precedence rule**: Higher tier ALWAYS wins unless explicit exception documented. Platform tier is FOUNDATIONAL and cannot be overridden.

### Category Structure (18 categories across 5 content tiers)

**Business Tier (3 categories)**:
- **compliance-framework** (comp): Regulatory requirements, standards, data residency
- **governance** (gov): Approval workflows, SLAs, change management
- **cost** (cost): Budget targets, cost optimization, spending constraints

**Security Tier (3 categories)**:
- **data-protection** (dp): Encryption, key management, TLS requirements
- **access-control** (ac): Authentication, authorization, RBAC, SSH keys
- **audit-logging** (audit): Audit trails, monitoring, log retention

**Infrastructure Tier (5 categories)**:
- **compute** (compute): VM SKUs, autoscaling, reserved instances
- **networking** (net): VNets, NSGs, load balancing, DNS
- **storage** (stor): Disk types, replication, backup, retention
- **cicd-pipeline** (cicd): Deployment automation, approval gates, rollback
- **iac-modules** (iac): Centralized reusable IaC wrapper modules

**DevOps Tier (4 categories)**:
- **deployment-automation** (deploy): Deployment patterns, release strategies
- **observability** (obs): Logging, metrics, tracing, alerting
- **environment-management** (env): Environment definitions, secrets management
- **ci-cd-orchestration** (cicd-orch): CI/CD workflow orchestration

**Platform Tier (4 categories)**:
- **spec-system** (spec): THIS SPEC - meta-specification framework
- **iac-linting** (lint): Code quality standards (Bicep, PowerShell, YAML)
- **artifact-org** (artifact): Directory structure, naming conventions
- **policy-as-code** (pac): Azure Policy definitions, enforcement, remediation

**Application Tier (registry)**:
- Individual applications (e.g., mycoolapp) that adopt upstream category specs

### Frontmatter Structure

All category specs MUST include YAML frontmatter with these fields:

```yaml
---
# Required fields
tier: platform | business | security | infrastructure | devops | application
category: cost | governance | ... (see category list above)
spec-id: unique-id (e.g., cost, dp)
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
    spec-id: cost
    reason: "Explanation of dependency"

# Precedence rules
precedence:
  wins-over:
    - tier: infrastructure
      category: compute
      spec-id: compute
      reason: "Explanation of why this spec wins"
  
  loses-to:
    - tier: security
      category: data-protection
      spec-id: dp
      reason: "Explanation of why this spec loses"
  
  overrides:
    - tier: business
      category: cost
      spec-id: cost
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
- If specs are at different tiers: Higher tier wins (platform > business > security > infrastructure > devops > application)
- Platform tier is FOUNDATIONAL and cannot be overridden by any other tier
- Example: platform/iac-linting beats business/cost; business/cost beats infrastructure/compute

**Step 2: Check explicit overrides**
- If winning spec has `precedence.overrides` targeting losing spec: Override wins
- Platform tier specs cannot be overridden (technical standards are non-negotiable)
- Example: security/data-protection overrides business/cost (encryption non-negotiable)

**Step 3: Check category precedence within tier**
- Within same tier, use category precedence rules (documented in tier _categories.yaml)
- Example: platform/spec-system and platform/iac-linting are roughly equal priority
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

---

## Spec Lifecycle Workflows

### Creating a New Category Spec

Use this workflow when introducing a brand-new spec for a category that does not yet exist.

**Step 1 — Verify the category doesn't already exist**
```
grep -r "category: <name>" specs/              # check no collision
cat specs/<tier>/_categories.yaml             # confirm category slot is free
```

**Step 2 — Register the category in the tier index**  
Edit `specs/<tier>/_categories.yaml` — add a new entry with `spec-id`, `category`, `status: draft`, and a one-line `description`.  
Edit `specs/specs.yaml` — add the new spec-id to the `categories` map under the appropriate tier with `version: "1.0.0-draft"` and `status: draft`. This makes it the authoritative version record.

**Step 3 — Scaffold the spec file**  
```
mkdir specs/<tier>/<category>
cp .specify/templates/spec-template.md specs/<tier>/<category>/spec.md
```

**Step 4 — Fill in frontmatter**
- `tier`, `category`, `spec-id` (unique, format: `<abbrev>-001`)
- `version: "1.0.0-draft"`, `status: draft`, `created: <today>`
- `compliance-state: current`
- `version-history`: one entry with `version: "1.0.0-draft"`, `date: <today>`, `git-tag: spec/<spec-id>/1.0.0-draft`, and a summary
- `depends-on`: all upstream specs this category must comply with, each with a `version:` pin

**Step 5 — Write spec content**  
Follow the template structure: Executive Summary, User Scenarios, Requirements, Key Entities, Constraints.  
Every constraint that comes from an upstream spec MUST cite the upstream `spec-id` and version it was written against.

**Step 6 — Validate**
```powershell
.specify/scripts/powershell/validate-spec-versions.ps1
```
The script must exit 0 before a PR can be opened.

**Step 7 — Create the git tag**
```
git tag spec/<spec-id>/1.0.0-draft
```
The tag points to the commit that introduces the spec. Run `validate-spec-versions.ps1` again after tagging — it should now pass the tag-resolution check with no warnings.

**Step 8 — Open PR**  
PR description must reference the new `spec-id`, the tier it belongs to, and any upstream specs listed in `depends-on`.

---

### Maintaining an Existing Spec (patch / minor version bump)

Use this workflow when making non-breaking changes (bug fixes, clarifications, additive requirements).

**Determine the bump type** using semver rules:
- `patch` (x.y.**Z**): Corrects errors, clarifies ambiguity — no behavioral change for downstream specs
- `minor` (x.**Y**.0): Adds new requirements that downstream CAN adopt incrementally — does not invalidate existing downstream implementations

**Step 1 — Update the spec content**  
Make the change in `specs/<tier>/<category>/spec.md`. Update `last-updated:` in frontmatter.

**Step 2 — Bump `version:` in frontmatter**  
e.g., `1.0.0-draft` → `1.0.1` (patch) or `1.1.0` (minor).

**Step 3 — Prepend a version-history entry** (newest first)
```yaml
version-history:
  - version: "1.1.0"
    date: "<today>"
    git-tag: spec/<spec-id>/1.1.0
    summary: "Added X requirement. Downstream specs that depend on this may adopt incrementally."
  - version: "1.0.0-draft"   # previous entry stays
    ...
```

**Step 4 — Update `specs.yaml` authoritative registry**  
Change the `version:` for this spec-id in the `categories` map to the new version. This is what downstream `validate-spec-versions.ps1` compares against.

**Step 5 — Validate**
```powershell
.specify/scripts/powershell/validate-spec-versions.ps1
```
For minor bumps, downstream specs pinned to the old minor will show `[WARNING]` — not blocking, but owners should plan upgrades. For patch bumps, downstream specs will show `[INFO]`.

**Step 6 — Create the git tag and commit**
```
git tag spec/<spec-id>/<new-version>
git push && git push --tags
```

**Step 7 — Notify downstream owners**  
Identify all specs whose `depends-on` pins this spec-id. Open a tracking issue or PR comment listing the new version and linking to the `version-history` summary. Minor bumps are advisory; downstream specs remain compliant.

---

### Upgrading a Spec (major version bump — breaking)

Use this workflow when making a breaking change: changing units, removing fields, restructuring constraints downstream MUST implement differently.

> **Semver is the breaking-change flag** — a major bump (`X.0.0`) signals breaking. The `version-history` summary explains what broke and why. No separate `breaking:` field is needed.

**Step 1 — Write the spec changes and assess blast radius**  
Before bumping, identify every spec with a `depends-on` pin to this spec-id. Each one will show `[ERROR]` in `validate-spec-versions.ps1` after the bump. That's the list of specs that MUST update.

**Step 2 — Bump `version:` to next major**  
e.g., `2.0.0` → `3.0.0`.

**Step 3 — Prepend a version-history entry with a clear breaking-change summary**
```yaml
version-history:
  - version: "3.0.0"
    date: "<today>"
    git-tag: spec/<spec-id>/3.0.0
    summary: >
      Breaking: <what changed and why>.
      Downstream specs must: <exact remediation steps>.
      Specs pinned to 2.x remain valid for existing deployments but cannot
      adopt new capabilities until upgraded.
  - version: "2.0.0"
    ...
```

**Step 4 — Update `specs.yaml` authoritative registry**  
Change the `version:` to the new major version.

**Step 5 — Run the validator to see the full blast-radius list**
```powershell
.specify/scripts/powershell/validate-spec-versions.ps1
```
All downstream specs pinned to the old major will now show `[ERROR]`. This is intentional — they are lagging and blocking.

**Step 6 — Update each downstream spec**  
For each spec showing `[ERROR]`, the downstream author must:
1. Update `depends-on[].version` pin to the new major version
2. Set `compliance-state: current` (or `pending-upgrade` if still in progress)
3. Bump their own spec version (at least a minor bump) to indicate adoption
4. Prepend a `version-history` entry noting the upstream upgrade
5. Run `validate-spec-versions.ps1` to confirm the error clears

**Step 7 — Create the git tag and commit**
```
git tag spec/<spec-id>/<new-major-version>
git push && git push --tags
```

**Step 8 — Open a coordinated PR**  
The PR should include: the upstream spec change, all downstream spec updates, and the new git tag. All `[ERROR]` items must be resolved before merge.

---

### Deprecating a Spec

Use this workflow when a category is being retired or absorbed into another spec.

**Step 1 — Mark `status: deprecated` in frontmatter**  
Set `last-updated` to today.

**Step 2 — Add a final version-history entry**
```yaml
version-history:
  - version: "<final-version>"
    date: "<today>"
    git-tag: spec/<spec-id>/<final-version>
    summary: "Deprecated. Replaced by <new-spec-id>. Downstream specs should migrate depends-on to <new-spec-id>."
```

**Step 3 — Update `specs.yaml`**  
Change `status: deprecated` in the categories map. The version entry remains for historical resolution.

**Step 4 — Notify and migrate downstream specs**  
All specs with `depends-on` pins to this spec-id must update to the replacement spec-id and remove (or comment out) the deprecated dependency.

**Step 5 — Tag and push**
```
git tag spec/<spec-id>/deprecated
git push && git push --tags
```
- `specs-discovery.ps1`: Query specs by tier, category, dependency

## Spec System Files

**Root Manifest**:
- `specs/specs.yaml`: Defines all tiers, categories, precedence rules, conflicts

**Category Indexes**:
- `specs/platform/_categories.yaml`: Platform tier categories
- `specs/business/_categories.yaml`: Business tier categories
- `specs/security/_categories.yaml`: Security tier categories
- `specs/infrastructure/_categories.yaml`: Infrastructure tier categories
- `specs/devops/_categories.yaml`: DevOps tier categories
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

- **SC-001**: All 18 category specs created with valid frontmatter (4 Platform, 3 Business, 3 Security, 5 Infrastructure, 4 DevOps)
- **SC-002**: Precedence rules documented for all major conflicts with Platform tier foundational
- **SC-003**: Validation tooling passes on all specs (zero errors)
- **SC-004**: Hierarchy documentation complete with 10+ examples including DevOps tier
- **SC-005**: All applications migrated to reference category specs including DevOps dependencies

## Change Log

| Version | Date | Change | Approved By |
|---------|------|--------|------------|
| 1.0.0-draft | 2026-02-07 | Initial meta-spec for category-based system | Platform Team |

---

**Spec Version**: 1.0.0-draft  
**Created**: 2026-02-07  
**Is Meta**: true  
**Defines**: The entire category-based spec system
