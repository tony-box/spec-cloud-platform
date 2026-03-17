#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Detects version drift between downstream specs and validates git tag resolution.

.DESCRIPTION
    Compares the version pins in each spec's depends-on block against the
    authoritative latest versions in the specs.yaml category registry.

    For each spec file found under specs/:
      - Reads depends-on[].version (the compliance pin)
      - Looks up the current version for that spec-id in specs.yaml
      - Reports drift using semver severity:
          Major bump → ERROR   (breaking change, must upgrade)
          Minor bump → WARNING (additive, should upgrade)
          Patch bump → INFO    (fix only, opportunistic)
      - Validates that compliance-state field matches actual drift state

    Git tag resolution check:
      - For every depends-on[].version pin across all specs, verifies that a
        git tag named spec/<spec-id>/<version> exists in the local repository.
      - Missing tags are WARNING (non-blocking) since tags are created on publish.
      - Convention: git tag spec/cost/2.0.0  then  git push --tags
      - Resolve any version: git show spec/cost/2.0.0:specs/business/cost/spec.md

    Exits 0 if no errors, 1 if any ERROR-level drift or missing required fields.

.PARAMETER Json
    Output results in JSON format.

.PARAMETER Help
    Show usage information and exit.

.EXAMPLE
    ./validate-spec-versions.ps1
    ./validate-spec-versions.ps1 -Json

.NOTES
    To simulate a version bump and see how drift is detected:
      1. Bump a spec version in specs.yaml (e.g., cost from 2.0.0 to 3.0.0)
      2. Run this script — specs pinned to 2.x.x will be flagged
      3. Update those specs' depends-on version and compliance-state to clear the flag
      4. Create the new git tag: git tag spec/cost/3.0.0
#>
[CmdletBinding()]
param(
    [switch]$Json,
    [switch]$Help
)
$ErrorActionPreference = 'Stop'

if ($Help) {
    Write-Host "Usage: ./validate-spec-versions.ps1 [-Json] [-Help]"
    Write-Host ""
    Write-Host "Detects version drift between downstream specs and upstream dependencies."
    Write-Host "Compares depends-on version pins against the specs.yaml registry."
    Write-Host "Also checks that each pinned version has a resolvable git tag."
    Write-Host ""
    Write-Host "Severity:"
    Write-Host "  ERROR   - Major version bump (breaking change)"
    Write-Host "  WARNING - Minor version bump (additive) or missing git tag"
    Write-Host "  INFO    - Patch version bump (fix only)"
    Write-Host ""
    Write-Host "Git tag convention:  spec/<spec-id>/<version>"
    Write-Host "  Create:   git tag spec/cost/2.0.0"
    Write-Host "  Resolve:  git show spec/cost/2.0.0:specs/business/cost/spec.md"
    exit 0
}

# --- Helpers ---
. (Join-Path $PSScriptRoot "common.ps1")

function Compare-SemVer {
    param([string]$Pinned, [string]$Latest)
    # Strip pre-release suffixes for numeric comparison
    $pinnedCore = $Pinned -replace '-.*$', ''
    $latestCore = $Latest  -replace '-.*$', ''

    try {
        $p = [version]$pinnedCore
        $l = [version]$latestCore
    } catch {
        return "unknown"
    }

    if ($l.Major -gt $p.Major) { return "major" }
    if ($l.Minor -gt $p.Minor) { return "minor" }
    if ($l.Build -gt $p.Build) { return "patch" }
    return "current"
}

# --- Locate repo and files ---
$repoRoot = Get-RepoRoot
$specsDir = Join-Path $repoRoot "specs"
$specsYamlPath = Join-Path $repoRoot "specs" "specs.yaml"

if (-not (Test-Path $specsYamlPath)) {
    $msg = "specs.yaml not found at $specsYamlPath"
    if ($Json) { [ordered]@{ status = "error"; message = $msg } | ConvertTo-Json -Compress } else { Write-Error $msg }
    exit 1
}

# --- Build authoritative version map from specs.yaml ---
$specsYamlContent = Get-Content -Path $specsYamlPath -Raw
$authoritative = @{}  # spec-id → latest version string

# Parse "spec-id: xxx\n      version: yyy" pairs in the categories block
$categoryMatches = [regex]::Matches($specsYamlContent, 'spec-id:\s*(\S+)\s*\n\s*version:\s*"?([^"\s\n]+)"?')
foreach ($m in $categoryMatches) {
    $sid = $m.Groups[1].Value
    $ver = $m.Groups[2].Value
    $authoritative[$sid] = $ver
}

