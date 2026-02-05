# Specification: Application Artifact Organization Standard

**Tier**: platform  
**Spec ID**: platform-001-application-artifact-organization  
**Created**: 2026-02-05  
**Status**: Approved  
**Approved By**: Platform Team  
**Approved Date**: 2026-02-05  
**Input**: User description: "Establish standardized directory structure for application artifacts organized by application name with subdirectories for different artifact types (IaC, modules, scripts, pipelines, documentation)"

---

## 🎯 IMPORTANT: Role Declaration Protocol (Per Constitution §II)

This spec was created via:
- **Role Declared**: Platform
- **Application Target**: N/A (Platform tier is foundational governance)

> Constitution §II requires ALL spec updates to begin with explicit role declaration. This Platform spec establishes foundational artifact organization governance that applies across all application tiers.

---

## Spec Source & Hierarchy

**Parent Tier Specs** (constraints that apply to this spec):
- None (Platform tier is foundational; no parent tiers)

**Derived Downstream Specs** (specs that will depend on this one):
- All application-tier specs MUST conform to this artifact organization standard
- Infrastructure-tier specs generating application IaC MUST target app-specific directories
- Security-tier specs enforcing compliance MUST reference artifacts in app-specific structure

---

## Executive Summary

**Problem**: Currently, application artifacts are scattered across `/artifacts/` with no consistent organization by application. This makes it difficult to:
- Track which artifacts belong to which application
- Isolate application-specific configurations
- Scale to multiple applications
- Apply per-application governance

**Solution**: Establish a standardized artifact directory hierarchy at `/artifacts/applications/<appname>/` with structured subdirectories for different artifact types.

**Impact**: All application teams will organize artifacts consistently, enabling better governance, traceability, and multi-application platform management.

**Timeline**: Implementation should complete by end of Q1 2026.

---

## User Scenarios & Testing

### User Story 1 - Application Team Deploys Infrastructure Code (Priority: P1)

An application team has a new application ("payment-service") and needs to deploy infrastructure components. Following this standard, they:

1. Create directory structure: `/artifacts/applications/payment-service/`
2. Create subdirectory: `/artifacts/applications/payment-service/iac/`
3. Add Bicep templates: `main.bicep`, `parameters.json`
4. Follow naming convention: `<appname>-<component>.bicep` (e.g., `payment-service-function-app.bicep`)
5. Artifacts are isolated, versioned, and traceable to the application

**Why this priority**: Core use case; all applications need IaC organization.

**Independent Test**: Can create application directory, add IaC files, and deploy via `az deployment` targeting that structure.

**Acceptance Scenarios**:

1. **Given** an application team creates a new application, **When** they need to deploy infrastructure, **Then** they can create `/artifacts/applications/<appname>/iac/` and add Bicep templates there
2. **Given** an application has multiple infrastructure components (function app, storage, networking), **When** they need to organize them, **Then** they can create separate Bicep files in `iac/` subdirectory with clear naming
3. **Given** a team reviews artifacts, **When** they look at `/artifacts/applications/payment-service/`, **Then** they can immediately identify what artifacts belong to that application

---

### User Story 2 - Platform Team Manages Multiple Applications (Priority: P1)

The platform team manages multiple applications (payment-service, analytics-platform, web-app-001). Following this standard:

