#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Writes a spec.md file with validated frontmatter and body content.

.DESCRIPTION
    Deterministic script that:
      1. Validates parameters (-Tier, -Category, -SpecId, -FrontmatterJson, -BodyMarkdown)
      2. Validates all required frontmatter fields are present in the JSON input
      3. Enforces mandatory values: status=draft, compliance-state=current,
         requested-by="transcripttospecs", decision-mode=autonomous
      4. Injects a conflict-flags block into frontmatter and body if the input
         JSON contains a non-empty conflict-flags array
      5. Resolves the output path to specs/<tier>/<category>/spec.md, creating
         the directory if needed
      6. Skips (exit 2) if the file already exists and -Force is not set
      7. Writes the final spec.md and validates the written file is non-empty

    Exit codes:
      0 — success (file written)
      1 — validation or I/O failure
      2 — file already exists and -Force was not set (skip, not error)

    This script is idempotent when -Force is not set: repeated calls on an
    existing file always exit 2 without modifying the file.

    Part of the transcripttospecs platform toolkit.

.PARAMETER Tier
    Target tier. Must be one of: platform, business, security, infrastructure, devops, application.

.PARAMETER Category
    Category directory name (e.g. 'cost', 'access-control', 'transcript-ingestion').

.PARAMETER SpecId
    Spec identifier (e.g. 'txin'). Used for validation and conflict-flag injection.

.PARAMETER FrontmatterJson
    JSON string containing all spec frontmatter fields. Required fields:
    tier, category, spec-id, version, status, compliance-state, role-context.

.PARAMETER BodyMarkdown
    Full markdown body for the spec (everything after the closing --- of frontmatter).
    When -Force is used for an existing spec update, this should be the complete
    merged body (original content + new additions) — the script replaces the file
    wholesale and does NOT perform any merge itself.

.PARAMETER Force
    Overwrite an existing spec.md. Required for updating existing specs.

.PARAMETER Json
    Output result in JSON format for machine consumption.

.PARAMETER Help
    Show usage information and exit.

.EXAMPLE
    ./write-spec.ps1 -Tier business -Category cost -SpecId cost -FrontmatterJson $json -BodyMarkdown $body

.EXAMPLE
    ./write-spec.ps1 -Tier devops -Category ci-cd-orchestration -SpecId cicd-orch -FrontmatterJson $json -BodyMarkdown $body -Force -Json
#>
[CmdletBinding()]
param(
    [string]$Tier,
    [string]$Category,
    [string]$SpecId,
    [string]$FrontmatterJson,
    [string]$BodyMarkdown,
    [switch]$Force,
    [switch]$Json,
    [switch]$Help
)
$ErrorActionPreference = 'Stop'

# --- Help ---
if ($Help) {
    Write-Host "Usage: ./write-spec.ps1 -Tier <tier> -Category <cat> -SpecId <id> -FrontmatterJson <json> -BodyMarkdown <body> [-Force] [-Json] [-Help]"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  -Tier             One of: platform, business, security, infrastructure, devops, application"
    Write-Host "  -Category         Category directory name (e.g. cost, access-control)"
    Write-Host "  -SpecId           Spec identifier (e.g. txin)"
    Write-Host "  -FrontmatterJson  JSON with all required frontmatter fields"
    Write-Host "  -BodyMarkdown     Full spec body (complete merged content when updating)"
    Write-Host "  -Force            Overwrite existing spec.md"
    Write-Host "  -Json             Machine-readable JSON output"
    Write-Host "  -Help             Show this help"
    Write-Host ""
    Write-Host "Exit codes:  0=written  1=error  2=skipped (file exists, no -Force)"
    exit 0
}

# --- Source shared helpers ---
. (Join-Path $PSScriptRoot "common.ps1")
$repoRoot = Get-RepoRoot

# --- Required parameter check ---
if (-not $Tier -or -not $Category -or -not $SpecId -or -not $FrontmatterJson -or -not $BodyMarkdown) {
    $msg = "Missing required parameters. Use -Help for usage."
    if ($Json) {
        [ordered]@{ status = "error"; message = $msg } | ConvertTo-Json -Compress
    } else {
        Write-Error $msg
    }
    exit 1
}

# --- Tier validation ---
if ($Tier -notin $script:SpecTiers) {
    $msg = "Invalid -Tier '$Tier'. Must be one of: $($script:SpecTiers -join ', ')"
    if ($Json) {
        [ordered]@{ status = "error"; message = $msg } | ConvertTo-Json -Compress
    } else {
        Write-Error $msg
    }
    exit 1
}

