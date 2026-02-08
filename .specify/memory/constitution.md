<!-- 
═══════════════════════════════════════════════════════════════════════════════
SYNC IMPACT REPORT: Constitution v1.1.0 → v1.2.0 (2026-02-07)
═══════════════════════════════════════════════════════════════════════════════

VERSION CHANGE:
  Old: v1.1.0 (Role Declaration Protocol & Multi-Spec Tier Organization)
  New: v1.2.0 (Category-Based Spec System & 5-Tier Precedence Hierarchy)
  Bump Rationale: MINOR - New category-based organization system, expanded from 
                  4-tier to 5-tier hierarchy (added Platform tier), 14 granular 
                  categories replacing numbered specs, non-breaking governance update

MODIFIED SECTIONS:
  1. Principle I: "Spec-Driven Tiered Development"
     - Updated from 4-tier to 5-tier hierarchy (business > security > infrastructure > platform > application)
     - Replaced numbered spec references with category-based references
     - Added category-based versioning and precedence concepts
  
  2. Principle II: "Four-Tier Stakeholder Roles" → "Five-Tier Stakeholder Roles"
     - Renamed from "Four-Tier" to "Five-Tier" (added Platform tier)
     - Updated Platform role description (now manages platform-tier specs: spec-system, iac-linting, artifact-org, policy-as-code)
     - Clarified role-to-tier mapping with category examples
  
  3. "Tier Specifications Organization" section: COMPLETE REWRITE
     - Replaced numbered spec structure (001-cost-reduction-targets) with category structure (cost/spec.md)
     - Added 14 categories across 4 operational tiers (business: 3, security: 3, infrastructure: 4, platform: 4)
     - Added YAML frontmatter specification (tier, category, spec-id, version, dependencies, precedence)
     - Added root manifest (specs.yaml), tier indexes (_categories.yaml), application registry (_index.yaml)
     - Documented 7 formalized conflict resolution patterns
     - Added precedence resolution algorithm (tier-level → explicit overrides → category precedence → DAG dependencies)

ADDED SECTIONS:
  - Category-based directory structure (specs/<tier>/<category>/spec.md)
  - Root manifest system (specs.yaml with 5 tiers, 14 categories, 7 conflicts)
  - Tier-specific category indexes (business/_categories.yaml, security/_categories.yaml, etc.)
  - Application adoption registry (application/_index.yaml)
  - YAML frontmatter standard (mandatory fields: tier, category, spec-id, version, status)
  - Precedence override mechanism (precedence.overrides field)
  - Formalized conflict patterns (cost vs security, governance vs access-control, etc.)

REMOVED SECTIONS: None (all prior governance preserved, structure modernized)

