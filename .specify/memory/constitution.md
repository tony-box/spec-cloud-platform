<!-- Sync Impact Report: Constitution v1.0.0 Initial Ratification -->
<!-- ADDED: Five core governance principles for spec-driven tiered development -->
<!-- ADDED: Tier-specific role definitions (Business, Security, Infrastructure, Application) -->
<!-- ADDED: Spec cascading rules ensuring business decisions flow through security → infrastructure → application -->
<!-- ADDED: AI-generated artifact quality gates and human-in-the-loop governance -->

# Azure Spec-Driven Cloud Platform Constitution

The Platform Team governs this project as a "platform as a product," delivering AI-assisted infrastructure and application templates governed by a four-tier specification hierarchy.

## Core Principles

### I. Spec-Driven Tiered Development (NON-NEGOTIABLE)
All platform outputs MUST originate from and align with the four-tier specification hierarchy: Business Requirements → Security Policies → Infrastructure Templates → Application Architecture. Specs at each tier cascade downward; changes at higher tiers MUST propagate through dependent lower tiers. No infrastructure or application code may exist without corresponding spec alignment. The platform team MUST validate that all generated outputs reflect this hierarchy.

### II. Four-Tier Stakeholder Roles with Declared Role Protocol
The platform defines four distinct stakeholder roles, each interfacing via plain-English conversational prompts. ALL spec update requests MUST begin with an explicit role declaration:

**Role Declaration Protocol**:
When any stakeholder requests a spec update, they MUST declare their role FIRST:
1. **Platform**: Updates the core speckit platform framework itself (tier definitions, templates, governance rules, platform tooling)
2. **Business**: Updates business-tier specifications (cost targets, SLAs, operational policies, business requirements)
3. **Security**: Updates security-tier specifications (compliance policies, policy-as-code, threat models, security constraints)
4. **Infrastructure**: Updates infrastructure-tier specifications (landing zones, IaC modules, networking, pipelines, observability)
5. **Application**: Updates application-tier specifications for a specific application (either NEW application or EXISTING application to be named)

**Role Definitions**:
- **Business Role**: Defines operational requirements, budgets, cost targets, SLAs, and business objectives that drive top-level business specifications. Can have multiple specs per business area (e.g., cost-optimization, security-posture, disaster-recovery).
- **Security Role**: Translates business requirements into security policies, compliance standards (NIST, ISO), and policy-as-code constraints that limit infrastructure choices. Can have multiple specs per compliance domain (e.g., encryption-standards, identity-governance, incident-response).
- **Infrastructure Role**: Designs Azure landing zones, networking, IaC modules (using Azure Verified Modules), pipelines, and observability patterns for application and infrastructure teams. Can have multiple specs per infrastructure domain (e.g., compute-modules, networking-design, observability-platform).
- **Application Role**: Specifies application features, architecture, performance requirements, and deployment pipelines constrained by infrastructure and security tiers. MUST specify target application:
  - If **NEW application**: Platform MUST create a new application-specific directory (e.g., `/specs/application/[app-name]/`) containing that application's spec files, plans, and tasks (separate from other applications).
  - If **EXISTING application**: Platform MUST update spec files within that application's existing directory (e.g., update `/specs/application/web-app-001/` files). EXISTING applications are identified by checking if `/specs/application/[app-name]/` or `/artifacts/applications/[app-name]/` already exists; if so, changes are confined to the existing application's directory (no new directories created).
  - **Application Artifact Organization** (Per `specs/platform/001-application-artifact-organization/spec.md` v1.0.0):
    - **NEW Applications**: 
      - Platform MUST automatically execute `./artifacts/.templates/scripts/create-app-directory.ps1 -AppName "[app-name]"` to create compliant directory structure
      - Creates `/artifacts/applications/[app-name]/` with required subdirectories: `iac/`, `modules/`, `scripts/`, `pipelines/`, `docs/`
      - Automatically validates structure and provides guidance to team
    - **EXISTING Applications**:
      - Platform MUST first CHECK if application directory exists (`/artifacts/applications/[app-name]/` or `/specs/application/[app-name]/`)
      - If application EXISTS: REUSE existing directories, validate structure, ensure compliance
      - If application DOES NOT exist: Create new structure using automated script
      - ALL CHANGES for EXISTING applications are confined to existing directory location; no new directories created
      - Validate existing structure and provide status/next steps
    - All artifacts (NEW or EXISTING) MUST follow naming conventions: `<appname>-<component>.bicep` for IaC, `<appname>-<purpose>.<ext>` for scripts
    - Validation required: Run `./artifacts/.templates/scripts/validate-artifact-structure.ps1 -AppName "[app-name]"` before any deployment

Each role operates independently on its tier but MUST respect cascade constraints from higher tiers.

