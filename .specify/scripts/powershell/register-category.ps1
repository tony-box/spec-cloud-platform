#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Registers a new category in a tier _categories.yaml and updates specs/specs.yaml.

.DESCRIPTION
    Deterministic script that:
      1. Validates parameters (-Tier, -CategoryName, -SpecId, -Description)
      2. Checks global spec-id uniqueness across all tier _categories.yaml catalogs
      3. Upserts a new category entry in specs/<tier>/_categories.yaml
         (creates bootstrap skeleton if the file does not exist)
      4. Increments the tier's category-count in specs.yaml

    This script is idempotent — if the spec-id is already registered in the target
    tier, it exits 0 without modifying any file.

    Part of the transcript-to-specs platform toolkit.

.PARAMETER Tier
    Target tier. Must be one of: platform, business, security, infrastructure, devops, application.

.PARAMETER CategoryName
    kebab-case category directory name (e.g. 'disaster-recovery').

.PARAMETER SpecId
    Globally unique spec identifier matching ^[a-z][a-z0-9-]{1,7}$ (2-8 chars, starts with letter).

.PARAMETER Description
    One-line description of the category (shown in the catalog listing).

.PARAMETER Json
    Output result in JSON format for machine consumption.

.PARAMETER Help
    Show usage information and exit.

.EXAMPLE
    ./register-category.ps1 -Tier business -CategoryName disaster-recovery -SpecId dr -Description "Disaster recovery RTO/RPO requirements"

.EXAMPLE
    ./register-category.ps1 -Tier platform -CategoryName transcript-ingestion -SpecId txin -Description "AI-assisted transcript ingestion for spec generation" -Json
#>
[CmdletBinding()]
param(
    [string]$Tier,
    [string]$CategoryName,
    [string]$SpecId,
    [string]$Description,
    [switch]$Json,
    [switch]$Help
)
$ErrorActionPreference = 'Stop'

# --- Help ---
if ($Help) {
    Write-Host "Usage: ./register-category.ps1 -Tier <tier> -CategoryName <name> -SpecId <id> -Description <desc> [-Json] [-Help]"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  -Tier          One of: platform, business, security, infrastructure, devops, application"
    Write-Host "  -CategoryName  kebab-case directory name (e.g. disaster-recovery)"
    Write-Host "  -SpecId        Unique spec-id matching ^[a-z][a-z0-9-]{1,7}$ (e.g. dr)"
    Write-Host "  -Description   One-line description of the category"
    Write-Host "  -Json          Machine-readable JSON output"
    Write-Host "  -Help          Show this help"
    exit 0
}

# --- Source shared helpers ---
. (Join-Path $PSScriptRoot "common.ps1")
$repoRoot = Get-RepoRoot

# --- Required parameter check ---
if (-not $Tier -or -not $CategoryName -or -not $SpecId -or -not $Description) {
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

# --- CategoryName format validation ---
if ($CategoryName -notmatch '^[a-z][a-z0-9-]+$') {
    $msg = "Invalid -CategoryName '$CategoryName'. Must be kebab-case (lowercase letters, numbers, hyphens, starts with letter)."
    if ($Json) {
        [ordered]@{ status = "error"; message = $msg } | ConvertTo-Json -Compress
    } else {
        Write-Error $msg
    }
    exit 1
}

# --- SpecId format validation ---
if ($SpecId -notmatch '^[a-z][a-z0-9-]{1,7}$') {
    $msg = "Invalid -SpecId '$SpecId'. Must match ^[a-z][a-z0-9-]{1,7}$ (2-8 chars, starts with letter, may contain lowercase alphanumeric and hyphens)."
    if ($Json) {
        [ordered]@{ status = "error"; message = $msg } | ConvertTo-Json -Compress
    } else {
        Write-Error $msg
    }
    exit 1
}

# --- Global spec-id uniqueness check ---
$catalog = Build-CategoryCatalog
if ($catalog.ContainsKey($SpecId)) {
    $conflict = $catalog[$SpecId]
    $msg = "Spec-id '$SpecId' is already registered in tier '$($conflict.tier)'. Spec-ids must be globally unique across all tiers."
    if ($Json) {
        [ordered]@{ status = "error"; message = $msg; conflictTier = $conflict.tier } | ConvertTo-Json -Compress
    } else {
        Write-Error $msg
    }
    exit 1
}

# --- Locate _categories.yaml ---
$catFilePath = Join-Path $repoRoot "specs" $Tier "_categories.yaml"
$today = (Get-Date).ToString("yyyy-MM-dd")
$textInfo = (Get-Culture).TextInfo

# Bootstrap if missing
if (-not (Test-Path $catFilePath -PathType Leaf)) {
    $tierTitle = $textInfo.ToTitleCase($Tier)
    $skeleton  = @"
---
# $tierTitle Tier Category Index
# Created: $today
# Version: 1.0.0-draft

metadata:
  tier: $Tier
  name: "$tierTitle Categories"
  description: "All categories at the $Tier tier level"
  version: "1.0.0-draft"
  created: "$today"
  category-count: 0

categories: []
"@
    $catDir = Split-Path $catFilePath
    if (-not (Test-Path $catDir -PathType Container)) {
        New-Item -ItemType Directory -Path $catDir -Force | Out-Null
    }
    Set-Content -Path $catFilePath -Value $skeleton -NoNewline
}

$catContent = Get-Content -Path $catFilePath -Raw

# --- Idempotency: spec-id already in this tier's catalog ---
if ($catContent -match "(?m)^\s{2,8}spec-id:\s*[`"']?$([regex]::Escape($SpecId))[`"']?\s*$") {
    $msg = "Category with spec-id '$SpecId' is already registered in tier '$Tier'. No changes made."
    if ($Json) {
        [ordered]@{ status = "exists"; specId = $SpecId; tier = $Tier; message = $msg } | ConvertTo-Json -Compress
    } else {
        Write-Host "[specify] $msg" -ForegroundColor Yellow
    }
    exit 0
}

