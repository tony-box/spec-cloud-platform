# Artifact Organization Guide

**Version**: 1.0.0  
**Status**: Approved  
**Last Updated**: 2026-02-05  
**Per Specification**: [spec-platform-001-application-artifact-organization](../../../specs/platform/001-application-artifact-organization/spec.md)

---

## Table of Contents

1. [Overview](#overview)
2. [Standard Directory Structure](#standard-directory-structure)
3. [Directory Purposes](#directory-purposes)
4. [Naming Conventions](#naming-conventions)
5. [Creating a New Application](#creating-a-new-application)
6. [Validation & Quality Gates](#validation--quality-gates)
7. [Migration Guidelines](#migration-guidelines)
8. [Best Practices](#best-practices)
9. [FAQ](#faq)
10. [Support & Escalation](#support--escalation)

---

## Overview

This guide establishes the **standard artifact organization structure** for all applications deployed on the spec-cloud-platform. Every application must organize its Infrastructure-as-Code (IaC), scripts, pipelines, and documentation according to this structure.

**Key Principles**:
- **Consistency**: All applications follow the same directory layout
- **Clarity**: Clear purpose for each directory
- **Scalability**: Support for multiple applications and teams
- **Automation**: Scripts enable automatic creation and validation

**Scope**:
- All applications in `/artifacts/applications/<appname>/`
- All artifact types: IaC (Bicep), modules, scripts, pipelines, documentation
- Both new applications and migrations of existing artifacts

---

## Standard Directory Structure

Every application must have this directory structure:

```
artifacts/applications/<appname>/
├── README.md                      ← Application overview (REQUIRED)
├── .gitignore                     ← Git ignore patterns (RECOMMENDED)
│
├── iac/                           ← Infrastructure-as-Code
│   ├── README.md
│   ├── <appname>-main.bicep
│   ├── <appname>-networking.bicep
│   └── <appname>-*.bicep
│
├── modules/                       ← Reusable IaC modules
│   ├── README.md
│   ├── app-service/
│   │   └── main.bicep
│   ├── sql-database/
│   │   └── main.bicep
│   └── */
│       └── main.bicep
│
├── scripts/                       ← Deployment & operations scripts
│   ├── README.md
│   ├── <appname>-deploy.ps1
│   ├── <appname>-validate.ps1
│   ├── <appname>-configure.ps1
│   └── <appname>-*.ps1|sh|py
│
├── pipelines/                     ← CI/CD workflows
│   ├── README.md
│   ├── .github/
│   │   └── workflows/
│   │       ├── deploy.yml
│   │       ├── validate.yml
│   │       └── *.yml
│   └── (other CI/CD configs)
│
└── docs/                          ← Documentation
    ├── README.md
    ├── ARCHITECTURE.md            ← Architecture overview
    ├── DEPLOYMENT.md              ← Deployment procedures
    ├── RUNBOOK.md                 ← Operations runbook
    ├── CONFIGURATION.md           ← Configuration guide
    └── *.md
```

---

## Directory Purposes

### `README.md` (Root Level) - REQUIRED

**Purpose**: Provides high-level overview of the application and its artifacts.

**Content**:
- Application name and description
- Quick start / getting started instructions
- Architecture overview (link to docs/ARCHITECTURE.md)
- Key contacts / responsible teams
- Links to detailed documentation

**Template**:
```markdown
# [Application Name]

**Status**: [Active/Beta/Deprecated]  
**Owner**: [Team Name]  
**Parent Spec**: [spec-platform-001-application-artifact-organization]

## Overview

[Brief description of the application]

## Quick Start

1. Review [ARCHITECTURE.md](docs/ARCHITECTURE.md) for system design
2. For deployment, see [DEPLOYMENT.md](docs/DEPLOYMENT.md)
3. For operations, see [RUNBOOK.md](docs/RUNBOOK.md)

## Project Structure

- `iac/` - Infrastructure-as-Code (Bicep)
- `modules/` - Reusable modules
- `scripts/` - Deployment and operations scripts
- `pipelines/` - CI/CD workflows
- `docs/` - Documentation

## Key Artifacts

| Artifact | Type | Purpose |
|----------|------|---------|
| [main.bicep](iac/main.bicep) | IaC | Main infrastructure definition |
| [deploy.yml](pipelines/.github/workflows/deploy.yml) | Pipeline | Deployment workflow |

## Support

For questions or issues, contact: [Team Name] @ [slack/email]
```

### `iac/` Directory

**Purpose**: Infrastructure-as-Code definitions for the application.

**Naming**: `<appname>-<component>.bicep`

**Examples**:
- `payment-service-main.bicep` - Main infrastructure
- `payment-service-database.bicep` - Database resources
- `payment-service-networking.bicep` - Network configuration
- `payment-service-security.bicep` - Security resources

**Guidelines**:
- One `.bicep` file per logical component
- Use `modules/` for reusable components
- Include comments explaining parameters and variables
- Reference security and compliance requirements

**See Also**: [iac/README.md](../.templates/application-artifact-template/iac/README.md)

### `modules/` Directory

**Purpose**: Reusable infrastructure modules that can be used across applications.

**Structure**:
```
modules/
├── app-service/
│   ├── main.bicep
│   ├── variables.bicep
│   └── README.md
├── sql-database/
│   ├── main.bicep
│   ├── variables.bicep
│   └── README.md
└── [component-name]/
    └── main.bicep
```

**Naming**: Descriptive folder names matching component type

**Guidelines**:
- Each module in its own folder
- Include `main.bicep` with module definition
- Add `README.md` documenting module usage
- Include `variables.bicep` for input parameters
- Support cross-application reuse

**See Also**: [modules/README.md](../.templates/application-artifact-template/modules/README.md)

### `scripts/` Directory

**Purpose**: PowerShell, Python, and Bash scripts for deployment and operations.

**Naming**: `<appname>-<purpose>.<extension>`

**Examples**:
- `payment-service-deploy.ps1` - Deploy infrastructure
- `payment-service-validate.ps1` - Validate deployment
- `payment-service-configure.ps1` - Configure application
- `payment-service-backup.sh` - Backup operations
- `payment-service-rollback.py` - Rollback operations

**Guidelines**:
- Use PowerShell (.ps1) as primary scripting language
- Add Bash (.sh) or Python (.py) for cross-platform support
- Include script documentation (comment header)
- Implement error handling and validation
- Make scripts idempotent where possible

**See Also**: [scripts/README.md](../.templates/application-artifact-template/scripts/README.md)

### `pipelines/` Directory

**Purpose**: CI/CD pipeline definitions and GitHub Actions workflows.

**Structure**:
```
pipelines/
├── .github/
│   └── workflows/
│       ├── deploy.yml
│       ├── validate.yml
│       └── test.yml
└── README.md
```

**Naming**: Descriptive workflow names matching purpose
- `deploy.yml` - Production deployment
- `validate.yml` - Infrastructure validation
- `test.yml` - Automated testing

**Guidelines**:
- Use GitHub Actions for primary CI/CD
- Include workflow triggers (push, pull_request, manual)
- Parameterize for application-specific configuration
- Reference scripts from `scripts/` directory
- Include status badges in main README.md

**See Also**: [pipelines/README.md](../.templates/application-artifact-template/pipelines/README.md)

### `docs/` Directory

**Purpose**: Comprehensive documentation for the application.

**Required Files**:
- `README.md` - Documentation index

**Recommended Files**:
- `ARCHITECTURE.md` - System architecture and design
- `DEPLOYMENT.md` - Deployment procedures and runbooks
- `RUNBOOK.md` - Operational procedures
- `CONFIGURATION.md` - Configuration options and settings

**Guidelines**:
- Use Markdown format for all documentation
- Include diagrams for architecture (Mermaid or ASCII)
- Keep documentation up-to-date with code
- Link documentation from main README.md

**See Also**: [docs/README.md](../.templates/application-artifact-template/docs/README.md)

---

## Naming Conventions

### Application Names

- **Format**: lowercase, hyphen-separated alphanumerics
- **Examples**: `payment-service`, `api-gateway`, `cost-optimizer`
- **Valid Pattern**: `^[a-z0-9][a-z0-9-]*[a-z0-9]$`

### Artifact Names

All artifacts should follow the pattern: `<appname>-<purpose>.<extension>`

**Examples**:
- IaC: `payment-service-main.bicep`
- Scripts: `payment-service-deploy.ps1`
- Workflows: Individual files in `workflows/` directory

### Directory Names

- Lowercase, no spaces
- Descriptive purpose
- Examples: `iac`, `modules`, `scripts`, `pipelines`, `docs`

---

## Creating a New Application

### Automated Creation (Recommended)

Use the `create-app-directory.ps1` script to automatically create the standard structure:

```powershell
# From repository root
./artifacts/.templates/scripts/create-app-directory.ps1 -AppName "my-app"
```

**Output**:
```
✅ Created application directory structure:
   artifacts/applications/my-app/
   ├── README.md (generated from template)
   ├── .gitignore
   ├── iac/
   │   └── README.md
   ├── modules/
   │   └── README.md
   ├── scripts/
   │   └── README.md
   ├── pipelines/
   │   └── README.md
   └── docs/
       └── README.md

Next Steps:
1. Update README.md with application details
2. Create your first Bicep file: iac/my-app-main.bicep
3. Add deployment script: scripts/my-app-deploy.ps1
4. Create deployment workflow: pipelines/.github/workflows/deploy.yml
5. Run validation: ./artifacts/.templates/scripts/validate-artifact-structure.ps1 -AppName "my-app"
```

### Manual Creation

If creating manually:

1. Create directory: `artifacts/applications/<appname>/`
2. Create subdirectories: `iac/`, `modules/`, `scripts/`, `pipelines/`, `docs/`
3. Copy README.md templates from `.templates/application-artifact-template/<subdir>/README.md`
4. Update templates with application-specific content
5. Run validation (see below)

---

## Validation & Quality Gates

### Manual Validation

Before committing changes, validate the artifact structure:

```powershell
./artifacts/.templates/scripts/validate-artifact-structure.ps1 -AppName "my-app"
```

**Output (Success)**:
```
🔍 Validating artifact structure for: my-app
✓ Directory exists: artifacts/applications/my-app
✓ Found: iac/
  → README.md present
✓ Found: modules/
  → README.md present
✓ Found: scripts/
  → README.md present
✓ Found: pipelines/
  → README.md present
✓ Found: docs/
  → README.md present
✓ Application README.md found
✓ .gitignore found
✓ App name format valid: my-app

✅ VALIDATION PASSED
```

**Output (Failure)**:
```
❌ Missing required subdirectory: iac
❌ Missing required file: README.md (application overview)
❌ VALIDATION FAILED
   Fix the errors above and try again
```

### Automated CI/CD Validation

GitHub Actions pipeline should include validation step:

```yaml
- name: Validate artifact structure
  run: |
    ./artifacts/.templates/scripts/validate-artifact-structure.ps1 `
      -AppName ${{ env.APP_NAME }} `
      -Verbose
```

**Deployment Blockers**:
- ✗ Missing required subdirectories (iac, modules, scripts, pipelines, docs)
- ✗ Missing root README.md
- ✗ Invalid application name format

**Warnings** (do not block):
- ⚠️ Missing .gitignore
- ⚠️ Missing subdirectory README.md files

---

## Migration Guidelines

For migrating existing artifacts to the new structure:

### Pre-Migration Checklist

- [ ] Inventory existing artifacts (IaC files, scripts, pipelines)
- [ ] Identify application grouping
- [ ] Plan directory mapping
- [ ] Review for outdated or duplicate artifacts
- [ ] Get stakeholder approval

### Migration Steps

1. **Create new application directory** (see "Creating a New Application" above)
2. **Migrate IaC files** to `iac/` directory
   - Rename files to follow naming convention: `<appname>-<component>.bicep`
   - Update file references and imports
   - Test deployment from new location
3. **Migrate/consolidate modules** to `modules/` directory
   - Extract reusable components
   - Update module references
4. **Migrate scripts** to `scripts/` directory
   - Update script paths and references
   - Test script execution
5. **Migrate/update pipelines** to `pipelines/` directory
   - Update workflow file paths
   - Update artifact references
   - Test workflow execution
6. **Consolidate documentation** to `docs/` directory
   - Create/update README.md files per directory
   - Link from main application README.md
7. **Validation**
   - Run validation script: `validate-artifact-structure.ps1`
   - Test deployment pipeline end-to-end
   - Verify documentation completeness
8. **Cleanup**
   - Remove old artifact directories
   - Update any external references
   - Document migration in changelog

### Timeline

- **Phase 2** (Weeks 2-4): Migrate existing artifacts
- **Phase 3** (Weeks 5-12): Enforce standards with automated gates
- **Phase 4** (by 2026-03-31): Sunset old artifact locations

---

## Best Practices

### 1. Modularization

- Break large Bicep files into focused components (database, networking, security)
- Extract common patterns into reusable modules
- Reference modules from main IaC files

**Example**:
```bicep
// iac/payment-service-main.bicep
module database './modules/sql-database/main.bicep' = { ... }
module appService './modules/app-service/main.bicep' = { ... }
```

### 2. Documentation

- Keep docs updated with code changes
- Include architecture diagrams (Mermaid or ASCII art)
- Document deployment procedures step-by-step
- Maintain operational runbooks

### 3. Scripts

- Use descriptive names matching their purpose
- Include comment headers with usage
- Implement error handling
- Make scripts idempotent (safe to run multiple times)

**Example**:
```powershell
# scripts/payment-service-deploy.ps1
<#
.SYNOPSIS
    Deploys payment-service infrastructure

.DESCRIPTION
    Deploys Bicep templates for payment-service to Azure

.PARAMETER Environment
    Target environment: dev, staging, prod

.EXAMPLE
    ./payment-service-deploy.ps1 -Environment "dev"
#>

param([string]$Environment = "dev")

# Validate input
if ("dev", "staging", "prod" -notcontains $Environment) {
    Write-Error "Invalid environment: $Environment"
    exit 1
}

# Deploy
Write-Host "Deploying payment-service to $Environment..."
# ... deployment logic ...
```

### 4. Pipelines

- Trigger on relevant events (push to main, pull request)
- Include validation before deployment
- Support manual approval for production
- Parameterize for multiple environments

### 5. Version Control

- Commit all artifacts to Git
- Use semantic versioning for releases
- Tag major milestones
- Document breaking changes

---

## FAQ

**Q: Can I keep old artifacts in their original locations?**  
A: No. Phase 3 will enforce this structure with quality gates that block deployments using old locations. Migration must complete by Phase 3 start date (2026-02-12).

**Q: Do modules have to be in the `modules/` directory?**  
A: Yes. All reusable modules must be in the standard location for discoverability and consistency.

**Q: Can I create subdirectories under `iac/`, `modules/`, etc.?**  
A: For `modules/`, yes (one subdirectory per module). For `iac/`, `scripts/`, `docs/`, keep them flat unless strongly justified. Contact the Platform team for approval.

**Q: What if my application spans multiple technologies (not just Azure)?**  
A: The structure still applies. Use subdirectories in `iac/` for different IaC tools:
```
iac/
├── bicep/        (for Azure/Bicep)
├── terraform/    (for multi-cloud)
└── cloudformation/ (for AWS)
```

**Q: Do I need to update all existing applications immediately?**  
A: No. Phase 2 (Weeks 2-4) is designated for migration. Phase 3 (Weeks 5-12) will enforce compliance.

---

## Support & Escalation

### Getting Help

- **Quick Questions**: Check [FAQ](#faq) section above
- **Technical Issues**: Slack #platform-engineering
- **Documentation**: [specs/platform/001-application-artifact-organization](../../../specs/platform/001-application-artifact-organization/spec.md)
- **Script Issues**: Run validation with `-Verbose` flag: `validate-artifact-structure.ps1 -AppName "my-app" -Verbose`

### Escalation Path

1. Check this guide and FAQ
2. Ask in #platform-engineering Slack
3. Create issue in GitHub repository
4. Contact Platform team lead

### Feedback & Improvements

Have suggestions for improving the artifact organization standard?
- Create discussion in GitHub
- Propose amendment to Constitution v1.1.0
- Follow spec change process per specs/GOVERNANCE.md

---

**Last Updated**: 2026-02-05  
**Next Review**: 2026-05-05 (Quarterly)  
**Maintained By**: Platform Engineering Team
