#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Validates the application registry against the canonical spec system.

.DESCRIPTION
    Deterministic CI-friendly validation script that checks:
    1. Every app entry in _index.yaml has all required fields.
    2. Every adheres-to spec-id resolves to an existing spec in specs.yaml.
    3. Every app's spec file exists on disk.
    4. Lifecycle status values are valid (draft, active, retired).
    5. Retired entries have retired-date and retired-reason.
    6. Application-count metadata is accurate.

    Exits with code 0 on success, 1 on validation failure.

.PARAMETER Json
    Output validation results in JSON format.

.PARAMETER Help
    Show usage information and exit.

.EXAMPLE
    ./validate-registry.ps1
    ./validate-registry.ps1 -Json
#>
[CmdletBinding()]
param(
    [switch]$Json,
    [switch]$Help
)
$ErrorActionPreference = 'Stop'

if ($Help) {
    Write-Host "Usage: ./validate-registry.ps1 [-Json] [-Help]"
    Write-Host ""
    Write-Host "Validates the application registry (specs/application/_index.yaml) for:"
    Write-Host "  - Required fields on every entry"
    Write-Host "  - Valid lifecycle status values"
    Write-Host "  - Retirement metadata completeness"
    Write-Host "  - adheres-to spec-id references resolve in specs.yaml"
    Write-Host "  - Spec files exist on disk"
    Write-Host "  - application-count accuracy"
    exit 0
}

# --- Locate repo and files ---
. (Join-Path $PSScriptRoot "common.ps1")
$repoRoot = Get-RepoRoot
$registryPath = Join-Path $repoRoot "specs" "application" "_index.yaml"
$specsYamlPath = Join-Path $repoRoot "specs" "specs.yaml"

$errors = @()
$warnings = @()

# --- Check files exist ---
if (-not (Test-Path $registryPath)) {
    $errors += "Registry file not found: $registryPath"
}
if (-not (Test-Path $specsYamlPath)) {
    $errors += "Root manifest not found: $specsYamlPath"
}

if ($errors.Count -gt 0) {
    if ($Json) {
        [ordered]@{ status = "error"; errors = $errors; warnings = $warnings } | ConvertTo-Json -Depth 3
    } else {
        foreach ($e in $errors) { Write-Host "ERROR: $e" -ForegroundColor Red }
    }
    exit 1
}

# --- Parse known spec-ids from specs.yaml ---
$specsContent = Get-Content -Path $specsYamlPath -Raw
$knownSpecIds = @()
$specIdMatches = [regex]::Matches($specsContent, 'spec-id:\s*(\S+)')
foreach ($m in $specIdMatches) {
    $knownSpecIds += $m.Groups[1].Value
}

# --- Parse registry ---
$registryContent = Get-Content -Path $registryPath -Raw
$registryLines = Get-Content -Path $registryPath

# Extract application-count from metadata
$countMatch = [regex]::Match($registryContent, 'application-count:\s*(\d+)')
$declaredCount = if ($countMatch.Success) { [int]$countMatch.Groups[1].Value } else { -1 }

# Check if registry is empty
if ($registryContent -match 'applications:\s*\[\]') {
    $actualCount = 0
    if ($declaredCount -ne $actualCount -and $declaredCount -ne -1) {
        $errors += "application-count mismatch: declared=$declaredCount, actual=$actualCount"
    }
    if ($Json) {
        [ordered]@{
            status   = if ($errors.Count -eq 0) { "valid" } else { "invalid" }
            apps     = 0
            errors   = $errors
            warnings = $warnings
        } | ConvertTo-Json -Depth 3
    } else {
        Write-Host "[validate-registry] Registry is empty. No entries to validate." -ForegroundColor Cyan
        if ($errors.Count -gt 0) {
            foreach ($e in $errors) { Write-Host "  ERROR: $e" -ForegroundColor Red }
        }
    }
    if ($errors.Count -gt 0) { exit 1 }
    exit 0
}