# --- Parse and validate FrontmatterJson ---
$fm = $null
try {
    $fm = $FrontmatterJson | ConvertFrom-Json
} catch {
    $msg = "Could not parse -FrontmatterJson: $_"
    if ($Json) {
        [ordered]@{ status = "error"; message = $msg } | ConvertTo-Json -Compress
    } else {
        Write-Error $msg
    }
    exit 1
}

# Validate required frontmatter fields
$requiredFields = @('tier', 'category', 'spec-id', 'version', 'status', 'compliance-state', 'role-context')
$missing = @()
foreach ($field in $requiredFields) {
    if ($null -eq $fm.$field -and $null -eq $fm.PSObject.Properties[$field]) {
        $missing += $field
    }
}
if ($missing.Count -gt 0) {
    $msg = "FrontmatterJson is missing required fields: $($missing -join ', ')"
    if ($Json) {
        [ordered]@{ status = "error"; message = $msg; missingFields = $missing } | ConvertTo-Json -Compress
    } else {
        Write-Error $msg
    }
    exit 1
}

# --- Resolve output path and path-traversal check ---
$targetDir  = Join-Path $repoRoot "specs" $Tier $Category
$targetPath = Join-Path $targetDir "spec.md"

# Ensure resolved path stays within repo root (prevent path traversal)
$resolvedTarget = [System.IO.Path]::GetFullPath($targetPath)
$resolvedRoot   = [System.IO.Path]::GetFullPath($repoRoot)
if (-not $resolvedTarget.StartsWith($resolvedRoot + [System.IO.Path]::DirectorySeparatorChar) -and
    $resolvedTarget -ne $resolvedRoot) {
    $msg = "Resolved output path '$resolvedTarget' is outside repo root. Path traversal is not permitted."
    if ($Json) {
        [ordered]@{ status = "error"; message = $msg } | ConvertTo-Json -Compress
    } else {
        Write-Error $msg
    }
    exit 1
}

# --- Skip if exists and no -Force ---
if ((Test-Path $targetPath -PathType Leaf) -and -not $Force) {
    $msg = "spec.md already exists at '$targetPath'. Use -Force to overwrite."
    if ($Json) {
        [ordered]@{ status = "skipped"; path = $targetPath; message = $msg } | ConvertTo-Json -Compress
    } else {
        Write-Host "[specify] Skipped: $msg" -ForegroundColor Yellow
    }
    exit 2
}

# --- Enforce mandatory frontmatter values ---
$today = (Get-Date).ToString("yyyy-MM-dd")

# Build YAML frontmatter string from validated object
# Enforce fixed fields regardless of input values
function ConvertTo-YamlValue {
    param([object]$Value, [int]$Indent = 0)
    $pad = ' ' * $Indent
    if ($null -eq $Value) { return 'null' }
    if ($Value -is [bool]) { return $Value.ToString().ToLower() }
    if ($Value -is [int] -or $Value -is [double]) { return $Value.ToString() }
    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        $items = @($Value)
        if ($items.Count -eq 0) { return '[]' }
        $lines = @()
        foreach ($item in $items) {
            $lines += "${pad}- $item"
        }
        return ("`n" + ($lines -join "`n"))
    }
    # String — quote if contains special chars
    $str = $Value.ToString()
    if ($str -match '[:#\[\]{},&*?|>!''"%@`\\]' -or $str -match '^\s' -or $str -match '\s$') {
        return '"' + $str.Replace('"', '\"') + '"'
    }
    return $str
}

# Extract conflict-flags from input (may not be present)
$conflictFlags = $null
if ($fm.PSObject.Properties['conflict-flags']) {
    $conflictFlags = @($fm.'conflict-flags')
}

# Render core frontmatter fields
$fmLines = @('---')
$fmLines += "tier: $Tier"
$fmLines += "category: $Category"
$fmLines += "spec-id: $SpecId"
$fmLines += "version: `"$($fm.version)`""
$fmLines += "status: draft"
$fmLines += "compliance-state: current"
$fmLines += "created: `"$today`""

# description (optional)
if ($fm.PSObject.Properties['description'] -and $fm.description) {
    $desc = $fm.description.ToString().Replace('"', '\"')
    $fmLines += "description: `"$desc`""
}

# conflict-flags block (if present)
if ($conflictFlags -and $conflictFlags.Count -gt 0) {
    $fmLines += "conflict-flags:"
    foreach ($flag in $conflictFlags) {
        if ($flag -is [string]) {
            $fmLines += "  - `"$($flag.ToString().Replace('"','\"'))`""
        } else {
            # Object with upstream-spec-id and reason fields
            $fmLines += "  - upstream-spec-id: `"$($flag.'upstream-spec-id')`""
            $fmLines += "    reason: `"$($flag.reason)`""
        }
    }
}

