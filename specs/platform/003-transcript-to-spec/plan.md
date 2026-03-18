---
# YAML Frontmatter
tier: platform
category: transcript-ingestion
spec-id: txin
artifact-type: plan
version: "1.0.0-draft"
created: 2026-03-17
last-updated: 2026-03-17

# Role Context (per governance v2.0.0)
role-context:
  declared-role: platform
  authority-scope: platform-meta-governance
  change-intent: "Design and implement the transcript-ingestion capability: transcript-to-specs agent mode (spec-interpreted) + register-category.ps1 + write-spec.ps1 (script-enforced) + transcript-analysis-template.md"
  upstream-snapshot:
    - spec-id: spec
      version: "1.0.0-draft"
    - spec-id: artifact
      version: "1.0.0-draft"
  cascade-run-id: null
  decision-mode: reviewed
  requested-by: "Platform Dev"
  approved-by: null
---

# Implementation Plan: AI Transcript Ingestion for Spec Generation

**Branch**: `003-transcript-to-spec` | **Date**: 2026-03-17 | **Spec**: [specs/platform/003-transcript-to-spec/spec.md](spec.md)  
**Input**: Feature specification from `specs/platform/003-transcript-to-spec/spec.md`

---

## Summary

Build a new platform capability for AI-assisted meeting transcript ingestion. The primary deliverable is the **`transcript-to-specs`** VS Code agent mode: a user invokes it in Copilot Chat, provides a transcript file path, and the agent orchestrates the full session — reading the file, loading the live category catalog, extracting decisions by tier, presenting a grouping plan, conducting clarifying Q&A, handling per-conflict interactive resolution, checking existing specs for additive updates, and writing output spec drafts. All file writes and registry updates are delegated to two new toolkit scripts: `register-category.ps1` (script-enforced, category registration) and `write-spec.ps1` (script-enforced, spec file creation with frontmatter). A new platform category `transcript-ingestion` (spec-id: `txin`) is registered in `specs/platform/` and `specs.yaml`.

---

## Technical Context

**Language/Version**: PowerShell 7+ (pwsh) — toolkit scripts; Copilot Chat agent mode (`.agent.md`)  
**Primary Dependencies**: `common.ps1` (shared helpers: repo root, branch, paths, `$script:SpecTiers`), PSScriptAnalyzer (CI validation), `.specify/templates/transcript-analysis-template.md` (tier signal vocabulary for agent)  
**Storage**: File system — agent reads transcript `.md`/`.txt`, reads `specs.yaml` + `_categories.yaml`; toolkit scripts write `spec.md` files and update `_categories.yaml`/`specs.yaml`  
**Testing**: Manual validation (agent + scripts), PSScriptAnalyzer for scripts  
**Target Platform**: VS Code Copilot Chat (agent); cross-platform pwsh (scripts — Linux, Windows, macOS)  
**Project Type**: Platform toolkit extension (`.github/agents/` + `.specify/scripts/` + `.specify/templates/`)  
**Performance Goals**: Script operations complete within 10 seconds each; agent session completes without leaving Copilot Chat  
**Constraints**: No API keys in scripts; all AI reasoning inside agent session; agent MUST NOT write files directly — all file operations via toolkit scripts; scripts must not overwrite existing specs without `-Force`  
**Scale/Scope**: One transcript per agent session; up to ~50 category mappings per transcript; single-user interactive agent session

---

## Constitution Check: Tier Alignment & Spec Cascading

- **Spec Tier**: platform (authority-scope: platform-meta-governance)
- **Parent Tier Specs**: This feature operates at the highest authority scope — it extends the `.specify/` framework itself, which is reserved exclusively for platform-meta-governance. No upstream specs override this work.
- **Derived Constraints**:
  - All generated spec files MUST comply with `platform/spec-system` frontmatter schema (required fields, semver versioning, status values)
  - All generated file paths MUST follow `platform/artifact-org` directory structure (`specs/<tier>/<category>/spec.md`)
  - `register-category.ps1` and `write-spec.ps1` MUST satisfy the script-enforced interface standard: deterministic output, non-zero exit on failure, idempotent where applicable
  - `transcript-analysis-template.md` MUST be placed in `.specify/templates/` to qualify as spec-interpreted mode
  - PSScriptAnalyzer MUST pass with zero errors per `platform/iac-linting`
