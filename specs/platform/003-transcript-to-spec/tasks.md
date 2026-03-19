---
# YAML Frontmatter
tier: platform
category: transcript-ingestion
spec-id: txin
artifact-type: tasks
version: "2.0.0-draft"
description: "Task list for AI Transcript Ingestion — transcripttospecs agent, toolkit scripts, hysteresis matching, and three-phase execution model (REQ-021-024, NFR-005-006)"
created: 2026-03-17
last-updated: 2026-03-19

# Role Context (per governance v2.0.0)
role-context:
  declared-role: platform
  authority-scope: platform-meta-governance
  change-intent: "Phase 0-9 (v1.1.0-draft): initial agent, toolkit scripts, analysis template, hysteresis matching — all complete. Phase 10-17 (v2.0.0-draft): implement REQ-021-024 three-phase execution model (context banner, per-group markers, error resilience), NFR-005-006 parallel batching, Decision 9 privacy guardrail, Decision 10 failure-mode differentiation; update governing spec to v1.2.0-draft"
  upstream-snapshot:
    - spec-id: txin
      version: "1.1.0-draft"
    - spec-id: 003-transcript-to-spec
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
- [X] T017 test [US1] Smoke test using `quickstart.md` Q2 Planning Meeting walkthrough: invoke `@transcripttospecs` on a sample multi-tier transcript; verify grouping plan appears before writes; verify each output spec has `status: draft`, `requested-by: "transcripttospecs"`, `decision-mode: autonomous`; verify session summary

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
- [X] T021 test [US2] Smoke test: process a transcript proposing zero-friction CI/CD deployment against a stubbed `security/access-control` spec with a change-board approval MUST; verify conflict is surfaced; verify Write-with-flag output includes `conflict-flags:` in frontmatter

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
- [X] T025 test [US3] Smoke test: transcript adds two new requirements to a category with an existing spec; verify only net-new requirements appear as proposed; confirm; verify merged spec; re-run same transcript — verify no duplicate additions (idempotency, REQ-013)

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
- [X] T031 test [US4] Verification — Decision 7 worked example (plan.md T029): invoke agent on a stub transcript with only the cost-allocation tagging topic against existing platform categories; verify:
  - Agent classifies as CLOSE MATCH with `platform/governance` (NOT a new category)
  - Grouping plan entry shows `UPDATE specs/platform/governance/spec.md` with `~65% concept overlap` rationale
  - Agent does NOT propose `platform/cost-tagging` or any new platform category
- [X] T032 test [US4] Verification — AMBIGUOUS default bias (plan.md T030): invoke agent on stub transcript with only *"define a process for rotating platform team access credentials"* against platform tier; verify:
  - [X] Grouping plan shows inline A/B choice with A explicitly labeled as Default
  - [X] Confirming without entering B routes group as UPDATE, not NEW CATEGORY
  - [X] Agent does NOT call `register-category.ps1` for this group
- [X] T033 test [US4] Full smoke test (plan.md T031): invoke agent on `meetings/test-hysteresis-dr-2026-03-17.md`; verify all 7 checklist items:
  - [X] Group A (disaster-recovery) classified as NEW CATEGORY with condition (a) cited
  - [X] Group B (reserved-instance right-sizing) classified as CLOSE MATCH with `business/cost`
  - [X] Grouping plan shows `Closest evaluated: business/governance — rejected: distinct lifecycle phase`
  - [X] Grouping plan shows `merge-into governance` as a valid response option
  - [X] `merge-into governance` response reclassifies Group A as UPDATE; `register-category.ps1` NOT called
  - [X] Confirm-as-is path calls `register-category.ps1 -Tier business -CategoryName disaster-recovery -SpecId dr`
  - [X] Session summary shows 1 new category registered + 1 spec updated
