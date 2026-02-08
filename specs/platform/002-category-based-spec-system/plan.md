# Implementation Plan: Category-Based Spec System

**Specification**: [spec.md](spec.md)  
**Created**: 2026-02-07  
**Phase Duration**: 2-3 weeks (5 phases across discovery, design, implementation, validation, rollout)

---

## Executive Summary

Transform the current flat-hierarchical spec structure (business/001, security/001, etc.) into a **category-based system** that enables:
- Granular versioning (change `business/cost` without touching `business/governance`)
- Explicit hierarchy with conflict resolution (category-aware precedence)
- Scalability (add new categories without restructuring existing ones)
- Discoverability (manifest + indexes enable tool integration)

**Key Deliverables**: 5 YAML manifests, 15+ migrated specs, validation script, documentation

---

## Phase Overview

| Phase | Goal | Effort | Duration |
|-------|------|--------|----------|
| Phase 0 | Research & design category taxonomy | 4 hours | 1 day |
| Phase 1 | Create manifests and category indexes | 8 hours | 2 days |
| Phase 2 | Migrate existing specs to category structure | 12 hours | 3-4 days |
| Phase 3 | Build validation and discovery tooling | 10 hours | 2-3 days |
| Phase 4 | Document, test, rollout | 6 hours | 1-2 days |
| **Total** | **End-to-end category system** | **40 hours** | **2-3 weeks** |

---

## Phase 0: Research & Discovery

**Goal**: Finalize category definitions for all tiers; identify migration obstacles

**Tasks**:

- [ ] T001 Define initial business tier categories (cost, governance, compliance-framework)
  - Research: What decisions does finance make independently? What about IT governance?
  - Decision: 3 categories minimum, each independently versioned
  
- [ ] T002 Define security tier categories (access-control, data-protection, audit-logging)
  - Research: Which security decisions are independent? (e.g., "all data encrypted" vs. "audit all ops")
  - Decision: 3+ categories based on security domains
  
- [ ] T003 Define infrastructure tier categories (compute, networking, storage, cicd-pipeline)
  - Research: Can we change compute SKUs independently from storage tiers?
  - Decision: 4+ categories for different infrastructure domains
  
- [ ] T004 Define platform tier categories (iac-linting, policy-as-code, artifact-org, spec-system)
  - Research: What platform decisions are independent? (Linting rules vs. artifact organization)
  - Decision: 4+ categories; spec-system is meta (specs about specs)
  
- [ ] T005 Map existing specs to proposed categories
  - Input: business/001, security/001, infrastructure/001, platform/001, application/mycoolapp
  - Output: Mapping document showing which category each belongs to
  
- [ ] T006 Identify conflicts in existing specs
  - Research: Are there any contradictions between business/001 and infrastructure/001?
  - Decision: Document trade-offs; create precedence rules to resolve

**Output**: Category taxonomy document with definitions, rationale, and migration map

**Acceptance**: All 5 tiers have 3+ categories defined; zero ambiguity about category boundaries

---

## Phase 1: Create System Manifests

**Goal**: Build formal manifest files that define the category structure and precedence rules

**Independent Tasks** (can run in parallel):

- [ ] T101 Create `specs.yaml` root manifest
  - Define: tiers, categories, precedence rules, validation rules
  - Include: schema validation rules, version constraints
  - Test: Validate against JSON Schema
  - Output: `specs.yaml` (150+ lines)
  
- [ ] T102 [P] Create `specs/business/_categories.yaml` index
  - Define: 3+ categories (cost, governance, compliance-framework)
  - Include: spec-id, version, file path, description for each
  - Output: Business category index (50 lines)
  
- [ ] T103 [P] Create `specs/security/_categories.yaml` index
  - Define: 3+ categories (access-control, data-protection, audit-logging)
  - Include: spec-id, version, file path for each
  - Output: Security category index (50 lines)
  
