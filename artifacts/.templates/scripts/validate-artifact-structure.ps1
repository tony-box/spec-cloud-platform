<#
.SYNOPSIS
    Validates application artifact directory structure

.DESCRIPTION
    Validates that an application's artifact directory conforms to the standard
    structure defined in /specs/platform/001-application-artifact-organization/
    
    Checks:
    - Directory structure (iac, modules, scripts, pipelines, docs)
    - README.md files in each directory
    - Naming conventions
    - Required files (.gitignore recommended)

.PARAMETER AppName
    Application name to validate (required)

.PARAMETER Path
    Path to application directory (optional, defaults to artifacts/applications/<appname>)

.PARAMETER Verbose
    Show detailed validation results

.EXAMPLE
    # Validate application
    ./validate-artifact-structure.ps1 -AppName "payment-service"

.EXAMPLE
    # Validate with detailed output
    ./validate-artifact-structure.ps1 -AppName "payment-service" -Verbose

.NOTES
    Per Constitution v1.1.0, artifact organization validation is a quality gate
    required before deployment.
    
    See /specs/platform/001-application-artifact-organization/spec.md
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$AppName,
    
    [Parameter(Mandatory=$false)]
    [string]$Path,
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose
)

# Configuration
$ArtifactsRoot = "artifacts"
$ApplicationsDir = Join-Path $ArtifactsRoot "applications"
if (-not $Path) {
    $Path = Join-Path $ApplicationsDir $AppName
}

# Initialize validation result
$validationResult = @{
    appName = $AppName
    path = $Path
    passed = $true
    errors = @()
    warnings = @()
    details = @{}
}

function Add-Error {
    param([string]$message)
    $validationResult.errors += $message
    $validationResult.passed = $false
    Write-Host "❌ $message" -ForegroundColor Red
}

function Add-Warning {
    param([string]$message)
    $validationResult.warnings += $message
    Write-Host "⚠️  $message" -ForegroundColor Yellow
}

function Add-Success {
    param([string]$message)
    Write-Host "✓ $message" -ForegroundColor Green
}

# Validate directory exists
Write-Host "🔍 Validating artifact structure for: $AppName" -ForegroundColor Cyan
if (-not (Test-Path $Path)) {
    Add-Error "Application directory not found: $Path"
    exit 1
}
Add-Success "Directory exists: $Path"

# Validate subdirectories
$requiredDirs = @('iac', 'modules', 'scripts', 'pipelines', 'docs')
foreach ($dir in $requiredDirs) {
    $fullPath = Join-Path $Path $dir
    if (-not (Test-Path $fullPath)) {
        Add-Error "Missing required subdirectory: $dir"
    } else {
        Add-Success "Found: $dir/"
        
        # Check for README.md in subdirectory
        $readmePath = Join-Path $fullPath "README.md"
        if (Test-Path $readmePath) {
            Add-Success "  → README.md present"
        } else {
            Add-Warning "  → Missing README.md (recommended)"
        }
    }
}

# Validate root files
$rootReadmePath = Join-Path $Path "README.md"
if (-not (Test-Path $rootReadmePath)) {
    Add-Error "Missing required file: README.md (application overview)"
} else {
    Add-Success "Application README.md found"
}

$gitignorePath = Join-Path $Path ".gitignore"
if (-not (Test-Path $gitignorePath)) {
    Add-Warning ".gitignore not found (recommended)"
} else {
    Add-Success ".gitignore found"
}

# Validate app name format
if ($AppName -match '^[a-z0-9][a-z0-9-]*[a-z0-9]$|^[a-z0-9]$') {
    Add-Success "App name format valid: $AppName"
} else {
    Add-Warning "App name should be lowercase, hyphen-separated (e.g., 'payment-service')"
}

# Check artifact files and naming conventions
if ($Verbose) {
    Write-Host ""
    Write-Host "📋 Detailed Inventory:" -ForegroundColor Cyan
    
    # List IaC files
    $iacPath = Join-Path $Path "iac"
    if (Test-Path $iacPath) {
        $bicepFiles = Get-ChildItem $iacPath -Filter "*.bicep" -ErrorAction SilentlyContinue
        if ($bicepFiles.Count -gt 0) {
            Write-Host "  IaC files:" -ForegroundColor Gray
            foreach ($file in $bicepFiles) {
                Write-Host "    - $($file.Name)" -ForegroundColor Gray
            }
        }
    }
    
    # List scripts
    $scriptsPath = Join-Path $Path "scripts"
    if (Test-Path $scriptsPath) {
        $scriptFiles = Get-ChildItem $scriptsPath -Include "*.ps1", "*.py", "*.sh" -ErrorAction SilentlyContinue
        if ($scriptFiles.Count -gt 0) {
            Write-Host "  Scripts:" -ForegroundColor Gray
            foreach ($file in $scriptFiles) {
                Write-Host "    - $($file.Name)" -ForegroundColor Gray
            }
        }
    }
    
    # List pipelines
    $pipelinesPath = Join-Path $Path "pipelines"
    if (Test-Path $pipelinesPath) {
        $workflowFiles = Get-ChildItem $pipelinesPath -Include "*.yml", "*.yaml" -ErrorAction SilentlyContinue
        if ($workflowFiles.Count -gt 0) {
            Write-Host "  Workflows:" -ForegroundColor Gray
            foreach ($file in $workflowFiles) {
                Write-Host "    - $($file.Name)" -ForegroundColor Gray
            }
        }
    }
}

# Final result
Write-Host ""
if ($validationResult.passed) {
    Write-Host "✅ VALIDATION PASSED" -ForegroundColor Green
    if ($validationResult.warnings.Count -gt 0) {
        Write-Host "  (with $($validationResult.warnings.Count) warning(s))" -ForegroundColor Yellow
    }
    exit 0
} else {
    Write-Host "❌ VALIDATION FAILED" -ForegroundColor Red
    Write-Host "  Fix the errors above and try again" -ForegroundColor Red
    exit 1
}
