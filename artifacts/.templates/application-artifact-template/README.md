# Application Artifact Organization Template

**Purpose**: Template directory structure for new applications  
**Template Version**: v1.0.0  
**Based On**: `/specs/platform/001-application-artifact-organization/spec.md`  
**Created**: 2026-02-05  

---

## Directory Structure

This template defines the standard structure for all application artifacts:

```
/artifacts/applications/<appname>/
├── iac/                      # Infrastructure-as-Code (Bicep, ARM templates, Terraform)
├── modules/                  # Reusable IaC modules
├── scripts/                  # Deployment, validation, operations scripts
├── pipelines/                # GitHub Actions workflows and CI/CD configurations
├── docs/                     # Documentation, runbooks, architecture diagrams
└── README.md                 # Application overview and links to spec
```

---

## How to Use This Template

### For Application Teams

1. **Copy this template** to create a new application directory:
   ```bash
   cp -r /artifacts/.templates/application-artifact-template /artifacts/applications/my-app-name
   ```

2. **Or use the automated script**:
   ```powershell
   ./create-app-directory.ps1 -AppName "my-app-name"
   ```

3. **Organize artifacts** in appropriate subdirectories:
   - Bicep/ARM templates → `iac/`
   - Reusable modules → `modules/`
   - Scripts → `scripts/`
   - GitHub Actions workflows → `pipelines/`
   - Documentation → `docs/`

4. **Create application README.md** linking to your spec:
   ```markdown
   # Application: my-app-name
   
   **Source Spec**: /specs/application/my-app-name/spec.md
   **Parent Specs**: /specs/infrastructure/..., /specs/security/..., /specs/business/...
   
   [Your application description]
   ```

5. **Run validation**:
   ```powershell
   ./validate-artifact-structure.ps1 -AppName "my-app-name"
   ```

---

## Subdirectory Guidelines

### iac/
**Contains**: Bicep templates, ARM templates, Terraform code, parameter files  
**Naming**: `<appname>-<component>.bicep` (e.g., `payment-service-function-app.bicep`)  
**Example Files**:
- `main.bicep` - Root template
- `payment-service-function-app.bicep` - Function App component
- `payment-service-storage.bicep` - Storage component
- `parameters.json` - Parameter file

### modules/
**Contains**: Reusable IaC modules shared across components  
**Naming**: `<modulename>.bicep` (e.g., `app-insights-monitoring.bicep`)  
**Example Files**:
- `app-insights-monitoring.bicep` - Reusable monitoring setup
- `storage-config.bicep` - Reusable storage configuration

### scripts/
**Contains**: PowerShell, Python, Bash scripts for deployment, validation, operations  
**Naming**: `<appname>-<purpose>.ps1` (e.g., `payment-service-validate-deployment.ps1`)  
**Example Files**:
- `payment-service-deploy.ps1` - Deployment script
- `payment-service-validate.ps1` - Validation script
- `payment-service-rollback.ps1` - Rollback script

### pipelines/
**Contains**: GitHub Actions workflows, pipeline templates, deployment configurations  
**Naming**: `<purpose>.yml` (e.g., `deploy-infrastructure.yml`)  
**Example Files**:
- `deploy-infrastructure.yml` - Main deployment workflow
- `validate-policy.yml` - Policy validation workflow
- `rollback.yml` - Rollback workflow

### docs/
**Contains**: README.md, architecture diagrams, runbooks, configuration guides  
**Naming**: Clear, descriptive titles  
**Example Files**:
- `README.md` - Application overview (REQUIRED)
- `ARCHITECTURE.md` - Application architecture diagram
- `RUNBOOK.md` - Operations runbook
- `DEPLOYMENT.md` - Deployment guide

---

## Naming Conventions

Follow these conventions to maintain consistency:

### Bicep Files
- Format: `<appname>-<component>.bicep`
- Examples:
  - `payment-service-function-app.bicep`
  - `payment-service-database.bicep`
  - `web-app-001-load-balancer.bicep`

### Scripts
- Format: `<appname>-<purpose>.<ext>`
- Examples:
  - `payment-service-deploy.ps1`
  - `payment-service-validate.py`
  - `web-app-001-rollback.sh`

### Pipelines
- Format: `<purpose>.yml`
- Examples:
  - `deploy-infrastructure.yml`
  - `validate-policy.yml`
  - `run-tests.yml`

---

## Validation

All artifact directories must pass validation. Run:

```powershell
./validate-artifact-structure.ps1 -AppName "my-app-name"
```

Validation checks:
- ✓ Directory structure exists
- ✓ All 5 subdirectories present (or documented as optional)
- ✓ README.md files in each directory
- ✓ Naming conventions followed
- ✓ Required files (.gitignore, etc.) in place

---

## Getting Started

1. **New Application?**
   ```powershell
   ./create-app-directory.ps1 -AppName "my-new-app"
   cd /artifacts/applications/my-new-app
   cat README.md  # See template
   ```

2. **Add IaC**:
   ```powershell
   cp my-main.bicep ./iac/my-new-app-main.bicep
   ```

3. **Add Scripts**:
   ```powershell
   cp deploy.ps1 ./scripts/my-new-app-deploy.ps1
   ```

4. **Validate**:
   ```powershell
   ../../.templates/scripts/validate-artifact-structure.ps1 -AppName "my-new-app"
   ```

---

## Questions?

See:
- **ARTIFACT_ORGANIZATION_GUIDE.md** - Comprehensive guide
- **README.md** files in each subdirectory - Specific guidance
- `/specs/platform/001-application-artifact-organization/spec.md` - Official specification

---

**Template Version**: v1.0.0  
**Created**: 2026-02-05  
**Spec**: `/specs/platform/001-application-artifact-organization/spec.md`