# --- Parse individual app entries ---
$validStatuses = @('draft', 'active', 'retired')
$requiredFields = @('app-id', 'app-name', 'version', 'status', 'created', 'tier', 'file', 'description')

# Simple line-based parser for YAML app entries
$apps = @()
$currentApp = $null
$inAdheresTo = $false

foreach ($line in $registryLines) {
    if ($line -match '^\s+-\s+app-id:\s*(.+)$') {
        if ($currentApp) { $apps += $currentApp }
        $currentApp = @{ 'app-id' = $Matches[1].Trim(); 'adheres-to' = @() }
        $inAdheresTo = $false
    }
    elseif ($currentApp -and $line -match '^\s+adheres-to:') {
        $inAdheresTo = $true
    }
    elseif ($currentApp -and $inAdheresTo -and $line -match '^\s+-\s+spec-id:\s*(.+)$') {
        $currentApp['adheres-to'] += $Matches[1].Trim()
    }
    elseif ($currentApp -and -not $inAdheresTo -and $line -match '^\s+(\S+):\s*"?([^"]*)"?\s*$') {
        $key = $Matches[1].Trim()
        $val = $Matches[2].Trim()
        if ($key -ne 'adheres-to') {
            $currentApp[$key] = $val
        }
    }
    elseif ($currentApp -and $line -match '^\s+-\s+app-id:') {
        # next entry — handled above
    }
}
if ($currentApp) { $apps += $currentApp }

$actualCount = $apps.Count

# --- Validate each app ---
foreach ($app in $apps) {
    $id = $app['app-id']

    # Required fields
    foreach ($field in $requiredFields) {
        if (-not $app.ContainsKey($field) -or [string]::IsNullOrWhiteSpace($app[$field])) {
            $errors += "[$id] Missing required field: $field"
        }
    }

    # Valid status
    $status = $app['status']
    if ($status -and $status -notin $validStatuses) {
        $errors += "[$id] Invalid status '$status'. Must be one of: $($validStatuses -join ', ')"
    }

    # Retired metadata
    if ($status -eq 'retired') {
        if (-not $app.ContainsKey('retired-date') -or [string]::IsNullOrWhiteSpace($app['retired-date'])) {
            $errors += "[$id] Retired app missing 'retired-date'"
        }
        if (-not $app.ContainsKey('retired-reason') -or [string]::IsNullOrWhiteSpace($app['retired-reason'])) {
            $errors += "[$id] Retired app missing 'retired-reason'"
        }
    }

    # Spec file exists on disk
    $specFile = $app['file']
    if ($specFile) {
        $fullPath = Join-Path $repoRoot "specs" "application" $specFile
        if (-not (Test-Path $fullPath)) {
            $warnings += "[$id] Spec file not found: specs/application/$specFile"
        }
    }

    # adheres-to references resolve
    foreach ($depId in $app['adheres-to']) {
        if ($depId -notin $knownSpecIds) {
            $errors += "[$id] adheres-to references unknown spec-id: $depId"
        }
    }
}

# --- application-count accuracy ---
if ($declaredCount -ne -1 -and $declaredCount -ne $actualCount) {
    $errors += "application-count mismatch: declared=$declaredCount, actual=$actualCount"
}

# --- Report ---
$isValid = $errors.Count -eq 0

if ($Json) {
    [ordered]@{
        status   = if ($isValid) { "valid" } else { "invalid" }
        apps     = $actualCount
        errors   = $errors
        warnings = $warnings
    } | ConvertTo-Json -Depth 3
} else {
    if ($isValid) {
        Write-Host "[validate-registry] Registry is valid. $actualCount app(s) checked." -ForegroundColor Green
    } else {
        Write-Host "[validate-registry] Registry validation FAILED." -ForegroundColor Red
        foreach ($e in $errors) { Write-Host "  ERROR: $e" -ForegroundColor Red }
    }
    if ($warnings.Count -gt 0) {
        foreach ($w in $warnings) { Write-Host "  WARN: $w" -ForegroundColor Yellow }
    }
}

if (-not $isValid) { exit 1 }
exit 0
