---
description: "Task list for Patio IaC template implementation"
---

# Tasks: Patio App IaC

**Input**: Specification documents from /specs/application/Patio/  
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md  
**Tier**: application  
**Depends-On**: platform/spec-system (spec-001 v1.0.0-draft), platform/iac-linting (lint-001 v1.0.0-draft), platform/policy-as-code (pac-001 v1.0.0-draft), platform/artifact-org (artifact-001 v1.0.0), platform/001-application-artifact-organization (platform-001, draft 2026-02-05), business/compliance-framework (comp-001 v1.0.0-draft), business/governance (gov-001 v1.0.0-draft), business/cost (cost-001 v2.0.0), security/access-control (ac-001 v1.0.0-draft), security/data-protection (dp-001 v1.0.0), security/audit-logging (audit-001 v1.0.0-draft), infrastructure/compute (compute-001 v2.0.0), infrastructure/networking (net-001 v2.0.0), infrastructure/storage (stor-001 v2.0.0), infrastructure/cicd-pipeline (cicd-001 v2.0.0), infrastructure/iac-modules (iac-001 v1.0.0-draft), devops/deployment-automation (deploy-001 v1.0.0-placeholder), devops/observability (obs-001 v1.0.0-placeholder), devops/environment-management (env-001 v1.0.0-placeholder), devops/ci-cd-orchestration (cicd-orch-001 v1.0.0-placeholder)

---

## 🎯 IMPORTANT: Role Declaration Protocol (Per Constitution §II)

These tasks were created via:
- **Role Declared**: Application
- **Category Target** (required for non-application roles): N/A (application role)
- **Application Target** (required for Application role): NEW: Patio
- **Source Tier Spec**: specs/application/Patio/spec.md

> Constitution §II requires ALL task generation (and specs) to maintain role declaration context. These tasks implement the spec from the application tier.

---

## Constitution Check: Tier Alignment & Spec Cascading

*GATE: Must verify tasks align with all parent tier constraints before execution. (Per Constitution §III)*

**Upstream Tier Validation** (MANDATORY per Constitution §III):
- [x] **Load all upstream tier specs**: Referenced plan.md Depends-On list
- [x] **Verify no constraint violations**: Tasks reflect platform artifact structure, security, compliance, cost, and CI/CD gates
- **Failure Protocol**: N/A (no violations)

---

## Phase 1: Setup (Spec Validation & Foundations)

- [x] T001 Confirm Patio spec and plan reflect upstream constraints in specs/application/Patio/spec.md and specs/application/Patio/plan.md
- [x] T002 Create artifact inventory stub in specs/application/Patio/artifact-list.md
- [x] T003 [P] Document Patio environment matrix in artifacts/applications/Patio/docs/environment-matrix.md
- [x] T004 [P] Update artifacts/applications/Patio/README.md with Patio IaC scope and artifact locations

---

## Phase 2: Foundational IaC Structure

- [x] T005 Create base IaC entrypoint in artifacts/applications/Patio/iac/main.bicep
- [x] T006 [P] Add environment parameter files in artifacts/applications/Patio/iac/dev.bicepparam, artifacts/applications/Patio/iac/test.bicepparam, artifacts/applications/Patio/iac/prod.bicepparam
- [x] T007 [P] Add shared naming and tagging configuration in artifacts/applications/Patio/iac/config.bicep

---

## Phase 3: User Story 1 - Define Patio IaC Scope (Priority: P1)

**Goal**: Deliver core infrastructure templates that deploy Patio environments using approved wrapper modules.

**Independent Test**: `main.bicep` composes wrapper modules and parameter files per environment with no missing resource dependencies.

- [x] T008 [US1] Wire VNet, NSG, and public IP wrapper modules in artifacts/applications/Patio/iac/main.bicep
- [x] T009 [US1] Wire Linux VM and managed disk wrapper modules in artifacts/applications/Patio/iac/main.bicep
- [x] T010 [US1] Wire storage account and key vault wrapper modules in artifacts/applications/Patio/iac/main.bicep
- [x] T011 [US1] Add outputs for core resource IDs in artifacts/applications/Patio/iac/main.bicep
- [x] T012 [US1] Document deployment steps in artifacts/applications/Patio/docs/iac-usage.md

---

## Phase 4: User Story 2 - Align With Security and Governance (Priority: P2)

**Goal**: Ensure security, audit logging, and access controls are implemented in the IaC templates.

**Independent Test**: Security controls and audit logging resources are defined and referenced by main deployment.

- [x] T013 [US2] Implement RBAC assignments and Key Vault access rules in artifacts/applications/Patio/iac/security.bicep
- [x] T014 [US2] Define Log Analytics workspace and diagnostic settings in artifacts/applications/Patio/iac/monitoring.bicep
- [x] T015 [US2] Integrate security and monitoring modules in artifacts/applications/Patio/iac/main.bicep
- [x] T016 [US2] Document security and audit mappings in artifacts/applications/Patio/docs/security-controls.md

---

## Phase 5: User Story 3 - Set Cost and Scaling Expectations (Priority: P3)

**Goal**: Encode workload criticality, cost guardrails, and deployment governance into artifacts and pipelines.

**Independent Test**: Cost and criticality metadata are present in parameters, scripts, and pipeline gates.

- [x] T017 [US3] Add workload criticality parameters and cost tags in artifacts/applications/Patio/iac/main.bicep and artifacts/applications/Patio/iac/*.bicepparam
- [x] T018 [US3] Add dev/test auto-shutdown schedule in artifacts/applications/Patio/iac/automation.bicep
- [x] T019 [US3] Create cost estimation script in artifacts/applications/Patio/scripts/cost-estimate.ps1
- [x] T020 [US3] Create workload tier compliance script in artifacts/applications/Patio/scripts/verify-tier-compliance.ps1
- [x] T021 [US3] Create deployment pipeline in artifacts/applications/Patio/pipelines/deploy-infrastructure.yml
- [x] T022 [US3] Document approval gates and rollback steps in artifacts/applications/Patio/docs/rollout.md

---

## Phase 6: Polish & Cross-Cutting Concerns

- [x] T023 Update specs/application/Patio/artifact-list.md with generated files and versions
- [ ] T024 [P] Record validation results in artifacts/applications/Patio/docs/validation-log.md after running artifact structure checks

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Requires Phase 1 completion
- **User Stories (Phases 3-5)**: Require Phase 2 completion
- **Polish (Phase 6)**: Requires Phases 3-5 completion

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Phase 2
- **User Story 2 (P2)**: Can start after Phase 2
- **User Story 3 (P3)**: Can start after Phase 2

---

## Parallel Execution Examples

### User Story 1

- T008 and T010 can run in parallel (different module blocks in main.bicep)
- T011 can run after T008-T010

### User Story 2

- T013 and T014 can run in parallel (separate files)
- T015 follows T013 and T014

### User Story 3

- T019, T020, and T021 can run in parallel (separate files)
- T022 follows T021

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 and Phase 2
2. Complete User Story 1 tasks (T008-T012)
3. Validate `main.bicep` composition and parameter coverage

### Incremental Delivery

1. Deliver User Story 1 (IaC scope) and validate
2. Deliver User Story 2 (security and audit alignment) and validate
3. Deliver User Story 3 (cost and scaling guardrails) and validate
4. Finish Polish tasks
