# Tasks: Application Artifact Organization Standard

**Input**: Implementation plan from `/specs/platform/001-application-artifact-organization/plan.md`  
**Prerequisites**: plan.md (required), spec.md (required for user stories)  
**Tier**: platform

---

## 🎯 IMPORTANT: Role Declaration Protocol (Per Constitution §II)

These tasks were created via:
- **Role Declared**: Platform
- **Application Target**: N/A (Platform tier)
- **Source Tier Spec**: `specs/platform/001-application-artifact-organization/spec.md`

> Constitution §II requires ALL task generation (and specs) to maintain role declaration context. These tasks implement the Platform spec establishing standardized application artifact organization.

---

## Format: `[ID] [P?] [Type] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Type]**: artifact-gen (generate artifacts), review (human review), test (validation), setup (infrastructure prep), doc (documentation), or implement (code changes)
- Include exact file paths in descriptions

---

## Implementation Strategy & Dependencies

**Critical Path**:
- Phase 1 (Week 1): Spec ratified → Templates created → Guide published
- Phase 2 (Weeks 2-4): Artifacts migrated → Backward compatibility active
- Phase 3 (Weeks 5-12): Validation automated → Quality gates enforced
- Phase 4 (by 2026-03-31): Old structure sunset

**Parallelizable Work**: Many Phase 1 tasks (template creation, guide writing, schema design) can run in parallel.

**Dependencies**:
- All Phase 2 tasks depend on Phase 1 completion (templates must exist before migration)
- All Phase 3 tasks depend on Phase 2 completion (migration must complete before validation)
- All Phase 4 tasks depend on Phase 3 completion (validation must be production-ready before sunset)

---

## PHASE 1: DEFINE STANDARD & CREATE TEMPLATES (Week 1)

### Goal
Ratify the specification and create reusable templates that application teams can use.

---

### Sprint 1.1: Specification Ratification

- [X] T001 [P] setup Confirm specification meets Constitution §I requirements in `specs/platform/001-application-artifact-organization/spec.md`
- [X] T002 [P] setup Update spec status from Draft → Approved in `specs/platform/001-application-artifact-organization/spec.md`
- [X] T003 [P] setup Create SPECIFICATION_RATIFICATION.md documenting approval date, approver, rationale
- [X] T004 review Obtain platform team approval (human sign-off required)

---

### Sprint 1.2: Directory Structure Template

- [X] T005 [P] artifact-gen Create template directory structure at `/artifacts/.templates/application-artifact-template/`
- [X] T006 [P] artifact-gen Create root README.md in `/artifacts/.templates/application-artifact-template/README.md` explaining overall structure
- [X] T007 [P] artifact-gen Create `/artifacts/.templates/application-artifact-template/iac/README.md` with IaC guidance (naming: `<appname>-<component>.bicep`, examples, links to spec)
- [X] T008 [P] artifact-gen Create `/artifacts/.templates/application-artifact-template/modules/README.md` with modules guidance
- [X] T009 [P] artifact-gen Create `/artifacts/.templates/application-artifact-template/scripts/README.md` with scripts guidance
- [X] T010 [P] artifact-gen Create `/artifacts/.templates/application-artifact-template/pipelines/README.md` with GitHub Actions guidance
- [X] T011 [P] artifact-gen Create `/artifacts/.templates/application-artifact-template/docs/README.md` with documentation guidance
- [X] T012 [P] artifact-gen Create example files in each subdirectory (`.gitignore`, example Bicep, etc.)
- [X] T013 review Verify all README.md files are clear and link to spec properly

---

### Sprint 1.3: Directory Creation Script

- [X] T014 [P] artifact-gen Create PowerShell script: `/artifacts/.templates/scripts/create-app-directory.ps1`
  - Takes parameter: `-AppName "app-name"`
  - Creates `/artifacts/applications/<appname>/` directory structure
  - Copies README.md files from template
  - Generates `.gitignore` files
  - Outputs success message with paths created
  
- [X] T015 [P] artifact-gen Create `.gitignore` template for `/artifacts/.templates/scripts/.gitignore-template` (ignore compiled files, secrets, etc.)

- [X] T016 test Test `create-app-directory.ps1` script:
  - Run: `./create-app-directory.ps1 -AppName "test-app"`
  - Verify: `/artifacts/applications/test-app/` created with all 5 subdirectories
  - Verify: README.md files present in each directory
  - Verify: `.gitignore` file created
  - Cleanup test directory

