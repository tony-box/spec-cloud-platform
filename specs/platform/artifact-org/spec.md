---
# YAML Frontmatter - Category-Based Spec System
tier: platform
category: artifact-org
spec-id: artifact-001
version: 1.0.0
status: published
created: 2026-02-06
last-updated: 2026-02-07
description: "Artifact repository organization, directory structure, naming conventions"

# Dependencies
depends-on:
  - tier: platform
    category: spec-system
    spec-id: spec-001
    reason: "Artifact organization follows specification system structure"

# Relationships
adhered-by:
  - app-id: mycoolapp
    version: "1.0.0"
    structure: "artifacts/applications/mycoolapp/ with iac/, scripts/, pipelines/, docs/ subdirectories"
---

# Specification: Application Artifact Organization Standard

**Tier**: platform  
**Category**: artifact-org  
**Spec ID**: artifact-001  
**Created**: 2026-02-05  
**Status**: Published  
**Approved By**: Platform Team  
**Approved Date**: 2026-02-05  
**Input**: User description: "Establish standardized directory structure for application artifacts organized by application name with subdirectories for different artifact types (IaC, modules, scripts, pipelines, documentation)"

## Spec Source & Hierarchy

**Parent Tier Specs** (constraints that apply to this spec):
- **platform/spec-system** (v1.0.0-draft) - Defines specification structure this artifact organization follows

**Derived Downstream Specs** (specs that will depend on this one):
- All application-tier specs MUST conform to this artifact organization standard
- Infrastructure-tier specs generating application IaC MUST target app-specific directories
- Security-tier specs enforcing compliance MUST reference artifacts in app-specific structure

## Executive Summary

**Problem**: Currently, application artifacts are scattered across `/artifacts/` with no consistent organization by application. This makes it difficult to:
- Track which artifacts belong to which application
- Isolate application-specific configurations
- Scale to multiple applications
- Apply per-application governance

**Solution**: Establish a standardized artifact directory hierarchy at `/artifacts/applications/<appname>/` with structured subdirectories for different artifact types.

**Impact**: All application teams will organize artifacts consistently, enabling better governance, traceability, and multi-application platform management.

**Timeline**: Implementation should complete by end of Q1 2026.

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
  - Naming: lowercase app name, hyphen-separated (e.g., `payment-service`, `mycoolapp`)
  - Metadata: README.md explaining structure

- **IaC Subdirectory** - `/artifacts/applications/<appname>/iac/`
  - Contains: Bicep templates, ARM templates, Terraform code, parameter files
  - Naming: `<appname>-<component>.bicep` or `main.bicep`

- **Modules Subdirectory** - `/artifacts/applications/<appname>/modules/`
  - Contains: Reusable IaC modules, module definitions, module parameters
  - Naming: `<modulename>.bicep` (e.g., `app-insights-monitoring.bicep`)

- **Scripts Subdirectory** - `/artifacts/applications/<appname>/scripts/`
  - Contains: PowerShell, Python, Bash scripts for deployment, validation, operations
  - Naming: `<purpose>.ps1` (e.g., `deploy.ps1`, `validate-deployment.ps1`)

- **Pipelines Subdirectory** - `/artifacts/applications/<appname>/pipelines/`
  - Contains: GitHub Actions workflows, pipeline templates, deployment configurations
  - Naming: `<purpose>.yml` (e.g., `deploy.yml`)

- **Docs Subdirectory** - `/artifacts/applications/<appname>/docs/`
  - Contains: README.md, architecture diagrams, runbooks, configuration guides

### Tier-Specific Constraints (Platform Tier)

- **Platform Governance**: This standard is MANDATORY for all applications; no exceptions
- **Compliance**: All application-tier specs MUST reference artifacts within `/artifacts/applications/<appname>/` structure
- **Infrastructure Teams**: When generating application IaC, MUST target app-specific directories
- **Application Teams**: When creating new applications, MUST create directory structure following this standard
- **Migration Deadline**: Existing artifacts must migrate by 2026-03-31 (90-day period)

## Success Criteria

- **SC-001**: All new applications created after 2026-02-05 follow `/artifacts/applications/<appname>/` structure
- **SC-002**: Directory structure includes all 5 artifact subdirectories (iac, modules, scripts, pipelines, docs)
- **SC-003**: Each subdirectory contains README.md explaining its purpose and naming conventions
- **SC-004**: Existing applications (mycoolapp) migrated to new structure (COMPLETED)
- **SC-005**: GitHub Actions templates parameterized to target app-specific artifact paths
- **SC-006**: Quality gates validate artifact organization (check directory structure exists, required files present)

## Change Log

| Version | Date | Change | Approved By |
|---------|------|--------|------------|
| 1.0.0 | 2026-02-05 | Initial platform spec: Application artifact organization | Platform Team |

---

**Spec Version**: 1.0.0  
**Approved Date**: 2026-02-05  
**Next Review**: 2026-05-31 (quarterly check-in)
