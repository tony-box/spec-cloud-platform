#!/usr/bin/env pwsh
# Common PowerShell functions analogous to common.sh

# Known spec tiers — used for tier-subdir autodiscovery
$script:SpecTiers = @('platform', 'business', 'security', 'infrastructure', 'devops', 'application')

function Get-RepoRoot {
    try {
        $result = git rev-parse --show-toplevel 2>$null
        if ($LASTEXITCODE -eq 0) {
            return $result
        }
    } catch {
        # Git command failed
    }
    
    # Fall back to script location for non-git repos
    return (Resolve-Path (Join-Path $PSScriptRoot "../../..")).Path
}

function Get-CurrentBranch {
    # First check if SPECIFY_FEATURE environment variable is set
    if ($env:SPECIFY_FEATURE) {
        return $env:SPECIFY_FEATURE
    }
    
    # Then check git if available
    try {
        $result = git rev-parse --abbrev-ref HEAD 2>$null
        if ($LASTEXITCODE -eq 0) {
            return $result
        }
    } catch {
        # Git command failed
    }
    
    # For non-git repos, try to find the latest feature directory
    $repoRoot = Get-RepoRoot
    $specsDir = Join-Path $repoRoot "specs"
    
    if (Test-Path $specsDir) {
        $latestFeature = ""
        $highest = 0
        
        # Search top-level specs/ and all tier subdirectories
        $searchDirs = @($specsDir)
        foreach ($tier in $script:SpecTiers) {
            $tierDir = Join-Path $specsDir $tier
            if (Test-Path $tierDir -PathType Container) { $searchDirs += $tierDir }
        }
        
        foreach ($searchDir in $searchDirs) {
            foreach ($dir in (Get-ChildItem -Path $searchDir -Directory)) {
                if ($dir.Name -match '^(\d{3})-') {
                    $num = [int]$matches[1]
                    if ($num -gt $highest) {
                        $highest = $num
                        $latestFeature = $dir.Name
                    }
                }
            }
        }
        
        if ($latestFeature) {
            return $latestFeature
        }
    }
    
    # Final fallback
    return "main"
}

function Test-HasGit {
    try {
        git rev-parse --show-toplevel 2>$null | Out-Null
        return ($LASTEXITCODE -eq 0)
    } catch {
        return $false
    }
}

function Test-FeatureBranch {
    param(
        [string]$Branch,
        [bool]$HasGit = $true
    )
    
    # For non-git repos, we can't enforce branch naming but still provide output
    if (-not $HasGit) {
        Write-Warning "[specify] Warning: Git repository not detected; skipped branch validation"
        return $true
    }
    
    if ($Branch -notmatch '^[0-9]{3}-') {
        Write-Output "ERROR: Not on a feature branch. Current branch: $Branch"
        Write-Output "Feature branches should be named like: 001-feature-name"
        return $false
    }
    return $true
}

function Get-FeatureDir {
    param([string]$RepoRoot, [string]$Branch, [string]$Tier)
    # If tier explicitly provided, use it directly
    if ($Tier) {
        return Join-Path $RepoRoot "specs/$Tier/$Branch"
    }
    # Extract slug: strip leading NNN- so we can match renumbered dirs (e.g. branch
    # 001-transcript-to-spec finds specs/platform/003-transcript-to-spec)
    $slug = if ($Branch -match '^\d+-(.+)$') { $matches[1] } else { $null }

    foreach ($t in $script:SpecTiers) {
        $tierPath = Join-Path $RepoRoot "specs/$t"
        # 1. Exact match
        $candidate = Join-Path $tierPath $Branch
        if (Test-Path $candidate -PathType Container) { return $candidate }
        # 2. Slug match (same slug, different number prefix) — handles renaming on tier promotion
        if ($slug) {
            $slugMatch = Get-ChildItem -Path $tierPath -Directory -Filter "*-$slug" -ErrorAction SilentlyContinue |
                Select-Object -First 1
            if ($slugMatch) { return $slugMatch.FullName }
        }
    }
    # Fallback: legacy flat layout specs/<branch>
    Join-Path $RepoRoot "specs/$Branch"
}

function Get-FeaturePathsEnv {
    param(
        [string]$AppName,
        [string]$Tier
    )
    $repoRoot = Get-RepoRoot
    $currentBranch = Get-CurrentBranch
    $hasGit = Test-HasGit
    $resolvedAppName = if ($AppName) { $AppName } elseif ($env:SPECIFY_APP) { $env:SPECIFY_APP } else { $null }
    $featureDir = if ($resolvedAppName) {
        Join-Path $repoRoot "specs/application/$resolvedAppName"
    } else {
        Get-FeatureDir -RepoRoot $repoRoot -Branch $currentBranch -Tier $Tier
    }
    
    [PSCustomObject]@{
        REPO_ROOT     = $repoRoot
        CURRENT_BRANCH = $currentBranch
        HAS_GIT       = $hasGit
        FEATURE_DIR   = $featureDir
        FEATURE_SPEC  = Join-Path $featureDir 'spec.md'
        IMPL_PLAN     = Join-Path $featureDir 'plan.md'
        TASKS         = Join-Path $featureDir 'tasks.md'
        RESEARCH      = Join-Path $featureDir 'research.md'
        DATA_MODEL    = Join-Path $featureDir 'data-model.md'
        QUICKSTART    = Join-Path $featureDir 'quickstart.md'
        CONTRACTS_DIR = Join-Path $featureDir 'contracts'
    }
}

function Build-CategoryCatalog {
    <#
    .SYNOPSIS
        Builds a hashtable mapping every registered spec-id to its tier.
    .DESCRIPTION
        Reads all specs/<tier>/_categories.yaml files and extracts spec-id entries,
        returning @{ 'spec-id' = @{ tier = '<tier>' } } for global uniqueness checks.
        Used by register-category.ps1 before accepting a new spec-id.
    #>
    $repoRoot = Get-RepoRoot
    $catalog = @{}
    foreach ($tier in $script:SpecTiers) {
        $catFile = Join-Path $repoRoot "specs" $tier "_categories.yaml"
        if (-not (Test-Path $catFile -PathType Leaf)) { continue }
        $content = Get-Content -Path $catFile -Raw
        # Match lines like:  spec-id: txin  or  spec-id: "txin"
        $specIdMatches = [regex]::Matches($content, "(?m)^\s{2,8}spec-id:\s*[`"']?([a-zA-Z][a-zA-Z0-9-]*)[`"']?\s*$")
        foreach ($m in $specIdMatches) {
            $specId = $m.Groups[1].Value.Trim()
            if ($specId -and -not $catalog.ContainsKey($specId)) {
                $catalog[$specId] = @{ tier = $tier; specId = $specId }
            }
        }
    }
    return $catalog
}

function Test-FileExists {
    param([string]$Path, [string]$Description)
    if (Test-Path -Path $Path -PathType Leaf) {
        Write-Output "  ✓ $Description"
        return $true
    } else {
        Write-Output "  ✗ $Description"
        return $false
    }
}

function Test-DirHasFiles {
    param([string]$Path, [string]$Description)
    if ((Test-Path -Path $Path -PathType Container) -and (Get-ChildItem -Path $Path -ErrorAction SilentlyContinue | Where-Object { -not $_.PSIsContainer } | Select-Object -First 1)) {
        Write-Output "  ✓ $Description"
        return $true
    } else {
        Write-Output "  ✗ $Description"
        return $false
    }
}

