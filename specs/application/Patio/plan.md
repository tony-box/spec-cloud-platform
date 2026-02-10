# Implementation Plan: Patio App IaC

**Branch**: `002-app-iac` | **Date**: February 10, 2026 | **Spec**: [specs/application/Patio/spec.md](specs/application/Patio/spec.md)  
**Input**: Feature specification from /specs/application/Patio/spec.md  
**Depends-On**: platform/spec-system (spec-001 v1.0.0-draft), platform/iac-linting (lint-001 v1.0.0-draft), platform/policy-as-code (pac-001 v1.0.0-draft), platform/artifact-org (artifact-001 v1.0.0), platform/001-application-artifact-organization (platform-001, draft 2026-02-05), business/compliance-framework (comp-001 v1.0.0-draft), business/governance (gov-001 v1.0.0-draft), business/cost (cost-001 v2.0.0), security/access-control (ac-001 v1.0.0-draft), security/data-protection (dp-001 v1.0.0), security/audit-logging (audit-001 v1.0.0-draft), infrastructure/compute (compute-001 v2.0.0), infrastructure/networking (net-001 v2.0.0), infrastructure/storage (stor-001 v2.0.0), infrastructure/cicd-pipeline (cicd-001 v2.0.0), infrastructure/iac-modules (iac-001 v1.0.0-draft), devops/deployment-automation (deploy-001 v1.0.0-placeholder), devops/observability (obs-001 v1.0.0-placeholder), devops/environment-management (env-001 v1.0.0-placeholder), devops/ci-cd-orchestration (cicd-orch-001 v1.0.0-placeholder)

**Note**: This plan follows the `/speckit.plan` workflow from .specify/templates/commands/plan.md.

---

## 🎯 IMPORTANT: Role Declaration Protocol (Per Constitution §II)

This plan was created via:
- **Role Declared**: Application
- **Category Target** (required for non-application roles): N/A (application role)
- **Application Target** (required for Application role): NEW: Patio
- **Source Tier Specs**: specs/platform/001-application-artifact-organization/spec.md, specs/security/access-control/spec.md, specs/security/data-protection/spec.md, specs/security/audit-logging/spec.md, specs/infrastructure/networking/spec.md, specs/infrastructure/compute/spec.md, specs/infrastructure/storage/spec.md, specs/business/cost/spec.md

> Constitution §II requires ALL spec updates (and derived plans) to maintain role declaration context. Verify this plan's tier alignment and parent spec references.

---

## Summary

Deliver a Patio infrastructure configuration (IaC) plan that defines environments, resource scope, security and compliance alignment, and cost guardrails, while enforcing platform artifact organization and upstream tier constraints through standardized IaC modules and CI/CD governance.

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: Bicep (Azure Bicep CLI), PowerShell 7 for scripts, YAML for pipelines  
**Primary Dependencies**: Azure Verified Modules (AVM) wrappers, Azure CLI, GitHub Actions  
**Storage**: N/A for spec; storage choices governed by infrastructure/storage spec  
**Testing**: `bicep build` validation, PSScriptAnalyzer, YAML validation in CI/CD  
**Target Platform**: Microsoft Azure (US regions only)  
**Project Type**: IaC specification and artifact planning  
**Performance Goals**: Workload SLAs and performance expectations defined by workload criticality tiers  
**Constraints**: Encryption (AES-256), TLS 1.2+, RBAC + MFA, audit logging retention (3 years), cost baselines, multi-zone for critical workloads  
**Scale/Scope**: 3 environments (dev/test/prod); workload criticality to be confirmed per environment

## Constitution Check: Tier Alignment & Spec Cascading

*GATE: Must verify this spec aligns with parent tier constraints before Phase 0 research. (Per Constitution §III)*