- [X] T034 test [US4] Test `merge-into` shortcut in isolation: from a fresh session where agent proposes `business/disaster-recovery` as NEW CATEGORY, respond `merge-into governance`; verify agent does NOT call `register-category.ps1`; verify agent reads `specs/business/governance/spec.md` and enters US3 additive-update flow
- [X] T035 test [US4] Cleanup test artifacts — run plan.md cleanup commands:
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
- [X] T038 test [US5] Smoke test: remove one `_categories.yaml`; verify agent bootstraps it; verify all new specs are compliant; verify session summary distinguishes newly registered vs pre-existing categories

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
- [X] T044 [P] review [US1] Verify all generated spec files are human-readable in VS Code with no binary characters (NFR-003)
- [X] T045 test [US1] End-to-end session test: full transcript session (multi-tier, one conflict, one additive update, one new category with hysteresis evaluation) without leaving Copilot Chat (NFR-004); record session summary output

---

## Implementation Notes

- **T026–T029 are verification, not implementation**: classifier, hysteresis rule, and display requirements are already in `.github/agents/transcripttospecs.agent.md` (commit `9d68f7e`) — Phase 6 is verify-and-test only
- **No script changes required for hysteresis** (T026–T035): REQ-018/019/020 are agent-behavioral changes only; `register-category.ps1` and `write-spec.ps1` interfaces are unchanged
- **Parallel opportunities**: T001+T003, T004+T008, T006+T011, T027+T028 (independent agent section checks), T031+T032 (independent verification scenarios), T042+T043+T044 (NFR checks)
- **AMBIGUOUS default bias** (T028/T032): A (extend existing) is always the default — agent must require explicit B to split; this is the primary guard against category proliferation
- **merge-into shortcut** (T029/T034): any `merge-into <category>` response reclassifies as UPDATE and routes through Phase 5 existing-spec handling — no new script required
- **Phase 6 completion gate**: T033 all 7 items + T034 merge-into verified + T035 cleanup → T026–T035 markable `[X]`

---

## Phase 10: Three-Phase Execution Model — Agent Restructure (US1, P1) 🎯 NEW

**Context**: Phases 0–9 delivered the Steps 1–7 agent using a sequential per-step loop without explicit phase structure. REQ-021–024 and NFR-005–006 (added 2026-03-18) require a strict three-phase model: Phase 1 issues all reads as one parallel batch and posts a context banner; Phase 2 is plan + clarification with no writes; Phase 3 writes with per-group progress markers, parallel batching, and error resilience. All tasks in this phase modify `.github/agents/transcripttospecs.agent.md`.

**Independent Test**: Invoke `@transcripttospecs meetings/q2-planning-2026.md` in Copilot Chat. Verify: (1) "✅ Context loaded" banner with word count, tier/category/spec counts, and UPDATE candidates appears before any grouping plan; (2) grouping plan presented and agent **waits** for confirmation; (3) `▶ Processing N groups` header starts Phase 3; (4) each group has a `▶` start marker before tool calls and a `✓` or `✗` completion marker after; (5) a failing group posts `✗` and the remaining groups still execute; (6) session summary ends with the "📝 All output specs are status: draft" reminder.

