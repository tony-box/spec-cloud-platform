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

---

## MODERNIZATION PHASE: Unlimited Performance Strategy (cost-001 v3.0.0)

**Date**: February 10, 2026  
**Change**: Migrate from cost-optimized (v2.0.0) → unlimited performance (v3.0.0)  
**Branch**: `patio-unlimited-performance`  
**Depends-On**: 
- business/cost-001 v3.0.0
- infrastructure/compute-001 v3.0.0
- infrastructure/storage-001 v3.0.0
- infrastructure/networking-001 v3.0.0
- infrastructure/iac-modules-001 v2.0.0

### Phase M1: Spec Dependency Updates

- [x] T101 Update Patio plan.md Depends-On field with v3.0.0 spec versions in `specs/application/Patio/plan.md`
- [x] T102 Update Constitution Check section in `specs/application/Patio/plan.md` to reflect unlimited performance constraints
- [x] T103 Create git branch `patio-unlimited-performance` and push initial commit with spec updates

### Phase M2: IaC Module Migration - Config & Parameters

- [x] T104 [P] Update config.bicep VM SKU allowed values (D32+, M192+, GPU) in `artifacts/applications/Patio/iac/config.bicep`
- [x] T105 [P] Add GPU acceleration parameters (enableGpuAcceleration, gpuSku) to `artifacts/applications/Patio/iac/config.bicep`
- [x] T106 [P] Update config.bicep storage SKU allowed values (Premium LRS, Premium ZRS, PremiumV2, UltraSSD) in `artifacts/applications/Patio/iac/config.bicep`
- [x] T107 [P] Add Ultra Disk parameters (enableUltraDisk, ultraDiskIops, ultraDiskThroughput) to `artifacts/applications/Patio/iac/config.bicep`
- [x] T108 [P] Change disk encryption default from conditional to always-enabled in `artifacts/applications/Patio/iac/config.bicep`
- [x] T109 [P] Add customer-managed encryption parameter for production in `artifacts/applications/Patio/iac/config.bicep`
- [x] T110 Update version tag to '3.0.0' in `artifacts/applications/Patio/iac/config.bicep` header

- [x] T111 [P] Update dev.bicepparam: VM SKU→Standard_D32ds_v5, Storage→Premium_ZRS, Encryption→enabled in `artifacts/applications/Patio/iac/dev.bicepparam`
- [x] T112 [P] Update test.bicepparam: VM SKU→Standard_D48ds_v5, Storage→Premium_ZRS, Encryption→enabled in `artifacts/applications/Patio/iac/test.bicepparam`
- [x] T113 [P] Update prod.bicepparam: VM SKU→Standard_D96ds_v5, Storage→Premium_ZRS/Ultra, Encryption→customer-managed in `artifacts/applications/Patio/iac/prod.bicepparam`
- [x] T114 [P] Add costProfile parameter (unlimited-performance) to all parameter files in `artifacts/applications/Patio/iac/`

### Phase M2: IaC Module Migration - Infrastructure Files

- [x] T115 Update automation.bicep header & add GPU monitoring extension parameter in `artifacts/applications/Patio/iac/automation.bicep`
- [x] T116 Add network acceleration & disk I/O tuning to automation.bicep in `artifacts/applications/Patio/iac/automation.bicep`
- [x] T117 Update monitoring.bicep with performance metrics collection (latency, throughput, GPU) in `artifacts/applications/Patio/iac/monitoring.bicep`
- [x] T118 Create Application Insights queries and custom dashboards in monitoring.bicep in `artifacts/applications/Patio/iac/monitoring.bicep`
- [x] T119 Update security.bicep: Key Vault Premium, CMK, key rotation policy in `artifacts/applications/Patio/iac/security.bicep`
- [x] T120 Update main.bicep with spec version metadata and deployment tags in `artifacts/applications/Patio/iac/main.bicep`

### Phase M2: Documentation Updates

- [x] T121 Update README.md with unlimited performance strategy section in `artifacts/applications/Patio/iac/README.md`
- [x] T122 Add GPU workload deployment examples to README.md in `artifacts/applications/Patio/iac/README.md`
- [x] T123 Add success metrics section (60%+ latency reduction, 300%+ GPU speedup) to README.md in `artifacts/applications/Patio/iac/README.md`
- [x] T124 Update CHANGELOG.md documenting breaking changes v2.0.0→v3.0.0 in `artifacts/applications/Patio/iac/CHANGELOG.md`

