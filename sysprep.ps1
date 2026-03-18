#Requires -Version 7.0
<#
.SYNOPSIS
    Sysprep the customer template repository and publish a versioned release tag.

.DESCRIPTION
    Creates a clean customer-facing snapshot of the repo on an orphan branch, strips
    all internal platform meta-specs (0xx-*/), meeting transcripts, customer tier spec
    content, and agent session memory.  The snapshot is committed, tagged with the
    supplied version, and optionally pushed to origin.

    The main branch is NEVER modified.  The tag points to an orphan commit (no
    relationship to the main history), so customers receive a clean tree when they
    clone or checkout the tag.

.PARAMETER Version
    Semantic version string, e.g. "1.0.0".  The tag will be "template/v<Version>".

.PARAMETER Push
    Push the tag to origin after creating it locally.

.PARAMETER Force
    Re-create the tag even if it already exists (also force-pushes if -Push is set).

.EXAMPLE
    .\sysprep.ps1 -Version "1.0.0" -Push
    .\sysprep.ps1 -Version "1.2.0"               # creates tag locally, no push
    .\sysprep.ps1 -Version "1.0.0" -Push -Force  # overwrite existing tag
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^\d+\.\d+\.\d+$')]
    [string] $Version,

    [switch] $Push,
    [switch] $Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
$TagName       = "template/v$Version"
$RepoRoot      = $PSScriptRoot          # sysprep.ps1 lives at the repo root
$StagingBranch = "sysprep-staging-$(New-Guid)"
$StagingPath   = Join-Path ([System.IO.Path]::GetTempPath()) $StagingBranch

# ---------------------------------------------------------------------------
# Guards
# ---------------------------------------------------------------------------
$existingTag = git -C $RepoRoot tag -l $TagName 2>$null
if ($existingTag -and -not $Force) {
    throw "Tag '$TagName' already exists. Use -Force to overwrite."
}

$dirty = git -C $RepoRoot status --porcelain 2>$null
if ($dirty) {
    Write-Warning "Working tree has uncommitted changes. The tag will be built from HEAD; unsaved changes will NOT be included."
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

function Copy-Asset ([string]$RelPath) {
    $src        = Join-Path $RepoRoot $RelPath
    $dest       = Join-Path $StagingPath $RelPath
    $destParent = Split-Path $dest -Parent
    if (-not (Test-Path $destParent)) {
        New-Item -ItemType Directory -Path $destParent -Force | Out-Null
    }
    if (Test-Path $src -PathType Container) {
        Copy-Item -Path $src -Destination $destParent -Recurse -Force
    } elseif (Test-Path $src -PathType Leaf) {
        Copy-Item -Path $src -Destination $dest -Force
    } else {
        Write-Verbose "Skip (not found): $RelPath"
    }
}

function Reset-SpecsYamlCounts ([string]$Path) {
    # Zero category counts for all tiers EXCEPT platform.
    # Platform functional specs travel with every customer release; their count is preserved.
    if (-not (Test-Path $Path)) { return }
    $lines       = Get-Content $Path
    $currentTier = $null
    $result = for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line -match '^\s+- tier:\s+(\w+)') { $currentTier = $Matches[1] }
        if ($currentTier -ne 'platform' -and $line -match '^\s+categories:\s+\d+') {
            $line = $line -replace '(\bcategories:\s+)\d+', '${1}0'
        }
        $line
    }
    ($result -join "`n") | Set-Content -Path $Path -Encoding utf8NoBOM -NoNewline
}

function Reset-CategoriesYaml ([string]$Path) {
    if (-not (Test-Path $Path)) { return }
    $content = Get-Content $Path -Raw
    # Zero out the category-count metadata field
    $content = $content -replace '(?m)(^\s*category-count:\s*)\d+', '${1}0'
    # Replace the entire categories block (everything from the `categories:` key
    # to end-of-file) with an empty list
    $content = $content -replace '(?s)(\r?\n)categories:.*$', '$1categories: []'
    Set-Content -Path $Path -Value $content -Encoding utf8NoBOM -NoNewline
}

# ---------------------------------------------------------------------------
# Step 1 – Create staging worktree (orphan: no shared history with main)
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "==> Sysprep: $TagName"
Write-Host "    Repo   : $RepoRoot"
Write-Host "    Staging: $StagingPath"
Write-Host ""

# git ≥ 2.25 required for --orphan in worktree add
$gitVersion = (git --version) -replace 'git version ', ''
Write-Verbose "Git version: $gitVersion"

git -C $RepoRoot worktree add --orphan -b $StagingBranch $StagingPath 2>&1 | Write-Verbose
Write-Host "[1/7] Staging worktree created"