- [X] T017 [P] doc Create usage documentation in `/artifacts/.templates/scripts/README.md` explaining how to run the script

---

### Sprint 1.4: Validation Schema

- [X] T018 [P] artifact-gen Create JSON schema at `/artifacts/.templates/schemas/artifact-structure-schema.json`:
  - Validates directory structure exists
  - Validates required subdirectories present (or documents optional ones)
  - Validates README.md files in each directory
  - Validates naming conventions (e.g., `<appname>-<component>.bicep`)
  - Validates `.gitignore` file presence
  
- [X] T019 [P] artifact-gen Create PowerShell validation script: `/artifacts/.templates/scripts/validate-artifact-structure.ps1`
  - Takes parameter: `-AppName "app-name"` or `-Path "/artifacts/applications/app-name"`
  - Uses JSON schema to validate structure
  - Reports validation pass/fail with detailed errors
  - Suggests remediation steps
  
- [X] T020 test Test validation script:
  - Test against valid app structure (should pass)
  - Test against invalid structures (should fail with helpful messages)
  - Test against non-existent app (should fail gracefully)
  
- [X] T021 doc Create validation documentation in `/artifacts/.templates/schemas/README.md`

---

### Sprint 1.5: Artifact Organization Guide

- [X] T022 [P] doc Create `/ARTIFACT_ORGANIZATION_GUIDE.md` with:
  - **Overview section**: Problem statement, solution, benefits
  - **Standard structure section**: Directory diagram, naming conventions per artifact type
  - **Examples section**: payment-service, web-app-001, cost-optimized-demo examples
  - **How-to section**: Creating a new app artifact directory (step-by-step)
  - **GitHub Actions section**: How to parameterize pipelines by app name
  - **Migration section**: Path for existing artifacts
  - **FAQ section**: Common questions
  
- [X] T023 [P] doc Create `/artifacts/ARTIFACT_STRUCTURE.md` (at artifact root) providing quick reference to structure

- [X] T024 review Review ARTIFACT_ORGANIZATION_GUIDE.md for clarity, completeness, and links to spec

---

### Sprint 1.6: Phase 1 Acceptance & Documentation

- [X] T025 [P] test Run full Phase 1 checklist:
  - Specification ratified ✓
  - Templates created and tested ✓
  - Scripts working ✓
  - Guides published ✓
  - Validation schema and script complete ✓
  
- [X] T026 [P] doc Create `/specs/platform/001-application-artifact-organization/PHASE_1_COMPLETION.md` documenting what was delivered

- [X] T027 review Get platform team approval to proceed to Phase 2

---

## PHASE 2: MIGRATE EXISTING ARTIFACTS (Weeks 2-4)

### Goal
Move existing artifacts to new structure while maintaining backward compatibility.

---

### Sprint 2.1: Migration Planning & Audit

- [ ] T028 [P] setup Audit existing artifacts in `/artifacts/`:
  - Inventory all files and directories
  - Categorize by type (Bicep, Python, PowerShell, Markdown, etc.)
  - Map to applications (cost-optimized-demo, etc.)
  - Document findings in `MIGRATION_INVENTORY.md`
  
- [ ] T029 [P] setup Identify artifact dependencies:
  - Which files reference other artifacts?
  - Which specs reference `/artifacts/bicep/`, `/artifacts/scripts/`, etc.?
  - Document in `MIGRATION_INVENTORY.md`
  
- [ ] T030 setup Create `/MIGRATION_PLAN.md` documenting:
  - What moves where (file-by-file mapping)
  - Dependencies and cross-references to update
  - Backward compatibility strategy (symlinks vs documentation)
  - Risk mitigation steps
  - Rollback plan
  
- [ ] T031 review Get platform team approval of migration plan

---

### Sprint 2.2: Create Application Directories

- [ ] T032 [P] setup Run script: `./create-app-directory.ps1 -AppName "cost-optimized-demo"`
  - Creates `/artifacts/applications/cost-optimized-demo/` with full structure
  
- [ ] T033 setup Create application-specific documentation at `/artifacts/applications/cost-optimized-demo/README.md`:
  - Links to platform artifact org guide
  - Lists what's in this application
  - Links to source spec (`specs/business/001-cost-reduction-targets/`)
  - Explains how to deploy
  
- [ ] T034 [P] setup Verify directory structure created correctly using validation script

---

### Sprint 2.3: Migrate Artifact Files