### Phase M3: Bicep Validation

- [x] T125 [P] Run `bicep build` on all config/automation/monitoring/security/main.bicep files in `artifacts/applications/Patio/iac/`
- [x] T126 [P] Validate all .bicepparam parameter files against Bicep schema in `artifacts/applications/Patio/iac/`
- [x] T127 Run `bicep lint` on all modules to check code quality in `artifacts/applications/Patio/iac/`
- [x] T128 Commit validation results with message "[Patio IaC] Phase M3: Bicep validation complete"

### Phase M4: Dev Environment Testing

- [ ] T129 Run `az deployment group create --what-if` on dev to preview changes in rg-patio-dev
- [ ] T130 Deploy IaC to dev: `az deployment group create` with dev.bicepparam in rg-patio-dev
- [ ] T131 Run smoke tests on dev (connectivity, storage, VM login) on `artifacts/applications/Patio/iac/`
- [ ] T132 Validate Application Insights metrics collection in dev environment
- [ ] T133 Review Azure Monitor dashboard for performance baseline in dev environment
- [ ] T134 Document dev deployment results and metrics

### Phase M5: Test Environment Validation

- [ ] T135 Run `az deployment group create --what-if` on test to preview changes in rg-patio-test
- [ ] T136 Deploy IaC to test: `az deployment group create` with test.bicepparam in rg-patio-test
- [ ] T137 Run comprehensive smoke tests on test environment
- [ ] T138 Baseline performance metrics: latency p50/p95/p99, throughput (MB/s)
- [ ] T139 Monitor Azure Monitor dashboards for 24+ hours, identify anomalies
- [ ] T140 Document test results and 60%+ latency improvement vs v2.0.0

### Phase M6: Production Deployment

- [ ] T141 Obtain CTO/governance approval for prod deployment per governance-001 spec
- [ ] T142 Run `az deployment group create --what-if` on prod to preview changes in rg-patio-prod
- [ ] T143 Deploy IaC to prod: `az deployment group create` with prod.bicepparam in rg-patio-prod
- [ ] T144 Run smoke tests on prod, monitor dashboards 24/7 for 48+ hours
- [ ] T145 Validate performance against test baseline (confirm 60%+ latency reduction)

### Phase M7: Documentation & Handoff

- [ ] T146 Update `specs/application/Patio/quickstart.md` with unlimited performance examples
- [ ] T147 Update `specs/application/Patio/plan.md` to reference v3.0.0 dependencies
- [ ] T148 Create performance benchmarking report (v2.0.0 vs v3.0.0 improvements)
- [ ] T149 Schedule team training on new performance capabilities

### Phase M8: Git & Release

- [ ] T150 Review all code changes with git diff
- [ ] T151 Merge patio-unlimited-performance branch to main with approval
- [ ] T152 Tag release as `patio-iac-v3.0.0`
- [ ] T153 Archive iac-modernization-plan.md in `specs/application/Patio/` for future reference

---

## Parallel Execution Opportunities (Modernization Phase)

**Can run simultaneously**:
- T104-T110: config.bicep updates
- T111-T114: parameter file updates (dev, test, prod independent)
- T115-T120: automation/monitoring/security/main bicep updates
- T125-T127: Bicep validation (`bicep build` operations)
- T129-T134: Dev testing (after T128 validation)

**Must complete sequentially**:
- T128 validation BEFORE T129+ deployment
- T135+ test BEFORE T141+ prod approval
- T150+ merge AFTER all testing complete

---

## Success Criteria (Modernization Phase)

✅ All tasks T101-T153 completed  
✅ Bicep compilation: All files build without errors  
✅ Parameter validation: All .bicepparam validate successfully  
✅ Performance improvements:
  - Latency reduction: 60%+ vs v2.0.0 baseline
  - Throughput improvement: 3-10x for Premium storage
  - GPU availability: Ready for AI/ML (if enabled)
✅ Spec compliance: IaC references cost-001 v3.0.0  
✅ Team trained and handoff complete  
✅ Code merged to main with v3.0.0 release tag