- [ ] T104 [P] Create `specs/infrastructure/_categories.yaml` index
  - Define: 4+ categories (compute, networking, storage, cicd-pipeline)
  - Include: spec-id, version, file path for each
  - Output: Infrastructure category index (70 lines)
  
- [ ] T105 [P] Create `specs/platform/_categories.yaml` index
  - Define: 4+ categories (iac-linting, policy-as-code, artifact-org, spec-system)
  - Include: spec-id, version, file path for each
  - Output: Platform category index (70 lines)
  
- [ ] T106 Create `specs/application/_index.yaml` application registry
  - Define: List of all application specs (currently: mycoolapp)
  - Include: app-id, version, tier references for each
  - Output: Application index (30 lines)

**Output**: 6 manifest files defining category taxonomy

**Acceptance**: All manifests validate against schema; zero conflicts in spec-ids; all ref paths exist or can be created

---

## Phase 2: Migrate Existing Specs

**Goal**: Update existing specs (business/001, security/001, etc.) to use new category frontmatter + reorg into subdirectories

**Migration Path**:

```
OLD:
specs/business/001-cost-reduction-targets/spec.md
specs/security/001-cost-constrained-policies/spec.md
specs/infrastructure/001-cost-optimized-compute-modules/spec.md
specs/platform/001-application-artifact-organization/spec.md
specs/application/001-cost-optimized-vm-deployment/spec.md

NEW:
specs/business/cost/spec.md (was 001-cost-reduction-targets)
specs/security/data-protection/spec.md (new category folder)
specs/infrastructure/compute/spec.md (was 001-cost-optimized-compute-modules)
specs/platform/artifact-org/spec.md (was 001-application-artifact-organization)
specs/application/mycoolapp/spec.md (was 001-cost-optimized-vm-deployment)
```

**Independent Tasks** (migration parallelizable):

- [ ] T201 [P] Migrate business/cost spec
  - From: business/001-cost-reduction-targets/spec.md
  - To: business/cost/spec.md
  - Add: Frontmatter (tier, category, spec-id: cost-001, version: 1.0.0)
  - Add: depends-on, precedence fields
  - Preserve: All existing content
  - Output: business/cost/spec.md with frontmatter
  
- [ ] T202 [P] Create business/governance spec (new category)
  - From: New (no existing spec)
  - To: business/governance/spec.md
  - Content: Extract governance-related requirements from business/001
  - Frontmatter: tier: business, category: governance, version: 1.0.0-draft
  
- [ ] T203 [P] Create business/compliance-framework spec (new category)
  - From: New (no existing spec)
  - To: business/compliance-framework/spec.md
  - Content: Compliance requirements (not operational compliance, but strategic)
  - Frontmatter: tier: business, category: compliance-framework, version: 1.0.0-draft
  
- [ ] T204 [P] Migrate infrastructure/compute spec
  - From: infrastructure/001-cost-optimized-compute-modules/spec.md
  - To: infrastructure/compute/spec.md
  - Add: Frontmatter (spec-id: compute-001)
  - Add: depends-on business/cost, security/data-protection
  
- [ ] T205 [P] Create infrastructure/networking spec
  - From: New (no existing spec)
  - To: infrastructure/networking/spec.md
  - Content: Networking specs (VNets, NSGs, routing, connectivity)
  - Frontmatter: Version 1.0.0-draft
  
- [ ] T206 [P] Create infrastructure/storage spec
  - From: New (no existing spec)
  - To: infrastructure/storage/spec.md
  - Content: Storage specs (accounts, replication, encryption, lifecycle)
  - Frontmatter: Version 1.0.0-draft
  
- [ ] T207 [P] Migrate platform/artifact-org spec
  - From: platform/001-application-artifact-organization/spec.md
  - To: platform/artifact-org/spec.md
  - Add: Frontmatter (spec-id: artifact-001)
  - Preserve: All directory structure requirements
  
