<!--
═══════════════════════════════════════════════════════════════════════════════
SYNC IMPACT REPORT: Constitution v2.0.0 → v2.1.0 (2026-02-09)
═══════════════════════════════════════════════════════════════════════════════

VERSION CHANGE:
  Old: v2.0.0 (Platform-First Hierarchy & DevOps Tier - 6-Tier Restructure)
  New: v2.1.0 (Category-Scoped Role Targeting)
  Bump Rationale: MINOR - Added mandatory category targeting for all non-application roles
                  and aligned templates with category-scoped spec paths

MODIFIED SECTIONS:
  1. Principle II: "Six-Tier Stakeholder Roles with Declared Role Protocol"
     - Added mandatory category targeting for all non-application roles
     - Added explicit spec path rule: /specs/<tier>/<category>/spec.md
     - Clarified application role uses application target instead of category

  2. Tier Specifications Organization
     - Reinforced category-scoped spec paths and role targeting expectations

ADDED SECTIONS: None (governance tightened, no new sections)

REMOVED SECTIONS: None

TEMPLATES REQUIRING UPDATES:
  ✅ .specify/templates/spec-template.md - Added category target + devops/platform tiers
  ✅ .specify/templates/plan-template.md - Added category target + 6-tier structure
  ✅ .specify/templates/tasks-template.md - Added category target + devops/platform tiers

FOLLOW-UP TODOS:
  - Ensure /speckit.* commands enforce role + category targeting prompts

PROPAGATION STATUS:
  ✅ Constitution updated with category-scoped role targeting
  ✅ Spec/plan/tasks templates aligned with category targeting

═══════════════════════════════════════════════════════════════════════════════
-->

<!-- 
═══════════════════════════════════════════════════════════════════════════════
SYNC IMPACT REPORT: Constitution v1.4.1 → v2.0.0 (2026-02-09)
═══════════════════════════════════════════════════════════════════════════════

VERSION CHANGE:
  Old: v1.4.1 (Glob Pattern-Based Tier Validation for Future-Proofing)
  New: v2.0.0 (Platform-First Hierarchy & DevOps Tier - 6-Tier Restructure)
  Bump Rationale: MAJOR - Restructured tier hierarchy with Platform at priority 0 (foundational),
                  added DevOps tier at priority 4; Platform standards now supersede Business/Security/
                  Infrastructure/DevOps/Application (was incorrectly at priority 4); all tiers now
                  validate against Platform; priorities renumbered: Platform=0, Business=1, Security=2,
                  Infrastructure=3, DevOps=4, Application=5; backward-incompatible governance change