- **Artifact Traceability**:
  - `transcript-to-specs.md` (`.github/agents/`) — new spec-interpreted agent mode
  - `transcript-analysis-template.md` — new spec-interpreted template (tier signal vocabulary)
  - `register-category.ps1` — new script-enforced category registration script
  - `write-spec.ps1` — new script-enforced spec writer script
  - `specs/platform/transcript-ingestion/spec.md` — new platform category spec
  - `specs/platform/_categories.yaml` — updated with new category entry
  - `specs/specs.yaml` — updated with category-count and toolkit registration

*Constitution re-check (post-design)*: ✅ All generated artifacts align with tier constraints. No violations.

---

## Spec Organization

```text
specs/platform/003-transcript-to-spec/
├── plan.md                       ← this file
├── spec.md                       ← feature specification
├── research.md                   ← Phase 0: decisions & alternatives
├── data-model.md                 ← Phase 1: entities & state
└── quickstart.md                 ← Phase 1: usage walkthrough

# Delivered artifacts (output of implementation)
.github/agents/
└── transcript-to-specs.md        ← agent mode definition (spec-interpreted)

.specify/
├── scripts/powershell/
│   ├── register-category.ps1     ← category registration (script-enforced)
│   └── write-spec.ps1            ← spec file writer (script-enforced)
└── templates/
    └── transcript-analysis-template.md  ← tier signal vocabulary (spec-interpreted)

specs/platform/
└── transcript-ingestion/
    └── spec.md                   ← promoted platform category spec
```

---

## Implementation Phases

### Phase 1 — Signal Vocabulary Template (spec-interpreted)

Design `transcript-analysis-template.md` to guide the agent:
1. Full per-tier keyword signal table (all 6 tiers, disambiguation rules for multi-tier signals)
2. Extraction algorithm: meeting metadata → raw statement extraction → tier+category mapping → gap detection
3. Grouping rules: one spec per tier-category pair, how to merge multiple statements into one spec body
4. Output format: proposed grouping plan format + session summary table format

**Output**: `.specify/templates/transcript-analysis-template.md`

### Phase 2 — Agent Mode (spec-interpreted) + Toolkit Scripts (script-enforced)

**Phase 2a — `transcript-to-specs` agent mode**

Author `.github/agents/transcript-to-specs.md` with:
1. **Invocation**: how user provides transcript file path in Copilot Chat
2. **Workflow**: 7-step sequential flow (read → catalog → extract → group plan → confirm → resolve conflicts / check existing specs → write + summarize)
3. **Conflict resolution**: per-conflict interactive; 3-option prompt (Block / Write-with-flag / Propose-amendment); agent behavior for each choice
4. **Existing spec handling**: read existing spec → determine if additive → propose additions → confirm before write
5. **New category handling**: propose name+spec-id+tier → confirm → call `register-category.ps1`
6. **Toolkit script integration**: exact call signatures, exit code interpretation
7. **Constraints**: enumerate all behavioral guardrails from spec.md

**Output**: `.github/agents/transcript-to-specs.md`

**Phase 2b — `register-category.ps1`**

1. Validate parameters (`-Tier`, `-CategoryName`, `-SpecId`, `-Description`)
2. Check global spec-id uniqueness against full catalog
3. Upsert entry in `specs/<tier>/_categories.yaml` (create bootstrap skeleton if missing)
4. Increment `category-count` in `specs.yaml` (idempotent)
5. Exit 0 on success, 1 on validation failure

**Output**: `.specify/scripts/powershell/register-category.ps1`

**Phase 2c — `write-spec.ps1`**

1. Validate parameters (`-Tier`, `-Category`, `-SpecId`, `-FrontmatterJson`, `-BodyMarkdown`)
2. Parse and validate frontmatter JSON (all required fields present, `status: draft` enforced)
3. Inject `conflict-flags:` block into frontmatter + body if present in input JSON
4. Resolve target path; create directory if needed
5. Skip (exit 2) if file exists and `-Force` not set
6. Write frontmatter + body markdown; validate written file
7. Exit 0 on success, 1 on validation failure, 2 on skip

**Output**: `.specify/scripts/powershell/write-spec.ps1`

### Phase 3 — Platform Category Registration & Validation

- Create `specs/platform/transcript-ingestion/spec.md` (promote this feature spec)
- Add `transcript-ingestion` entry to `specs/platform/_categories.yaml`
- Run `Invoke-ScriptAnalyzer` on both new scripts — zero errors required
- End-to-end smoke test: invoke `transcript-to-specs` agent on sample transcript, verify grouping plan presentation, written spec frontmatter, session summary
- Tag: `git tag spec/txin/1.0.0-draft`

---

## Complexity Tracking

No constitution violations. Complexity is proportional to the feature scope.