- [X] T046 [US1] Restructure `.github/agents/transcripttospecs.agent.md` Steps 1–2 into an explicit **"Phase 1 — Context Build"** section; replace the sequential read loop with a single instruction block stating all reads — transcript file, `specs/specs.yaml`, all tier `_categories.yaml` files, and all `spec.md` files for UPDATE-candidate categories — MUST be issued as one parallel tool call batch per NFR-005; retain post-read metadata extraction (date, participants, purpose) as an in-phase analysis step
- [X] T047 [US1] Add "Context loaded" banner posting instruction immediately after Phase 1 parallel reads complete in `.github/agents/transcripttospecs.agent.md`; use the exact five-line block from `contracts/ingest-transcript-cli.md` (✅ header, `└─ Transcript`, `└─ Tiers`, `└─ Categories`, `└─ Existing specs loaded`, `└─ UPDATE candidates` lines); banner MUST appear in chat before any extraction or grouping work begins per REQ-022
- [X] T048 [US1] Add Phase 1 abort handling in `.github/agents/transcripttospecs.agent.md` for file-not-found, unreadable, and empty transcript conditions; use the exact `❌ Phase 1 error: <reason>. No specs will be written.` format from `contracts/ingest-transcript-cli.md`; after posting the error the agent MUST stop — no extraction, no registry updates, no spec writes per Decision 10
- [X] T049 [US1] Add zero-signal early-exit handling at the start of Phase 2 in `.github/agents/transcripttospecs.agent.md`; if extraction yields zero items mappable to the six-tier hierarchy using the tier signal vocabulary, post the `⚠️ No tier-relevant content found` block from `contracts/ingest-transcript-cli.md` and ask for confirmation before ending the session; do NOT silently exit per Decision 10
- [X] T050 [US1] Restructure `.github/agents/transcripttospecs.agent.md` Step 6 into an explicit **"Phase 3 — Parallel Write Execution"** section; add gate instruction that Phase 3 MUST NOT begin until the user has confirmed the grouping plan from Phase 2; add `▶ Processing N groups` header instruction (N = confirmed group count) that MUST be posted immediately before the first group is processed per REQ-021 and REQ-023
- [X] T051 [US1] Add per-group **▶ start marker** instruction in the Phase 3 section of `.github/agents/transcripttospecs.agent.md`; the agent MUST post `▶ [tier/category] — new | update | skip` to chat before invoking any file tool or script call for that group per REQ-023
- [X] T052 [US1] Add per-group **✓/✗ completion marker** instruction in the Phase 3 section of `.github/agents/transcripttospecs.agent.md`; after a group completes post `✓ [tier/category] — created | updated | skipped` on success, or `✗ [tier/category] — error: <reason>` on failure; use the exact formats from `contracts/ingest-transcript-cli.md` per REQ-023
- [X] T053 [US1] Add Phase 3 error-resilience instruction in `.github/agents/transcripttospecs.agent.md`; exit code 1 from `write-spec.ps1` MUST produce a `✗` marker for that group and the agent MUST continue to the next group without aborting the session; exit code 2 (unexpected skip) MUST also produce a `✗` marker; all `✗` entries MUST be consolidated in the Step 7 session summary per REQ-024
- [X] T054 [US1] Add Phase 3 parallel write-batching instruction in `.github/agents/transcripttospecs.agent.md`; groups whose `spec.md` output paths do not overlap AND whose `_categories.yaml` registry targets do not overlap MUST be batched as parallel tool calls per NFR-006; add same-tier NEW CATEGORY serialization caveat: multiple `register-category.ps1` calls for the SAME tier MUST be issued sequentially to prevent double-increment of `category-count` in `specs.yaml`
- [X] T055 [US1] Add **Privacy Guardrail** constraint block in `.github/agents/transcripttospecs.agent.md` (include in Constraints section); the agent MUST NOT reproduce raw transcript excerpts, speaker names, or personal attribution in any generated spec file; all generated spec content MUST be expressed as requirements, constraints, and decisions only — no narrative, no attributed quotation per Decision 9
- [X] T056 [P] [US1] Add a **Phase 1 / Phase 2 / Phase 3 execution model overview** section at the top of `.specify/templates/transcript-analysis-template.md` (before Section 1 — Tier Signal Vocabulary) with a compact three-row table summarising Phase 1 (parallel reads → context banner), Phase 2 (plan + Q&A + conflict resolution, no writes), and Phase 3 (per-group ▶/✓/✗ markers, parallel write batching); makes the template self-contained as an agent reference document

---

## Phase 11: Three-Phase — US2 Conflict Phase 3 Integration (P1)

**Goal**: Block / Write-with-flag / Propose-amendment outcomes are wired into Phase 3 marker flow. Blocked groups post `✗` and proceed to next group; successful writes post `✓`; amendment proposals are annotated in the `✓` marker.

**Independent Test**: Process a transcript that conflicts with an existing higher-authority spec. Verify: Block choice → `✗ [tier/category] — error: blocked, conflict with <upstream-spec-id>` and remaining groups continue; Write-with-flag → `✓` marker + `conflict-flags:` in frontmatter; Propose amendment → `✓` marker with `(amendment: specs/<path>.md)` annotation.

