---

description: "Task list template for platform artifact generation and implementation"
---

# Tasks: [SPEC_NAME]

**Input**: Specification documents from `/specs/[TIER-NAME]/[###-spec-name]/`  
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md  
**Tier**: [business | security | infrastructure | application]

---

## 🎯 IMPORTANT: Role Declaration Protocol (Per Constitution §II)

These tasks were created via:
- **Role Declared**: [Platform | Business | Security | Infrastructure | Application]
- **Application Target** (if Application role): [NEW: app-name | EXISTING: app-name]
- **Source Tier Spec**: [Reference to parent spec that generated these tasks]

> Constitution §II requires ALL task generation (and specs) to maintain role declaration context. These tasks implement the spec from the [declared role] tier.

---

**Tests**: The examples below include test & validation tasks. Tests are OPTIONAL - only include them if explicitly requested in the feature specification.

**Organization**: Tasks are grouped by user story and by artifact type (AI-generation, review, deployment) to enable independent spec compliance and testing of each story.

## Format: `[ID] [P?] [Story] [Type] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- **[Type]**: artifact-gen (AI-assisted code generation), review (human review of AI output), test (validation/deployment), or other
- Include exact file paths in descriptions

## Artifact Generation & Review Workflow

**Platform Artifacts** typically include:
- **IaC Modules** (Bicep, Terraform): Landing zones, networking, compute, storage
- **Policies**: Azure Policy definitions, security policies, cost policies
- **Pipelines**: GitHub Actions CI/CD, infrastructure deployment, compliance validation
- **Specs**: Derived specs for lower tiers, work items, migration guides
- **Configuration**: JSON schemas, parameter files, naming conventions

All AI-generated artifacts MUST pass human review before promotion to production.

<!-- 
  ============================================================================
  IMPORTANT: The tasks below are SAMPLE TASKS for illustration purposes only.
  
  The /speckit.tasks command MUST replace these with actual tasks based on:
  - User stories from spec.md (with their priorities P1, P2, P3...)
  - Feature requirements from plan.md
  - Generated artifacts (IaC, policies, pipelines)
  - Validation & compliance checks for each tier
  
  Tasks MUST be organized by user story so each story can be:
  - Implemented independently (via AI assistance)
  - Reviewed independently
  - Tested & validated independently
  - Delivered as an MVP increment
  
  For platform artifacts:
  - T-artifact tasks: AI generates the artifact (Bicep, policy, pipeline, etc.)
  - T-review tasks: Human validates artifact against spec, security, cost, etc.
  - T-test tasks: Deploy/validate artifact in test environment
  - T-deploy tasks: Promote artifact to production or consumption by lower tiers
  
  DO NOT keep these sample tasks in the generated tasks.md file.
  ============================================================================
-->

## Phase 1: Setup (Spec Validation & Foundation)

**Purpose**: Validate this spec aligns with parent tiers; document spec metadata

- [ ] T001 Validate spec alignment with parent tier specs (business/security/infrastructure)
- [ ] T002 Document spec version, rationale, and change log
- [ ] T003 [P] Create artifact-list.md template for generated outputs
- [ ] T004 [P] Setup spec traceability documentation

---

## Phase 2: Artifact Generation (AI-Assisted)

**Purpose**: Generate platform artifacts (IaC, policies, pipelines) from spec

**⚠️ CRITICAL**: All AI-generated artifacts REQUIRE human review before use

### Artifact Generation for User Story 1 - [Title] (Priority: P1) 🎯 MVP

**Goal**: Generate [artifact type] that implements this spec requirement

**Review Checkpoint**: All artifacts reviewed & approved before Phase 3

- [ ] T005 artifact-gen [US1] [P] Generate Bicep/Terraform module for [resource] in `/artifacts/[module-name]/main.bicep`
- [ ] T006 artifact-gen [US1] [P] Generate Azure Policy definitions in `/artifacts/policies/[policy-name].json`
- [ ] T007 artifact-gen [US1] Generate GitHub Actions pipeline in `.github/workflows/[pipeline-name].yml`
- [ ] T008 artifact-gen [US1] [P] Generate cost estimation template in `/artifacts/cost-estimates.json`
- [ ] T009 artifact-gen [US1] Generate derived spec for lower tier in `/specs/[LOWER-TIER]/[new-spec-id]/spec.md`

---

## Phase 3: Artifact Review & Compliance (Human-in-the-Loop)

