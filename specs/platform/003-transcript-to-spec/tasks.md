---
# YAML Frontmatter
tier: platform
category: transcript-ingestion
spec-id: txin
artifact-type: tasks
version: "1.1.0-draft"
description: "Task list for AI Transcript Ingestion — transcripttospecs agent + hysteresis category matching (plan v1.2.0-draft)"
created: 2026-03-17
last-updated: 2026-03-17

# Role Context (per governance v2.0.0)
role-context:
  declared-role: platform
  authority-scope: platform-meta-governance
  change-intent: "Implement transcripttospecs agent, toolkit scripts, analysis template, and hysteresis category matching (REQ-018/019/020)"
  upstream-snapshot:
    - spec-id: txin
      version: "1.0.0-draft"
    - spec-id: spec
      version: "1.0.0-draft"
    - spec-id: artifact
      version: "1.0.0-draft"
  cascade-run-id: null
  decision-mode: reviewed
  requested-by: "Platform Dev"
  approved-by: null
---

# Tasks: AI Transcript Ingestion — transcripttospecs Agent

**Input**: `specs/platform/003-transcript-to-spec/` (spec.md v1.0.0-draft, plan.md v1.1.0-draft)
**Prerequisites**: spec.md ✅  plan.md ✅  research.md ✅  data-model.md ✅  contracts/ingest-transcript-cli.md ✅
**Tier**: platform

---

## Format: `[ID] [P?] [Story] [Type] Description`

- **[P]**: Can run in parallel (no file-level dependency on another in-flight task)
- **[Story]**: US1–US5 maps to User Stories 1–5 in spec.md
- **[Type]**: `artifact-gen` (create/update file), `review` (human validation), `test` (smoke/validation)

---

## Phase 0: Foundation — Analysis Template & Category Catalog Load (US1, US3, US4, US5)

**Goal**: Deliver the tier-signal vocabulary template and the catalog-loading step that every subsequent agent behavior depends on.

**Review Checkpoint**: T002 review must pass before any Phase 1 work begins.

- [X] T001 artifact-gen [US1] Create `.specify/templates/transcript-analysis-template.md` — include full tier signal vocabulary (one sub-section per tier), signal keywords per tier, example phrases, mapping guidance, and a blank `IngestionManifest` JSON skeleton the agent fills at runtime
- [X] T002 review [US1] Validate `transcript-analysis-template.md` against REQ-003: each of the 6 tiers has signal keywords; JSON skeleton matches `IngestionManifest` fields in `data-model.md`; template contains no implementation details
- [X] T003 [P] artifact-gen [US1] Confirm `specs/specs.yaml` and all `specs/<tier>/_categories.yaml` files exist and are parseable; document any missing `_categories.yaml` skeletons needed for US5

---

## Phase 1: Toolkit Scripts — register-category.ps1 (US1, US4, US5)

**Goal**: Deliver a working, PSScriptAnalyzer-clean `register-category.ps1` per contract in `contracts/ingest-transcript-cli.md`.

**Review Checkpoint**: T006 exits 0 with PSScriptAnalyzer; T007 passes all acceptance checks.

- [X] T004 artifact-gen [US1] Create `.specify/scripts/powershell/register-category.ps1`:
  - Parameters: `-Tier` (required), `-CategoryName` (required), `-SpecId` (required), `-Description` (required)
  - Validates: tier is one of 6 known values; spec-id matches `^[a-z][a-z0-9-]{1,7}$`; spec-id is globally unique across all `_categories.yaml` files
  - Idempotent: if spec-id already exists, exits 0 silently
  - On success: appends entry to `specs/<tier>/_categories.yaml` (creates skeleton if missing); increments `category-count` in `specs/specs.yaml`
  - Non-zero exit on any validation failure with a descriptive error message (REQ-016)
- [X] T005 review [US1] Validate `register-category.ps1` against contract (parameters, exit codes, idempotency); check edge cases: duplicate spec-id, invalid tier, spec-id at min/max length boundary
- [X] T006 test [US1] Run `Invoke-ScriptAnalyzer register-category.ps1` — must exit with 0 errors (REQ-015, NFR-001)
- [X] T007 test [US1] Smoke test: register new category `business/test-reg` spec-id `tr`; verify `_categories.yaml` entry and `specs.yaml` count; re-run (idempotent); verify count did not change; then clean up test entry