- [ ] T035 [P] implement Move IaC files:
  - Move `artifacts/bicep/compute-reserved-instance.bicep` → `artifacts/applications/cost-optimized-demo/iac/compute-reserved-instance.bicep`
  - Verify file integrity (diff check)
  - Update any internal references if needed
  
- [ ] T036 [P] implement Move Python scripts:
  - Move `artifacts/scripts/cost-calculator.py` → `artifacts/applications/cost-optimized-demo/scripts/cost-calculator.py`
  - Verify file integrity
  
- [ ] T037 [P] implement Move PowerShell scripts:
  - Move `artifacts/scripts/demo-cascade.ps1` → `artifacts/applications/cost-optimized-demo/scripts/demo-cascade.ps1`
  - Verify file integrity
  
- [ ] T038 [P] implement Move documentation:
  - Move `DEMO_WALKTHROUGH.md` → `artifacts/applications/cost-optimized-demo/docs/DEMO_WALKTHROUGH.md`
  - Move `DEMO_IMPLEMENTATION.md` → `artifacts/applications/cost-optimized-demo/docs/DEMO_IMPLEMENTATION.md`
  - Verify file integrity
  
- [ ] T039 test Validate all migrated files are present and accessible

---

### Sprint 2.4: Update File References & Create Backward Compatibility

- [ ] T040 [P] implement Update `artifacts/applications/cost-optimized-demo/scripts/demo-cascade.ps1` to reference new paths:
  - Replace old path references with new app-specific paths
  - Test that script still executes correctly
  
- [ ] T041 [P] implement Create deprecation notices:
  - `/artifacts/bicep/README.md` (points to new location)
  - `/artifacts/scripts/README.md` (points to new location)
  - Keep files in place but mark as "DEPRECATED - See new structure at /artifacts/applications/"
  
- [ ] T042 [P] implement Create symlinks (optional - if using symlink strategy):
  - `/artifacts/bicep/` → `/artifacts/applications/cost-optimized-demo/iac/` (symlink)
  - `/artifacts/scripts/` → `/artifacts/applications/cost-optimized-demo/scripts/` (symlink)
  - Alternative: Skip symlinks, use deprecation notices instead
  
- [ ] T043 test Test backward compatibility:
  - Old paths should still work (either symlinks or deprecation notices visible)
  - New paths should work
  - Deployments from both paths should succeed

---

### Sprint 2.5: Update Platform Documentation

- [ ] T044 [P] doc Update `/ARTIFACT_ORGANIZATION_GUIDE.md`:
  - Add section explaining migration period
  - Add section on old vs new paths
  - Update examples to show new structure
  
- [ ] T045 [P] doc Update spec files to reference new artifact paths:
  - `/specs/business/001-cost-reduction-targets/spec.md` - Update artifact references
  - `/specs/security/001-cost-constrained-policies/spec.md` - Update artifact references
  - `/specs/infrastructure/001-cost-optimized-compute-modules/spec.md` - Update artifact references
  - `/specs/application/001-cost-optimized-vm-deployment/spec.md` - Update artifact references (or migrate to `/specs/application/cost-optimized-demo/`)
  
- [ ] T046 doc Update any GitHub Actions workflows to reference new paths (if any exist)

---

### Sprint 2.6: Phase 2 Testing & Validation

- [ ] T047 test Run validation script on migrated structure:
  - `./validate-artifact-structure.ps1 -AppName "cost-optimized-demo"`
  - Should pass with no errors
  
- [ ] T048 test Run demo script from new location:
  - `artifacts/applications/cost-optimized-demo/scripts/demo-cascade.ps1`
  - Should execute successfully
  - Should show same output as before
  
- [ ] T049 test Test backward compatibility paths:
  - Old paths should still be accessible (via symlinks or documentation)
  - New paths should be primary
  
- [ ] T050 [P] doc Create `/specs/platform/001-application-artifact-organization/PHASE_2_COMPLETION.md` documenting migration results

- [ ] T051 review Get platform team sign-off: Phase 2 complete, backward compatibility active, ready for Phase 3

---

## PHASE 3: ENFORCE & AUTOMATE (Weeks 5-12)

### Goal
Implement automated validation and quality gates to enforce the standard going forward.

---

### Sprint 3.1: Quality Gate Validation Integration

- [ ] T052 [P] implement Create GitHub Actions workflow at:
  - `/.github/workflows/validate-artifact-structure.yml`
  - Triggers on: push to `artifacts/applications/*`
  - Runs validation script
  - Fails if structure invalid
  - Suggests remediation steps in PR comment
  