**Purpose**: Validate AI-generated artifacts against spec, security, cost, and best practices

- [ ] T010 review [US1] Validate Bicep/Terraform module syntax & Azure best practices (see artifact from T005)
- [ ] T011 review [US1] [P] Verify cost estimates align with business tier budgets
- [ ] T012 review [US1] [P] Verify policy definitions enforce security tier compliance
- [ ] T013 review [US1] Validate pipeline syntax & deployment safety gates
- [ ] T014 review [US1] [P] Verify derived specs contain correct constraints from parent tiers
- [ ] T015 review [US1] [P] Check traceability: all artifacts link back to source spec; all requirements covered

---

## Phase 4: Testing & Validation (Pre-Deployment)

**Purpose**: Deploy artifacts to test environment; validate functionality & compliance

**⚠️ GATE**: All review tasks (T010-T015) MUST be complete before starting Phase 4

- [ ] T016 test [US1] [P] Deploy Bicep module to test subscription; verify successful deployment
- [ ] T017 test [US1] [P] Run Azure Policy scanning against test deployment; verify 100% compliance
- [ ] T018 test [US1] [P] Execute GitHub Actions pipeline in CI environment; verify all steps pass
- [ ] T019 test [US1] Verify cost estimates match actual deployment costs (within 10%)
- [ ] T020 test [US1] [P] Verify observability is configured (logging, metrics, diagnostics)

---

## Phase 5: Production Promotion & Consumption

**Purpose**: Promote approved artifacts; notify consumer teams; track usage

- [ ] T021 deploy [US1] Tag and version all artifacts; document version in artifact-list.md
- [ ] T022 deploy [US1] [P] Publish IaC modules to artifact repository (Azure Container Registry or GitHub package registry)
- [ ] T023 deploy [US1] [P] Create work items for lower tier teams (infrastructure/application) to consume new artifacts
- [ ] T024 deploy [US1] Document migration path for teams using previous artifact versions
- [ ] T025 deploy [US1] Create feedback loop: log AI output quality, issues, improvements for future iterations

---

## Phase 4: User Story 2 - [Title] (Priority: P2)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 2 (OPTIONAL - only if tests requested) ⚠️

- [ ] T018 [P] [US2] Contract test for [endpoint] in tests/contract/test_[name].py
- [ ] T019 [P] [US2] Integration test for [user journey] in tests/integration/test_[name].py

### Implementation for User Story 2

- [ ] T020 [P] [US2] Create [Entity] model in src/models/[entity].py
- [ ] T021 [US2] Implement [Service] in src/services/[service].py
- [ ] T022 [US2] Implement [endpoint/feature] in src/[location]/[file].py
- [ ] T023 [US2] Integrate with User Story 1 components (if needed)

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - [Title] (Priority: P3)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 3 (OPTIONAL - only if tests requested) ⚠️

- [ ] T024 [P] [US3] Contract test for [endpoint] in tests/contract/test_[name].py
- [ ] T025 [P] [US3] Integration test for [user journey] in tests/integration/test_[name].py

### Implementation for User Story 3

- [ ] T026 [P] [US3] Create [Entity] model in src/models/[entity].py
- [ ] T027 [US3] Implement [Service] in src/services/[service].py
- [ ] T028 [US3] Implement [endpoint/feature] in src/[location]/[file].py

**Checkpoint**: All user stories should now be independently functional

---

[Add more user story phases as needed, following the same pattern]

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] TXXX [P] Documentation updates in docs/
- [ ] TXXX Code cleanup and refactoring
- [ ] TXXX Performance optimization across all stories
- [ ] TXXX [P] Additional unit tests (if requested) in tests/unit/
- [ ] TXXX Security hardening
- [ ] TXXX Run quickstart.md validation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - May integrate with US1 but should be independently testable
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - May integrate with US1/US2 but should be independently testable

### Within Each User Story

- Tests (if included) MUST be written and FAIL before implementation
- Models before services
- Services before endpoints
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Models within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together (if tests requested):
Task: "Contract test for [endpoint] in tests/contract/test_[name].py"
Task: "Integration test for [user journey] in tests/integration/test_[name].py"

# Launch all models for User Story 1 together:
Task: "Create [Entity1] model in src/models/[entity1].py"
Task: "Create [Entity2] model in src/models/[entity2].py"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 3 → Test independently → Deploy/Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