---

## Phase 2: Toolkit Scripts — write-spec.ps1 (US1, US2, US3)

**Goal**: Deliver a working, PSScriptAnalyzer-clean `write-spec.ps1` per contract in `contracts/ingest-transcript-cli.md`.

**Review Checkpoint**: T011 exits 0 with PSScriptAnalyzer; T012 passes all acceptance checks.

- [X] T008 artifact-gen [US1] Create `.specify/scripts/powershell/write-spec.ps1`:
  - Parameters: `-Tier`, `-Category`, `-SpecId`, `-FrontmatterJson`, `-BodyMarkdown`, `-Force` (switch)
  - Enforces `status: draft` regardless of what `-FrontmatterJson` provides (REQ-010)
  - Enforces `requested-by: "transcripttospecs"` and `decision-mode: autonomous` (REQ-011)
  - Without `-Force`: errors if `spec.md` already exists
  - With `-Force`: overwrites existing `spec.md` (required for additive updates in US3)
  - Injects `conflict-flags:` frontmatter block when `FrontmatterJson` contains `conflict_flags` array (REQ-012)
  - Creates parent directory if it does not exist; validates JSON before writing
  - Non-zero exit on missing required params or validation failure (REQ-016)
- [X] T009 review [US1] Validate `write-spec.ps1` against contract; check: `status: draft` enforcement, `conflict-flags:` injection, `-Force` overwrite behavior, directory creation, exit codes
- [X] T010 [P] review [US3] Verify `-Force` is used for merged bodies only (original content + new items appended), never for wholesale overwrites that lose existing content; document merge contract
- [X] T011 test [US1] Run `Invoke-ScriptAnalyzer write-spec.ps1` — must exit with 0 errors (REQ-015, NFR-001)
- [X] T012 test [US1] Smoke test: write a new spec to `specs/business/test-write/spec.md`; verify all YAML frontmatter fields; verify `status: draft`; verify `requested-by: "transcripttospecs"`; clean up

---

## Phase 3: Agent Mode — US1 Core Flow (Multi-tier Spec Generation)

**Goal**: Deliver the `transcripttospecs` agent handling the standard multi-tier analysis-to-write session.

**Review Checkpoint**: T017 smoke test uses the Q2 Planning Meeting example from `quickstart.md`.

- [X] T013 artifact-gen [US1] Create/update `.github/agents/transcripttospecs.agent.md` — implement Steps 1–6:
  - **Step 1**: Accept transcript file path; read file; validate non-empty (REQ-001)
  - **Step 2**: Load category catalog — read `specs.yaml` + all `_categories.yaml` (REQ-002); build in-memory `CategoryCatalog` per `data-model.md`
  - **Step 3**: Extract decisions/requirements/constraints using tier signal vocabulary from `transcript-analysis-template.md` (REQ-003); produce draft `IngestionManifest` JSON
  - **Step 4**: Present proposed grouping plan — one entry per tier-category pair; wait for explicit user confirmation before any file operations (REQ-004)
  - **Step 5**: Ask up to 5 clarifying questions for unresolvable topics, one at a time (REQ-005)
  - **Step 6**: For each proposed spec, check all higher-authority tier specs for normative conflicts; for each conflict pause and present Block / Write-with-flag / Propose amendment options (REQ-007); honor user choice per conflict before continuing
- [X] T014 review [US1] Validate agent Steps 1–6 against US1 acceptance criteria: grouping plan before any writes; max 5 clarifying questions; correct YAML frontmatter in output; session summary lists every action (REQ-014)
- [X] T015 [P] review [US1] Verify agent never writes a file before user confirms grouping plan (REQ-004); verify agent never embeds API keys or makes direct LLM API calls from scripts (Constraints)
- [X] T016 [P] artifact-gen [US1] Register the `transcript-ingestion` platform category: run `register-category.ps1 -Tier platform -CategoryName "Transcript Ingestion" -SpecId txin -Description "AI-assisted meeting transcript ingestion for automatic spec generation"`; verify `_categories.yaml` entry
- [ ] T017 test [US1] Smoke test using `quickstart.md` Q2 Planning Meeting walkthrough: invoke `@transcripttospecs` on a sample multi-tier transcript; verify grouping plan appears before writes; verify each output spec has `status: draft`, `requested-by: "transcripttospecs"`, `decision-mode: autonomous`; verify session summary

