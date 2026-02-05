<#
.SYNOPSIS
    Sets up artifact directories for a new application specification

.DESCRIPTION
    Automatically creates standardized application artifact directories and
    initializes the application specification structure. This script is called
    when a new Application-tier spec is created per Constitution §II.
    
    Enforces the artifact organization standard defined in:
    specs/platform/001-application-artifact-organization/spec.md

.PARAMETER AppName
    Application name (required) - used for directory creation and spec files
    Format: lowercase, hyphen-separated (e.g., 'payment-service')

.PARAMETER SpecTier
    Specification tier - determines where spec files are created
    Valid: 'application' (required for this script)

.PARAMETER Verbose
    Show detailed output during setup

.EXAMPLE
    # Setup new application (when NEW application spec is created)
    ./setup-application-artifacts.ps1 -AppName "payment-service" -SpecTier "application"

.NOTES
    Per Constitution v1.1.0, all application-tier specifications MUST conform to
    the standardized artifact organization. This script enforces that requirement
    by automatically creating the required directory structure and validation gates.
    
    Part of spec-driven development governance framework.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$AppName,
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("application")]
    [string]$SpecTier = "application",
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose
)

# Configuration
$RepoRoot = Split-Path -Parent (git rev-parse --show-toplevel 2>$null) -ErrorAction SilentlyContinue
if (-not $RepoRoot) {
    $RepoRoot = (Get-Location).Path
}

$ArtifactsRoot = Join-Path $RepoRoot "artifacts"
$ApplicationsDir = Join-Path $ArtifactsRoot "applications"
$SpecsRoot = Join-Path $RepoRoot "specs"
$AppSpecsDir = Join-Path $SpecsRoot "application"
$TemplatesRoot = Join-Path $ArtifactsRoot ".templates"
$TemplateScript = Join-Path $TemplatesRoot "scripts" "create-app-directory.ps1"
$ValidationScript = Join-Path $TemplatesRoot "scripts" "validate-artifact-structure.ps1"

# Determine if application already exists
$AppArtifactDir = Join-Path $ApplicationsDir $AppName
$AppSpecDir = Join-Path $AppSpecsDir $AppName
$AppExists = (Test-Path $AppArtifactDir) -or (Test-Path $AppSpecDir)
$AppMode = if ($AppExists) { "EXISTING" } else { "NEW" }

# Validate prerequisites
function Test-Prerequisites {
    Write-Host "🔍 Verifying prerequisites..." -ForegroundColor Cyan
    
    # Check that templates exist
    if (-not (Test-Path $TemplateScript)) {
        Write-Host "❌ ERROR: create-app-directory.ps1 not found at $TemplateScript" -ForegroundColor Red
        Write-Host "   Ensure Phase 1 of artifact organization is complete" -ForegroundColor Red
        return $false
    }
    
    if (-not (Test-Path $ValidationScript)) {
        Write-Host "❌ ERROR: validate-artifact-structure.ps1 not found at $ValidationScript" -ForegroundColor Red
        return $false
    }
    
    Write-Host "✓ All prerequisites satisfied" -ForegroundColor Green
    return $true
}

# Main execution
function Initialize-ApplicationArtifacts {
    Write-Host ""
    Write-Host "📦 Setting up Application Artifacts" -ForegroundColor Cyan
    Write-Host "   App Name: $AppName" -ForegroundColor Gray
    Write-Host "   Tier: $SpecTier" -ForegroundColor Gray
    Write-Host "   Mode: $AppMode" -ForegroundColor Gray
    Write-Host ""
    
    # Test prerequisites
    if (-not (Test-Prerequisites)) {
        exit 1
    }
    
    Write-Host ""
    
    # Check if application already exists
    if ($AppMode -eq "EXISTING") {
        Write-Host "⚠️  Application already exists" -ForegroundColor Yellow
        Write-Host "   Artifact Location: $AppArtifactDir" -ForegroundColor Gray
        if (Test-Path $AppSpecDir) {
            Write-Host "   Spec Location: $AppSpecDir" -ForegroundColor Gray
        }
        Write-Host ""
        Write-Host "Mode: EXISTING APPLICATION" -ForegroundColor Yellow
        Write-Host "Action: Reusing existing directories, validating structure" -ForegroundColor Yellow
        Write-Host ""
        
        # For existing apps, validate and update if needed
        Validate-ExistingApplication
    } else {
        Write-Host "Mode: NEW APPLICATION" -ForegroundColor Cyan
        Write-Host "Action: Creating new standardized directory structure" -ForegroundColor Cyan
        Write-Host ""
        
        # For new apps, create full structure
        Create-NewApplication
    }
}