- [ ] T053 [P] implement Add validation to main CI/CD pipeline:
  - Integrate `validate-artifact-structure.ps1` into deployment workflow
  - Make validation a required step before deployment
  - Provide detailed error messages
  
- [ ] T054 test Test GitHub Actions workflow:
  - Commit valid artifact structure → workflow passes ✓
  - Commit invalid structure → workflow fails with helpful message ✓
  - PR comments suggest fixes ✓
  
- [ ] T055 [P] implement Create exception handling mechanism:
  - `.artifact-validation-exception` file for documented exceptions
  - Requires approval comment in PR
  - Documents reason for exception

---

### Sprint 3.2: GitHub Actions Template Updates

- [ ] T056 [P] artifact-gen Create parameterized GitHub Actions template:
  - `/.github/workflows/deploy-application-template.yml`
  - Parameterized by app name
  - Targets `/artifacts/applications/${{ env.APP_NAME }}/iac/`
  - Can be copied by teams for their specific apps
  
- [ ] T057 [P] doc Create deployment template documentation:
  - How to use the parameterized template
  - Environment variables to set
  - Example for payment-service, web-app-001, etc.
  
- [ ] T058 test Test parameterized template with cost-optimized-demo:
  - Deploy from `/artifacts/applications/cost-optimized-demo/iac/`
  - Verify deployment succeeds
  - Verify artifact path is dynamically resolved

---

### Sprint 3.3: Platform Documentation Enhancements

- [ ] T059 [P] doc Create `/ARTIFACT_ORGANIZATION_COMPLIANCE.md`:
  - List all quality gate validation rules
  - Explain failure scenarios
  - Provide remediation steps
  - Examples of valid vs invalid structures
  
- [ ] T060 [P] doc Update `ARTIFACT_ORGANIZATION_GUIDE.md`:
  - Add quality gate information
  - Add GitHub Actions examples
  - Add troubleshooting section
  - Add video/walkthrough links (if applicable)
  
- [ ] T061 [P] doc Create artifact organization quick reference card (one-pager):
  - Directory structure diagram
  - Naming conventions
  - Key commands (create directory, validate, deploy)
  - Links to full documentation

---

### Sprint 3.4: Team Training & Support

- [ ] T062 [P] doc Create team training materials (optional, but recommended):
  - Markdown guide: "How to organize your application artifacts"
  - Walkthrough: Creating a new app directory
  - FAQ: Common questions
  - Troubleshooting: Validation failures
  
- [ ] T063 doc Create FAQ document at `/ARTIFACT_ORGANIZATION_FAQ.md`:
  - Q: How do I create a new application directory?
  - Q: How do I migrate existing artifacts?
  - Q: Why are my artifacts organized this way?
  - Q: What do I do if validation fails?
  - Q: Can I have exceptions?
  - Q: How do I deploy from the new structure?
  - (Add 5-10 more relevant FAQs)
  
- [ ] T064 setup Schedule team training session (optional)
  - Present artifact organization standard
  - Demo: Create new app directory
  - Demo: Validate structure
  - Demo: Deploy from new structure
  - Q&A

---

### Sprint 3.5: Testing & Validation

- [ ] T065 test Run validation suite:
  - Test on valid structures ✓
  - Test on invalid structures ✓
  - Test on edge cases (large files, special characters, etc.)
  - Measure validation performance (<1 second requirement)
  
- [ ] T066 test Test GitHub Actions workflows:
  - Deploy valid artifact → succeeds ✓
  - Deploy invalid artifact → fails with helpful message ✓
  - Parameterization works correctly ✓
  
- [ ] T067 test Create test cases for validation script:
  - Store in `/artifacts/.templates/tests/`
  - Include valid and invalid examples
  - Document expected behavior
  
- [ ] T068 [P] test Measure quality gate effectiveness:
  - Number of validation failures
  - Common failure patterns
  - Time to remediate
  - Adjust error messages if needed

---

### Sprint 3.6: Phase 3 Completion & Documentation

- [ ] T069 [P] doc Create `/specs/platform/001-application-artifact-organization/PHASE_3_COMPLETION.md` documenting:
  - Quality gates implemented
  - GitHub Actions templates created
  - Validation testing results
  - Training materials completed
  