1. Each application has isolated artifact directory
2. Platform team can list applications: `ls /artifacts/applications/`
3. Platform team can apply governance per-app (e.g., scan each app's IaC independently)
4. Platform team can track artifacts by app for cost allocation
5. Multi-app platform is cleanly organized

**Why this priority**: Essential for platform scaling to multiple applications.

**Independent Test**: Can list all applications, identify artifact types per app, and apply platform-wide governance scans.

**Acceptance Scenarios**:

1. **Given** the platform has 3+ applications, **When** the platform team reviews `/artifacts/applications/`, **Then** they can see all applications organized consistently
2. **Given** each application has different artifact types, **When** platform team scans for policy violations, **Then** they can target `<appname>/iac/*.bicep` independently
3. **Given** cost allocation is required, **When** cost tools analyze `/artifacts/applications/*/iac/`, **Then** costs can be attributed per application

---

### User Story 3 - Developer Finds Artifacts by Application (Priority: P2)

A developer joins the team and needs to find artifacts for "web-app-001". Following this standard:

1. Developer navigates to `/artifacts/applications/web-app-001/`
2. Discovers subdirectories: `iac/`, `modules/`, `scripts/`, `pipelines/`, `docs/`
3. Can immediately find relevant artifacts
4. Documentation explains what each subdirectory contains
5. Onboarding is faster

**Why this priority**: Improves developer experience; enables faster onboarding.

**Independent Test**: New developer can find all artifacts for an application without external guidance.

**Acceptance Scenarios**:

1. **Given** a developer needs Bicep templates for web-app-001, **When** they navigate to `/artifacts/applications/web-app-001/iac/`, **Then** they find organized templates
2. **Given** a developer needs to understand artifact organization, **When** they read `/artifacts/applications/web-app-001/README.md`, **Then** they understand the structure
3. **Given** a developer needs to modify IaC modules, **When** they look in `/artifacts/applications/web-app-001/modules/`, **Then** they find reusable module definitions

---

### User Story 4 - GitHub Actions Pipeline Targets App-Specific Artifacts (Priority: P2)

CI/CD pipelines need to deploy application-specific artifacts. Following this standard:

1. Pipeline template references: `/artifacts/applications/${{ github.event.repository.name }}/iac/`
2. Pipeline can be parameterized by application name
3. Multiple applications can share the same pipeline template structure
4. Deployment is isolated per application

**Why this priority**: Enables automation at scale; supports multiple applications with consistent pipelines.

**Independent Test**: GitHub Actions pipeline can parameterize app name and deploy from app-specific directory.

**Acceptance Scenarios**:

1. **Given** a GitHub Actions workflow deploys infrastructure, **When** it's configured with `appname` parameter, **Then** it targets `/artifacts/applications/$appname/iac/`
2. **Given** two applications use the same pipeline template, **When** they deploy, **Then** each deploys from its own `/artifacts/applications/*/iac/` directory

---

### User Story 5 - Compliance Scanning is Per-Application (Priority: P3)

Security scanning tools need to analyze artifacts. Following this standard:

1. Compliance scanner targets `/artifacts/applications/<appname>/iac/` for policy violations
2. Results are attributed to specific application
3. Remediation can be tracked per application
4. Multi-application compliance reporting is feasible

**Why this priority**: Enables governance at scale; supports compliance audits.

**Independent Test**: Compliance scanner can run per-application and generate per-app reports.

**Acceptance Scenarios**:

1. **Given** a security policy scan runs, **When** it targets `/artifacts/applications/*/iac/`, **Then** violations are reported per application
2. **Given** an application fails compliance, **When** remediation is applied, **Then** only that application's artifacts are updated

---

### Edge Cases

- What if an application artifact is too large for single directory? → Create subdirectories within artifact type (e.g., `iac/core/`, `iac/addons/`)
- What if an artifact is shared between applications? → Store in `/artifacts/shared/` with cross-references in app-specific `docs/`
- What if an application has no certain artifact type (e.g., no scripts)? → Omit that subdirectory; only create needed directories
- What if migrating existing artifacts? → Create new structure; maintain backward compatibility with old structure temporarily (90-day sunset)

---

## Requirements

### Functional Requirements

- **REQ-001**: Platform MUST enforce artifact organization standard: `/artifacts/applications/<appname>/` for all application artifacts
- **REQ-002**: Platform MUST define standard subdirectories within app artifact directory: `iac/`, `modules/`, `scripts/`, `pipelines/`, `docs/`
- **REQ-003**: Platform MUST provide directory creation templates that auto-generate subdirectories with README.md files explaining each directory's purpose
- **REQ-004**: Platform MUST document naming conventions for artifacts (e.g., `<appname>-<component>.bicep`)
- **REQ-005**: Platform MUST create migration tooling to move existing artifacts to new structure
- **REQ-006**: Platform MUST enforce this standard in quality gates (artifact review gates MUST validate directory structure compliance)
- **REQ-007**: Platform MUST provide documentation (README, examples) showing correct artifact organization for all application teams
- **REQ-008**: Platform MUST support GitHub Actions templates that reference app-specific artifact paths

### Key Entities

- **Application Artifact Directory** - Root directory: `/artifacts/applications/<appname>/`
  - Contains: Subdirectories for artifact types
  - Naming: lowercase app name, hyphen-separated (e.g., `payment-service`, `web-app-001`)
  - Metadata: README.md explaining structure

- **IaC Subdirectory** - `/artifacts/applications/<appname>/iac/`
  - Contains: Bicep templates, ARM templates, Terraform code, parameter files
  - Naming: `<appname>-<component>.bicep` (e.g., `payment-service-function-app.bicep`)

- **Modules Subdirectory** - `/artifacts/applications/<appname>/modules/`
  - Contains: Reusable IaC modules, module definitions, module parameters
  - Naming: `<modulename>.bicep` (e.g., `app-insights-monitoring.bicep`)

- **Scripts Subdirectory** - `/artifacts/applications/<appname>/scripts/`
  - Contains: PowerShell, Python, Bash scripts for deployment, validation, operations
  - Naming: `<appname>-<purpose>.ps1` (e.g., `payment-service-validate-deployment.ps1`)

- **Pipelines Subdirectory** - `/artifacts/applications/<appname>/pipelines/`
  - Contains: GitHub Actions workflows, pipeline templates, deployment configurations
  - Naming: `<purpose>.yml` (e.g., `deploy-infrastructure.yml`)

- **Docs Subdirectory** - `/artifacts/applications/<appname>/docs/`
  - Contains: README.md, architecture diagrams, runbooks, configuration guides
  - README.md: Explains application structure, artifact organization, deployment steps

### Tier-Specific Constraints (Platform Tier)

- **Platform Governance**: This standard is MANDATORY for all applications; no exceptions
- **Compliance**: All application-tier specs MUST reference artifacts within `/artifacts/applications/<appname>/` structure
- **Infrastructure Teams**: When generating application IaC, MUST target app-specific directories
- **Application Teams**: When creating new applications, MUST create directory structure following this standard
- **Migration Deadline**: Existing artifacts must migrate by 2026-03-31 (90-day period)

---

## Success Criteria

- **SC-001**: All new applications created after 2026-02-05 follow `/artifacts/applications/<appname>/` structure
- **SC-002**: Directory structure includes all 5 artifact subdirectories (iac, modules, scripts, pipelines, docs)
- **SC-003**: Each subdirectory contains README.md explaining its purpose and naming conventions
- **SC-004**: Existing applications (cost-optimized-demo) migrated to new structure by 2026-03-31
- **SC-005**: GitHub Actions templates parameterized to target app-specific artifact paths
- **SC-006**: Quality gates validate artifact organization (check directory structure exists, required files present)
- **SC-007**: Platform documentation (ARTIFACT_ORGANIZATION_GUIDE.md) published and available
- **SC-008**: Team onboarding documentation updated to include artifact organization standard

---

## Implementation Approach

### Phase 1: Define Standard & Create Templates (Week 1)
1. Ratify this spec (Constitution compliant)
2. Create directory structure template with README.md files
3. Publish ARTIFACT_ORGANIZATION_GUIDE.md with examples
4. Create PowerShell/bash scripts to auto-generate directory structure

### Phase 2: Update Existing Artifacts (Weeks 2-4)
1. Create migration plan for existing artifacts
2. Move cost-optimized-demo artifacts to new structure
3. Update specifications and plans to reference new paths
4. Maintain backward compatibility (symlinks if needed)

### Phase 3: Enforce Standard (Weeks 5-12)
1. Update quality gates to validate directory structure
2. Update GitHub Actions templates to parameterize app name
3. Add compliance scanning per-app
4. Provide team training/documentation

### Phase 4: Sunset Old Structure (by 2026-03-31)
1. Remove backward compatibility
2. Archive old artifact locations
3. Celebrate successful migration!

---

## Open Questions / NEEDS CLARIFICATION

- **NEEDS CLARIFICATION**: Should we version artifacts per application (`<appname>/v1.0/iac/` structure)? Or version at platform level?
- **NEEDS CLARIFICATION**: Should we enforce strict naming conventions (validation script) or provide guidelines (soft enforcement)?
- **NEEDS CLARIFICATION**: Who owns artifact organization governance? Platform team or individual application teams?

---

## Related Platform Specs

- **platform/002-artifact-governance-automation** (planned) - Automated quality gates for artifact structure
- **platform/003-multi-application-platform-management** (planned) - Governance across multiple applications
- **Constitution §Principle I** - Spec-driven tiered development (this spec establishes artifact tier structure)

---

**Specification Status**: Draft  
**Created**: 2026-02-05  
**Author**: Platform Team  
**Next Step**: Create implementation plan (plan.md)