---

## Phase 4: Agent Mode — US2 Conflict Detection & Resolution

**Goal**: Agent correctly surfaces normative conflicts with higher-tier specs and honors all three resolution choices.

**Review Checkpoint**: T021 smoke test reproduces the CI/CD vs security/access-control conflict from US2.

- [X] T018 artifact-gen [US2] Extend agent Step 6 with full conflict detection and resolution:
  - Conflict definition: a MUST/MUST NOT/SHALL/SHALL NOT in a higher-authority tier spec directly contradicting a proposed requirement (REQ-007)
  - Present conflict with: upstream spec-id, version, violated requirement reference, proposed spec name
  - Choice 1 (Block): log to session summary, skip write
  - Choice 2 (Write-with-flag): pass `conflict_flags` array into `write-spec.ps1 -FrontmatterJson`; verify output has `conflict-flags:` frontmatter + `## ⚠️ Conflict Flags` inline section (REQ-012)
  - Choice 3 (Propose amendment): write draft spec AND generate companion amendment proposal at `specs/<upstream-tier>/<upstream-category>/spec-amendment-<new-spec-id>.md`
- [X] T019 review [US2] Validate against US2 acceptance criteria: correct upstream spec-id/version/requirement cited; all three choices honored; Write-with-flag output has correct frontmatter block; amendment proposal targets the correct upstream spec
- [X] T020 [P] review [US2] Verify conflict resolution is always interactive — no silent skip, no silent block (Constraints: "Conflict resolution MUST be per-conflict and interactive")
- [ ] T021 test [US2] Smoke test: process a transcript proposing zero-friction CI/CD deployment against a stubbed `security/access-control` spec with a change-board approval MUST; verify conflict is surfaced; verify Write-with-flag output includes `conflict-flags:` in frontmatter

---

## Phase 5: Agent Mode — US3 Additive Update to Existing Spec

**Goal**: Agent reads existing specs, identifies net-new content, and merges rather than overwrites.

**Review Checkpoint**: T025 smoke test verifies the merge contract from T010 in practice.

- [X] T022 artifact-gen [US3] Extend agent with existing-spec handling (REQ-008):
  - Read existing `spec.md` fully when transcript maps to a known category
  - Additive check: a transcript item is additive if it is not semantically equivalent to any item already in the existing spec's Requirements or Constraints sections
  - If additive: build merged body (original content + proposed additions appended to Requirements section); present additions in chat for confirmation; call `write-spec.ps1 -Force` with complete merged body on confirm
  - If not additive: skip with a chat note (no write)
- [X] T023 review [US3] Validate against US3 acceptance criteria: no wholesale overwrite; skips when fully covered; requires confirmation before any change; merged body preserves all original content
- [X] T024 [P] review [US3] Cross-check that agent's merged body construction and `write-spec.ps1 -Force` (T010 contract) agree — no data-loss scenario possible at the handoff point
- [ ] T025 test [US3] Smoke test: transcript adds two new requirements to a category with an existing spec; verify only net-new requirements appear as proposed; confirm; verify merged spec; re-run same transcript — verify no duplicate additions (idempotency, REQ-013)

---

## Phase 6: Agent Mode — US4 Hysteresis Category Matching (REQ-018/019/020)

**Goal**: Verify the pre-implemented hysteresis classifier in `.github/agents/transcripttospecs.agent.md` (commit `9d68f7e`) is complete per REQ-018/019/020; run three verification procedures from plan.md Phase 2.

**Status**: T026–T029 are agent-file verification tasks (classifier already written). T030–T035 are test execution tasks.

**Completion Gate**: All 7 checklist items in T033 pass + T034 merge-into verified + T035 cleanup done.

