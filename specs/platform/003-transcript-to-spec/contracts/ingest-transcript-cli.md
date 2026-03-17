# Contract: ingest-transcript.ps1 CLI Interface

**Branch**: `001-transcript-to-spec` | **Date**: 2026-03-17 | **Phase**: 1 | **Location**: `specs/platform/003-transcript-to-spec/`  
**Execution Mode**: script-enforced  
**Script path**: `.specify/scripts/powershell/ingest-transcript.ps1`

---

## Parameters

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `-TranscriptFile` | string (path) | **Yes** | — | Path to transcript file (`.md` or `.txt`) |
| `-ManifestFile` | string (path or `-`) | No | — | Path to file containing the AI's `IngestionManifest` JSON response (use `-` to read from stdin). If omitted, the script outputs the composed analysis prompt to stdout (Step 1) and exits 0. If provided, the script reads the manifest and proceeds to write specs (Step 2). |
| `-DryRun` | switch | No | `$false` | Preview manifest without writing any files |
| `-Force` | switch | No | `$false` | Overwrite existing spec files and create new categories without confirmation |
| `-Json` | switch | No | `$false` | Output results as JSON to stdout |
| `-Help` | switch | No | `$false` | Print usage and exit 0 |

---

## Invocation Examples

```powershell
# ── Step 1: Generate analysis prompt (no -ManifestFile) ──────────────────────
# Script outputs the composed prompt; paste it into your AI agent
./ingest-transcript.ps1 -TranscriptFile meetings/q2-planning-2026.md

# ── Step 2: Process AI response and write specs ───────────────────────────────
# After pasting the prompt and receiving the manifest JSON from your AI agent,
# save the response to a file and supply it with -ManifestFile
./ingest-transcript.ps1 -TranscriptFile meetings/q2-planning-2026.md -ManifestFile ai-response.md

# Step 2 — read manifest from stdin (pipeline use)
cat ai-response.md | ./ingest-transcript.ps1 -TranscriptFile meetings/q2-planning-2026.md -ManifestFile -

# Preview only — no files written (dry run with manifest)
./ingest-transcript.ps1 -TranscriptFile meetings/q2-planning-2026.md -ManifestFile ai-response.md -DryRun

# Machine-readable output (CI usage)
./ingest-transcript.ps1 -TranscriptFile meetings/q2-planning-2026.md -ManifestFile ai-response.md -Json

# Overwrite existing drafts and auto-create new categories
./ingest-transcript.ps1 -TranscriptFile meetings/q2-planning-2026.md -ManifestFile ai-response.md -Force

# Dry run + JSON (CI preview gate)
./ingest-transcript.ps1 -TranscriptFile meetings/q2-planning-2026.md -ManifestFile ai-response.md -DryRun -Json
```

---

## Inputs (Deterministic Contract)

| Input | Source | Validation |
|---|---|---|
| Transcript content | `-TranscriptFile` path | File must exist; content must be non-empty; max 500,000 chars |
| Category catalog | `specs/specs.yaml` + all `<tier>/_categories.yaml` | Parsed at startup; missing files treated as empty catalogs for bootstrap mode |
| IngestionManifest | AI response parsed from stdout/clipboard | Must be valid JSON matching `IngestionManifest` schema; extracted from fenced ` ```json ` block |

---

## Outputs (Deterministic Contract)

### Files Written

For each `SpecEntry` in the manifest where the target path does not exist (or `-Force` is set):

```
specs/<tier>/<category>/spec.md
```

Each file contains:
- YAML frontmatter with all required fields
- `status: draft`
- `compliance-state: current`
- `role-context.requested-by: "transcript-ingestion"`
- `role-context.decision-mode: autonomous`
- Spec body with: Executive Summary, Decisions (from transcript), Requirements, Constraints

### Registry Updates

For each `NewCategoryProposal`:
1. `specs/<tier>/_categories.yaml` — new entry appended under `categories:`, `category-count` incremented
2. `specs/specs.yaml` — `category-count` for the affected tier incremented

### Stdout (default mode)

Human-readable summary table:

```
[ingest-transcript] Processing: meetings/q2-planning-2026.md
[ingest-transcript] Category catalog loaded: 18 categories across 5 tiers

Spec generation manifest:
  TIER            CATEGORY               SPEC-ID  ACTION
  business        cost                   cost     created
  business        compliance-framework   comp     created
  infrastructure  compute                compute  skipped (exists, use -Force to overwrite)
  business        disaster-recovery      dr       created (NEW CATEGORY)

[ingest-transcript] Complete: 3 created, 1 skipped, 0 failed, 1 new category registered
```

### Stdout (JSON mode, `-Json`)

```json
{
  "success": true,
  "dry_run": false,
  "transcript_file": "meetings/q2-planning-2026.md",
  "specs_created": 3,
  "specs_skipped": 1,
  "specs_failed": 0,
  "categories_created": 1,
  "errors": [],
  "warnings": [
    "specs/infrastructure/compute/spec.md already exists — skipped (use -Force to overwrite)"
  ],
  "specs": [
    { "tier": "business", "category": "cost", "spec_id": "cost", "path": "specs/business/cost/spec.md", "action": "created" },
    { "tier": "business", "category": "compliance-framework", "spec_id": "comp", "path": "specs/business/compliance-framework/spec.md", "action": "created" },
    { "tier": "infrastructure", "category": "compute", "spec_id": "compute", "path": "specs/infrastructure/compute/spec.md", "action": "skipped" },
    { "tier": "business", "category": "disaster-recovery", "spec_id": "dr", "path": "specs/business/disaster-recovery/spec.md", "action": "created", "new_category": true }
  ]
}
```

---

## Exit Codes

| Code | Meaning |
|---|---|
| `0` | All entries processed successfully (skips are not failures) |
| `1` | One or more spec entries failed validation or could not be written; or required inputs missing |

---

## Idempotency Behaviour

| Scenario | Behaviour |
|---|---|
| Run twice with same transcript | Second run: all specs skipped with warnings; exit 0 |
| Run twice with `-Force` | Second run: all specs overwritten; exit 0 |
| Category already exists in `_categories.yaml` | Deduped by `spec_id`; no duplicate entry added |
| `specs.yaml` `category-count` already correct | No change (read-compare before write) |

---

## Prerequisite Checks (before any writes)

The script performs these checks and exits with code 1 if any fail:

1. `-TranscriptFile` path exists and is readable
2. Repo root is locatable (via `common.ps1 Get-RepoRoot`)
3. `specs/specs.yaml` exists (or bootstrap mode: all tiers empty)
4. IngestionManifest JSON is parseable and schema-valid
5. All `tier` values in manifest are in the known tier list
6. All `spec_id` values for new categories are valid (`^[a-z][a-z0-9-]{1,7}$`) and globally unique

---

## Toolkit Registration

This script must be registered in `specs.yaml` toolkit-components.scripts:

```yaml
ingest-transcript.ps1:
  purpose: "AI-assisted transcript ingestion to generate categorized spec drafts"
  contracts:
    input: "transcript file path; IngestionManifest JSON from AI"
    output: "spec.md files created; _categories.yaml and specs.yaml updated"
    idempotent: true
```
