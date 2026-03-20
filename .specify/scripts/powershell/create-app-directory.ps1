<#
.SYNOPSIS
    Creates a new application artifact directory structure

.DESCRIPTION
    Creates /artifacts/applications/<appname>/ with all required subdirectories
    and README.md files. Application artifacts are organized by type (iac, modules,
    scripts, pipelines, docs) to support multi-application platform management.

.PARAMETER AppName
    Application name (required). Used for directory name and naming conventions.
    Format: lowercase, hyphen-separated (e.g., 'payment-service', 'web-app-001')

.PARAMETER Force
    If specified, overwrites existing directory (dangerous - use with caution)

.EXAMPLE
    # Create new application directory
    ./create-app-directory.ps1 -AppName "payment-service"

.EXAMPLE
    # Create with overwrite (dangerous)
    ./create-app-directory.ps1 -AppName "payment-service" -Force

.NOTES
    Per Constitution v1.1.0, all application artifacts MUST be organized in
    /artifacts/applications/<appname>/ structure.
    
    See /specs/platform/001-application-artifact-organization/spec.md

.LINK
    https://[platform-wiki]/artifact-organization
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$AppName,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force
)

# Configuration
$ArtifactsRoot = "artifacts"
$ApplicationsDir = Join-Path $ArtifactsRoot "applications"
$TemplateDir = Join-Path ".specify" "templates" "application-artifact-template"
$AppDir = Join-Path $ApplicationsDir $AppName

# Validation
Write-Host "🔍 Creating application artifact directory: $AppName" -ForegroundColor Cyan

# Check if app directory already exists
if (Test-Path $AppDir) {
    if (-not $Force) {
        Write-Host "❌ Directory already exists: $AppDir" -ForegroundColor Red
        Write-Host "   Use -Force to overwrite (dangerous!)" -ForegroundColor Yellow
        exit 1
    }
    else {
        Write-Host "⚠️  Overwriting existing directory (you specified -Force)" -ForegroundColor Yellow
        Remove-Item $AppDir -Recurse -Force
    }
}

# Create main application directory
New-Item -ItemType Directory -Path $AppDir | Out-Null
Write-Host "✓ Created: $AppDir" -ForegroundColor Green

# Create subdirectories
$SubDirs = @('iac', 'modules', 'scripts', 'pipelines', 'docs')
foreach ($dir in $SubDirs) {
    $SubDir = Join-Path $AppDir $dir
    New-Item -ItemType Directory -Path $SubDir | Out-Null
    Write-Host "✓ Created: $SubDir" -ForegroundColor Green
    
    # Copy README.md from template
    $TemplateReadme = Join-Path $TemplateDir $dir "README.md"
    if (Test-Path $TemplateReadme) {
        Copy-Item $TemplateReadme -Destination (Join-Path $SubDir "README.md")
        Write-Host "  ✓ Copied README.md" -ForegroundColor Gray
    }
}

# Create application root README.md
$AppReadmeContent = @"
# Application: $AppName

**Created**: $(Get-Date -Format 'yyyy-MM-dd')  
**Source Spec**: /specs/application/$AppName/spec.md  
**Parent Specs**: 
- /specs/business/.../ (specify parent business specs)
- /specs/security/.../ (specify parent security specs)
- /specs/infrastructure/.../ (specify parent infrastructure specs)

## Overview

[Brief description of the application]

## Directory Structure

- **iac/**: Infrastructure-as-Code templates (Bicep, ARM, Terraform)
- **modules/**: Reusable IaC modules
- **scripts/**: Deployment, validation, operations scripts
- **pipelines/**: GitHub Actions workflows
- **docs/**: Documentation, runbooks, architecture diagrams

## Key Components

[List key components and their purposes]

## How to Deploy

See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)

## Architecture

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

## Operations

See [docs/RUNBOOK.md](docs/RUNBOOK.md)

## Links

- **Specification**: [/specs/application/$AppName/spec.md](/specs/application/$AppName/spec.md)
- **Platform Guide**: [ARTIFACT_ORGANIZATION_GUIDE.md](/ARTIFACT_ORGANIZATION_GUIDE.md)

---

Created per Constitution v1.1.0 and `/specs/platform/001-application-artifact-organization/`
"@

$AppReadmeFile = Join-Path $AppDir "README.md"
$AppReadmeContent | Out-File -FilePath $AppReadmeFile -Encoding UTF8
Write-Host "✓ Created: $(Split-Path $AppReadmeFile -Leaf)" -ForegroundColor Green

# Copy .gitignore template
$GitignoreSrc = Join-Path $TemplateDir ".." "scripts" ".gitignore-template"
if (Test-Path $GitignoreSrc) {
    Copy-Item $GitignoreSrc -Destination (Join-Path $AppDir ".gitignore")
    Write-Host "✓ Created: .gitignore" -ForegroundColor Green
}

# Success summary
Write-Host ""
Write-Host "✅ Application artifact directory created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Edit README.md to describe your application"
Write-Host "  2. Add IaC templates to ./iac/"
Write-Host "  3. Add modules to ./modules/"
Write-Host "  4. Add scripts to ./scripts/"
Write-Host "  5. Add pipelines to ./pipelines/"
Write-Host "  6. Add documentation to ./docs/"
Write-Host "  7. Validate structure:"
Write-Host "     ./artifacts/.templates/scripts/validate-artifact-structure.ps1 -AppName '$AppName'"
Write-Host ""
Write-Host "Documentation:" -ForegroundColor Cyan
Write-Host "  • Template guide: artifacts/.templates/application-artifact-template/README.md"
Write-Host "  • Platform guide: ARTIFACT_ORGANIZATION_GUIDE.md"
Write-Host "  • Specification: specs/platform/001-application-artifact-organization/spec.md"
Write-Host ""