try {

    # -----------------------------------------------------------------------
    # Step 2 – Copy customer-facing assets into the staging tree
    # -----------------------------------------------------------------------

    # Tooling: scripts, templates, agent definitions
    Copy-Asset ".specify"
    Copy-Asset ".github"
    Copy-Asset ".gitignore"

    # Artifacts skeleton — empty role directories only (no pre-populated content).
    # Customer teams fill these with their own outputs.
    foreach ($roleDir in @('applications', 'devops', 'infrastructure')) {
        $skelDest = Join-Path $StagingPath "artifacts\$roleDir"
        New-Item -ItemType Directory -Path $skelDest -Force | Out-Null
        Set-Content -Path (Join-Path $skelDest ".gitkeep") `
                    -Value "# $roleDir team artifacts" -Encoding utf8NoBOM
    }

    # Spec system skeleton — tier manifest and index files
    Copy-Asset "specs\specs.yaml"
    foreach ($tier in @('business','security','infrastructure','devops','platform')) {
        Copy-Asset "specs\$tier\_categories.yaml"
    }
    # Application tier may use _index.yaml or _categories.yaml
    foreach ($leaf in @('_categories.yaml','_index.yaml')) {
        Copy-Asset "specs\application\$leaf"
    }

    # Copy functional platform spec directories.
    # These define system behavior (spec-system, iac-linting, artifact-org,
    # policy-as-code, transcript-ingestion) and must travel with every release
    # so that agent workflows function out-of-the-box.
    # 0xx-* directories are internal development-plan artifacts for the template
    # itself and are intentionally excluded.
    $platformSrcDir = Join-Path $RepoRoot "specs\platform"
    Get-ChildItem $platformSrcDir -Directory |
        Where-Object { $_.Name -notmatch '^\d{3}-' } |
        ForEach-Object { Copy-Asset "specs\platform\$($_.Name)" }

    Write-Host "[2/7] Customer assets copied"

    # -----------------------------------------------------------------------
    # Step 3 – Strip internal / generated content from the staging tree
    # -----------------------------------------------------------------------

    # Remove all tier spec subdirectories (customer-authored content)
    foreach ($tier in @('business','security','infrastructure','devops','application')) {
        $tierDir = Join-Path $StagingPath "specs\$tier"
        if (Test-Path $tierDir) {
            Get-ChildItem $tierDir -Directory | Remove-Item -Recurse -Force
        }
    }

    # Remove platform development-plan directories (0xx-*) only.
    # These are internal feature-roadmap artifacts for the template itself.
    # Functional platform specs (spec-system, iac-linting, artifact-org,
    # policy-as-code, transcript-ingestion) were copied in Step 2 and are kept.
    $platformDir = Join-Path $StagingPath "specs\platform"
    if (Test-Path $platformDir) {
        Get-ChildItem $platformDir -Directory |
            Where-Object { $_.Name -match '^\d{3}-' } |
            Remove-Item -Recurse -Force
    }

    # Clear agent session memory (accumulated during template development)
    $memoryDir = Join-Path $StagingPath ".specify\memory"
    if (Test-Path $memoryDir) {
        Get-ChildItem $memoryDir | Remove-Item -Recurse -Force
    }

    # Remove IDE settings (workspace-specific, not part of the deliverable)
    $vscodePath = Join-Path $StagingPath ".vscode"
    if (Test-Path $vscodePath) { Remove-Item $vscodePath -Recurse -Force }

    # Remove internal development tracking files
    $todoPath = Join-Path $StagingPath "to-do.md"
    if (Test-Path $todoPath) { Remove-Item $todoPath -Force }

    Write-Host "[3/7] Internal content stripped"

    # -----------------------------------------------------------------------
    # Step 4 – Reset _categories.yaml skeletons for customer-authored tiers
    # -----------------------------------------------------------------------
    # Platform _categories.yaml is NOT reset — it indexes the functional platform
    # specs that shipped in Step 2 and must remain accurate for agents to work.
    foreach ($tier in @('business','security','infrastructure','devops')) {
        $catFile = Join-Path $StagingPath "specs\$tier\_categories.yaml"
        Reset-CategoriesYaml $catFile
    }
    foreach ($leaf in @('_categories.yaml','_index.yaml')) {
        Reset-CategoriesYaml (Join-Path $StagingPath "specs\application\$leaf")
    }
    Write-Host "[4/7] Category indexes reset (platform preserved)"

    # -----------------------------------------------------------------------
    # Step 5 – Reset specs.yaml category counts for customer-authored tiers
    # -----------------------------------------------------------------------
    # Platform tier count (categories: 5) is preserved — functional platform specs shipped.
    # All other tier counts are zeroed; customers populate these from transcripts.
    $specsYaml = Join-Path $StagingPath "specs\specs.yaml"
    Reset-SpecsYamlCounts $specsYaml
    Write-Host "[5/7] specs.yaml counts reset (platform preserved)"

    # -----------------------------------------------------------------------
    # Step 6 – Write GETTING_STARTED.md and placeholder directories
    # -----------------------------------------------------------------------

    # Single-quoted here-string: no interpolation, backticks are literal
    $gettingStartedTemplate = @'
# Getting Started

This repository is a **Spec-Cloud Platform Template** — a pre-wired workspace for
AI-assisted architecture specification using GitHub Copilot Chat.

## Prerequisites

- VS Code with GitHub Copilot Chat extension
- Git ≥ 2.25, PowerShell ≥ 7.0

## Quick Start

### 1. Run the prerequisites check

```powershell
.\.specify\scripts\powershell\check-prerequisites.ps1
```

### 2. Drop your meeting transcripts

Place `.md` or `.txt` meeting transcript files in the `meetings/` folder:

```
meetings/
  q1-planning-2026.md
  architecture-review-2026-02.md
```

### 3. Invoke the transcript ingestion agent

Open GitHub Copilot Chat and run:

```
@transcripttospecs process meetings/q1-planning-2026.md
```

The agent will:

1. Extract architectural decisions from the transcript
2. Classify each decision into the correct specification tier
3. Detect conflicts with existing higher-authority specs (surfaced for human review)
4. Write compliant spec drafts to `specs/`
5. Register new categories in `_categories.yaml` and `specs.yaml`

> On first run, any missing `_categories.yaml` skeletons are auto-created (bootstrap).

---

## Specification Tier Hierarchy

Tiers are ordered by authority — higher tiers win when conflicts arise.

| Priority | Tier           | Scope                                          |
|----------|----------------|------------------------------------------------|
| 0        | Platform       | Framework, tooling, templates, agent rules     |
| 1        | Business       | Cost governance, compliance, change management |
| 2        | Security       | Access control, audit logging, data protection |
| 3        | Infrastructure | Compute, networking, storage, IaC modules      |
| 4        | DevOps         | CI/CD, observability, deployment automation    |
| 5        | Application    | Application-level architecture                 |

---

## Repository Structure

```
.github/agents/          GitHub Copilot agent definitions
.specify/scripts/        PowerShell helper scripts
.specify/templates/      Spec, plan, and task scaffolding templates
artifacts/               IaC modules and application deliverables
meetings/                Drop transcript files here
specs/                   Generated specification documents
```

---

Generated from template **{{TAG_NAME}}**.
'@

    $gettingStarted = $gettingStartedTemplate.Replace('{{TAG_NAME}}', $TagName)
    Set-Content -Path (Join-Path $StagingPath "GETTING_STARTED.md") `
                -Value $gettingStarted -Encoding utf8NoBOM

    # Empty meetings/ directory with a placeholder so it's tracked by git
    $meetingsDir = Join-Path $StagingPath "meetings"
    New-Item -ItemType Directory -Path $meetingsDir -Force | Out-Null
    Set-Content -Path (Join-Path $meetingsDir ".gitkeep") `
                -Value "# Drop meeting transcript files (.md / .txt) here" `
                -Encoding utf8NoBOM

    Write-Host "[6/7] GETTING_STARTED.md written, meetings/ placeholder created"

    # -----------------------------------------------------------------------
    # Step 7 – Commit and tag in the staging worktree
    # -----------------------------------------------------------------------
    Push-Location $StagingPath
    try {
        git add --all
        git commit -m "chore: sysprep customer template $TagName"

        # Remove an existing tag if -Force was requested
        if ($Force -and $existingTag) {
            git -C $RepoRoot tag -d $TagName 2>$null | Out-Null
        }

        git -C $RepoRoot tag -a $TagName -m "Customer template release $TagName"
        Write-Host "[7/7] Commit and tag '$TagName' created"
    } finally {
        Pop-Location
    }

} finally {
    # -----------------------------------------------------------------------
    # Cleanup – remove the staging worktree regardless of success/failure
    # -----------------------------------------------------------------------
    git -C $RepoRoot worktree remove $StagingPath --force 2>$null | Out-Null
    git -C $RepoRoot branch -D $StagingBranch 2>$null | Out-Null
    Write-Host ""
    Write-Host "Staging worktree removed."
}

# ---------------------------------------------------------------------------
# Optionally push the tag to origin
# ---------------------------------------------------------------------------
if ($Push.IsPresent) {
    if ($PSCmdlet.ShouldProcess("origin", "Push tag '$TagName'")) {
        $pushArgs = @('push', 'origin', $TagName)
        if ($Force) { $pushArgs += '--force' }
        git -C $RepoRoot @pushArgs
        Write-Host "Pushed tag '$TagName' to origin."
    }
} else {
    Write-Host ""
    Write-Host "Tag '$TagName' is ready locally."
    Write-Host "To publish: git push origin $TagName"
}

Write-Host ""
Write-Host "Done. Customers can clone with:"
Write-Host "  git clone --branch $TagName <repo-url> --single-branch"