TEMPLATES REQUIRING UPDATES:
  ✅ .specify/templates/spec-template.md - Already uses category-based frontmatter
  ✅ .specify/templates/plan-template.md - No changes required (constitution-agnostic)
  ✅ .specify/templates/tasks-template.md - No changes required (constitution-agnostic)
  ✅ .specify/templates/commands/*.md - No changes required (mode commands constitution-agnostic)

FOLLOW-UP TODOS: None - all placeholders resolved

PROPAGATION STATUS:
  ✅ Core spec system operational (14 category specs created)
  ✅ Manifest system deployed (specs.yaml + 5 tier indexes)
  ✅ Application adoption tracked (mycoolapp references 14 upstream categories)
  ✅ Precedence rules documented (7 conflicts formalized)
  ✅ Constitution updated to reflect reality
  
═══════════════════════════════════════════════════════════════════════════════
-->

# Azure Spec-Driven Cloud Platform Constitution

The Platform Team governs this project as a "platform as a product," delivering AI-assisted infrastructure and application templates governed by a four-tier specification hierarchy.

## Core Principles

### I. Spec-Driven Category-Based Development (NON-NEGOTIABLE)
All platform outputs MUST originate from and align with the five-tier specification hierarchy: Business Requirements → Security Policies → Infrastructure Templates → Platform Standards → Application Architecture. The platform implements a **category-based spec system** where each tier contains multiple independent categories (14 categories total across 4 operational tiers). Specs cascade downward via explicit dependencies; changes at higher tiers MUST propagate through dependent lower tiers following documented precedence rules. No infrastructure or application code may exist without corresponding spec alignment. The platform team MUST validate that all generated outputs reflect this hierarchy.

**Categorive-Tier Stakeholder Roles with Declared Role Protocol
The platform defines five distinct stakeholder roles mapped to the 5-tier hierarchy, each interfacing via plain-English conversational prompts. ALL spec update requests MUST begin with an explicit role declaration:

**Role Declaration Protocol**:
When any stakeholder requests a spec update, they MUST declare their role FIRST:
1. **Platform**: Updates platform-tier specifications (spec-system, iac-linting, artifact-org, policy-as-code) OR core speckit framework (tier definitions, templates, governance rules)
2. **Business**: Updates business-tier category specifications (cost, governance, compliance-framework)
3. **Security**: Updates security-tier category specifications (data-protection, access-control, audit-logging)
4. **Infrastructure**: Updates infrastructure-tier category specifications (compute, networking, storage, cicd-pipelinequests MUST begin with an explicit role declaration:

**Role Declaration Protocol**:
When any stakeholder requests a spec update, they MUST declare their role FIRST:
1. *Platform Role**: Manages platform-tier category specs (artifact-org, iac-linting, policy-as-code, spec-system) defining platform standards and tooling, OR updates core speckit framework (tier definitions, templates, governance rules). Platform tier categories: `artifact-org` (directory structure), `iac-linting` (code quality), `policy-as-code` (Azure Policy enforcement), `spec-system` (meta-spec defining category system itself).
- **Business Role**: Manages business-tier category specs defining strategic decisions and operational requirements. Business tier categories: `cost` (budget targets, cost optimization), `governance` (approval workflows, SLAs, change management), `compliance-framework` (NIST 800-171, data residency, retention policies). Each category versions independently.
- **Security Role**: Manages security-tier category specs translating business requirements into security controls and compliance policies. Security tier categories: `data-protection` (encryption, key management, TLS), `access-control` (authentication, RBAC, MFA), `audit-logging` (auditd, monitoring, log retention). Each category can override business-tier specs when security non-negotiable.
- **Infrastructure Role**: Manages infrastructure-tier category specs designing Azure technical implementation. Infrastructure tier categories: `compute` (VM SKUs, autoscaling, reserved instances), `networking` (VNets, NSGs, load balancing), `storage` (disk tiers, backup, replication), `cicd-pipeline` (deployment automation, approval gates). Each category depends on upstream business/security constraints.
- **Application Role**: Manages application-tier specs for specific applications, adopting upstream category specs from business/security/infrastructure/platform
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
implements a **category-based spec system** with 14 categories across 5 tiers, governed by a root manifest and tier-specific category indexes. Directory structure: `/specs/<tier>/<category>/spec.md`

### Root Manifest & Indexes

**Root Manifest** (`/specs/specs.yaml`):
- Defines 5-tier hierarchy with priority levels (business=0 → application=4)
- Lists all 14 categories across 4 operational tiers
- Documents 7 formalized conflict patterns with precedence rules
- Declares category precedence within tiers
- 200+ lines, canonical source of truth for tier/category relationships

**Tier-Specific Category Indexes**:
- `/specs/business/_categories.yaml` (3 categories: compliance-framework > governance > cost)
- `/specs/security/_categories.yaml` (3 categories: data-protection ≈ access-control > audit-logging)
- `/specs/infrastructure/_categories.yaml` (4 categories: workload-dependent precedence)
- `/specs/platform/_categories.yaml` (4 categories: spec-system ≈ iac-linting foundational)
- Each index lists category IDs, names, descriptions, current versions, precedence order

**Application Registry** (`/specs/application/_index.yaml`):
- Lists all registered applications (e.g., mycoolapp)
- Tracks upstream category dependencies per application
- Documents compliance status with category specs

### Business Tier (`/specs/business/`)
**Purpose**: Strategic decisions, operational requirements, budget targets  
**Priority**: 0 (highest tier in 5-tier hierarchy)  
**Categories** (3 total):

1. **Cost** (`business/cost/spec.md`, spec-id: `cost-001`)
   - Purpose: Budget targets, cost optimization, reserved instance strategies
   - Example: 10% year-over-year cost reduction, 3-year reserved instance commitments
   - Precedence: Loses to security/data-protection (encryption non-negotiable), compliance-framework (regulatory binding)
   - Status: Published v1.0.0

2. **Governance** (`business/governance/spec.md`, spec-id: `gov-001`)
   - Purpose: Approval workflows, SLA definitions, change management, break-glass procedures
   - Example: Production requires approval, 99.95% SLA critical workloads, 99% SLA non-critical
   - Precedence: Wins over cost, loses to security/access-control (foundational security)
   - Status: Draft v1.0.0-draft

3. **Compliance-Framework** (`business/compliance-framework/spec.md`, spec-id: `comp-001`)
   - Purpose: Regulatory requirements (NIST 800-171), data residency, retention policies, audit schedules
   - Example: US regions only, 7-year retention, annual compliance audits
   - Precedence: OVERRIDES cost and storage (regulatory requirements binding)
   - Status: Draft v1.0.0-draft

### Security Tier (`/specs/security/`)
**Purpose**: Security controls, compliance policies, threat mitigation  
**Priority**: 1 (second-highest tier)  
**Categories** (3 total):

1. **Data-Protection** (`security/data-protection/spec.md`, spec-id: `dp-001`)
   - Purpose: Encryption standards (AES-256), key management, TLS requirements, data-at-rest/in-transit protection
   - Example: Azure Key Vault Premium (HSM), 90-day key rotation, TLS 1.2+ mandatory
   - Dependencies: None (foundational security)
   - Precedence: OVERRIDES business/cost (encryption non-negotiable even if costly)
   - Status: Published v1.0.0

2. **Access-Control** (`security/access-control/spec.md`, spec-id: `ac-001`)
   - Purpose: Authentication, authorization, RBAC, MFA, SSH key management
   - Example: SSH keys only (no passwords), MFA for privileged access, Azure RBAC role assignments
   - Dependencies: None (foundational security)
   - Precedence: OVERRIDES business/governance (access control foundational, non-negotiable)
   - Status: Draft v1.0.0-draft

3. **Audit-Logging** (`security/audit-logging/spec.md`, spec-id: `audit-001`)
   - Purpose: Audit trails, monitoring, log retention, immutability
   - Example: auditd on all Linux VMs, Azure Monitor integration, 3-year retention, immutable logs
   - Dependencies: access-control (monitors access events)
   - Precedence: Loses to data-protection and access-control (logging supports security controls)
   - Status: Draft v1.0.0-draft

### Infrastructure Tier (`/specs/infrastructure/`)
**Purpose**: Azure technical implementation, IaC modules, networking, pipelines  
**Priority**: 2 (middle tier)  
**Categories** (4 total):

1. **Compute** (`infrastructure/compute/spec.md`, spec-id: `compute-001`)
   - Purpose: VM SKUs, autoscaling, reserved instances, availability sets/zones
   - Example: Standard_B2s (dev), Standard_B4ms (prod), 3-year reserved instances, availability zones for critical workloads
   - Dependencies: business/cost-001 (budget constraints), security/dp-001 (disk encryption)
   - Precedence: Wins over storage (workload determines storage tier)
   - Status: Published v1.0.0

2. **Networking** (`infrastructure/networking/spec.md`, spec-id: `net-001`)
   - Purpose: VNet architecture, NSGs, load balancing, private DNS, ExpressRoute/VPN
   - Example: /16 VNets, NSGs on all subnets, Standard Load Balancer, private DNS zones
   - Dependencies: business/governance (SLA requirements for load balancer tier)
   - Precedence: Dual-gate with cost (SLA + cost both constrain networking SKUs)
   - Status: Draft v1.0.0-draft

3. **Storage** (`infrastructure/storage/spec.md`, spec-id: `stor-001`)
   - Purpose: Disk tiers, replication strategies, backup policies, retention
   - Example: Standard SSD default, LRS replication, 30-day backup retention, GRS for critical data
   - Dependencies: compute-001 (workload determines tier), compliance-framework (retention requirements)
   - Precedence: Loses to compute (workload-driven), loses to compliance (retention binding)
   - Status: Draft v1.0.0-draft

4. **CI/CD-Pipeline** (`infrastructure/cicd-pipeline/spec.md`, spec-id: `cicd-001`)
   - Purpose: Deployment automation, approval gates, rollback procedures, pipeline security
   - Example: GitHub Actions, production approval gates, automated validation, rollback procedures
   - Dependencies: business/governance (approval workflow requirements), compute (deployment targets)
   - Precedence: Loses to governance (approval gates non-negotiable)
   - Status: Draft v1.0.0-draft

### Platform Tier (`/specs/platform/`)
**Purpose**: Platform standards, tooling, code quality, policy enforcement  
**Priority**: 3 (second-lowest tier)  
**Categories** (4 total):

1. **Spec-System** (`platform/spec-system/spec.md`, spec-id: `spec-001`, **META-SPEC**)
   - Purpose: Defines the category-based spec system itself (self-referential meta-specification)
   - Example: YAML frontmatter structure, 5-tier hierarchy, precedence algorithm, validation rules
   - Is-Meta: true (defines the system governing all specs)
   - Dependencies: None (foundational platform standard)
   - Status: Draft v1.0.0-draft

2. **Artifact-Org** (`platform/artifact-org/spec.md`, spec-id: `artifact-001`)
   - Purpose: Directory structure, naming conventions, artifact organization
   - Example: /artifacts/applications/<appname>/{iac, scripts, pipelines, docs} structure
   - Dependencies: spec-001 (follows spec system structure)
   - Status: Published v1.0.0

3. **IaC-Linting** (`platform/iac-linting/spec.md`, spec-id: `lint-001`)
   - Purpose: Code quality standards for Bicep, PowerShell, YAML
   - Example: bicep build validation, PSScriptAnalyzer, yamllint, errors block PR merge
   - Dependencies: None (foundational platform standard)
   - Status: Draft v1.0.0-draft

4. **Policy-as-Code** (`platform/policy-as-code/spec.md`, spec-id: `pac-001`)
   - Purpose: Azure Policy enforcement, remediation tasks, compliance dashboards
   - Example: Policies for encryption, data residency, tagging, SKU restrictions, automatic remediation
   - Dependencies: compliance-framework (policies enforce compliance), access-control (policies enforce access rules)
   - Status: Draft v1.0.0-draft

### Application Tier (`/specs/application/`)
**Purpose**: Application-specific architecture, features, deployment patterns  
**Priority**: 4 (lowest tier, adopts upstream category specs)  
**Structure**: Application-specific directories (separate directory per application):
- `/specs/application/mycoolapp/` — Single application's specs, plans, tasks
  - `spec.md` (application spec with upstream category dependencies)
  - `plan.md` (implementation plan)
  - `tasks.md` (work breakdown)
- `/specs/appli2.0 | **Ratified**: 2026-02-05 | **Last Amended**: 2026-02-07 (Amendment: Category-Based Spec System & 5-Tier Precedence Hierarchy
- etc.

**Application Registry**: `/specs/application/_index.yaml` tracks all applications and their upstream category dependencies.

When application role requests update for a **NEW application**, platform creates entire `/specs/application/[app-name]/` directory structure.  
When application role requests update for an **EXISTING application**, platform modifies files within that application's directory.

### Category Spec Frontmatter Standard (YAML)

ALL category specs MUST include YAML frontmatter with mandatory fields:

```yaml
---
tier: business | security | infrastructure | platform | application
category: cost | governance | data-protection | compute | ... (14 categories)
spec-id: unique-id (e.g., cost-001, dp-001, compute-001)
version: semver (1.0.0, 1.0.0-draft, etc.)
status: draft | published | deprecated
created: YYYY-MM-DD
description: "One sentence category purpose"
depends-on:
  - tier: parent-tier
    category: parent-category
    spec-id: parent-spec-id
    reason: "Dependency rationale"
precedence:
  wins-over:
    - tier: lower-tier
      category: lower-category
      spec-id: lower-spec-id
  loses-to:
    - tier: higher-tier
      category: higher-category
      spec-id: higher-spec-id
  overrides:
    - tier: tier-to-override
      category: category-to-override
      spec-id: spec-to-override
      reason: "Override rationale (e.g., security non-negotiable)"
adhered-by:
  - app-id: application-name
    version: app-version
    compliance: full | partial | planned
---
```

### Precedence Resolution Algorithm

When conflicts arise between category specs, resolve using this 5-step algorithm:

1. **Tier Precedence** (primary): Higher tier always wins (business > security > infrastructure > platform > application)
2. **Explicit Overrides** (trumps tier): Check `precedence.overrides` field for documented exceptions (e.g., security/data-protection OVERRIDES business/cost)
3. **Category Precedence** (within tier): Use tier-specific category order from tier index files (e.g., within business: compliance-framework > governance > cost)
4. **Dependency Order** (DAG): Dependencies form directed acyclic graph; upstream dependencies constrain downstream dependents
5. **Manual Escalation** (last resort): If still ambiguous, document exception in both conflicting specs and add to root manifest conflicts list

**Formalized Conflict Patterns** (7 documented in specs.yaml):
1. **Cost vs Compute**: Cost wins (business budget constrains infrastructure SKUs)
2. **Cost vs Data-Protection**: Security wins (encryption non-negotiable even if costly)
3. **Governance vs CI/CD-Pipeline**: Governance wins (production approval gates required)
4. **Compliance-Framework vs Storage**: Compliance wins (regulatory retention requirements binding)
5. **Access-Control vs Governance**: Security wins (access control foundational, non-negotiable)
6. **Compute vs Storage**: Compute wins (workload determines storage tier)
7. **Cost vs Networking**: Dual-gate (both SLA and cost constrain networking SKUs)th AI assistance).
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
  3. Reference parent platform/infrastructure/security/business specs in new spec
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
