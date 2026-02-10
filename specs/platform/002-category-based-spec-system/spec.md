# Specification: Category-Based Spec System with Hierarchical Precedence

**Tier**: platform  
**Spec ID**: 002-category-based-spec-system  
**Created**: 2026-02-07  
**Status**: Draft  
**Input**: Platform engineer request: "Enable granular, versioned specs across tiers with category-aware hierarchy"

---

## Spec Source & Hierarchy

**Parent Tier Specs**:
- None (Platform tier is foundational; no parent tiers)
- Note: platform/001-application-artifact-organization provides artifact structure context

**Derived Downstream Specs**:
- (Future) platform/003-spec-validation-pipeline (validates spec hierarchy and dependencies)
- (Future) platform/004-spec-discovery-api (enables tools to query spec structure)

---

## User Scenarios & Testing

### User Story 1 - Platform Engineer Manages Granular Specs (Priority: P1)

Platform engineer needs: *"I want to organize specs by category (e.g., business/cost, infrastructure/compute) so I can version and change individual category specs independently without affecting others."*

**Why this priority**: Enables scalability of spec management; allows different teams to own different categories without cross-team blocking.

**Independent Test**: Platform supports creating, versioning, and discovering spec categories; application specs can reference specific category specs.

**Acceptance Scenarios**:

1. **Given** platform engineer creates new category directory, **When** category spec is added with frontmatter, **Then** system discovers it via `_categories.yaml` index
2. **Given** business requests cost change (business/cost spec update), **When** platform processes change, **Then** all downstream application specs see precedence: business/cost overrides infrastructure/cost
3. **Given** two category specs conflict, **When** precedence rules evaluated, **Then** tier-level precedence applies first, then `precedence.overrides` field
4. **Given** application spec references upstream category spec, **When** validation runs, **Then** system confirms upstream spec exists and is not deprecated

---

## Requirements

### Functional Requirements

- **REQ-001**: System MUST support tier-specific categories (each tier defines its own categories)
- **REQ-002**: System MUST enable independent versioning of category specs (git-based; version in frontmatter)
- **REQ-003**: Category specs MUST declare dependencies on other categories via `depends-on` field
- **REQ-004**: Hierarchy must be category-aware: business/cost overrides infrastructure/cost, etc.
- **REQ-005**: Application specs MUST explicitly reference which category specs they adhere to
- **REQ-006**: System MUST validate that no circular dependencies exist between categories
- **REQ-007**: System MUST support category discovery via `_categories.yaml` index files
- **REQ-008**: System MUST formalize hierarchy rules in `specs.yaml` manifest (root-level)

### Tier-Specific Categories (Platform Tier)

**Platform Categories**:
- `iac-linting`: Bicep/Terraform linting rules, code quality standards
- `policy-as-code`: Azure Policy definitions, governance rules
- `artifact-org`: Artifact directory structure and organization (extends platform/001)
- `spec-system`: Spec structure, format, versioning standards
- `deployment-pipeline`: CI/CD pipeline structure and automation

**Initial Categories** (cross-cutting):
- (To be defined per tier; examples: cost, security, performance, compliance)

### Tier-Specific Constraints (Platform Tier)

- **Spec Format**: YAML frontmatter + Markdown content
- **Versioning**: Semantic versioning in frontmatter (major.minor.patch); git history as source of truth
- **Categories**: Platform maintains 5+ categories; other tiers define their own
- **Manifest**: Central `specs.yaml` declares all tiers, categories, and precedence rules
- **Discovery**: Tools must be able to list all categories and query spec details

### Hierarchy & Conflict Resolution

**Precedence Rules** (ordered):

1. **Tier-level**: platform > business > security > infrastructure > devops > application
2. **Category-aware**: Within same tier, if two categories conflict:
   - Check `precedence.overrides` field for explicit precedence
   - If none specified, first-applied-wins
3. **Dependency order**: All dependencies must be satisfied before dependent spec
4. **Downstream override**: Application specs cannot override upstream tier decisions; Platform tier is foundational
5. **Immutability**: Released specs (version 1.0.0+) cannot be modified; must create new version

---

## Success Criteria

### Measurable Outcomes

- **SC-001**: All existing specs (business/001, security/001, infrastructure/001, application/mycoolapp) migrated to category structure
- **SC-002**: New platform categories (iac-linting, policy-as-code, artifact-org, spec-system) created and documented
- **SC-003**: Validation script confirms zero circular dependencies, all refs resolvable
- **SC-004**: Application specs successfully reference 3+ upstream category specs
- **SC-005**: Precedence resolution works: business/cost > infrastructure/compute when both apply
- **SC-006**: Spec discovery tools can enumerate all 50+ category specs across tiers

---

## Artifact Generation & Human Review

**Generated Outputs**:
- `specs.yaml` root manifest (defines tiers, categories, precedence rules, validation rules)
- `specs/business/_categories.yaml` (cost, governance, compliance-framework)
- `specs/security/_categories.yaml` (access-control, data-protection, audit-logging)
- `specs/infrastructure/_categories.yaml` (compute, networking, storage, cicd-pipeline)
- `specs/platform/_categories.yaml` (iac-linting, policy-as-code, artifact-org, spec-system)
- Migrated specs with frontmatter (all existing specs updated to new format)
- `specs-validation.ps1` PowerShell script (validates hierarchy, dependencies, versioning)
- `HIERARCHY.md` documentation (explains precedence, resolution rules, examples)

**Review Checklist**:
- [ ] Category definitions clear and non-overlapping
- [ ] Precedence rules formalized and testable
- [ ] Dependency graph has no cycles
- [ ] All existing specs successfully migrated to category structure
- [ ] Manifest validates against schema
- [ ] Validation script passes all checks
- [ ] Example: Show how business/cost change cascades to application specs

---

## Example: Category Spec with Frontmatter

```yaml
---
# metadata
tier: business
category: cost
spec-id: cost-001
version: 1.0.0
status: approved
created: 2026-02-05
updated: 2026-02-07

# dependencies
depends-on:
  - tier: security
    category: audit-logging
    spec-id: audit-001
    reason: "cost changes must be auditable"

# precedence: what this spec overrides
precedence:
  overrides:
    - tier: infrastructure
      category: compute
      on-conflicts: "cost reduction goals take precedence over performance for non-critical workloads"
    - tier: infrastructure
      category: storage
      on-conflicts: "cost constraints limit storage tier and replication options"

# applications this affects (optional)
applies-to:
  - tier: application
    pattern: ".*"  # all applications must follow cost targets

---

# Content below...
```

---

## Change Log

| Version | Date | Change | Approved By |
|---------|------|--------|------------|
| 1.0.0 (draft) | 2026-02-07 | Initial platform spec: category-based spec system with hierarchical precedence | Platform Engineering |

---

**Spec Version**: 1.0.0-draft  
**Status**: Ready for Planning Phase  
**Next Step**: Execute plan.md to implement phases 1-4