# --- Find all spec.md files ---
$specFiles = Get-ChildItem -Path $specsDir -Filter "spec.md" -Recurse -ErrorAction SilentlyContinue

$results = @()
$errorCount = 0
$warnCount = 0
$allPinnedVersions = @{}  # key: "spec-id@version" → { spec-id, version }

foreach ($specFile in $specFiles) {
    $content = Get-Content -Path $specFile.FullName -Raw
    $relPath = $specFile.FullName.Replace($repoRoot + '\', '').Replace('\', '/')

    # Scope all parsing to the YAML frontmatter block only (between opening and closing ---)
    $fmMatch = [regex]::Match($content, '(?s)^---\s*\n(.*?)\n---')
    $frontmatterContent = if ($fmMatch.Success) { $fmMatch.Groups[1].Value } else { "" }
    $frontmatterLines = if ($frontmatterContent) { $frontmatterContent -split '\n' } else { @() }

    # Extract this spec's own id (frontmatter only)
    $ownIdMatch = [regex]::Match($frontmatterContent, 'spec-id:\s*(\S+)')
    $ownId = if ($ownIdMatch.Success) { $ownIdMatch.Groups[1].Value } else { "unknown" }

    # Extract compliance-state (frontmatter only)
    $stateMatch = [regex]::Match($frontmatterContent, 'compliance-state:\s*(\S+)')
    $declaredState = if ($stateMatch.Success) { $stateMatch.Groups[1].Value } else { $null }

    # Parse depends-on entries (frontmatter only)
    $findings = @()
    $inDependsOn = $false
    $currentDep = $null

    foreach ($line in $frontmatterLines) {
        if ($line -match '^\s*depends-on:') {
            $inDependsOn = $true
            continue
        }
        if ($inDependsOn) {
            if ($line -match '^\s*-\s+tier:') {
                if ($currentDep) { $findings += $currentDep }
                $currentDep = @{ tier = $null; 'spec-id' = $null; version = $null }
            }
            elseif ($currentDep -and $line -match '^\s+spec-id:\s*(\S+)') {
                $currentDep['spec-id'] = $Matches[1]
            }
            elseif ($currentDep -and $line -match '^\s+version:\s*"?([^"\s\n]+)"?') {
                $currentDep['version'] = $Matches[1]
            }
            elseif ($line -match '^[^\s#]' -or ($line -match '^\s*#' -and $line -notmatch '^\s+-')) {
                # Top-level key or comment — end of depends-on block
                if ($currentDep) { $findings += $currentDep }
                $currentDep = $null
                $inDependsOn = $false
            }
        }
    }
    if ($currentDep) { $findings += $currentDep }

    # Skip specs with no dependencies
    if ($findings.Count -eq 0) { continue }

    $specDrift = @()
    $worstSeverity = "current"

    foreach ($dep in $findings) {
        $depId = $dep['spec-id']
        $pinnedVer = $dep['version']

        if (-not $depId) { continue }

        # Missing version pin
        if (-not $pinnedVer) {
            $specDrift += [ordered]@{
                'spec-id'      = $depId
                pinned         = $null
                latest         = $authoritative[$depId]
                severity       = "error"
                message        = "depends-on.$depId is missing a version pin"
            }
            $worstSeverity = "major"
            $errorCount++
            continue
        }

        # Track all pinned versions for git tag check later
        $pvKey = "$depId@$pinnedVer"
        if (-not $allPinnedVersions.ContainsKey($pvKey)) {
            $allPinnedVersions[$pvKey] = [ordered]@{ 'spec-id' = $depId; version = $pinnedVer }
        }

        # Unknown spec-id in registry
        if (-not $authoritative.ContainsKey($depId)) {
            $specDrift += [ordered]@{
                'spec-id'      = $depId
                pinned         = $pinnedVer
                latest         = $null
                severity       = "warning"
                message        = "$depId not found in specs.yaml registry — cannot check version"
            }
            continue
        }

        $latestVer = $authoritative[$depId]
        $drift = Compare-SemVer -Pinned $pinnedVer -Latest $latestVer

        if ($drift -eq "current") { continue }

        $severity = switch ($drift) {
            "major" { "error";   $errorCount++; break }
            "minor" { "warning"; $warnCount++;  break }
            "patch" { "info";                   break }
            default { "info" }
        }
        if ($drift -eq "major" -and $worstSeverity -ne "major") { $worstSeverity = "major" }
        elseif ($drift -eq "minor" -and $worstSeverity -eq "current") { $worstSeverity = "minor" }
        elseif ($drift -eq "patch" -and $worstSeverity -eq "current") { $worstSeverity = "patch" }

        $specDrift += [ordered]@{
            'spec-id' = $depId
            pinned    = $pinnedVer
            latest    = $latestVer
            severity  = $severity
            message   = "Pinned to $depId@$pinnedVer but latest is $latestVer ($drift version bump)"
        }
    }

    if ($specDrift.Count -eq 0) { continue }

    # Validate compliance-state accuracy
    $expectedState = switch ($worstSeverity) {
        "major" { "lagging" }
        "minor" { "lagging" }
        "patch" { "lagging" }
        default { "current" }
    }
    $stateWarning = $null
    if ($declaredState -and $declaredState -ne $expectedState) {
        $stateWarning = "compliance-state is '$declaredState' but drift detected — should be '$expectedState'"
        $warnCount++
    } elseif (-not $declaredState) {
        $stateWarning = "compliance-state field is missing"
    }

    $results += [ordered]@{
        file             = $relPath
        'spec-id'        = $ownId
        'compliance-state' = $declaredState
        drift            = $specDrift
        'state-warning'  = $stateWarning
    }
}

# --- Check git tag resolution for all pinned versions ---
$tagWarnings = @()
$gitAvailable = $null -ne (Get-Command git -ErrorAction SilentlyContinue)
if ($gitAvailable) {
    # Get all tags in one call for efficiency
    $allTags = git tag 2>$null
    if ($LASTEXITCODE -eq 0 -and $allTags) {
        $tagSet = [System.Collections.Generic.HashSet[string]]($allTags)
    } else {
        $tagSet = [System.Collections.Generic.HashSet[string]]@()
    }

    foreach ($entry in $allPinnedVersions.GetEnumerator()) {
        $sid  = $entry.Value['spec-id']
        $ver  = $entry.Value['version']
        $tagName = "spec/$sid/$ver"
        if (-not $tagSet.Contains($tagName)) {
            $tagWarnings += [ordered]@{
                tag     = $tagName
                'spec-id' = $sid
                version = $ver
                message = "Git tag '$tagName' not found — pinned version cannot be resolved from git history. Create with: git tag $tagName"
            }
            $warnCount++
        }
    }
} else {
    $tagWarnings += [ordered]@{
        tag     = $null
        'spec-id' = $null
        version = $null
        message = "git is not available — skipping tag resolution check"
    }
}

# --- Report ---
$isValid = ($errorCount -eq 0)

if ($Json) {
    [ordered]@{
        status       = if ($isValid) { "valid" } else { "invalid" }
        errors       = $errorCount
        warnings     = $warnCount
        drift        = $results
        'tag-warnings' = $tagWarnings
    } | ConvertTo-Json -Depth 6
} else {
    if ($results.Count -eq 0 -and $tagWarnings.Count -eq 0) {
        Write-Host "[validate-spec-versions] All specs are current with upstream versions and all pinned version tags exist." -ForegroundColor Green
    } else {
        $statusColor = if ($isValid) { "Yellow" } else { "Red" }
        $statusText  = if ($isValid) { "Warnings only — no blocking drift." } else { "ERROR-level drift detected." }
        Write-Host "[validate-spec-versions] $statusText" -ForegroundColor $statusColor
        Write-Host ""

        foreach ($r in $results) {
            Write-Host "  $($r.file) [$($r.'spec-id')]" -ForegroundColor Cyan
            foreach ($d in $r.drift) {
                $color = switch ($d.severity) {
                    "error"   { "Red" }
                    "warning" { "Yellow" }
                    default   { "Gray" }
                }
                Write-Host "    [$($d.severity.ToUpper())] $($d.message)" -ForegroundColor $color
            }
            if ($r.'state-warning') {
                Write-Host "    [WARN] $($r.'state-warning')" -ForegroundColor Yellow
            }
            Write-Host ""
        }

        if ($tagWarnings.Count -gt 0) {
            Write-Host "  Git tag resolution:" -ForegroundColor Cyan
            foreach ($t in $tagWarnings) {
                Write-Host "    [WARN] $($t.message)" -ForegroundColor Yellow
            }
            Write-Host ""
        }
    }
}

if (-not $isValid) { exit 1 }
exit 0
