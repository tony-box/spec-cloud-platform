---
tier: platform
category: transcript-ingestion
spec-id: txin
artifact-type: tasks
version: "1.0.0-draft"
description: "Task list for AI Transcript Ingestion for Spec Generation"
created: 2026-03-17
last-updated: 2026-03-17

role-context:
  declared-role: platform
  authority-scope: platform-meta-governance
  change-intent: "Implement ingest-transcript.ps1 (script-enforced) + transcript-analysis-template.md (spec-interpreted) + platform category registration"
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

# Tasks: AI Transcript Ingestion for Spec Generation

**Input**: `specs/platform/003-transcript-to-spec/`  
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/ingest-transcript-cli.md  
**Tier**: platform | **Spec ID**: txin | **Branch**: `003-transcript-to-spec`

---

## Format: `[ID] [P?] [Story?] Description with file path`

- **[P]**: Parallelizable — different files or independent functions, no incomplete dependencies
- **[US#]**: Story label — required for all Phase 3+ tasks; maps to user stories in spec.md
- No test tasks — TDD not requested in spec

---

## Phase 1: Setup

**Purpose**: Create file scaffolds for both deliverable artifacts

- [ ] T001 Create `.specify/scripts/powershell/ingest-transcript.ps1` with CmdletBinding param block (`-TranscriptFile`, `-DryRun`, `-Force`, `-Json`, `-Help`), `$ErrorActionPreference = 'Stop'`, and `. $PSScriptRoot/common.ps1` source line
- [ ] T002 [P] Create `.specify/templates/transcript-analysis-template.md` with frontmatter (`tier: platform`, `category: transcript-ingestion`, `spec-id: txin`, `artifact-type: template`, `execution-mode: spec-interpreted`) and top-level section headings

---

## Phase 2: Foundational (shared building blocks — blocking all user stories)

**Purpose**: Core helpers used by every user story; must be complete before Phase 3

- [ ] T003 [P] Implement `-Help` display block in `.specify/scripts/powershell/ingest-transcript.ps1` — print usage, all parameters, invocation examples from contracts/ingest-transcript-cli.md, then `exit 0`
- [ ] T004 [P] Implement `Build-CategoryCatalog` function in `.specify/scripts/powershell/ingest-transcript.ps1` — reads `specs/specs.yaml` via `Get-RepoRoot` (from `common.ps1`), iterates all `specs/<tier>/_categories.yaml` files, returns `CategoryCatalog` object with `Tiers`, `Categories`, and `SpecIds` arrays per data-model.md
- [ ] T005 [P] Implement `Get-TranscriptDocument` function in `.specify/scripts/powershell/ingest-transcript.ps1` — validates `-TranscriptFile` exists and is non-empty (≤500 000 chars), returns `TranscriptDocument` object with `FilePath`, `Content`, `InferredDate`, `Participants`, `Purpose` per data-model.md
- [ ] T006 [P] Implement `ConvertFrom-IngestionManifest` function in `.specify/scripts/powershell/ingest-transcript.ps1` — extracts the first fenced ` ```json ` block from a string input and returns the deserialized object via `ConvertFrom-Json`; throws on parse failure
- [ ] T007 Implement `Test-IngestionManifest` validation function in `.specify/scripts/powershell/ingest-transcript.ps1` — validates: all `tier` values are in the 6 known tiers; all `spec_id` values match `^[a-z][a-z0-9-]{1,7}$`; `spec_entries` is non-empty; returns `$true`/`$false` with descriptive error messages

---

## Phase 3: User Story 1 — Core spec generation from transcript (P1) 🎯 MVP

**Goal**: An engineer with a transcript can run `ingest-transcript.ps1 -DryRun` to preview a manifest and then run without `-DryRun` to write spec files with correct frontmatter into existing categories.

**Independent test**: Run script on `quickstart.md` sample transcript → dry run prints table of 2–3 specs → full run writes `specs/<tier>/<category>/spec.md` files with correct YAML frontmatter, `status: draft`, `decision-mode: autonomous`

- [ ] T008 [P] [US1] Write tier signal vocabulary section in `.specify/templates/transcript-analysis-template.md` — include the full per-tier keyword table from research.md Decision 4 (all 19 tier/category signal rows)
- [ ] T009 [P] [US1] Write extraction guidance sections in `.specify/templates/transcript-analysis-template.md` — Step 1: meeting metadata extraction (date, participants, purpose); Step 2: decision/requirement/constraint extraction per signal vocabulary; Step 3: tier+category mapping rules; Step 4: gap detection instructions
- [ ] T010 [US1] Write `IngestionManifest` output schema and generation instructions in `.specify/templates/transcript-analysis-template.md` — include complete JSON schema from research.md Decision 3, fenced ` ```json ` block instruction, and field-level guidance for `spec_entries` and `new_categories`
- [ ] T011 [P] [US1] Implement `New-GeneratedSpec` function in `.specify/scripts/powershell/ingest-transcript.ps1` — accepts a `SpecEntry` and returns a `GeneratedSpec` object with rendered YAML frontmatter (all required fields per spec-system: `tier`, `category`, `spec-id`, `version: "1.0.0-draft"`, `status: draft`, `compliance-state: current`, `role-context.requested-by: "transcript-ingestion"`, `role-context.decision-mode: autonomous`) and body markdown (Executive Summary from `summary`, Decisions list, Requirements list, Constraints list) per data-model.md
- [ ] T012 [US1] Implement spec-writing loop in `.specify/scripts/powershell/ingest-transcript.ps1` — for each `SpecEntry` in manifest: resolve target path `specs/<tier>/<category>/spec.md`; skip with warning if file exists and `-Force` not set; otherwise create directory if needed and write `GeneratedSpec.FrontmatterYaml + GeneratedSpec.BodyMarkdown`; accumulate `IngestionResult` counters
- [ ] T013 [P] [US1] Implement dry-run table display in `.specify/scripts/powershell/ingest-transcript.ps1` — when `-DryRun` is set (and `-Json` is not), print formatted table with columns `TIER`, `CATEGORY`, `SPEC-ID`, `ACTION` and summary line; then `exit 0`
- [ ] T014 [US1] Implement text-mode `IngestionResult` summary output in `.specify/scripts/powershell/ingest-transcript.ps1` — when `-Json` is not set, print `[ingest-transcript] Complete: N created, N skipped, N failed` plus any warnings and errors, then exit 0 or 1 based on `IngestionResult.Success`

---

## Phase 4: User Story 2 — New category discovery (P2)

**Goal**: A transcript mentioning a concept with no matching category causes the tool to propose, validate, and register a new category in `_categories.yaml` and `specs.yaml`, then write the spec into the newly created directory.

**Independent test**: Run on a transcript containing "disaster-recovery" language → with `-Force`, tool creates `specs/business/disaster-recovery/spec.md`, adds entry to `specs/business/_categories.yaml`, increments `category-count` in `specs/specs.yaml`

- [ ] T015 [P] [US2] Implement `Test-CategoryNameValid` function in `.specify/scripts/powershell/ingest-transcript.ps1` — validates `category` against `^[a-z][a-z0-9-]+$`; validates `spec_id` against `^[a-z][a-z0-9-]{1,7}$`; checks `spec_id` is not already in `CategoryCatalog.SpecIds`; returns `$true`/`$false` with error text
- [ ] T016 [US2] Implement `Update-CategoryYaml` function in `.specify/scripts/powershell/ingest-transcript.ps1` — reads `specs/<tier>/_categories.yaml`; checks if `spec_id` already present (idempotent); if not, appends new entry (`name`, `spec-id`, `description`) and increments `category-count`; writes file back
- [ ] T017 [P] [US2] Implement `Update-SpecsYamlCategoryCount` function in `.specify/scripts/powershell/ingest-transcript.ps1` — reads `specs/specs.yaml`; finds the tier block by name; increments `category-count` value; writes file back (idempotent: reads current count, compares before writing)
- [ ] T018 [US2] Wire new-category flow in `.specify/scripts/powershell/ingest-transcript.ps1` — after manifest validation, for each entry in `manifest.new_categories`: call `Test-CategoryNameValid`; if `-Force` not set, prompt for confirmation or error in non-interactive mode; call `Update-CategoryYaml` then `Update-SpecsYamlCategoryCount`; create directory `specs/<tier>/<category>/`; accumulate `CategoriesCreated` count

---

## Phase 5: User Story 3 — Empty project bootstrap (P2)

**Goal**: Running on a fresh repo with no `_categories.yaml` files bootstraps the entire spec catalog from a single transcript — all references tier `_categories.yaml` files are created, all specs written, and a manifest file produced.

**Independent test**: Run on an empty `specs/` tree → all required `_categories.yaml` files are created, all specs written with correct frontmatter, `transcript-ingestion-manifest.md` written to the transcript's containing directory

- [ ] T019 [US3] Update `Build-CategoryCatalog` in `.specify/scripts/powershell/ingest-transcript.ps1` to handle missing `_categories.yaml` gracefully — if a tier directory exists but has no `_categories.yaml`, treat that tier as having zero categories (empty array for that tier) rather than throwing; if `specs/specs.yaml` is missing, use a built-in default tier list
- [ ] T020 [US3] Update `Update-CategoryYaml` in `.specify/scripts/powershell/ingest-transcript.ps1` to handle non-existent `_categories.yaml` — if file does not exist, write a bootstrap skeleton (`tier:`, `category-count: 1`, `categories:` with the first entry) instead of reading then appending
- [ ] T021 [P] [US3] Implement `Write-IngestionManifestFile` function in `.specify/scripts/powershell/ingest-transcript.ps1` — after all writes, create `transcript-ingestion-manifest.md` in same directory as the transcript file; record: source transcript path, run date, all specs created (tier/category/path), all new categories registered, skip and error counts

---

## Phase 6: User Story 4 — CI / machine-readable output (P3)

**Goal**: Running with `-Json` emits a valid JSON `IngestionResult` on stdout, with exit code 0 on full success or 1 on any failure — parseable by CI pipelines.

**Independent test**: `ingest-transcript.ps1 -TranscriptFile sample.md -Json | ConvertFrom-Json` succeeds and returns object with `success`, `specs_created`, `specs_skipped`, `specs_failed`, `specs` array matching the schema from contracts/ingest-transcript-cli.md

- [ ] T022 [P] [US4] Implement `-Json` `IngestionResult` output in `.specify/scripts/powershell/ingest-transcript.ps1` — when `-Json` is set (and `-DryRun` is not), serialize the final `IngestionResult` to the JSON schema defined in contracts/ingest-transcript-cli.md (fields: `success`, `dry_run`, `transcript_file`, `specs_created`, `specs_skipped`, `specs_failed`, `categories_created`, `errors`, `warnings`, `specs[]`) via `ConvertTo-Json -Compress`
- [ ] T023 [US4] Implement `-DryRun -Json` combined mode in `.specify/scripts/powershell/ingest-transcript.ps1` — when both flags set, emit JSON representation of the manifest preview (same schema with `dry_run: true`, all entries with `action: "would-create"` or `action: "would-skip"`) and exit 0
- [ ] T024 [US4] Enforce exit codes throughout `.specify/scripts/powershell/ingest-transcript.ps1` — audit all exit paths: `exit 0` only when `IngestionResult.SpecsFailed -eq 0` (skips are not failures); `exit 1` on: missing or unreadable transcript, unparseable manifest JSON, any `SpecsFailed > 0`, any failed prerequisite check

---

## Phase 7: Polish & Platform Registration

**Purpose**: Register the new capability in the platform spec tree; lint; end-to-end validation; tag

- [ ] T025 [P] Add `transcript-ingestion` category entry to `specs/platform/_categories.yaml` — entry must include `name: transcript-ingestion`, `spec-id: txin`, a description, and increment `category-count`
- [ ] T026 [P] Register `ingest-transcript.ps1` in `specs/specs.yaml` toolkit-components scripts section — add entry with `purpose`, `contracts.input`, `contracts.output`, `contracts.idempotent: true` per the toolkit-registration block in contracts/ingest-transcript-cli.md
- [ ] T027 [P] Create `specs/platform/transcript-ingestion/spec.md` — copy and promote the feature spec from `specs/platform/003-transcript-to-spec/spec.md`, update path references, set `status: ratified`, update `version-history`
- [ ] T028 Run PSScriptAnalyzer on `.specify/scripts/powershell/ingest-transcript.ps1` and fix all errors — `Invoke-ScriptAnalyzer -Path .specify/scripts/powershell/ingest-transcript.ps1`; zero issues must remain
- [ ] T029 End-to-end validation — run `ingest-transcript.ps1 -TranscriptFile specs/platform/003-transcript-to-spec/quickstart.md -DryRun` to confirm manifest output, then run without `-DryRun` on a scratch branch to confirm spec files are written correctly
- [ ] T030 Commit, push, and tag — `git tag spec/txin/1.0.0-draft` after T025–T029 are complete

---

## Dependencies

```
T001 ──┬──► T003
       ├──► T004 ──► T007 ──► T011 ──► T012 ──► T013 ──► T022 ──► T023 ──► T024
       ├──► T004 ──► T019 ──► T016 ──► T018               │
       ├──► T005 ──┘                                       └──► T014
       └──► T006 ──┘

T002 ──►  T008 ─┐
          T009 ─┴──► T010

T015 ──► T016 ──► T018
T017 ──────────► T018
T018 ──► T020 ──► T021

# US1 complete when: T010 + T012 + T014 done
# US2 complete when: T018 done
# US3 complete when: T019 + T020 + T021 done
# US4 complete when: T022 + T023 + T024 done
# Done when: T025 + T026 + T027 + T028 + T029 + T030 done
```

---

## Parallel Execution Examples

### US1 — Start in parallel after T001 and T002 complete

```
T003  ─── (help block in .ps1)
T004  ─── (Build-CategoryCatalog in .ps1)       ← start all 5 in parallel
T005  ─── (Get-TranscriptDocument in .ps1)
T006  ─── (ConvertFrom-IngestionManifest in .ps1)
T008  ─── (signal vocabulary in .md template)
T009  ─── (extraction guidance in .md template)
T011  ─── (New-GeneratedSpec in .ps1)
T013  ─── (dry-run display in .ps1)
```

### US2 — Start T015 and T017 in parallel after US1 is done

```
T015  ─── (Test-CategoryNameValid)
T017  ─── (Update-SpecsYamlCategoryCount)
```

### Phase 7 — Start T025, T026, T027 in parallel after T024

```
T025  ─── (_categories.yaml entry)
T026  ─── (specs.yaml registration)
T027  ─── (platform category spec.md)
```

---

## Implementation Strategy

**MVP**: Complete Phase 3 (US1) first — this delivers the core value (transcript → spec files for existing categories). US1 is independently testable with `quickstart.md` as the sample transcript.

**Phase ordering**:
1. Phase 1 + Phase 2 (unblock all stories)
2. Phase 3 US1 (MVP — core flow including dry-run and spec writing)
3. Phase 4 US2 (new category registration — enables full bootstrap)
4. Phase 5 US3 (bootstrap mode — needed for greenfield repos)
5. Phase 6 US4 (CI mode — needed for pipeline integration)
6. Phase 7 (registration + lint + tag)

**Key implementation notes** (from research.md):
- AI invocation is **out-of-band** — the script prints the rendered template + transcript; the human pastes the AI response back. The script only parses the returned JSON manifest. No API keys, no network calls.
- Idempotency is enforced at two levels: (1) existence check on spec file path before write; (2) `spec_id` dedup in `_categories.yaml` before append.
- `common.ps1` provides `Get-RepoRoot` and `$script:SpecTiers` — use these rather than hardcoding paths or tier lists.
- The template (`transcript-analysis-template.md`) is spec-interpreted: variation in AI output is expected and acceptable. The script validates the JSON structure, not the content values.