- [X] T057 [US2] Update the **Conflict Resolution** section in `.github/agents/transcripttospecs.agent.md` to wire each resolution outcome into the Phase 3 marker system: (1) Block → post `✗ [tier/category] — error: blocked, conflict with <upstream-spec-id>` and continue to next group (replacing the old "log to session summary" instruction); (2) Write-with-flag → call `write-spec.ps1` with populated `conflict-flags` JSON, then post the standard `✓`/`✗` marker based on exit code; (3) Propose amendment → call `write-spec.ps1` for the new spec, write the amendment file directly, then post `✓` marker
- [X] T058 [US2] Add amendment proposal path annotation to the Phase 3 `✓` marker in `.github/agents/transcripttospecs.agent.md`; when option 3 is chosen the `✓` MUST include `(amendment: specs/<upstream-tier>/<upstream-category>/spec-amendment-<spec-id>.md)` so the amendment file location is visible in the chat session summary

---

## Phase 12: Three-Phase — US3 Additive Update Phase 3 Integration (P2)

**Goal**: UPDATE groups post `▶ — update` start markers and `✓ — updated` completion markers. SKIP groups (fully covered) post `✓ — skipped` without calling `write-spec.ps1`. Merged body must be complete.

**Independent Test**: Process a transcript that adds 2 requirements to an existing spec. Verify: (1) `▶ [tier/category] — update` start marker before write call; (2) `write-spec.ps1 -Force` called with complete merged body; (3) for fully-covered content, `✓ [tier/category] — skipped (already covered)` with no write; (4) skipped count increments in session summary.

- [X] T059 [US3] Update the **Existing Spec Handling** section in `.github/agents/transcripttospecs.agent.md` to use Phase 3 markers: add instruction that before calling `write-spec.ps1 -Force` the agent MUST post `▶ [tier/category] — update` start marker; after the write call post `✓ [tier/category] — updated` or `✗` on error; reinforce that `-BodyMarkdown` MUST receive the COMPLETE merged body (original + additions), not a partial or diff body
- [X] T060 [US3] Add SKIP group handling in the Phase 3 section of `.github/agents/transcripttospecs.agent.md`; when an UPDATE group has no additive items the agent MUST post `✓ [tier/category] — skipped (already covered)` without invoking `write-spec.ps1`; this outcome MUST increment the "skipped" counter in the Step 7 session summary, not the "created" or "updated" counter

---

## Phase 13: Three-Phase — US4 New Category Phase 3 Integration (P2)

**Goal**: NEW CATEGORY groups display `[new category]` in the `▶` start marker. `register-category.ps1` is confirmed before `write-spec.ps1`. Same-tier registrations are never parallelized in Phase 3 batching.

**Independent Test**: Process a transcript introducing a concept with no existing same-tier match. Verify: `▶ [tier/category] — create [new category]` start marker; `register-category.ps1` invoked and exit 0 confirmed before `write-spec.ps1`; exit 1 from `register-category.ps1` → `✗` marker, `write-spec.ps1` skipped; two NEW CATEGORY groups for the same tier are processed sequentially despite NFR-006.

- [X] T061 [US4] Add `[new category]` annotation to Phase 3 `▶` start marker for NEW CATEGORY groups in `.github/agents/transcripttospecs.agent.md`; format: `▶ [tier/category] — create [new category]`; add instruction that `register-category.ps1` MUST be called and exit 0 confirmed before `write-spec.ps1`; exit 1 from `register-category.ps1` MUST produce a `✗` marker and skip `write-spec.ps1` for that group
- [X] T062 [US4] Add same-tier parallel serialization caveat to the Phase 3 batching section of `.github/agents/transcripttospecs.agent.md`; NEW CATEGORY groups for the SAME tier MUST be processed sequentially (never batched in parallel) to prevent double-increment of `category-count` in `specs.yaml`; groups for DIFFERENT tiers that have non-overlapping file paths and registry targets MAY still be batched per NFR-006

---

## Phase 14: Three-Phase — US5 Bootstrap Phase 1 Integration (P3)

**Goal**: Phase 1 handles absent `_categories.yaml` files gracefully (treat as 0 categories, no abort). Session summary distinguishes newly registered categories from pre-existing ones.