# Handle NEW application setup
function Create-NewApplication {
    # Step 1: Create application directory structure
    Write-Host "📂 Creating new application directory structure..." -ForegroundColor Cyan
    & $TemplateScript -AppName $AppName -Force -Verbose:$Verbose
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to create application directory structure" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
    
    # Step 2: Validate the created structure
    Write-Host "✔️  Validating artifact structure..." -ForegroundColor Cyan
    & $ValidationScript -AppName $AppName -Verbose:$Verbose
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Artifact validation failed" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
    
    # Step 3: Create application spec directory
    Write-Host "📋 Creating application specification directory..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $AppSpecDir -Force | Out-Null
    
    # Create a note file linking to artifact organization guide
    $noteFile = Join-Path $AppSpecDir "ARTIFACT_ORGANIZATION_NOTE.md"
    @"
# Application Artifact Organization

This NEW application's artifacts are organized per the standardized structure:

**Location**: \`/artifacts/applications/$AppName/\`

**Required Structure**:
\`\`\`
/artifacts/applications/$AppName/
├── iac/              ← Infrastructure-as-Code (Bicep files)
├── modules/          ← Reusable IaC modules
├── scripts/          ← Deployment and operations scripts
├── pipelines/        ← CI/CD workflows (GitHub Actions)
└── docs/             ← Documentation
\`\`\`

**See Also**:
- Full Guide: [\`ARTIFACT_ORGANIZATION_GUIDE.md\`](../../../ARTIFACT_ORGANIZATION_GUIDE.md)
- Platform Spec: [\`specs/platform/001-application-artifact-organization/spec.md\`](../../../specs/platform/001-application-artifact-organization/spec.md)

**Validation**:
Run before deployment:
\`\`\`powershell
./artifacts/.templates/scripts/validate-artifact-structure.ps1 -AppName "$AppName"
\`\`\`

Per Constitution v1.1.0, all application artifacts MUST conform to this standardized structure.
"@ | Set-Content $noteFile -Encoding UTF8
    
    Write-Host "✓ Application spec directory created: $AppSpecDir" -ForegroundColor Green
    
    Write-Host ""
    
    # Step 4: Print next steps
    Write-Host "✅ NEW Application Setup Complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Navigate to: $AppSpecDir" -ForegroundColor Gray
    Write-Host "  2. Create specification files:" -ForegroundColor Gray
    Write-Host "     - spec.md (application specification)" -ForegroundColor Gray
    Write-Host "     - plan.md (implementation plan)" -ForegroundColor Gray
    Write-Host "     - tasks.md (task breakdown)" -ForegroundColor Gray
    Write-Host "  3. Create application artifacts in:" -ForegroundColor Gray
    Write-Host "     $(Join-Path $ApplicationsDir $AppName)" -ForegroundColor Gray
    Write-Host "  4. Reference artifact location in your spec:" -ForegroundColor Gray
    Write-Host "     /artifacts/applications/$AppName/" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Artifact Organization Guide:" -ForegroundColor Cyan
    Write-Host "  $ArtifactsRoot/ARTIFACT_ORGANIZATION_GUIDE.md" -ForegroundColor Gray
    Write-Host ""
}

# Handle EXISTING application setup
function Validate-ExistingApplication {
    # Step 1: Verify artifact directory exists
    if (-not (Test-Path $AppArtifactDir)) {
        Write-Host "⚠️  Artifact directory does not exist, creating..." -ForegroundColor Yellow
        & $TemplateScript -AppName $AppName -Force -Verbose:$Verbose
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Failed to create artifact directory" -ForegroundColor Red
            exit 1
        }
    }
    
    Write-Host ""
    
    # Step 2: Validate existing structure
    Write-Host "✔️  Validating existing artifact structure..." -ForegroundColor Cyan
    & $ValidationScript -AppName $AppName -Verbose:$Verbose
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️  Validation issues found (see above)" -ForegroundColor Yellow
        Write-Host "   Ensure all required directories and files exist" -ForegroundColor Gray
    } else {
        Write-Host "✓ Artifact structure valid" -ForegroundColor Green
    }
    
    Write-Host ""
    
    # Step 3: Ensure spec directory exists
    if (-not (Test-Path $AppSpecDir)) {
        Write-Host "📋 Creating application specification directory..." -ForegroundColor Cyan
        New-Item -ItemType Directory -Path $AppSpecDir -Force | Out-Null
        Write-Host "✓ Specification directory created: $AppSpecDir" -ForegroundColor Green
    } else {
        Write-Host "✓ Specification directory exists: $AppSpecDir" -ForegroundColor Green
    }
    
    Write-Host ""
    
    # Step 4: Print next steps
    Write-Host "✅ EXISTING Application Validated!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Status:" -ForegroundColor Cyan
    Write-Host "  ✓ Artifact directory: $AppArtifactDir" -ForegroundColor Gray
    Write-Host "  ✓ Specification directory: $AppSpecDir" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Ensure all artifacts are within:" -ForegroundColor Gray
    Write-Host "     $AppArtifactDir/" -ForegroundColor Gray
    Write-Host "  2. Update specifications if needed in:" -ForegroundColor Gray
    Write-Host "     $AppSpecDir/" -ForegroundColor Gray
    Write-Host "  3. Run validation before deployment:" -ForegroundColor Gray
    Write-Host "     ./validate-artifact-structure.ps1 -AppName '$AppName'" -ForegroundColor Gray
    Write-Host ""
}

# Execute setup
Initialize-ApplicationArtifacts