# role-context block
$rc = $fm.'role-context'
$fmLines += 'role-context:'
$fmLines += "  declared-role: $($rc.'declared-role' ?? 'platform')"
$fmLines += "  authority-scope: $($rc.'authority-scope' ?? 'platform-meta-governance')"
$fmLines += "  requested-by: `"transcripttospecs`""
$fmLines += "  decision-mode: autonomous"
if ($rc.PSObject.Properties['cascade-run-id']) {
    $fmLines += "  cascade-run-id: null"
}
if ($rc.PSObject.Properties['approved-by']) {
    $fmLines += "  approved-by: null"
}

# depends-on (optional)
if ($fm.PSObject.Properties['depends-on'] -and $fm.'depends-on') {
    $fmLines += 'depends-on:'
    foreach ($dep in @($fm.'depends-on')) {
        $fmLines += "  - tier: $($dep.tier)"
        $fmLines += "    category: $($dep.category)"
        $fmLines += "    spec-id: $($dep.'spec-id')"
        if ($dep.PSObject.Properties['version']) {
            $fmLines += "    version: `"$($dep.version)`""
        }
        if ($dep.PSObject.Properties['reason']) {
            $fmLines += "    reason: `"$($dep.reason.ToString().Replace('"','\"'))`""
        }
    }
}

$fmLines += '---'
$frontmatterBlock = $fmLines -join "`n"

# --- Build conflict-flags section for body (if applicable) ---
$conflictSection = ""
if ($conflictFlags -and $conflictFlags.Count -gt 0) {
    $conflictSection = "`n## ⚠️ Conflict Flags`n`nThis spec was written with one or more unresolved conflicts with higher-authority tier specs. Review and resolve before promoting from draft status.`n"
    foreach ($flag in $conflictFlags) {
        if ($flag -is [string]) {
            $conflictSection += "`n- $flag"
        } else {
            $conflictSection += "`n- **Upstream spec**: $($flag.'upstream-spec-id')  `n  **Reason**: $($flag.reason)"
        }
    }
    $conflictSection += "`n"
}

# --- Assemble final file content ---
$finalContent = $frontmatterBlock + "`n" + $conflictSection + "`n" + $BodyMarkdown.TrimStart("`n")

# --- Create directory if needed ---
if (-not (Test-Path $targetDir -PathType Container)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

# --- Atomic write via temp + rename ---
$tempPath = "$targetPath.tmp"
Set-Content -Path $tempPath -Value $finalContent -NoNewline
Move-Item -Path $tempPath -Destination $targetPath -Force

# --- Validate written file is non-empty and starts with YAML frontmatter ---
$written = Get-Content -Path $targetPath -Raw
if (-not $written -or $written.Length -lt 5) {
    $msg = "Wrote file but validation failed: file is empty. Path: $targetPath"
    if ($Json) {
        [ordered]@{ status = "error"; message = $msg } | ConvertTo-Json -Compress
    } else {
        Write-Error $msg
    }
    exit 1
}
if (-not ($written.TrimStart().StartsWith('---'))) {
    $msg = "Wrote file but validation failed: file does not open with YAML frontmatter (---). Path: $targetPath"
    if ($Json) {
        [ordered]@{ status = "error"; message = $msg } | ConvertTo-Json -Compress
    } else {
        Write-Error $msg
    }
    exit 1
}

# --- Output ---
$action = if ($Force) { "updated" } else { "created" }
if ($Json) {
    [ordered]@{
        status   = $action
        tier     = $Tier
        category = $Category
        specId   = $SpecId
        path     = $targetPath
        hasConflictFlags = ($null -ne $conflictFlags -and $conflictFlags.Count -gt 0)
    } | ConvertTo-Json -Compress
} else {
    Write-Host "[specify] Spec ${action}: $targetPath" -ForegroundColor Green
    Write-Host "  Tier/Category: ${Tier}/${Category}  Spec-id: $SpecId" -ForegroundColor Gray
    if ($conflictFlags -and $conflictFlags.Count -gt 0) {
        Write-Host "  ⚠️  conflict-flags injected ($($conflictFlags.Count) flag(s))" -ForegroundColor Yellow
    }
}