- [ ] T208 [P] Create platform/iac-linting spec (new category)
  - From: New (no existing spec)
  - To: platform/iac-linting/spec.md
  - Content: Bicep/Terraform linting rules, code quality standards
  - Frontmatter: Version 1.0.0-draft
  
- [ ] T209 [P] Create platform/policy-as-code spec (new category)
  - From: New (no existing spec)
  - To: platform/policy-as-code/spec.md
  - Content: Azure Policy definitions, governance automation
  - Frontmatter: Version 1.0.0-draft
  
- [ ] T210 Migrate application/mycoolapp spec
  - From: application/mycoolapp/spec.md (or application/001-cost-optimized-vm-deployment/spec.md)
  - To: specs/application/mycoolapp/spec.md
  - Add: adheres-to field listing upstream category specs it follows
  - Update: References to reflect new category structure
  - Output: Updated spec with explicit upstream references

**Output**: 15+ category specs with frontmatter; old directory structure retired

**Acceptance**: 
- All specs have valid frontmatter (tier, category, spec-id, version)
- All dependencies resolvable (no broken refs)
- All specs discoverable via `_categories.yaml` indexes
- Application specs reference 3+ upstream category specs
- Zero duplicate spec-ids across tiers

---

## Phase 3: Build Tooling

**Goal**: Create validation and discovery tools to enforce hierarchy and enable smart querying

**Independent Tasks**:

- [ ] T301 [P] Create `specs-validate.ps1` PowerShell script
  - Features:
    - Validate all specs have required frontmatter fields
    - Check for circular dependencies
    - Verify all dep refs resolvable
    - Validate semantic versioning format
    - Check for duplicate spec-ids
    - Confirm no deprecated specs in active use
  - Output: specs-validate.ps1 (200+ lines)
  - Test: Run against full spec tree; expect 0 errors
  
- [ ] T302 [P] Create `specs-hierarchy.ps1` precedence resolution script
  - Features:
    - Given two conflicting specs, determine winner via precedence rules
    - Output: Explanation of precedence decision
    - Validate: All `precedence.overrides` are justified
  - Output: specs-hierarchy.ps1 (150+ lines)
  - Test: Scenarios (business/cost vs infra/compute, etc.)
  
- [ ] T303 Create `HIERARCHY.md` documentation
  - Content:
    - Explain tier precedence (business > security > infra > platform > app)
    - Show category-aware conflict resolution examples
    - Document how to add new categories
    - Show how to declare dependencies and precedence
    - Include decision trees for common conflicts
  - Output: HIERARCHY.md (500+ lines with examples)
  
- [ ] T304 [P] Create `specs-discovery.ps1` query tool (optional)
  - Features:
    - List all specs in a tier
    - Find all specs that depend on a given spec
    - Find all specs that override a given spec
    - Search specs by keyword
  - Output: specs-discovery.ps1 (100+ lines)

**Output**: 3-4 PowerShell utilities + comprehensive documentation

**Acceptance**:
- All validation rules pass against full spec tree
- Precedence tool correctly resolves 10+ test scenarios
- HIERARCHY.md is comprehensive and examples work
- Discovery tool query scenarios validated

---

## Phase 4: Document, Test & Rollout

**Goal**: Ensure system is production-ready; document for all users; plan rollout

**Tasks**:

- [ ] T401 Create `CATEGORY_SYSTEM_README.md`
  - For: New platform engineers joining the team
  - Content:
    - Overview of category system
    - Directory structure diagram
    - How to create new category spec
    - How to reference upstream specs
    - Common mistakes to avoid
  - Output: 300+ line guide
  
- [ ] T402 Create migration guide for existing specs
  - Document: How specs moved from old to new structure
  - Show: Before/after examples
  - Provide: Git history pointers to see changes
  - Output: MIGRATION_GUIDE.md
  
- [ ] T403 Run end-to-end system test
  - Scenario 1: Business/cost changes; verify cascade to application specs
  - Scenario 2: Infrastructure/compute conflict with business/cost; verify resolution
  - Scenario 3: New platform engineer adds category; system discovery works
  - Output: Test results + 0 failures
  