### III. Spec Propagation & Cascading Changes
When business stakeholders update business-tier specs (e.g., "reduce costs 15% year-over-year"), the platform MUST:
1. Document the change in business-tier spec.
2. Audit and regenerate security-tier specs to enforce new cost/SLA constraints.
3. Regenerate infrastructure-tier IaC modules, templates, and design documents reflecting cost optimization.
4. Flag application-tier specs and workloads for review; auto-generate migration work items for existing applications.
5. Track change lineage: which outputs depend on which specs.

This ensures business decisions immediately cascade through the platform, avoiding spec drift.

### IV. AI-Generated Outputs with Human-in-the-Loop Quality Gates
All platform outputs (IaC modules, Bicep templates, GitHub Actions pipelines, policy documents, work items) MUST be generated via AI assistance but reviewed and approved by platform team members before deployment or consumption. No auto-deployment of AI-generated artifacts; human validation is mandatory. The platform team MUST maintain a feedback loop, logging AI output quality, correctness issues, and iterative improvements to prompts and templates.

### V. Observable & Auditable Spec Relationships
Every artifact (IaC module, pipeline, policy, application code deployment) MUST be traceable to its originating spec tier and linked specs. Bidirectional traceability required: spec → generated artifacts, artifacts → source specs. Version specs alongside artifacts; when a spec changes, mark dependent artifacts for regeneration review.

## Tier Specifications Organization

The platform maintains four parallel specification directories under `/specs/` with a multi-spec, hierarchical structure:

### Business Tier (`/specs/business/`)
**Purpose**: Business requirements, cost targets, SLAs, operational policies  
**Structure**: Multiple independent spec files per business domain:
- `001-cost-reduction-targets/spec.md` (business cost targets)
- `002-disaster-recovery-sla/spec.md` (RTO/RPO requirements)
- `003-security-posture/spec.md` (security investment priorities)
- etc.

Each business spec is independently versioned but all cascade down to security/infrastructure/application tiers.

### Security Tier (`/specs/security/`)
**Purpose**: Compliance frameworks, policy-as-code rules, threat models, security policies derived from business tier  
**Structure**: Multiple independent spec files per compliance/security domain:
- `001-encryption-standards/spec.md` (derived from business/001)
- `002-identity-governance/spec.md` (derived from business/002)
- `003-incident-response/spec.md` (derived from business/003)
- etc.

Each security spec must cite its parent business spec(s) and flows down to infrastructure/application tiers.

### Infrastructure Tier (`/specs/infrastructure/`)
**Purpose**: Azure landing zones, networking, module catalogs, pipeline templates, observability policies derived from business + security tiers  
**Structure**: Multiple independent spec files per infrastructure domain:
- `001-compute-modules/spec.md` (derived from business/001, security/001)
- `002-networking-design/spec.md` (derived from business/002, security/002)
- `003-observability-platform/spec.md` (derived from business/003, security/003)
- etc.

Each infrastructure spec must cite its parent business and security specs and flows down to application tier.

### Application Tier (`/specs/application/`)
**Purpose**: Application architecture, feature specs, performance requirements, deployment patterns derived from business + security + infrastructure tiers  
**Structure**: Application-specific directory hierarchies (separate directory per application):
- `/specs/application/web-app-001/` — Single application's specs, plans, tasks (NEW app)
  - `spec.md` (application spec)
  - `plan.md` (implementation plan)
  - `tasks.md` (work breakdown)
- `/specs/application/api-service-002/` — Another application's specs, plans, tasks
- etc.

When application role requests update for a NEW application, platform creates entire `/specs/application/[app-name]/` directory structure with standard spec/plan/tasks templates.  
When application role requests update for an EXISTING application, platform modifies files within that application's directory.

### Common Pattern for All Tiers (except Application)
Each tier spec MUST include:
- **Source Specs**: References to parent tier specs that constrain this tier.
- **Derived Constraints**: Specific rules, SKU limitations, cost budgets, security policies, or architectural patterns inherited from above.
- **Generated Outputs**: IaC modules, pipelines, policy documents, configuration templates generated from these specs (with AI assistance).
- **Version/Change Log**: Tracks when specs change and why (business decision, security update, cost optimization, etc.).

## AI-Generated Artifact Standards

All AI-generated platform outputs MUST conform to:
- **Spec Alignment**: Traceable to at least one specification tier; cite source specs in artifact comments or headers.
- **Validation Tests**: Infrastructure outputs MUST include cost estimation, policy compliance checks, and deployment tests.
- **Code Quality**: IaC modules MUST use Azure Verified Modules; Bicep/Terraform MUST follow Microsoft best practices; GitHub Actions pipelines MUST include security scanning.
- **Observability**: All templates MUST include logging, metrics, and diagnostics integration.
- **Versioning**: Artifact version MUST increment when source specs change; maintain compatibility matrix.
- **Documentation**: Generated artifacts MUST include inline comments linking to source specs and human-readable summaries of constraints applied.