MODIFIED SECTIONS:
  1. Constitution Title & Preamble:
     - Updated from "five-tier" to "six-tier" specification hierarchy
  
  2. Principle I: "Spec-Driven Category-Based Development"
     - Updated hierarchy: Business → Security → Infrastructure → **DevOps** → Platform → Application
     - Added DevOps Practices between Infrastructure Templates and Platform Standards
     - Removed specific category count reference (allows flexibility for DevOps categories)
  
  3. Principle II: "Five-Tier Stakeholder Roles" → "Six-Tier Stakeholder Roles"
     - Renamed from "Five-Tier" to "Six-Tier"
     - Added DevOps role (#5) with priority 3 between Infrastructure and Application
     - Updated Platform role priority: 3→4
     - Updated Application role priority: 4→5
     - Updated role definitions:
       * Infrastructure: Now upper-middle tier (priority 2), provides base patterns for DevOps
       * DevOps: New lower-middle tier (priority 3), bridges infrastructure and applications
       * Platform: Now priority 4 (was 3)
       * Application: Now priority 5, lowest tier (was 4)
  
  4. "Each role operates independently" section:
     - Updated tier cascade: business > security > infrastructure > **devops** > platform > application
  
  5. Principle III: "Tier-Specific Validation Requirements"
     - **Application Tier** (priority 5): Added DevOps tier validation (5 upstream tiers total)
       * NEW: Validates against specs/devops/**/spec.md
       * Still validates: infrastructure, platform, security, business
     - **Platform Tier** (priority 4): Added DevOps tier validation (4 upstream tiers total)
       * NEW: Validates against specs/devops/**/spec.md
       * Still validates: infrastructure, security, business
     - **DevOps Tier** (priority 3): NEW tier with 3 upstream tier validations
       * Validates against: specs/infrastructure/**/spec.md
       * Validates against: specs/security/**/spec.md
       * Validates against: specs/business/**/spec.md
     - Infrastructure, Security, Business: No changes (validate same upstream tiers)
  
  6. "Tier Specifications Organization" section:
     - Updated Root Manifest: 5-tier → 6-tier hierarchy (business=0 → application=5)
     - Updated Tier-Specific Category Indexes: Added `/specs/devops/_categories.yaml`
  
  7. NEW: DevOps Tier Section (`/specs/devops/`)
     - Purpose: Deployment automation, observability, CI/CD orchestration, environment management
     - Priority: 3 (lower-middle content tier, between infrastructure and platform)
     - Categories (4 suggested):
       1. deployment-automation (spec-id: deploy-001)
       2. observability (spec-id: obs-001)
       3. environment-management (spec-id: env-001)
       4. ci-cd-orchestration (spec-id: cicd-orch-001)
     - All marked as "Placeholder (to be created)"
  
  8. Infrastructure Tier Section:
     - Added 5th category: IaC-Modules (spec-id: iac-001) for clarity
  
  9. Platform Tier Section:
     - Updated priority: 3→4
     - Updated Spec-System: "5-tier hierarchy" → "6-tier hierarchy"
  
  10. Application Tier Section:
     - Updated priority: 4→5
     - Updated description: "adopts upstream category specs from all higher tiers"
  
  11. "Spec Update Workflow" - Step 3: "MANDATORY UPSTREAM VALIDATION CHECKPOINT"
     - For Application tier: Added specs/devops/**/spec.md to glob pattern list
     - For Platform tier: Added specs/devops/**/spec.md to glob pattern list
     - For DevOps tier: NEW validation checkpoint (infrastructure, security, business)
  
  12. "Role Declaration" workflow step:
     - Added DevOps role to declaration list
     - Updated Infrastructure role description
  
  13. "Application-Tier Specific Workflow" - CASE A and CASE B:
     - CASE A (NEW): Added specs/devops/**/spec.md to upstream validation glob patterns (5 tiers total)
     - CASE B (EXISTING): Added specs/devops/**/spec.md to upstream validation glob patterns (5 tiers total)
  
  14. "Artifact Review Gates" - Application-Tier IaC Artifacts:
     - Added NEW "DevOps Tier Validation" section (BLOCKING)
       * Follow deployment automation patterns
       * Include observability instrumentation (logging, metrics, tracing)
       * Comply with environment management requirements
       * Integrate with CI/CD orchestration
     - Reordered validation subsections: DevOps → Platform → Infrastructure → Security → Business
  
  15. "Artifact Review Gates" - Application-Tier Tasks:
     - Added requirement: MUST reference DevOps practices from devops tier specs
     - Updated FAIL GATE: Tasks rejected if missing devops OR infrastructure tier spec references
  
  16. "Artifact Review Gates" - Infrastructure/Platform/Security Tier Artifacts:
     - Added DevOps tier to list: "Infrastructure/Platform/Security/DevOps Tier Artifacts"
     - Added note: DevOps tier artifacts MUST validate against infrastructure, security, business
  
  17. "Precedence Resolution Algorithm" - Step 1:
     - Updated tier precedence order: business > security > infrastructure > **devops** > platform > application

ADDED SECTIONS:
  - DevOps role definition (Principle II)
  - DevOps tier validation requirements (Principle III, 3 upstream tiers)
  - DevOps tier specification organization section (complete tier definition with 4 categories)
  - DevOps tier validation checkpoint in workflow (Step 3)
  - DevOps tier validation in Application workflow (CASE A & B)
  - DevOps tier validation in Artifact Review Gates (Application-tier IaC artifacts)
  - DevOps tier reference requirement in Application-tier tasks

REMOVED SECTIONS: None (all prior governance preserved, DevOps tier added)

TEMPLATES REQUIRING UPDATES:
  ⚠️  .specify/templates/spec-template.md - Should add DevOps tier to depends-on examples
  ⚠️  .specify/templates/plan-template.md - Should add DevOps tier to tier list and validation section
  ⚠️  .specify/templates/tasks-template.md - Should add DevOps tier specs reference checklist
  ⚠️  .specify/templates/commands/*.md - May need updates to reference 6-tier hierarchy
  ⚠️  Root manifest (specs.yaml) - MUST be updated to include DevOps tier (priority 3)

FOLLOW-UP TODOS:
  - Create /specs/devops/ directory structure
  - Create /specs/devops/_categories.yaml index file
  - Create placeholder DevOps category spec files:
    * /specs/devops/deployment-automation/spec.md
    * /specs/devops/observability/spec.md
    * /specs/devops/environment-management/spec.md
    * /specs/devops/ci-cd-orchestration/spec.md
  - Update root manifest (specs/specs.yaml) to include DevOps tier with priority 3
  - Update existing application specs to include DevOps tier dependencies
  - Update plan/task templates to reflect 6-tier hierarchy
  - Validate that glob pattern specs/devops/**/spec.md works correctly

PROPAGATION STATUS:
  ✅ Principle I updated (6-tier hierarchy, DevOps added to cascade)
  ✅ Principle II updated (Six-Tier roles, DevOps role added, priorities renumbered)
  ✅ Principle III updated (DevOps tier validation requirements added)
  ✅ DevOps tier specification section added (complete with 4 categories)
  ✅ Workflow updated (DevOps validation checkpoint added)
  ✅ Application workflow updated (DevOps specs added to CASE A & B)
  ✅ Artifact Review Gates updated (DevOps tier validation added)
  ✅ Precedence algorithm updated (DevOps in tier order)
  ✅ Version footer updated (v2.0.0)
  ⚠️  DevOps tier directory structure needs creation
  ⚠️  Root manifest needs DevOps tier addition
  ⚠️  Templates need 6-tier updates

BACKWARD-INCOMPATIBILITY IMPACT:
  - Existing Application specs that validated against 4 upstream tiers now MUST validate against 5
  - Platform tier priority changed (3→4): Affects any existing precedence rules
  - Application tier priority changed (4→5): Affects any existing precedence rules
  - Existing validation scripts may break if they hardcode tier priorities
  - Existing tier cascade references (business>security>infrastructure>platform>application) outdated
  - glob patterns automatically include DevOps once specs created (future-proofed)

MIGRATION REQUIRED:
  - Update all existing application specs to include DevOps tier dependencies (once created)
  - Review and update any hardcoded tier priority references in scripts or docs
  - Update tier cascade documentation throughout project
  - Create DevOps tier category specs before creating new applications
  
═══════════════════════════════════════════════════════════════════════════════
-->

MODIFIED SECTIONS:
  1. Principle III: "Spec Propagation & Cascading Changes" → "Mandatory Tier Validation & Cascading Enforcement"
     - COMPLETE REWRITE: Added NON-NEGOTIABLE upstream validation requirements
     - Added tier-specific validation matrix (Application validates 4 upstream tiers)
     - Added mandatory blocking validation checkpoints (no downstream work without upstream compliance)
     - Added validation failure handling protocol (BLOCK + violation report + remediation)
     - Strengthened cascading change propagation with auto-flagging and blocking
  
  2. "Spec Update Workflow" section:
     - Added mandatory Step 3: "UPSTREAM VALIDATION CHECKPOINT" (BLOCKING)
     - Platform MUST load ALL upstream tier specs before proceeding
     - Added explicit spec loading requirements (spec-id, version, constraints)
     - Added GATE at Step 3: BLOCK if upstream specs missing
     - Added GATE at Step 5: BLOCK if hierarchy violations detected
     - Added GATE at Step 8: REJECT artifacts failing upstream validation
  
  3. "Application-Tier Specific Workflow" section:
     - CASE A (NEW): Added 8-step mandatory upstream validation workflow
       - Load ALL 13 upstream category specs (infrastructure, platform, security, business)
       - Auto-inject upstream dependencies into spec.md frontmatter
       - VALIDATION GATE before proceeding
       - Generate artifacts using upstream specs as binding constraints
     - CASE B (EXISTING): Added 10-step compliance audit workflow
       - Load current upstream spec versions
       - COMPLIANCE AUDIT against current upstream specs
       - GATE if critical violations detected
       - Update depends-on field to reflect current upstream versions
  
  4. "Artifact Review Gates" section: COMPLETE REWRITE
     - Added "MANDATORY BLOCKING VALIDATION" subtitle
     - Added universal upstream spec compliance check (ALL artifacts)
     - Added tier-specific gates with detailed requirements:
       * Application-Tier IaC Artifacts: 4-tier validation (Infrastructure, Platform, Security, Business)
       * Infrastructure Tier Validation: MUST use IaC modules from catalog, follow naming, comply with SKU/networking/storage
       * Platform Tier Validation: MUST pass iac-linting, follow artifact-org structure, include policy tags
       * Security Tier Validation: MUST include encryption, RBAC, audit logging
       * Business Tier Validation: MUST include cost estimation, approval gates, compliance tags
     - Added Application-Tier Tasks validation: MUST reference infrastructure IaC modules
     - Added rejection protocol with detailed violation reporting

ADDED SECTIONS:
  - Upstream Validation Requirement (Principle III)
  - Tier-Specific Validation Requirements matrix (4-tier validation for Application)
  - Validation Failure Handling protocol
  - Mandatory upstream validation checkpoint (Step 3 in workflow)
  - Compliance audit workflow (CASE B existing applications)
  - Detailed Application-tier IaC artifact validation gates (infrastructure/iac-modules compliance)
  - Rejection protocol for non-compliant artifacts

REMOVED SECTIONS: None (all prior governance preserved, enforcement significantly strengthened)

TEMPLATES REQUIRING UPDATES:
  ✅ .specify/templates/spec-template.md - Already includes depends-on frontmatter field
  ⚠️  .specify/templates/plan-template.md - Should add "Upstream Tier Validation" section
  ⚠️  .specify/templates/tasks-template.md - Should add infrastructure/iac-modules reference checklist
  ✅ .specify/templates/commands/*.md - Constitution-agnostic

FOLLOW-UP TODOS:
  - Update plan-template.md to include mandatory "Upstream Tier Validation Checkpoint" section
  - Update tasks-template.md to include infrastructure/iac-modules spec reference requirements
  - Create validation script: validate-upstream-compliance.ps1 to automate spec loading and validation
  - Update Application workflow to auto-load upstream specs when creating spec.md
  - Document violation report format for failed validation gates

PROPAGATION STATUS:
  ✅ Principle III rewritten with mandatory validation requirements
  ✅ Workflow updated with 3 blocking validation gates (Steps 3, 5, 8)
  ✅ Application-tier workflow updated with upstream spec loading (13 category specs)
  ✅ Artifact Review Gates completely rewritten with 4-tier validation for Application IaC
  ⚠️  Plan/tasks templates need update to reflect new validation requirements
  ⚠️  Validation automation script needed

CRITICAL ENFORCEMENT CHANGES:
  - Application-tier IaC artifacts MUST reference infrastructure/iac-modules/spec.md catalog
  - Application-tier tasks REJECTED if they don't reference infrastructure IaC module specs
  - All downstream work BLOCKED until upstream validation passes
  - Violation reports MUST cite specific upstream spec (tier, category, spec-id, version, requirement)
  
═══════════════════════════════════════════════════════════════════════════════
-->

MODIFIED SECTIONS:
  1. NEW Principle 0: "Platform Meta-Governance Authority (SUPERSEDES ALL TIERS)"
     - Establishes Platform role exclusive control over .specify/ and .github/ directories
     - Framework governance (constitution, templates, tier definitions) supersedes content hierarchy
     - Separates platform framework authority from platform tier content specs
     - Business/Security/Infrastructure/Application roles cannot modify framework
  
  2. Principle II: "Five-Tier Stakeholder Roles" (renumbered to Principle II, was previously mixed)
     - Updated Platform Role definition to explicitly state dual scope: 
       (a) framework governance (supersedes all), (b) platform-tier content specs (priority 3)
     - Clarified that framework modifications are meta-level, not subject to tier precedence
  
  3. "Tier Specifications Organization" section:
     - Updated Platform Tier description to distinguish framework control from content specs
     - Added explicit note: "Platform framework governance supersedes tier precedence"

ADDED SECTIONS:
  - Principle 0: Platform Meta-Governance Authority (new governance layer above tier precedence)
  - Framework vs Content separation in Platform role definition
  - Explicit reserved directories: .specify/, .github/ under Platform role exclusive control

REMOVED SECTIONS: None (all prior governance preserved, enhanced with meta-governance)

TEMPLATES REQUIRING UPDATES:
  ✅ .specify/templates/spec-template.md - No changes required (already references constitution)
  ✅ .specify/templates/plan-template.md - No changes required (already references constitution)
  ✅ .specify/templates/tasks-template.md - No changes required (already references constitution)
  ✅ .specify/templates/commands/*.md - No changes required (constitution-agnostic)
  ⚠️  .specify/templates/commands/constitution.md - May require update to reflect Principle 0

FOLLOW-UP TODOS:
  - Update .specify/templates/commands/constitution.md to reference new Principle 0
  - Validate that all platform framework scripts respect meta-governance authority
  - Document Platform role workflow for framework vs content spec modifications

PROPAGATION STATUS:
  ✅ Constitution amended with Principle 0 (Platform Meta-Governance Authority)
  ✅ Platform Role definition updated (framework supersedes all tiers)
  ✅ Tier precedence algorithm updated (meta-governance step added)
  ⚠️  Command templates require review for Principle 0 references

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

The Platform Team governs this project as a "platform as a product," delivering AI-assisted infrastructure and application templates governed by a six-tier specification hierarchy with meta-governance framework authority.

## Core Principles

### 0. Platform Meta-Governance Authority (SUPERSEDES ALL TIERS)

The **Platform role** holds EXCLUSIVE authority over the governance framework itself, which supersedes all tier-based precedence rules. This meta-governance authority is separate from and superior to the platform-tier content specifications.

**Framework Control (Meta-Governance)**:
- **Reserved Directories**: Platform role has EXCLUSIVE control over:
  - `.specify/` — All framework templates, scripts, commands, configuration
  - `.github/` — All CI/CD workflows, GitHub Actions, repository automation
- **Constitution & Governance**: Only Platform role may modify:
  - This constitution document (`.specify/memory/constitution.md`)
  - Tier definitions and precedence rules
  - Role definitions and workflows
  - Template structures (spec, plan, tasks templates)
  - Command mode definitions
- **Framework Versioning**: Constitution and framework changes follow semantic versioning independent of content spec versions

**Access Restrictions**:
- Business, Security, Infrastructure, and Application roles **CANNOT** modify:
  - Framework governance documents
  - Template structures
  - Tier precedence algorithms
  - Role definitions
  - `.specify/` or `.github/` contents
- These roles MAY request changes via Platform role proposals, subject to Platform team approval

**Scope Separation**:
- **Meta-Governance** (Principle 0): Framework control, supersedes all tiers, reserved directories
- **Platform Content Specs** (Platform tier, priority 3): Platform-tier category specs (iac-linting, artifact-org, policy-as-code, spec-system) follow normal tier precedence

**Rationale**: The governance framework must remain stable and controlled to prevent tier conflicts from destabilizing the system itself. Business decisions may change cost targets, security may override budgets, but none may alter the fundamental governance structure without Platform team oversight.

### I. Spec-Driven Category-Based Development (NON-NEGOTIABLE)
All platform outputs MUST originate from and align with the six-tier specification hierarchy: **Platform Standards → Business Requirements → Security Policies → Infrastructure Templates → DevOps Practices → Application Architecture**. The platform implements a **category-based spec system** where each tier contains multiple independent categories. Specs cascade downward via explicit dependencies; changes at higher tiers MUST propagate through dependent lower tiers following documented precedence rules. No infrastructure or application code may exist without corresponding spec alignment. The platform team MUST validate that all generated outputs reflect this hierarchy.

**Rationale for Platform-First Hierarchy**: Platform tier defines foundational standards (code quality, directory structure, policy enforcement, spec system) that ALL other tiers must follow. Business requirements cannot override platform code quality standards; security policies must comply with platform artifact organization; infrastructure and DevOps must adhere to platform linting rules; applications must follow all platform standards. Platform tier is the technical foundation upon which all content tiers operate.

### II. Six-Tier Stakeholder Roles with Declared Role Protocol

The platform defines six distinct stakeholder roles mapped to the 6-tier hierarchy, each interfacing via plain-English conversational prompts. ALL spec update requests MUST begin with an explicit role declaration.

**Required Role Declaration Fields**:
- **Role**: Platform | Business | Security | Infrastructure | DevOps | Application
- **Category Target** (required for Platform/Business/Security/Infrastructure/DevOps): the category being modified (e.g., `spec-system`, `iac-linting`, `cost`, `data-protection`, `networking`, `observability`)
- **Application Target** (required for Application): `NEW: app-name` or `EXISTING: app-name`
- **Spec Path**: MUST map to `/specs/<tier>/<category>/spec.md` (non-application) or `/specs/application/<app-name>/spec.md` (application)

**Role Declaration Protocol**:
When any stakeholder requests a spec update, they MUST declare their role FIRST:

1. **Platform**: (a) Updates **meta-governance framework** (.specify/, .github/, constitution, templates, tier definitions) — SUPERSEDES ALL TIERS per Principle 0, OR (b) Updates **platform-tier content specifications** (spec-system, iac-linting, artifact-org, policy-as-code) — **highest content tier (priority 0)**, foundational standards for all other tiers. Category target required for content specs; meta-governance uses framework scope rather than a category spec file.
2. **Business**: Updates business-tier category specifications (cost, governance, compliance-framework) — second-highest content tier (priority 1)
3. **Security**: Updates security-tier category specifications (data-protection, access-control, audit-logging) — third-highest content tier (priority 2)
4. **Infrastructure**: Updates infrastructure-tier category specifications (compute, networking, storage, cicd-pipeline, iac-modules) — upper-middle content tier (priority 3)
5. **DevOps**: Updates devops-tier category specifications (deployment-automation, observability, environment-management, ci-cd-orchestration) — lower-middle content tier (priority 4)
6. **Application**: Updates application-tier specifications for a specific application (either NEW application or EXISTING application to be named) — lowest content tier (priority 5)

**Role Definitions**:

- **Platform Role**: Has **dual scope** with distinct authority levels:
  - **(a) Meta-Governance** (Principle 0, supersedes all tiers): Exclusive control over `.specify/`, `.github/`, constitution, tier definitions, templates, role workflows, governance rules. Framework modifications are NOT subject to tier precedence.
  - **(b) Platform-Tier Content Specs** (priority 0, **highest content tier**): Manages platform-tier category specs (spec-system, iac-linting, artifact-org, policy-as-code) defining foundational technical standards that ALL other tiers must follow. Platform content specs are NOT subject to override by Business, Security, Infrastructure, DevOps, or Application tiers. **Rationale**: Code quality, directory structure, policy enforcement, and the spec system itself are non-negotiable technical foundations.
  - **Category Target Requirement**: Platform content-spec updates MUST target a category spec at `/specs/platform/<category>/spec.md`.
  
- **Business Role**: Defines operational requirements, budgets, cost targets, SLAs, and business objectives that drive business-tier specifications. Can have multiple specs per business area. **Second-highest content tier** (priority 1), constrained by Platform standards. **Cannot modify platform technical standards** (Platform priority 0 constrains Business). Category target required at `/specs/business/<category>/spec.md`.

- **Security Role**: Translates business requirements into security policies, compliance standards (NIST, ISO), and security controls. Can have multiple specs per compliance domain. **Third-highest content tier** (priority 2) with override authority over business when security non-negotiable, but constrained by Platform standards. Category target required at `/specs/security/<category>/spec.md`.

- **Infrastructure Role**: Designs Azure landing zones, networking, IaC modules (using Azure Verified Modules), base infrastructure patterns for DevOps and application teams. **Upper-middle content tier** (priority 3) constrained by Platform, Business, and Security. Category target required at `/specs/infrastructure/<category>/spec.md`.

- **DevOps Role**: Defines deployment automation, CI/CD orchestration, observability standards, environment management, and operational practices that bridge infrastructure and applications. **Lower-middle content tier** (priority 4) constrained by Platform, Business, Security, and Infrastructure. DevOps tier consumes infrastructure IaC modules and defines how they are deployed, monitored, and operated. Category target required at `/specs/devops/<category>/spec.md`.

- **Application Role**: Specifies application features, architecture, performance requirements, and deployment patterns constrained by DevOps, infrastructure, and security tiers. **Lowest content tier** (priority 5). Application target required (category target not applicable):
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

Each role operates independently on its tier but MUST respect:
- **Principle 0**: Platform role meta-governance authority (framework modifications supersede all)
- **Tier Cascade**: Higher content tier specs constrain lower content tier specs (**platform > business > security > infrastructure > devops > application**)

### III. Mandatory Tier Validation & Cascading Enforcement (NON-NEGOTIABLE)

**Upstream Validation Requirement**:
Before ANY spec, plan, task, or artifact can be created or modified at a lower tier, the platform MUST validate compliance with ALL upstream tier specifications. This validation is MANDATORY and BLOCKING—no downstream work proceeds without upstream compliance verification.

**Tier-Specific Validation Requirements**:

- **Application Tier** (lowest, priority 5) MUST validate against:
  1. **Platform tier**: ALL specs matching `specs/platform/**/spec.md` (includes all current and future platform category specs: spec-system, iac-linting, artifact-org, policy-as-code, etc.) — FOUNDATIONAL
  2. **Business tier**: ALL specs matching `specs/business/**/spec.md` (includes all business category specs: cost, governance, compliance-framework, etc.)
  3. **Security tier**: ALL specs matching `specs/security/**/spec.md` (includes all security category specs: data-protection, access-control, audit-logging, etc.)
  4. **Infrastructure tier**: ALL specs matching `specs/infrastructure/**/spec.md` (includes all infrastructure category specs: iac-modules, compute, networking, storage, cicd-pipeline, etc.)
  5. **DevOps tier**: ALL specs matching `specs/devops/**/spec.md` (includes all DevOps category specs: deployment-automation, observability, environment-management, ci-cd-orchestration, etc.)
  
- **DevOps Tier** (priority 4) MUST validate against:
  1. **Platform tier**: ALL specs matching `specs/platform/**/spec.md` — FOUNDATIONAL
  2. **Business tier**: ALL specs matching `specs/business/**/spec.md`
  3. **Security tier**: ALL specs matching `specs/security/**/spec.md`
  4. **Infrastructure tier**: ALL specs matching `specs/infrastructure/**/spec.md`

- **Infrastructure Tier** (priority 3) MUST validate against:
  1. **Platform tier**: ALL specs matching `specs/platform/**/spec.md` — FOUNDATIONAL
  2. **Business tier**: ALL specs matching `specs/business/**/spec.md`
  3. **Security tier**: ALL specs matching `specs/security/**/spec.md`
  
- **Security Tier** (priority 2) MUST validate against:
  1. **Platform tier**: ALL specs matching `specs/platform/**/spec.md` — FOUNDATIONAL
  2. **Business tier**: ALL specs matching `specs/business/**/spec.md`

- **Business Tier** (priority 1) MUST validate against:
  1. **Platform tier**: ALL specs matching `specs/platform/**/spec.md` — FOUNDATIONAL

- **Platform Tier** (priority 0, highest) validates against:
  - **None** (Platform is the foundational tier; no upstream content tier constraints)
  - Platform content specs define technical standards that all other tiers must follow

**Pattern Explanation**: The glob pattern `specs/<tier>/**/spec.md` matches all `spec.md` files in any subdirectory under the specified tier directory, automatically including any new category specs added without requiring constitution amendments.

**Validation Failure Handling**:
- If upstream validation FAILS, downstream work MUST be BLOCKED
- Platform MUST report specific upstream spec violations (cite spec-id, version, violated requirement)
- Resolver MUST either: (a) update downstream work to comply, OR (b) request upstream spec amendment via proper role
- NO WORKAROUNDS PERMITTED—upstream specs are binding constraints

**Cascading Change Propagation**:
When upstream tier specs change, the platform MUST:
1. Document the change in upstream tier spec with version increment and rationale
2. Identify all dependent downstream specs and artifacts (via dependency graph)
3. Auto-flag downstream specs for compliance review
4. Regenerate or update downstream artifacts to reflect new constraints
5. Track change lineage: upstream change → affected downstream specs → regenerated artifacts
6. BLOCK deployment of non-compliant downstream artifacts until updated

This ensures tier hierarchy is strictly enforced at all times, preventing spec drift and non-compliant artifacts.

### IV. AI-Generated Outputs with Human-in-the-Loop Quality Gates
All platform outputs (IaC modules, Bicep templates, GitHub Actions pipelines, policy documents, work items) MUST be generated via AI assistance but reviewed and approved by platform team members before deployment or consumption. No auto-deployment of AI-generated artifacts; human validation is mandatory. The platform team MUST maintain a feedback loop, logging AI output quality, correctness issues, and iterative improvements to prompts and templates.

### V. Observable & Auditable Spec Relationships
Every artifact (IaC module, pipeline, policy, application code deployment) MUST be traceable to its originating spec tier and linked specs. Bidirectional traceability required: spec → generated artifacts, artifacts → source specs. Version specs alongside artifacts; when a spec changes, mark dependent artifacts for regeneration review.

## Tier Specifications Organization
implements a **category-based spec system** across 6 tiers, governed by a root manifest and tier-specific category indexes. Directory structure: `/specs/<tier>/<category>/spec.md`. Role declarations MUST identify the target category for all non-application tiers.

### Root Manifest & Indexes

**Root Manifest** (`/specs/specs.yaml`):
- Defines 6-tier hierarchy with priority levels (**platform=0 → application=5**)
- Platform tier at priority 0 (foundational technical standards)
- Business tier at priority 1, Security at 2, Infrastructure at 3, DevOps at 4, Application at 5
- Lists all categories across 6 tiers
- Documents formalized conflict patterns with precedence rules
- Declares category precedence within tiers
- Canonical source of truth for tier/category relationships

**Tier-Specific Category Indexes**:
- `/specs/platform/_categories.yaml` (PRIORITY 0, FOUNDATIONAL: spec-system, iac-linting, artifact-org, policy-as-code)
- `/specs/business/_categories.yaml` (priority 1: compliance-framework > governance > cost)
- `/specs/security/_categories.yaml` (priority 2: data-protection ≈ access-control > audit-logging)
- `/specs/infrastructure/_categories.yaml` (priority 3: workload-dependent precedence)
- `/specs/devops/_categories.yaml` (priority 4: deployment-automation, observability, environment-management, ci-cd-orchestration)
- Each index lists category IDs, names, descriptions, current versions, precedence order

**Application Registry** (`/specs/application/_index.yaml`):
- Lists all registered applications (e.g., mycoolapp)
- Tracks upstream category dependencies per application
- Documents compliance status with category specs

### Platform Tier (`/specs/platform/`)
**Purpose**: Foundational platform standards, tooling, code quality, policy enforcement  
**Priority**: 0 (HIGHEST content tier - foundational technical standards)  
**Note**: Platform-tier **content specs** define non-negotiable technical standards that ALL other tiers must follow. Platform **framework governance** (Principle 0) supersedes even platform content specs and controls `.specify/`, `.github/`, constitution.  
**Rationale**: Code quality (iac-linting), directory structure (artifact-org), policy enforcement (policy-as-code), and the spec system itself (spec-system) are foundational technical requirements that cannot be overridden by Business, Security, Infrastructure, DevOps, or Application tiers.  
**Categories** (4 total):

1. **Spec-System** (`platform/spec-system/spec.md`, spec-id: `spec-001`, **META-SPEC**)
   - Purpose: Defines the category-based spec system itself (self-referential meta-specification)
   - Example: YAML frontmatter structure, 6-tier hierarchy, precedence algorithm, validation rules
   - Is-Meta: true (defines the system governing all specs)
   - Dependencies: None (foundational platform standard)
   - Precedence: Cannot be overridden by any other tier
   - Status: Draft v1.0.0-draft

2. **IaC-Linting** (`platform/iac-linting/spec.md`, spec-id: `lint-001`)
   - Purpose: Code quality standards for Bicep, PowerShell, YAML
   - Example: bicep build validation, PSScriptAnalyzer, yamllint, errors block PR merge
   - Dependencies: None (foundational platform standard)
   - Precedence: Cannot be overridden by any other tier (code quality non-negotiable)
   - Status: Draft v1.0.0-draft

3. **Artifact-Org** (`platform/artifact-org/spec.md`, spec-id: `artifact-001`)
   - Purpose: Directory structure, naming conventions, artifact organization
   - Example: /artifacts/applications/<appname>/{iac, scripts, pipelines, docs} structure
   - Dependencies: spec-001 (follows spec system structure)
   - Precedence: Cannot be overridden by any other tier (directory structure foundational)
   - Status: Published v1.0.0

4. **Policy-as-Code** (`platform/policy-as-code/spec.md`, spec-id: `pac-001`)
   - Purpose: Azure Policy enforcement, remediation tasks, compliance dashboards
   - Example: Policies for encryption, data residency, tagging, SKU restrictions, automatic remediation
   - Dependencies: None (foundational platform standard, but integrates with compliance-framework and access-control)
   - Precedence: Cannot be overridden by any other tier (policy enforcement non-negotiable)
   - Status: Draft v1.0.0-draft

### Business Tier (`/specs/business/`)
**Purpose**: Strategic decisions, operational requirements, budget targets  
**Priority**: 1 (second-highest content tier)  
**Note**: Constrained by Platform tier standards (must follow code quality, directory structure, policy enforcement)  
**Categories** (3 total):

1. **Cost** (`business/cost/spec.md`, spec-id: `cost-001`)
   - Purpose: Budget targets, cost optimization, reserved instance strategies
   - Example: 10% year-over-year cost reduction, 3-year reserved instance commitments
   - Dependencies: None (top-level business requirement)
   - Precedence: Loses to platform/* (technical standards non-negotiable), security/data-protection (encryption non-negotiable), compliance-framework (regulatory binding)
   - Status: Published v1.0.0

2. **Governance** (`business/governance/spec.md`, spec-id: `gov-001`)
   - Purpose: Approval workflows, SLA definitions, change management, break-glass procedures
   - Example: Production requires approval, 99.95% SLA critical workloads, 99% SLA non-critical
   - Dependencies: None (top-level business requirement)
   - Precedence: Loses to platform/* (technical standards non-negotiable), wins over cost, loses to security/access-control (foundational security)
   - Status: Draft v1.0.0-draft

3. **Compliance-Framework** (`business/compliance-framework/spec.md`, spec-id: `comp-001`)
   - Purpose: Regulatory requirements (NIST 800-171), data residency, retention policies, audit schedules
   - Example: US regions only, 7-year retention, annual compliance audits
   - Dependencies: None (top-level regulatory requirement)
   - Precedence: Loses to platform/* (technical standards non-negotiable), OVERRIDES cost and storage (regulatory requirements binding)
   - Status: Draft v1.0.0-draft

### Security Tier (`/specs/security/`)
**Purpose**: Security controls, compliance policies, threat mitigation  
**Priority**: 2 (third-highest content tier)  
**Note**: Constrained by Platform tier standards, may override Business tier when security non-negotiable  
**Categories** (3 total):

1. **Data-Protection** (`security/data-protection/spec.md`, spec-id: `dp-001`)
   - Purpose: Encryption standards (AES-256), key management, TLS requirements, data-at-rest/in-transit protection
   - Example: Azure Key Vault Premium (HSM), 90-day key rotation, TLS 1.2+ mandatory
   - Dependencies: None (foundational security)
   - Precedence: Loses to platform/* (technical standards non-negotiable), OVERRIDES business/cost (encryption non-negotiable even if costly)
   - Status: Published v1.0.0

2. **Access-Control** (`security/access-control/spec.md`, spec-id: `ac-001`)
   - Purpose: Authentication, authorization, RBAC, MFA, SSH key management
   - Example: SSH keys only (no passwords), MFA for privileged access, Azure RBAC role assignments
   - Dependencies: None (foundational security)
   - Precedence: Loses to platform/* (technical standards non-negotiable), OVERRIDES business/governance (access control foundational, non-negotiable)
   - Status: Draft v1.0.0-draft

3. **Audit-Logging** (`security/audit-logging/spec.md`, spec-id: `audit-001`)
   - Purpose: Audit trails, monitoring, log retention, immutability
   - Example: auditd on all Linux VMs, Azure Monitor integration, 3-year retention, immutable logs
   - Dependencies: access-control (monitors access events)
   - Precedence: Loses to platform/* (technical standards non-negotiable), loses to data-protection and access-control (logging supports security controls)
   - Status: Draft v1.0.0-draft

### Infrastructure Tier (`/specs/infrastructure/`)
**Purpose**: Azure technical implementation, IaC modules, networking, pipelines  
**Priority**: 3 (upper-middle content tier)  
**Note**: Constrained by Platform, Business, and Security tiers  
**Categories** (5 total):

1. **Compute** (`infrastructure/compute/spec.md`, spec-id: `compute-001`)
   - Purpose: VM SKUs, autoscaling, reserved instances, availability sets/zones
   - Example: Standard_B2s (dev), Standard_B4ms (prod), 3-year reserved instances, availability zones for critical workloads
   - Dependencies: business/cost-001 (budget constraints), security/dp-001 (disk encryption)
   - Precedence: Loses to platform/* (technical standards non-negotiable), wins over storage (workload determines storage tier)
   - Status: Published v1.0.0

2. **Networking** (`infrastructure/networking/spec.md`, spec-id: `net-001`)
   - Purpose: VNet architecture, NSGs, load balancing, private DNS, ExpressRoute/VPN
   - Example: /16 VNets, NSGs on all subnets, Standard Load Balancer, private DNS zones
   - Dependencies: business/governance (SLA requirements for load balancer tier)
   - Precedence: Loses to platform/* (technical standards non-negotiable), dual-gate with cost (SLA + cost both constrain networking SKUs)
   - Status: Draft v1.0.0-draft

3. **Storage** (`infrastructure/storage/spec.md`, spec-id: `stor-001`)
   - Purpose: Disk tiers, replication strategies, backup policies, retention
   - Example: Standard SSD default, LRS replication, 30-day backup retention, GRS for critical data
   - Dependencies: compute-001 (workload determines tier), compliance-framework (retention requirements)
   - Precedence: Loses to platform/* (technical standards non-negotiable), loses to compute (workload-driven), loses to compliance (retention binding)
   - Status: Draft v1.0.0-draft

4. **CI/CD-Pipeline** (`infrastructure/cicd-pipeline/spec.md`, spec-id: `cicd-001`)
   - Purpose: Deployment automation, approval gates, rollback procedures, pipeline security
   - Example: GitHub Actions, production approval gates, automated validation, rollback procedures
   - Dependencies: business/governance (approval workflow requirements), compute (deployment targets)
   - Precedence: Loses to platform/* (technical standards non-negotiable), loses to governance (approval gates non-negotiable)
   - Status: Draft v1.0.0-draft

5. **IaC-Modules** (`infrastructure/iac-modules/spec.md`, spec-id: `iac-001`)
   - Purpose: Centralized reusable IaC wrapper modules based on Azure Verified Modules
   - Example: Wrapper modules for VMs, VNets, Storage, Key Vault exposing only compliant parameters
   - Dependencies: business/cost (cost-optimized SKU defaults), security/data-protection (encryption standards), platform/iac-linting (code quality)
   - Precedence: Loses to platform/* (technical standards non-negotiable), foundational for DevOps and Application tiers
   - Status: Draft v1.0.0-draft

### DevOps Tier (`/specs/devops/`)
**Purpose**: Deployment automation, observability, CI/CD orchestration, environment management  
**Priority**: 4 (lower-middle content tier)  
**Note**: Constrained by Platform, Business, Security, and Infrastructure tiers. DevOps tier bridges infrastructure and applications, defining how infrastructure is deployed, monitored, and operated.  
**Categories** (4 suggested):

1. **Deployment-Automation** (`devops/deployment-automation/spec.md`, spec-id: `deploy-001`)
   - Purpose: Deployment patterns, blue-green deployments, canary releases, rollback strategies
   - Example: Blue-green deployment for zero-downtime, automated rollback triggers, environment promotion workflows
   - Dependencies: infrastructure/iac-modules (uses IaC modules), infrastructure/cicd-pipeline (integrates with pipelines), platform/iac-linting (code quality)
   - Precedence: Loses to platform/* (technical standards non-negotiable), consumed by Application tier, constrained by Infrastructure tier
   - Status: Placeholder (to be created)

2. **Observability** (`devops/observability/spec.md`, spec-id: `obs-001`)
   - Purpose: Logging, metrics, tracing, alerting, dashboards, SLI/SLO definitions
   - Example: Azure Monitor integration, Application Insights, custom metrics, SLO: 99.9% uptime
   - Dependencies: security/audit-logging (audit log requirements), business/governance (SLA requirements), platform/* (observability standards)
   - Precedence: Loses to platform/* (technical standards non-negotiable), required by Application tier (all apps must be observable)
   - Status: Placeholder (to be created)

3. **Environment-Management** (`devops/environment-management/spec.md`, spec-id: `env-001`)
   - Purpose: Environment definitions (dev, staging, prod), configuration management, secrets management
   - Example: Dev/staging/prod environments, Azure Key Vault for secrets, environment-specific configurations
   - Dependencies: infrastructure/compute (environment sizing), security/access-control (environment access controls), platform/artifact-org (directory structure)
   - Precedence: Loses to platform/* (technical standards non-negotiable), defines deployment targets for Application tier
   - Status: Placeholder (to be created)

4. **CI-CD-Orchestration** (`devops/ci-cd-orchestration/spec.md`, spec-id: `cicd-orch-001`)
   - Purpose: CI/CD workflow orchestration, build pipelines, test automation, deployment pipelines
   - Example: GitHub Actions workflows, automated testing gates, deployment approvals
   - Dependencies: infrastructure/cicd-pipeline (pipeline infrastructure), platform/iac-linting (code quality gates)
   - Precedence: Loses to platform/* (technical standards non-negotiable), orchestrates how Application tier deploys
   - Status: Placeholder (to be created)

### Platform Tier (`/specs/platform/`)
**Purpose**: Platform standards, tooling, code quality, policy enforcement  
**Priority**: 4 (second-lowest content tier)  
**Note**: Platform-tier **content specs** (listed below) follow tier precedence. Platform **framework governance** (Principle 0) supersedes all tiers and controls `.specify/`, `.github/`, constitution.  
**Categories** (4 total):

1. **Spec-System** (`platform/spec-system/spec.md`, spec-id: `spec-001`, **META-SPEC**)
   - Purpose: Defines the category-based spec system itself (self-referential meta-specification)
   - Example: YAML frontmatter structure, 6-tier hierarchy, precedence algorithm, validation rules
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
**Priority**: 5 (lowest tier, adopts upstream category specs from all higher tiers)  
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

When conflicts arise between specs, resolve using this 6-step algorithm:

**STEP 0: Meta-Governance Check (Principle 0)**
- If conflict involves `.specify/`, `.github/`, constitution, templates, tier definitions, or role workflows:
  - **Platform role meta-governance ALWAYS WINS** (supersedes all content tier specs)
  - No other role may override framework governance
  - Proceed to governance amendment process if framework change required

**STEP 1-5: Content Spec Precedence** (applies only after Step 0 confirms no meta-governance conflict):

1. **Tier Precedence** (primary): Higher content tier always wins (**platform > business > security > infrastructure > devops > application**)
2. **Explicit Overrides** (trumps tier): Check `precedence.overrides` field for documented exceptions (e.g., security/data-protection may OVERRIDE business/cost when security non-negotiable, but Platform tier cannot be overridden)
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
- **Role: Platform** — (a) Updates meta-governance framework (.specify/, .github/, constitution, templates) OR (b) Updates platform-tier content specs (iac-linting, artifact-org, policy-as-code, spec-system)
- **Role: Business** — Updates business-tier content specs (cost, governance, compliance-framework)
- **Role: Security** — Updates security-tier content specs (data-protection, access-control, audit-logging)
- **Role: Infrastructure** — Updates infrastructure-tier content specs (compute, networking, storage, cicd-pipeline, iac-modules)
- **Role: DevOps** — Updates devops-tier content specs (deployment-automation, observability, environment-management, ci-cd-orchestration)
- **Role: Application** — Updates application-tier specs (requires application target specification: NEW or EXISTING)

**Application Role Specification**:
When declaring "Role: Application", stakeholder MUST also specify:
- **Application: NEW: [app-name]** — Create new application directory and specs
- **Application: EXISTING: [app-name]** — Update existing application's specs

### Spec Update Workflow (Steps 1-8)

1. **Role Declaration**: Stakeholder declares role + application target (if Application role).

2. **Tier Context Validation**: Platform AI acknowledges role and validates tier context.

3. **MANDATORY UPSTREAM VALIDATION CHECKPOINT** (BLOCKING):
   - Platform MUST load ALL upstream tier specs relevant to this work using glob patterns:
   - For Application tier: Load ALL specs matching `specs/platform/**/spec.md`, `specs/business/**/spec.md`, `specs/security/**/spec.md`, `specs/infrastructure/**/spec.md`, `specs/devops/**/spec.md`
   - For DevOps tier: Load ALL specs matching `specs/platform/**/spec.md`, `specs/business/**/spec.md`, `specs/security/**/spec.md`, `specs/infrastructure/**/spec.md`
   - For Infrastructure tier: Load ALL specs matching `specs/platform/**/spec.md`, `specs/business/**/spec.md`, `specs/security/**/spec.md`
   - For Security tier: Load ALL specs matching `specs/platform/**/spec.md`, `specs/business/**/spec.md`
   - For Business tier: Load ALL specs matching `specs/platform/**/spec.md`
   - For Platform tier: No upstream content tier specs (Platform is foundational)
   - Display loaded specs (spec-id, version, key constraints) to user
   - **GATE**: If upstream specs cannot be loaded or are missing, BLOCK and report error
   - **Note**: Glob pattern `specs/<tier>/**/spec.md` automatically discovers all current and future category specs in each tier

4. **Spec Creation/Update**: Stakeholder creates or updates spec via platform chat; AI assists in refining spec while continuously validating against loaded upstream specs.

5. **Compliance Verification**: Platform team reviews for:
   - Clarity and feasibility
   - **Hierarchy compliance** (explicit validation against each upstream spec)
   - Identification of any upstream constraint violations
   - **GATE**: If violations detected, BLOCK approval until resolved

6. **Spec Approval & Versioning**: Once upstream compliance verified, spec is versioned and tagged with date, rationale, approver, and upstream spec dependencies.

7. **Dependent Artifact Regeneration**: Platform triggers dependent artifact regeneration (specs cascade downward per Principle III), ensuring all artifacts reflect upstream constraints.

8. **Artifact Validation & Promotion**:
   - Generated artifacts staged for human review
   - Platform team validates: AI output quality, deployment tests, upstream spec compliance
   - **GATE**: Artifacts failing upstream spec validation are REJECTED
   - Approved artifacts promoted to production with traceability to source specs
   - Work items created for teams to consume or migrate to new versions

### Application-Tier Specific Workflow

**CASE A: NEW APPLICATION** (declared as "Application: NEW: my-app-name")
- Platform MUST:
  1. **MANDATORY UPSTREAM VALIDATION**: Load and display ALL upstream tier specs using glob patterns:
     - ALL specs matching `specs/platform/**/spec.md` (e.g., spec-system, iac-linting, artifact-org, policy-as-code) — FOUNDATIONAL
     - ALL specs matching `specs/business/**/spec.md` (e.g., cost, governance, compliance-framework)
     - ALL specs matching `specs/security/**/spec.md` (e.g., data-protection, access-control, audit-logging)
     - ALL specs matching `specs/infrastructure/**/spec.md` (e.g., iac-modules, compute, networking, storage, cicd-pipeline)
     - ALL specs matching `specs/devops/**/spec.md` (e.g., deployment-automation, observability, environment-management, ci-cd-orchestration)
     - **Note**: Using glob patterns ensures any new category specs added to these tiers are automatically included in validation
  2. Create `/specs/application/my-app-name/` directory structure
  3. Populate with standard templates: `spec.md`, `plan.md`, `tasks.md`
  4. **INJECT UPSTREAM DEPENDENCIES**: Auto-populate `spec.md` frontmatter `depends-on` field with ALL loaded upstream specs (spec-id, version, constraint summary)
  5. Prompt user to fill in application-specific requirements **while validating against upstream constraints**
  6. **VALIDATION GATE**: Before proceeding, validate that application spec does NOT violate any upstream spec constraint
  7. Version as v1.0.0 (new application) with upstream dependency manifest
  8. Auto-generate work items and cascading downstream artifacts (IaC modules, tasks) **using upstream specs as binding constraints**

**CASE B: EXISTING APPLICATION** (declared as "Application: EXISTING: my-app-name")
- Platform MUST:
  1. Locate `/specs/application/my-app-name/` directory
  2. Review existing `spec.md`, `plan.md`, `tasks.md` files
  3. **MANDATORY UPSTREAM VALIDATION**: Load current versions of ALL upstream tier specs using glob patterns (same patterns as CASE A):
     - ALL specs matching `specs/platform/**/spec.md` — FOUNDATIONAL
     - ALL specs matching `specs/business/**/spec.md`
     - ALL specs matching `specs/security/**/spec.md`
     - ALL specs matching `specs/infrastructure/**/spec.md`
     - ALL specs matching `specs/devops/**/spec.md`
  4. **COMPLIANCE AUDIT**: Compare existing application spec against current upstream specs
     - Identify any upstream specs that have changed since last application spec update
     - Flag any new upstream constraints that existing spec violates
     - **GATE**: If critical violations detected, BLOCK updates until resolved
  5. Update appropriate file(s) based on user request **while maintaining upstream compliance**
  6. **VALIDATION GATE**: Validate that updates do NOT introduce new upstream spec violations
  7. Update `spec.md` frontmatter `depends-on` field to reflect current upstream spec versions
  8. Increment version (PATCH/MINOR/MAJOR as appropriate) with upstream compliance verification
  9. Maintain changelog documenting upstream spec changes and compliance updates
  10. Auto-generate work items and cascading downstream artifact updates **validated against current upstream specs**

### Artifact Review Gates (MANDATORY BLOCKING VALIDATION)

**ALL Artifacts** (regardless of tier) MUST pass:
1. **Upstream Spec Compliance Check** (BLOCKING):
   - Validate against ALL upstream tier specs (cite spec-id + version in artifact metadata)
   - Check explicit constraints: cost limits, SKU restrictions, encryption requirements, retention policies, etc.
   - **FAIL GATE**: If any upstream constraint violated, artifact REJECTED with violation report

2. **Tier-Specific Gates**:

   **Application-Tier IaC Artifacts** (Bicep, Terraform, ARM templates):
   - **Platform Tier Validation** (BLOCKING, FOUNDATIONAL):
     - MUST validate compliance with ALL specs matching `specs/platform/**/spec.md`
     - Example validations include (but not limited to):
       * Pass iac-linting validation (bicep build, PSScriptAnalyzer, yamllint)
       * Follow directory structure per artifact-org spec
       * Include Azure Policy compliance tags per policy-as-code spec
       * Follow spec-system frontmatter and versioning requirements
     - **Note**: Platform validation is FOUNDATIONAL and cannot be overridden by any other tier
   - **Business Tier Validation** (BLOCKING):
     - MUST validate compliance with ALL specs matching `specs/business/**/spec.md`
     - Example validations include (but not limited to):
       * Include cost estimation aligned with cost spec budget targets
       * Include approval gates per governance spec
       * Include compliance tags per compliance-framework spec (data residency, retention)
     - **Note**: Validation automatically includes any new business category specs added
   - **Security Tier Validation** (BLOCKING):
     - MUST validate compliance with ALL specs matching `specs/security/**/spec.md`
     - Example validations include (but not limited to):
       * Include encryption settings per data-protection spec (disk encryption, Key Vault integration)
       * Include RBAC assignments per access-control spec
       * Include audit logging configurations per audit-logging spec
     - **Note**: Validation automatically includes any new security category specs added
   - **Infrastructure Tier Validation** (BLOCKING):
     - MUST validate compliance with ALL specs matching `specs/infrastructure/**/spec.md`
     - Example validations include (but not limited to):
       * Use IaC modules from iac-modules catalog only (Azure Verified Module wrappers)
       * Follow module naming conventions defined in infrastructure specs
       * Comply with compute SKU restrictions from compute specs
       * Comply with networking architecture (VNet/NSG requirements) from networking specs
       * Comply with storage tier policies from storage specs
       * Integrate with CI/CD pipelines per cicd-pipeline specs
     - **Note**: Validation automatically includes any new infrastructure category specs added
   - **DevOps Tier Validation** (BLOCKING):
     - MUST validate compliance with ALL specs matching `specs/devops/**/spec.md`
     - Example validations include (but not limited to):
       * Follow deployment automation patterns per deployment-automation spec
       * Include observability instrumentation per observability spec (logging, metrics, tracing)
       * Comply with environment management requirements per environment-management spec
       * Integrate with CI/CD orchestration per ci-cd-orchestration spec
     - **Note**: Validation automatically includes any new DevOps category specs added

   **Application-Tier Tasks** (tasks.md, work breakdown):
   - MUST reference Platform tier standards (discovered via `specs/platform/**/spec.md` pattern) — FOUNDATIONAL
   - MUST reference specific DevOps practices from devops tier specs (discovered via `specs/devops/**/spec.md` pattern)
   - MUST reference specific IaC modules from infrastructure tier specs (discovered via `specs/infrastructure/**/spec.md` pattern)
   - MUST include validation steps for each upstream tier spec (all specs discovered via glob patterns)
   - MUST include upstream spec compliance verification tasks
   - **FAIL GATE**: Tasks that do NOT reference platform, devops, or infrastructure tier specs are REJECTED

   **Infrastructure/Platform/Security/DevOps Tier Artifacts**:
   - Similar upstream validation against applicable higher tiers
   - IaC modules MUST include cost estimates, policy compliance, deployment tests
   - DevOps tier artifacts MUST validate against infrastructure, security, and business tier specs

3. **Deployment Testing**:
   - Bicep/Terraform templates MUST successfully deploy in test subscription
   - Policy-as-code scanning MUST pass all security policies
   - GitHub Actions pipelines MUST run successfully in CI with security scanning

4. **Traceability Documentation**:
   - Work items & change logs MUST document:
     - Source spec (tier, category, spec-id, version)
     - Upstream spec dependencies (all dependent spec-ids + versions)
     - Cost impact (validated against business/cost spec)
     - Security changes (validated against security tier specs)
     - Migration steps

**Rejection Protocol**:
- Artifacts failing ANY gate are REJECTED immediately
- Platform MUST provide detailed violation report:
  - Failing gate name
  - Upstream spec violated (tier, category, spec-id, version, specific requirement)
  - Remediation guidance
- Artifact CANNOT proceed until all violations resolved and re-validated

## Governance

The Platform Team holds **exclusive meta-governance authority** (Principle 0) over:
- **Constitution and Framework**: This constitution, tier definitions, role workflows, precedence algorithms
- **Reserved Directories**: `.specify/` (templates, scripts, commands, config), `.github/` (workflows, automation)
- **Template Structures**: spec-template, plan-template, tasks-template, command mode definitions
- **Quality Standards**: AI-generated artifact standards, validation gates, review processes
- **Change Approval**: Workflow and cascade rules, amendment procedures
- **Tooling**: Selection and integration (AI models, IaC frameworks, CI/CD platforms)

No other role may modify these framework elements without Platform team approval.

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

**Version**: 2.1.0 | **Ratified**: 2026-02-05 | **Last Amended**: 2026-02-09 (Amendment: Category-Scoped Role Targeting)
