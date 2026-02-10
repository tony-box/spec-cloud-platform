# Specification: [SPEC_NAME]

**Tier**: [platform | business | security | infrastructure | devops | application]  
**Spec ID**: [###-spec-name]  
**Created**: [DATE]  
**Status**: Draft | Approved  
**Input**: User description: "$ARGUMENTS"  
**Depends-On** (mandatory upstream tier specs per Constitution §III): [[tier/category/spec.md versions that constrain this spec]]

---

## 🎯 IMPORTANT: Role Declaration Protocol (Per Constitution §II)

This spec was created via:
- **Role Declared**: [Platform | Business | Security | Infrastructure | DevOps | Application]
- **Category Target** (required for non-application roles): [spec-system | iac-linting | artifact-org | policy-as-code | cost | data-protection | networking | observability | ...]
- **Application Target** (required for Application role): [NEW: app-name | EXISTING: app-name]

> Constitution §II requires ALL spec updates to begin with explicit role declaration. This ensures clarity on which tier is being modified and how the spec hierarchy is affected.

---

## Spec Source & Hierarchy

**Parent Tier Specs** (constraints that apply to this spec):
- [List specs from the tier above this one that constrain this specification]
- Example: If this is an infrastructure spec, list the business & security specs it must align with

**Derived Downstream Specs** (specs that will depend on this one):
- [List specs in the tier(s) below that will inherit constraints from this spec]
- Example: If this is a security spec, list application specs that must comply

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.
  
  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - [Brief Title] (Priority: P1)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently - e.g., "Can be fully tested by [specific action] and delivers [specific value]"]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]
2. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### User Story 2 - [Brief Title] (Priority: P2)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### User Story 3 - [Brief Title] (Priority: P3)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

[Add more user stories as needed, each with an assigned priority]

### Edge Cases

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right edge cases.
-->

- What happens when [boundary condition]?
- How does system handle [error scenario]?

## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional/operational requirements.
  
  For Tier-Specific Examples:
  - Business: Budget caps, cost reduction targets, SLA uptime requirements, compliance mandates
  - Security: Policy-as-code rules, encryption requirements, audit logging, threat models
  - Infrastructure: Landing zone design, resource naming conventions, module versioning, pipeline stages
  - Application: API contracts, feature flags, deployment strategies, observability requirements
-->

### Functional Requirements

- **REQ-001**: System MUST [specific capability, e.g., "support cost reduction targets of 5-30%"]
- **REQ-002**: System MUST [specific capability, e.g., "enforce NIST 800-171 policy requirements"]  
- **REQ-003**: System MUST [key interaction, e.g., "cascade spec changes through all dependent tiers"]
- **REQ-004**: System MUST [data requirement, e.g., "maintain audit trail of all spec changes"]
- **REQ-005**: System MUST [behavior, e.g., "generate Azure Policy definitions from security specs"]

*Example of marking unclear requirements:*

- **REQ-006**: System MUST deploy to Azure via [NEEDS CLARIFICATION: Bicep, Terraform, or ARM templates?]
- **REQ-007**: System MUST validate against [NEEDS CLARIFICATION: which compliance frameworks - NIST, ISO, PCI?]

### Key Entities *(include if spec involves data or artifacts)*

- **[Entity 1]**: [What it represents, key attributes without implementation]
  - Example for infrastructure tier: "Landing Zone Module - encapsulates resource group, networking, policies, monitoring"
- **[Entity 2]**: [What it represents, relationships to other entities]

### Tier-Specific Constraints *(mandatory - depends on spec tier)*

**IF Business Tier**:
- Cost budget/targets
- SLA requirements (uptime, RTO, RPO)
- Compliance/governance mandates
- Headcount/team structure impact

**IF Security Tier**:
- Compliance frameworks (NIST, ISO, PCI, SOC 2, etc.)
- Encryption standards
- Network isolation requirements
- Authentication/authorization models
- Audit logging requirements

**IF Infrastructure Tier**:
- Azure service/SKU choices constrained by business budgets & security policies
- Landing zone structure
- Network design (hub-and-spoke, mesh, etc.)
- Module versioning & compatibility
- Pipeline stages & approval gates

**IF Application Tier**:
- Feature requirements constrained by infrastructure capabilities & security policies
- Performance SLAs (latency, throughput)
- Deployment strategy (blue-green, canary, etc.)
- Scaling constraints & limits
- **ARTIFACT ORGANIZATION** (Required per `specs/platform/001-application-artifact-organization/spec.md`):
  - **NEW Applications**: 
    - All artifacts MUST use standardized directory structure: `/artifacts/applications/[app-name]/`
    - Required subdirectories: `iac/`, `modules/`, `scripts/`, `pipelines/`, `docs/`
    - Application directory created automatically via `./artifacts/.templates/scripts/create-app-directory.ps1 -AppName "[app-name]"`
  - **EXISTING Applications**:
    - Artifacts MUST reuse existing directory: `/artifacts/applications/[app-name]/` (check before creating)
    - All changes confined to existing application directory (do NOT create new directories)
    - If directory doesn't exist yet, create using the same script
    - Validation ensures existing structure is compliant
  - Naming conventions: `<appname>-<component>.bicep` (IaC), `<appname>-<purpose>.<ext>` (scripts)
  - Validation: Run `./artifacts/.templates/scripts/validate-artifact-structure.ps1 -AppName "[app-name]"` before deployment

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be testable and tied to spec user stories.
  
  For Platform Specs: Success = AI-generated outputs are correct, complete, aligned with parent specs, and pass human review.
-->

### Measurable Outcomes

- **SC-001**: [Measurable metric, e.g., "Cost reduction achieved within 5% of target"]
- **SC-002**: [Measurable metric, e.g., "100% of new IaC modules pass policy compliance scanning"]
- **SC-003**: [User outcome, e.g., "Infrastructure team can generate landing zone IaC in <5 min via prompt"]
- **SC-004**: [Quality metric, e.g., "All AI-generated artifacts reviewed & approved by platform team within 24h"]

## Artifact Generation & Human Review

**Generated Outputs** (AI-assisted, human-reviewed per constitution):
- [e.g., "Bicep modules for cost-optimized compute", "Azure Policy definitions", "GitHub Actions CI/CD pipelines", "Application deployment specs"]

**Review Checklist**:
- [ ] Outputs correctly implement this spec
- [ ] Outputs align with all parent tier specs (no constraint violations)
- [ ] Cost estimates match business tier budgets
- [ ] Policy compliance verified via Azure Policy scanning
- [ ] Code quality passes linting & best practices
- [ ] Traceability to source spec is documented
- [ ] Outputs are versioned & tagged with spec version
