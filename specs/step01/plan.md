# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]  
**Input**: Feature specification from `/specs/[tier]/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

---

## 🎯 IMPORTANT: Role Declaration Protocol (Per Constitution §II)

This plan was created via:
- **Role Declared**: [Platform | Business | Security | Infrastructure | Application]
- **Application Target** (if Application role): [NEW: app-name | EXISTING: app-name]
- **Source Tier Specs**: [List parent specs this plan implements]

> Constitution §II requires ALL spec updates (and derived plans) to maintain role declaration context. Verify this plan's tier tier alignment and parent spec references.

---

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: [e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION]  
**Primary Dependencies**: [e.g., FastAPI, UIKit, LLVM or NEEDS CLARIFICATION]  
**Storage**: [if applicable, e.g., PostgreSQL, CoreData, files or N/A]  
**Testing**: [e.g., pytest, XCTest, cargo test or NEEDS CLARIFICATION]  
**Target Platform**: [e.g., Linux server, iOS 15+, WASM or NEEDS CLARIFICATION]  
**Project Type**: [single/web/mobile - determines source structure]  
**Performance Goals**: [domain-specific, e.g., 1000 req/s, 10k lines/sec, 60 fps or NEEDS CLARIFICATION]  
**Constraints**: [domain-specific, e.g., <200ms p95, <100MB memory, offline-capable or NEEDS CLARIFICATION]  
**Scale/Scope**: [domain-specific, e.g., 10k users, 1M LOC, 50 screens or NEEDS CLARIFICATION]

## Constitution Check: Tier Alignment & Spec Cascading

*GATE: Must verify this spec aligns with parent tier constraints before Phase 0 research.*

- **Spec Tier**: [business | security | infrastructure | application]
- **Parent Tier Specs**: [Reference to specs in next-higher tier that constrain this spec]
- **Derived Constraints**: [List specific rules, limits, or requirements inherited from parent tier]
- **Artifact Traceability**: This spec will generate the following outputs (AI-assisted, human-reviewed):
  - [e.g., "Bicep modules for cost-optimized VMs", "Azure Policy definitions", "GitHub Actions pipelines", "Application deployment manifests"]

*Re-check after Phase 1 design to ensure generated artifacts align with all tier constraints.*

## Spec Organization & Four-Tier Structure

### Business-Tier Specifications (`/specs/business/`)
Operational requirements, budgets, cost targets, SLAs, business objectives. Platform updates at this level cascade through all downstream tiers.

### Security-Tier Specifications (`/specs/security/`)
Compliance frameworks (NIST, ISO), policy-as-code rules, threat models. Derived from business requirements; constrains infrastructure and application choices.

### Infrastructure-Tier Specifications (`/specs/infrastructure/`)
Azure landing zones, networking design, IaC module catalogs, pipeline templates, observability policies. Derived from business + security tiers; used by application teams.

### Application-Tier Specifications (`/specs/application/`)
Application architecture, feature specs, performance SLAs, deployment patterns. Constrained by business, security, and infrastructure tiers.

### Documentation for This Specification

```text
specs/[TIER-NAME]/[###-feature]/
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
# [REMOVE IF UNUSED] Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [REMOVE IF UNUSED] Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [REMOVE IF UNUSED] Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure: feature modules, UI flows, platform tests]
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