## Development Workflow & Quality Gates

### Role Declaration Protocol (MANDATORY FIRST STEP)

**STEP 0: ROLE DECLARATION**
ALL spec update requests MUST begin with explicit role declaration:
- **Role: Platform** — Updates core platform framework (tier definitions, templates, governance, platform tooling)
- **Role: Business** — Updates business-tier specs (cost targets, SLAs, operational policies)
- **Role: Security** — Updates security-tier specs (compliance policies, policy-as-code, threat models)
- **Role: Infrastructure** — Updates infrastructure-tier specs (landing zones, IaC modules, networking, pipelines)
- **Role: Application** — Updates application-tier specs (requires application target specification)

**Application Role Specification**:
When declaring "Role: Application", stakeholder MUST also specify:
- **Application: NEW: [app-name]** — Create new application directory and specs
- **Application: EXISTING: [app-name]** — Update existing application's specs

### Spec Update Workflow (Steps 1-6)
1. Stakeholder declares role + application target (if Application role).
2. Platform AI acknowledges role and validates tier context.
3. Stakeholder creates or updates spec via platform chat; AI assists in refining spec.
4. Platform team reviews for clarity, feasibility, and hierarchy compliance.
5. Once approved, spec is versioned and tagged with date, rationale, and approver.
6. Platform triggers dependent artifact regeneration (specs cascade downward per Principle III).
7. Generated artifacts are staged for human review; platform team inspects AI outputs, tests deployments, flags issues.
8. Approved artifacts are promoted to production; work items are created for teams to consume or migrate to new versions.

### Application-Tier Specific Workflow

**CASE A: NEW APPLICATION** (declared as "Application: NEW: my-app-name")
- Platform MUST:
  1. Create `/specs/application/my-app-name/` directory structure
  2. Populate with standard templates: `spec.md`, `plan.md`, `tasks.md`
  3. Reference parent infrastructure/security/business specs in new spec
  4. Prompt user to fill in application-specific requirements
  5. Version as v1.0.0 (new application)
  6. Auto-generate work items and cascading downstream artifacts

**CASE B: EXISTING APPLICATION** (declared as "Application: EXISTING: my-app-name")
- Platform MUST:
  1. Locate `/specs/application/my-app-name/` directory
  2. Review existing `spec.md`, `plan.md`, `tasks.md` files
  3. Update appropriate file(s) based on user request
  4. Increment version (PATCH/MINOR/MAJOR as appropriate)
  5. Maintain changelog and audit trail
  6. Auto-generate work items and cascading downstream artifact updates

### Artifact Review Gates
- **IaC Modules**: Cost estimates must align with business tier budgets; policy-as-code scanning must pass all security policies.
- **Bicep Templates**: Must successfully deploy in test subscription; must validate policy compliance.
- **GitHub Actions Pipelines**: Must run successfully in CI environment; security scanning (SAST, dependency checks) must pass.
- **Work Items & Change Logs**: Must document spec source, cost impact, security changes, and migration steps.

## Governance

The Platform Team holds authority over:
- Spec hierarchy and tier definitions.
- Quality standards for AI-generated artifacts.
- Change approval workflow and cascade rules.
- Tool selection and integration (AI models, IaC frameworks, CI/CD platforms).

### Amendment Procedure
Changes to this constitution require:
1. **Rationale**: Document the change and why (e.g., new security tier, new role, new artifact type).
2. **Impact Assessment**: Identify which tier specs, templates, and workflows are affected.
3. **Migration Plan**: If removing or redefining a principle, outline how existing artifacts migrate.
4. **Platform Team Review & Vote**: Unanimous consensus required for MAJOR version bumps (e.g., new tier, new principle); simple majority for MINOR/PATCH updates.
5. **Version Increment**: MAJOR for backward-incompatible governance changes, MINOR for new specs/roles/artifact types, PATCH for clarifications.
6. **Documentation**: Publish amendment date, version, and rationale in this file.

### Compliance Review Cadence
Platform team MUST conduct quarterly compliance audits:
- Are all active artifacts traceable to current specs?
- Have any specs drifted from their parent tier constraints?
- Are AI-generated outputs meeting quality standards?
- Are there spec-to-artifact version mismatches?

Issues discovered trigger spec/artifact regeneration or manual correction within 30 days.

---

**Version**: 1.1.0 | **Ratified**: 2026-02-05 | **Last Amended**: 2026-02-05 (Amendment: Role Declaration Protocol & Multi-Spec Tier Organization)