- [ ] T404 Update existing tooling to recognize new structure
  - Update: spec-cloud-platform tools to reference new manifest
  - Update: CI/CD pipelines to validate hierarchy
  - Output: All tools compatible with new system
  
- [ ] T405 Create rollout checklist
  - When: Ready to activate system
  - What: Stakeholders need to know
  - How: Teams migrate to new system
  - Risk: Any breaking changes? (Answer: No; old structure is read-only)
  
- [ ] T406 Archive old spec structure (optional)
  - Action: Move old 001-*, 002-* directories to `_archive/`
  - Reason: Keep git history but signal deprecation
  - Risk: None (all data preserved)

**Output**: Documentation, test results, rollout plan

**Acceptance**:
- CATEGORY_SYSTEM_README is clear enough for 2 new engineers to add categories independently
- End-to-end test passes with 0 failures
- All tools updated and validated
- Stakeholders understand changes + zero concerns

---

## Dependencies & Blocking

**Critical Path**:
```
Phase 0 (Research) 
  ↓ 
Phase 1 (Manifests) 
  ↓ 
Phase 2 (Migrate specs) 
  ↓ 
Phase 3 (Build tools) 
  ↓ 
Phase 4 (Document & test)
```

**Parallelizable**:
- Phase 1: All 6 manifest creation tasks (T101-T106)
- Phase 2: All 10 spec migration tasks (T201-T210)
- Phase 3: Validation + discovery scripts (T301, T302, T304)

**Blocked By**:
- Nothing (greenfield implementation)

**Blocks**:
- New spec creation (teams wait for Phase 4 rollout before creating new categories)

---

## Success Criteria & Validation

**Before Phase 4 Completion**:
- [ ] All 15+ category specs have valid frontmatter
- [ ] Zero circular dependencies detected
- [ ] All application specs reference 3+ upstream categories
- [ ] `specs-validate.ps1` returns 0 errors on full tree
- [ ] Precedence resolution works for 10+ test scenarios
- [ ] HIERARCHY.md explains system clearly with 20+ examples
- [ ] End-to-end test: business/cost change cascades correctly

**Before Production Rollout**:
- [ ] All stakeholders (business, security, infra, platform, app teams) trained
- [ ] Tools integrated into CI/CD pipelines
- [ ] No breaking changes to existing workflows
- [ ] Rollback plan documented (if needed)

---

## Risk Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| Specs become too granular | Hard to find relevant specs | Category index + discovery tool search |
| Precedence rules create confusion | Teams make conflicting decisions | HIERARCHY.md + decision tree tool |
| Migration takes longer than estimated | Delays project | Parallelize Phase 2 tasks |
| Tool validation misses edge case | Invalid specs pass validation | Include 20+ test scenarios |
| Teams resist new structure | Low adoption | Evangelize benefits + training sessions |

---

## Timeline

**Week 1**:
- Monday-Tuesday: Phase 0 (Research)
- Wednesday-Thursday: Phase 1 (Manifests) + start Phase 2 (Migrate specs)

**Week 2**:
- Monday-Wednesday: Phase 2 (Complete all migrations)
- Thursday-Friday: Phase 3 (Build tools)

**Week 3**:
- Monday-Wednesday: Phase 4 (Document & test)
- Thursday-Friday: Rollout + stakeholder kickoff

**Total**: 2-3 weeks for full implementation

---

## Next Steps

1. **Approve spec.md** (Phase 0 gate)
2. **Execute Phase 0** (research + taxonomy finalization)
3. **Proceed through phases 1-4 sequentially** (with parallelization where noted)
4. **Run end-to-end test** before rollout
5. **Activate new system** and retire old structure

---

**Plan Version**: 1.0.0  
**Status**: Ready for Phase 0 Execution  
**Estimated Start**: 2026-02-10  
**Estimated Completion**: 2026-02-24
