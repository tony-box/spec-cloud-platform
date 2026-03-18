#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Validates toolkit components against the execution-mode policy.

.DESCRIPTION
    CI gate script that enforces the execution-mode-policy defined in specs/specs.yaml.

    Execution mode is inferred from file type (no per-file declarations needed):
      .ps1 under .specify/scripts/  → script-enforced
      .md  under .specify/templates/ → spec-interpreted

    Checks:
    1. Scripts (.ps1) meet the script-enforced interface standard (-Json, -Help).
    2. Every script and template on disk is registered in the specs.yaml toolkit matrix.
    3. Every entry in the specs.yaml toolkit matrix has a corresponding file on disk.

    Exits 0 on pass, 1 on failure.

.PARAMETER Json
    Output results in JSON format.

.PARAMETER Help
    Show usage information and exit.

.EXAMPLE
    ./validate-execution-modes.ps1
    ./validate-execution-modes.ps1 -Json
#>
[CmdletBinding()]
param(
    [switch]$Json,
    [switch]$Help
)
$ErrorActionPreference = 'Stop'

if ($Help) {
    Write-Host "Usage: ./validate-execution-modes.ps1 [-Json] [-Help]"
    Write-Host ""
    Write-Host "Validates that scripts meet the interface standard and all"
    Write-Host "toolkit components are registered in the specs.yaml matrix."
    exit 0
}

# --- Locate repo ---
. (Join-Path $PSScriptRoot "common.ps1")
$repoRoot = Get-RepoRoot
$scriptsDir = Join-Path $repoRoot ".specify" "scripts" "powershell"
$templatesDir = Join-Path $repoRoot ".specify" "templates"
$specsYamlPath = Join-Path $repoRoot "specs" "specs.yaml"

$errors = @()
$warnings = @()
$checked = @{ scripts = 0; templates = 0 }

# --- Check scripts meet interface standard ---
$scriptFiles = Get-ChildItem -Path $scriptsDir -Filter "*.ps1" -ErrorAction SilentlyContinue
foreach ($script in $scriptFiles) {
    $checked.scripts++
    $content = Get-Content -Path $script.FullName -Raw

    # Library scripts (like common.ps1) don't need -Json/-Help
    $hasParamBlock = $content -match '\[CmdletBinding\(\)\]|param\s*\('
    if ($hasParamBlock) {
        if ($content -notmatch '\[switch\]\s*\$Json') {
            $warnings += "[$($script.Name)] Missing -Json switch parameter"
        }
        if ($content -notmatch '\[switch\]\s*\$Help') {
            $warnings += "[$($script.Name)] Missing -Help switch parameter"
        }
    }
}

# --- Count templates ---
$templateFiles = Get-ChildItem -Path $templatesDir -Filter "*.md" -ErrorAction SilentlyContinue
foreach ($template in $templateFiles) {
    $checked.templates++
}

# --- Cross-check against specs.yaml toolkit matrix ---
if (Test-Path $specsYamlPath) {
    $specsContent = Get-Content -Path $specsYamlPath -Raw

    # Extract registered script names from the matrix
    $registeredScripts = [regex]::Matches($specsContent, '(?<=toolkit-components:[\s\S]*?scripts:[\s\S]*?)(\S+\.ps1):') |
        ForEach-Object { $_.Groups[1].Value }

    # Extract registered template names from the matrix
    $registeredTemplates = [regex]::Matches($specsContent, '(?<=templates:[\s\S]*?)(\S+\.md):') |
        ForEach-Object { $_.Groups[1].Value }

    # Check: every file on disk is registered
    foreach ($script in $scriptFiles) {
        if ($script.Name -notin $registeredScripts) {
            $errors += "[$($script.Name)] Script exists on disk but is not registered in specs.yaml toolkit-components.scripts"
        }
    }
    foreach ($template in $templateFiles) {
        if ($template.Name -notin $registeredTemplates) {
            $errors += "[$($template.Name)] Template exists on disk but is not registered in specs.yaml toolkit-components.templates"
        }
    }

    # Check: every matrix entry has a file on disk
    $diskScriptNames = $scriptFiles | ForEach-Object { $_.Name }
    $diskTemplateNames = $templateFiles | ForEach-Object { $_.Name }

    foreach ($name in $registeredScripts) {
        if ($name -notin $diskScriptNames) {
            $errors += "[specs.yaml] Registers script '$name' but file not found at .specify/scripts/powershell/$name"
        }
    }
    foreach ($name in $registeredTemplates) {
        if ($name -notin $diskTemplateNames) {
            $errors += "[specs.yaml] Registers template '$name' but file not found at .specify/templates/$name"
        }
    }
}

# --- Report ---
$isValid = $errors.Count -eq 0

if ($Json) {
    [ordered]@{
        status    = if ($isValid) { "valid" } else { "invalid" }
        scripts   = $checked.scripts
        templates = $checked.templates
        errors    = $errors
        warnings  = $warnings
    } | ConvertTo-Json -Depth 3
} else {
    if ($isValid) {
        Write-Host "[validate-execution-modes] All $($checked.scripts) scripts and $($checked.templates) templates are valid and registered." -ForegroundColor Green
    } else {
        Write-Host "[validate-execution-modes] Validation FAILED." -ForegroundColor Red
        foreach ($e in $errors) { Write-Host "  ERROR: $e" -ForegroundColor Red }
    }
    if ($warnings.Count -gt 0) {
        foreach ($w in $warnings) { Write-Host "  WARN: $w" -ForegroundColor Yellow }
    }
}

if (-not $isValid) { exit 1 }
exit 0