# --- Build YAML entry ---
$catTitle = $textInfo.ToTitleCase($CategoryName -replace '-', ' ')
$entry    = @"

  - category: $CategoryName
    spec-id: $SpecId
    version: "1.0.0-draft"
    file: $CategoryName/spec.md
    name: "$catTitle"
    description: "$Description"
    status: "draft"
    created: "$today"
"@

# Append entry — replace empty [] or append to end of existing list
if ($catContent -match 'categories:\s*\[\]') {
    $catContent = $catContent -replace 'categories:\s*\[\]', "categories:$entry"
} else {
    $catContent = $catContent.TrimEnd() + "`n$entry`n"
}

# Recount category entries and update category-count
$entryCount  = ([regex]::Matches($catContent, '(?m)^\s{2,4}-\s+category:')).Count
$catContent  = $catContent -replace 'category-count:\s*\d+', "category-count: $entryCount"

# Atomic write via temp file rename
$tempPath = "$catFilePath.tmp"
Set-Content -Path $tempPath -Value $catContent -NoNewline
Move-Item -Path $tempPath -Destination $catFilePath -Force

# --- Increment category count in specs.yaml tiers section ---
$specsYamlPath = Join-Path $repoRoot "specs" "specs.yaml"
if (Test-Path $specsYamlPath -PathType Leaf) {
    $specsLines  = Get-Content -Path $specsYamlPath
    $inTier      = $false
    $updated     = $false
    for ($i = 0; $i -lt $specsLines.Count; $i++) {
        if ($specsLines[$i] -match "^\s+-\s+tier:\s*$([regex]::Escape($Tier))\s*$") {
            $inTier = $true
            continue
        }
        # New tier block started — stop looking
        if ($inTier -and $specsLines[$i] -match '^\s+-\s+tier:\s*\w') {
            break
        }
        if ($inTier -and $specsLines[$i] -match '^\s+categories:\s*(\d+)') {
            $current      = [int]$Matches[1]
            $specsLines[$i] = $specsLines[$i] -replace "categories:\s*\d+", "categories: $($current + 1)"
            $updated      = $true
            break
        }
    }
    if ($updated) {
        Set-Content -Path $specsYamlPath -Value ($specsLines -join "`n") -NoNewline
    }
}

# --- Output ---
if ($Json) {
    [ordered]@{
        status       = "registered"
        specId       = $SpecId
        categoryName = $CategoryName
        tier         = $Tier
        catFile      = $catFilePath
    } | ConvertTo-Json -Compress
} else {
    Write-Host "[specify] Registered category '$CategoryName' (spec-id: $SpecId) in tier '$Tier'" -ForegroundColor Green
    Write-Host "  Catalog:      $catFilePath" -ForegroundColor Gray
    Write-Host "  Spec path:    specs/$Tier/$CategoryName/spec.md" -ForegroundColor Gray
}