**Independent Test**: Run `transcripttospecs` on a branch where all `_categories.yaml` files are absent. Verify: Phase 1 completes; context banner shows 0 categories, no Phase 1 abort; after Phase 3, `register-category.ps1` creates bootstrap skeletons; session summary shows "N new categories registered" with tier/category labels.

- [X] T063 [US5] When merging Steps 1–2 into the Phase 1 section of `.github/agents/transcripttospecs.agent.md` (via T046), confirm that the existing "do NOT pre-create the file" behavior is preserved: if a tier `_categories.yaml` file is absent the agent MUST treat that tier as having 0 registered categories and continue Phase 1 without aborting; only the absence of `specs/specs.yaml` warrants a Phase 1 abort; `_categories.yaml` skeletons are created by `register-category.ps1` in Phase 3, never by the agent in Phase 1 — verify this is still correct after T046's restructure
- [X] T064 [US5] Confirm the Step 7 session summary instruction in `.github/agents/transcripttospecs.agent.md` includes a "new categories registered: N" count that explicitly lists newly created tier/category pairs and distinguishes them from pre-existing ones; add this distinction if absent

---

## Phase 15: Governing Spec Promotion and Final Compliance Pass

**Purpose**: Incorporate all new phase-model requirements into the authoritative governing spec; add missing session-summary reminder; validate full requirement coverage in the agent.

- [X] T065 [P] Update `specs/platform/transcript-ingestion/spec.md` — add REQ-021 (three-phase sequential model, write-gate before Phase 3), REQ-022 (Phase 1 parallel reads + context banner with exact format), REQ-023 (Phase 3 `▶ Processing N groups` header, per-group `▶` start and `✓`/`✗` completion markers), REQ-024 (Phase 3 per-group error resilience — one failing group must not halt others); update NFR-005 to read "Phase 1 file reads MUST be issued as a single parallel tool call batch" (supersedes the v1.1.0-draft NFR-005 cross-tier consistency requirement); add NFR-006 "Phase 3 write operations targeting non-overlapping file paths and registry entries MUST be batched as parallel tool calls"; add Decision 9 (privacy guardrail) and Decision 10 (failure-mode differentiation) to Constraints; bump `version` to `"1.2.0-draft"` with a `version-history` entry dated `2026-03-19` summarising all additions
- [X] T066 [P] Confirm the Step 7 session summary section in `.github/agents/transcripttospecs.agent.md` ends with `📝 All output specs are status: draft and require human review before promotion`; add the line verbatim if absent per REQ-014 (added in 2026-03-18 clarification session)
- [X] T067 Cross-check `.github/agents/transcripttospecs.agent.md` against `specs/platform/003-transcript-to-spec/spec.md` REQ-001 through REQ-024 and NFR-001 through NFR-006; for each requirement confirm at least one explicit agent instruction covers it; mark any unaddressed requirements as inline `<!-- GAP: REQ-XXX — <brief note> -->` comments in the file for follow-up

---

## Phase 10–15 Task Summary

| Phase | User Story | Tasks | Parallelizable |
|---|---|---|---|
| 10 | US1 (P1) | T046–T056 (11 tasks) | T056 [P] — different file (template.md) |
| 11 | US2 (P1) | T057–T058 (2 tasks) | — |
| 12 | US3 (P2) | T059–T060 (2 tasks) | — |
| 13 | US4 (P2) | T061–T062 (2 tasks) | — |
| 14 | US5 (P3) | T063–T064 (2 tasks) | — |
| 15 | — (Polish) | T065–T067 (3 tasks) | T065+T066 [P] — different files |

**New task count**: 22 (T046–T067)  
**Total task count (all phases)**: 67  
**Dependency**: Phase 10 (T046–T055) is a prerequisite for Phases 11–14; all Phase 3 marker wiring in US2–US5 depends on the Phase 3 infrastructure added in T050–T054.

**MVP scope for new requirements**: Complete Phase 10 (T046–T056) to deliver US1 three-phase execution end-to-end before integrating US2–US5 Phase 3 markers.