- [ ] T070 review Measure against success metrics:
  - SM-001: 100% of new applications use new structure ✓
  - SM-002: 100% of existing applications migrated ✓
  - SM-003: Validation script 0% false-failure rate ✓
  - SM-004: GitHub Actions parameterized ✓
  - SM-005: Developer onboarding improved ✓
  - SM-006: Compliance 100% ✓
  
- [ ] T071 review Get platform team sign-off: Phase 3 complete, automation active, ready for Phase 4

---

## PHASE 4: SUNSET OLD STRUCTURE (by 2026-03-31)

### Goal
Remove backward compatibility and clean up old artifact locations.

---

### Sprint 4.1: Pre-Sunset Verification

- [ ] T072 setup Confirm all migrations complete:
  - All artifacts in `/artifacts/applications/<appname>/` ✓
  - No artifacts in old locations (except deprecation notices)
  - All deployments working from new structure
  
- [ ] T073 setup Audit for any remaining old path references:
  - Search codebase for `/artifacts/bicep/`
  - Search codebase for `/artifacts/scripts/`
  - Search documentation for old paths
  - Update any remaining references
  
- [ ] T074 test Test all deployments work from new structure:
  - cost-optimized-demo deployment ✓
  - Any other applications ✓
  
- [ ] T075 review Get final approval to proceed with sunset

---

### Sprint 4.2: Cleanup & Archive

- [ ] T076 implement Remove symlinks (if used):
  - Delete `/artifacts/bicep/` symlink
  - Delete `/artifacts/scripts/` symlink
  - Verify old paths are no longer accessible
  
- [ ] T077 implement Remove old artifact directories:
  - Archive old structure to git history (git log preserved)
  - Delete `/artifacts/bicep/`
  - Delete `/artifacts/scripts/`
  - Delete deprecation notice files
  - Run `git rm` commands
  
- [ ] T078 [P] doc Remove deprecation notices from repository

- [ ] T079 test Verify no broken links or references:
  - Run link checker on documentation
  - Verify all references point to new structure
  - Verify git history preserved

---

### Sprint 4.3: Final Communication & Celebration

- [ ] T080 doc Create sunset announcement:
  - Communicate to all teams
  - Celebrate successful migration
  - Thank teams for participation
  - Provide links to updated documentation
  
- [ ] T081 [P] doc Update main README.md with new artifact organization info

- [ ] T082 doc Archive MIGRATION_PLAN.md and migration documents:
  - Move to `/docs/archive/` or similar
  - Keep for historical reference
  
- [ ] T083 review Create `/specs/platform/001-application-artifact-organization/PHASE_4_COMPLETION.md` documenting sunset completion

---

### Sprint 4.4: Post-Sunset Validation

- [ ] T084 test Final validation:
  - All new applications created after 2026-02-05 follow structure ✓
  - All existing applications migrated ✓
  - Zero broken deployments ✓
  - Quality gates preventing non-compliance ✓
  
- [ ] T085 [P] doc Create lessons learned document:
  - What went well
  - What could be improved
  - Recommendations for future standards
  
- [ ] T086 review Get platform team final sign-off: Sunset complete, standard fully adopted

---

## Task Summary

**Total Tasks**: 86  
**By Phase**:
- Phase 1: T001-T027 (27 tasks) - Setup, templates, documentation
- Phase 2: T028-T051 (24 tasks) - Migration planning and execution
- Phase 3: T052-T071 (20 tasks) - Automation and enforcement
- Phase 4: T072-T086 (15 tasks) - Cleanup and sunset

**By Type**:
- setup (19 tasks) - Infrastructure and planning
- artifact-gen (11 tasks) - Create templates, scripts, schemas
- implement (9 tasks) - Code changes and migrations
- test (17 tasks) - Validation and testing
- doc (19 tasks) - Documentation and guides
- review (11 tasks) - Human review and approvals

**Parallelizable Tasks**: [P] markers indicate tasks that can run in parallel within same phase

---

## Execution Order

1. **Week 1**: Phase 1 (T001-T027) - All Phase 1 tasks can start immediately, many in parallel
2. **Weeks 2-4**: Phase 2 (T028-T051) - Depends on Phase 1 completion
3. **Weeks 5-12**: Phase 3 (T052-T071) - Depends on Phase 2 completion
4. **By 2026-03-31**: Phase 4 (T072-T086) - Depends on Phase 3 completion

---

**Tasks Status**: Ready for execution  
**Created**: 2026-02-05  
**Next Step**: Start Phase 1 (Week 1)