**Upstream Tier Validation** (MANDATORY per Constitution §III):
- [x] **Load all upstream tier specs**: Platform, Business, Security, Infrastructure, DevOps specs loaded from `specs/<tier>/**/spec.md`
- [x] **Verify no constraint violations**: No conflicts detected with upstream requirements; plan aligns with all constraints
- [x] **Document depends-on field**: Upstream spec versions captured in Depends-On above
- **Failure Protocol**: N/A (no violations)

**Spec-Tier Alignment**:
- **Spec Tier**: application
- **Parent Tier Specs**: platform/* (spec-system, iac-linting, policy-as-code, artifact-org, application-artifact-organization), business/* (cost, governance, compliance-framework), security/* (access-control, data-protection, audit-logging), infrastructure/* (compute, networking, storage, cicd-pipeline, iac-modules), devops/* (deployment-automation, observability, environment-management, ci-cd-orchestration)
- **Derived Constraints**:
  - Artifact directories must follow /artifacts/applications/patio/ with required subdirectories and naming rules
  - US-only regions, AES-256 at rest, TLS 1.2+ in transit, Key Vault HSM for production
  - Workload criticality drives cost baselines, SKU choices, multi-zone requirements, and pipeline approvals
  - Audit logs retained for 3 years with immutable storage
  - CI/CD must use GitHub Actions with cost validation and approval gates
- **Artifact Traceability**: This spec will generate the following outputs (AI-assisted, human-reviewed):
  - Patio environment matrix and IaC scope definition
  - Access control, data protection, and audit logging mappings
  - Deployment and rollback guidance with approval checkpoints
  - Artifact inventory for Patio IaC materials

*Re-check after Phase 1 design to ensure generated artifacts align with all tier constraints.*

## Spec Organization & Six-Tier Structure

### Platform-Tier Specifications (`/specs/platform/`)
Foundational standards, spec system rules, artifact organization, policy-as-code, linting.

### Business-Tier Specifications (`/specs/business/`)
Operational requirements, budgets, cost targets, SLAs, business objectives. Platform updates at this level cascade through all downstream tiers.

### Security-Tier Specifications (`/specs/security/`)
Compliance frameworks (NIST, ISO), policy-as-code rules, threat models. Derived from business requirements; constrains infrastructure and application choices.

### Infrastructure-Tier Specifications (`/specs/infrastructure/`)
Azure landing zones, networking design, IaC module catalogs, pipeline templates, observability policies. Derived from business + security tiers; used by application teams.

### DevOps-Tier Specifications (`/specs/devops/`)
Deployment automation, observability, environment management, CI/CD orchestration.

### Application-Tier Specifications (`/specs/application/`)
Application architecture, feature specs, performance SLAs, deployment patterns. Constrained by business, security, and infrastructure tiers.

### Documentation for This Specification

```text
specs/application/Patio/
├── plan.md              # This file (/speckit.plan command output)
├── spec.md              # Phase 0 output - Detailed specification & user stories
├── research.md          # Phase 0 output - Constraints from parent tier
├── data-model.md        # Phase 1 output - Entities & relationships (if applicable)
├── contracts/           # Phase 1 output - API/interface contracts (if applicable)
├── artifact-list.md     # List of generated outputs (IaC, policies, pipelines, etc.)
└── tasks.md             # Phase 2 output - Implementation tasks

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
artifacts/
└── applications/
  └── Patio/
    ├── iac/
    ├── modules/
    ├── scripts/
    ├── pipelines/
    └── docs/
```

**Structure Decision**: IaC-only planning scoped to artifacts/applications/Patio/ for application-specific assets.

## Phase 0 - Research

**Goal**: Resolve technical unknowns and confirm constraints from upstream specs.

**Outputs**:
- research.md with decisions, rationale, and alternatives

## Phase 1 - Design & Contracts

**Goal**: Capture conceptual data model and confirm that no external API contracts are required.

**Outputs**:
- data-model.md
- contracts/README.md
- quickstart.md

## Phase 2 - Planning

**Goal**: Define implementation tasks for Patio IaC artifacts, validation, and rollout.

**Outputs**:
- tasks.md (to be created in Phase 2)

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