- [X] T026 review [US4] Pre-implementation state audit — read `.github/agents/transcripttospecs.agent.md` and confirm all 6 sections exist per plan.md audit table:
  - (1) 4-tier classifier table in Step 3 with EXACT / CLOSE / AMBIGUOUS / NO MATCH rows
  - (2) Hysteresis rule in Step 3 with conditions (a), (b), (c) explicitly listed
  - (3) AMBIGUOUS A/B inline choice in Step 5 with Option A labeled as Default
  - (4) CLOSE MATCH inline rationale format in Step 5
  - (5) "Why a new category" + "Closest existing category considered" fields in New Category Discovery
  - (6) `merge-into <existing-category>` redirect handling in New Category Discovery
- [X] T027 review [US4] Verify 4-tier classifier content (REQ-018): confirm Step 3 rows state: EXACT MATCH → UPDATE; CLOSE MATCH (≥60% threshold explicitly stated) → UPDATE with rationale; AMBIGUOUS (different lifecycle/actor/enforcement boundary) → A/B flag; NO MATCH (different primary domain) → NEW CATEGORY candidate
- [X] T028 review [US4] Verify hysteresis bias rule content (REQ-019): confirm Step 3 includes MUST NOT language; confirm all three split conditions are present and distinct: (a) lifecycle phase, (b) actor/authority boundary, (c) zero normative overlap + radical scope expansion; no condition missing or conflated
- [X] T029 review [US4] Verify grouping plan display content (REQ-020): confirm Step 5 shows CLOSE MATCH inline rationale; AMBIGUOUS A/B with "Default: A" explicitly labeled; NEW CATEGORY shows closest evaluated category + hysteresis condition(s); New Category Discovery accepts `merge-into <category>` and redirects to UPDATE flow
- [X] T030 artifact-gen [US4] Create test transcript `meetings/test-hysteresis-dr-2026-03-17.md` using the exact content from plan.md Phase 2 T031 Test Transcript section (Q1 Business Resilience Review — Alice/Bob/Carol; DR strategy RPO/RTO/failover runbook + reserved-instance right-sizing)
- [ ] T031 test [US4] Verification — Decision 7 worked example (plan.md T029): invoke agent on a stub transcript with only the cost-allocation tagging topic against existing platform categories; verify:
  - Agent classifies as CLOSE MATCH with `platform/governance` (NOT a new category)
  - Grouping plan entry shows `UPDATE specs/platform/governance/spec.md` with `~65% concept overlap` rationale
  - Agent does NOT propose `platform/cost-tagging` or any new platform category
- [ ] T032 test [US4] Verification — AMBIGUOUS default bias (plan.md T030): invoke agent on stub transcript with only *"define a process for rotating platform team access credentials"* against platform tier; verify:
  - [ ] Grouping plan shows inline A/B choice with A explicitly labeled as Default
  - [ ] Confirming without entering B routes group as UPDATE, not NEW CATEGORY
  - [ ] Agent does NOT call `register-category.ps1` for this group
- [ ] T033 test [US4] Full smoke test (plan.md T031): invoke agent on `meetings/test-hysteresis-dr-2026-03-17.md`; verify all 7 checklist items:
  - [ ] Group A (disaster-recovery) classified as NEW CATEGORY with condition (a) cited
  - [ ] Group B (reserved-instance right-sizing) classified as CLOSE MATCH with `business/cost`
  - [ ] Grouping plan shows `Closest evaluated: business/governance — rejected: distinct lifecycle phase`
  - [ ] Grouping plan shows `merge-into governance` as a valid response option
  - [ ] `merge-into governance` response reclassifies Group A as UPDATE; `register-category.ps1` NOT called
  - [ ] Confirm-as-is path calls `register-category.ps1 -Tier business -CategoryName disaster-recovery -SpecId dr`
  - [ ] Session summary shows 1 new category registered + 1 spec updated
- [ ] T034 test [US4] Test `merge-into` shortcut in isolation: from a fresh session where agent proposes `business/disaster-recovery` as NEW CATEGORY, respond `merge-into governance`; verify agent does NOT call `register-category.ps1`; verify agent reads `specs/business/governance/spec.md` and enters US3 additive-update flow
- [ ] T035 test [US4] Cleanup test artifacts — run plan.md cleanup commands:
  ```powershell
  Remove-Item specs/business/disaster-recovery -Recurse -Force -ErrorAction SilentlyContinue
  Remove-Item meetings/test-hysteresis-dr-2026-03-17.md -ErrorAction SilentlyContinue
  git checkout HEAD -- specs/business/_categories.yaml specs/specs.yaml
  ```
  Verify no uncommitted changes remain in `specs/business/` or `specs/specs.yaml`

---

## Phase 7: Agent Mode — US5 Empty Project Bootstrap

**Goal**: Agent handles a repo with no existing category specs and bootstraps all `_categories.yaml` files correctly.

- [X] T036 artifact-gen [US5] Extend agent Step 2 catalog load: if a tier `_categories.yaml` is missing, create a skeleton (tier name, `categories: []`, `category-count: 0`) before proceeding (REQ-002)
- [X] T037 review [US5] Validate bootstrap behavior: agent does not error on missing `_categories.yaml`; skeletons comply with the schema used by `register-category.ps1`
- [ ] T038 test [US5] Smoke test: remove one `_categories.yaml`; verify agent bootstraps it; verify all new specs are compliant; verify session summary distinguishes newly registered vs pre-existing categories

---

## Phase 8: Platform Spec Registration & Deliverable Audit

**Goal**: Confirm all deliverables from spec.md Deliverables table exist on disk.

- [X] T039 [P] artifact-gen [US1] Verify (or create) `specs/platform/transcript-ingestion/spec.md` — must have compliant frontmatter (`tier: platform`, `category: transcript-ingestion`, `spec-id: txin`, `status: draft`)
- [X] T040 [P] review [US1] Cross-check all 6 deliverables in spec.md Deliverables table are present:
  - `.github/agents/transcripttospecs.agent.md`
  - `.specify/templates/transcript-analysis-template.md` ← T001
  - `.specify/scripts/powershell/register-category.ps1` ← T004
  - `.specify/scripts/powershell/write-spec.ps1` ← T008
  - `specs/platform/transcript-ingestion/spec.md` ← T039
  - `specs/platform/003-transcript-to-spec/data-model.md`
- [X] T041 review [US1] Verify `contracts/ingest-transcript-cli.md` parameter signatures match the actual implemented scripts after T004 and T008; update contract doc if any parameter name or default drifted

---

## Phase 9: Cross-Cutting Validation (All Stories)

**Goal**: NFR compliance and full end-to-end session pass.

- [X] T042 [P] test [US1] Run PSScriptAnalyzer across all `.ps1` files in `.specify/scripts/powershell/` — zero errors required (NFR-001)
- [X] T043 [P] test [US1] Time each toolkit script: `register-category.ps1` and `write-spec.ps1` must complete in under 10 seconds per call (NFR-002, REQ-017)
- [ ] T044 [P] review [US1] Verify all generated spec files are human-readable in VS Code with no binary characters (NFR-003)
- [ ] T045 test [US1] End-to-end session test: full transcript session (multi-tier, one conflict, one additive update, one new category with hysteresis evaluation) without leaving Copilot Chat (NFR-004); record session summary output

---

## Implementation Notes

- **T026–T029 are verification, not implementation**: classifier, hysteresis rule, and display requirements are already in `.github/agents/transcripttospecs.agent.md` (commit `9d68f7e`) — Phase 6 is verify-and-test only
- **No script changes required for hysteresis** (T026–T035): REQ-018/019/020 are agent-behavioral changes only; `register-category.ps1` and `write-spec.ps1` interfaces are unchanged
- **Parallel opportunities**: T001+T003, T004+T008, T006+T011, T027+T028 (independent agent section checks), T031+T032 (independent verification scenarios), T042+T043+T044 (NFR checks)
- **AMBIGUOUS default bias** (T028/T032): A (extend existing) is always the default — agent must require explicit B to split; this is the primary guard against category proliferation
- **merge-into shortcut** (T029/T034): any `merge-into <category>` response reclassifies as UPDATE and routes through Phase 5 existing-spec handling — no new script required
- **Phase 6 completion gate**: T033 all 7 items + T034 merge-into verified + T035 cleanup → T026–T035 markable `[X]`
