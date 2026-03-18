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
  change-intent: "Implement transcript-to-specs VS Code agent mode + toolkit scripts (register-category.ps1, write-spec.ps1) + signal vocabulary template + platform category registration"
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
**Prerequisites**: plan.md, spec.md, research.md, data-model.md  
**Tier**: platform | **Spec ID**: txin | **Branch**: `003-transcript-to-spec`

---

## Format: `[ID] [P?] [Story?] Description with file path`

- **[P]**: Parallelizable — different files or independent functions, no incomplete dependencies
- **[US#]**: Story label — maps to user stories in spec.md
- No test tasks — TDD not requested in spec

---

## Phase 1: Scaffolding

**Purpose**: Create skeleton files for all deliverable artifacts before any logic is implemented

- [ ] T001 Create `.github/agents/transcript-to-specs.md` with YAML frontmatter (`name`, `description`, `tools`, `version`) and top-level section headings: Overview, Invocation, Workflow, Conflict Resolution, Toolkit Script Integration, Constraints
- [ ] T002 [P] Create `.specify/templates/transcript-analysis-template.md` with frontmatter (`tier: platform`, `category: transcript-ingestion`, `spec-id: txin`, `artifact-type: template`, `execution-mode: spec-interpreted`) and top-level section headings: Purpose, Tier Signal Vocabulary, Extraction Guidance, Grouping Rules, Output Format
- [ ] T003 [P] Create `.specify/scripts/powershell/register-category.ps1` with `CmdletBinding` param block (`-Tier`, `-CategoryName`, `-SpecId`, `-Description`), `$ErrorActionPreference = 'Stop'`, and `. $PSScriptRoot/common.ps1` source line
- [ ] T004 [P] Create `.specify/scripts/powershell/write-spec.ps1` with `CmdletBinding` param block (`-Tier`, `-Category`, `-SpecId`, `-FrontmatterJson`, `-BodyMarkdown`, `-Force`), `$ErrorActionPreference = 'Stop'`, and `. $PSScriptRoot/common.ps1` source line

---

## Phase 2: Signal Vocabulary & Analysis Template (spec-interpreted)

**Purpose**: Author the `transcript-analysis-template.md` so the agent has a complete, accurate signal vocabulary and extraction algorithm

- [ ] T005 [P] [US1] Write tier signal vocabulary table in `.specify/templates/transcript-analysis-template.md` — include per-tier keyword signal rows for all six tiers: business (cost, budget, ROI, SLA, compliance, policy), security (zero-trust, encryption, RBAC, audit, threat, access-control), infrastructure (landing zone, VM, networking, storage, IAC, region), devops (CI/CD, pipeline, deployment, automation, observability, GitOps), platform (spec-system, framework, catalog, module, registry, scaffold), application (API, feature, SLA, deployment-strategy); include negative signals (keywords that appear in multiple tiers and require disambiguation by context)
- [ ] T006 [P] [US1] Write extraction guidance sections in `.specify/templates/transcript-analysis-template.md` — Step 1: extract meeting metadata (date, participants, purpose); Step 2: extract raw decision/requirement/constraint statements; Step 3: map each statement to exactly one tier+category using signal vocabulary; Step 4: identify gaps (topics that cannot be confidently mapped — surface these as clarifying questions); Step 5: identify conflicts with existing specs (check by reading referenced spec files)
- [ ] T007 [US1] Write grouping and output format sections in `.specify/templates/transcript-analysis-template.md` — grouping rule: one spec per tier-category pair, merge multiple statements into one spec body; output format: describe the proposed grouping plan format the agent presents to the user (numbered list with tier/category/rationale per group); describe the session summary format (markdown table: spec path, action, conflict-flag Y/N)

---

## Phase 3: Toolkit Scripts (script-enforced)

**Purpose**: Implement the deterministic file operation scripts that the agent calls for all writes

### `register-category.ps1`

- [ ] T008 Implement parameter validation in `.specify/scripts/powershell/register-category.ps1` — validate `-Tier` is one of the 6 known tiers (from `$script:SpecTiers` in `common.ps1`); validate `-CategoryName` against `^[a-z][a-z0-9-]+$`; validate `-SpecId` against `^[a-z][a-z0-9-]{1,7}$`; exit 1 with descriptive message on any failure
- [ ] T009 [P] Implement spec-id uniqueness check in `.specify/scripts/powershell/register-category.ps1` — call `Build-CategoryCatalog` (from `common.ps1`); check if `-SpecId` already exists in the global spec-id set; exit 1 with message listing the conflict if duplicate found
- [ ] T010 Implement `_categories.yaml` upsert in `.specify/scripts/powershell/register-category.ps1` — if `specs/<tier>/_categories.yaml` does not exist, write bootstrap skeleton; otherwise read existing file; check if `spec-id` already present (idempotent — exit 0 silently if already registered); append new entry (`name`, `spec-id`, `description`) and increment `category-count`; write back; atomic write (write to temp file, rename)
- [ ] T011 [P] Implement `specs.yaml` category-count increment in `.specify/scripts/powershell/register-category.ps1` — read `specs/specs.yaml`; find tier entry; increment `category-count`; write back; idempotent (only increments if the category was actually new per T010)
- [ ] T012 [P] Implement PSScriptAnalyzer compliance pass on `register-category.ps1` — all functions use approved verbs (`Register-`, `Build-`, `Test-`, `Write-`); no declared-but-unused variables; pass `Invoke-ScriptAnalyzer` with zero errors

### `write-spec.ps1`

- [ ] T013 Implement parameter validation in `.specify/scripts/powershell/write-spec.ps1` — validate `-Tier`, `-Category`, `-SpecId`, `-FrontmatterJson` (must be parseable via `ConvertFrom-Json`); validate target path resolves within repo root (no path traversal); exit 1 with descriptive message on any failure
- [ ] T014 Implement YAML frontmatter generation in `.specify/scripts/powershell/write-spec.ps1` — accept `-FrontmatterJson`, deserialize, validate all required fields are present (`tier`, `category`, `spec-id`, `version`, `status`, `compliance-state`, `role-context`), render as valid YAML block with `---` delimiters; enforce `status: draft`, `compliance-state: current`, `requested-by: "transcript-to-specs"`, `decision-mode: autonomous`
- [ ] T015 [P] Implement spec file write in `.specify/scripts/powershell/write-spec.ps1` — resolve target path `specs/<tier>/<category>/spec.md`; create directory if needed; if file exists and `-Force` not set, exit 2 (skip, not error) with message; write frontmatter + body markdown; validate written file is non-empty and YAML frontmatter block opens the file; exit 0 on success
- [ ] T016 Implement conflict-flag injection in `.specify/scripts/powershell/write-spec.ps1` — if `-FrontmatterJson` includes a `conflict-flags` array, add `conflict-flags:` block to generated YAML frontmatter and prepend a `## ⚠️ Conflict Flags` section to the body listing each flagged upstream spec and reason
- [ ] T017 [P] Implement PSScriptAnalyzer compliance pass on `write-spec.ps1` — approved verbs (`Write-`, `New-`, `Test-`, `ConvertTo-`); no declared-but-unused variables; pass `Invoke-ScriptAnalyzer` with zero errors

---

## Phase 4: Agent Mode — Core Workflow (US1 P1)

**Purpose**: Author `transcript-to-specs.md` workflow steps for the single-session analysis-to-write flow

- [ ] T018 [P] [US1] Write Overview and Invocation sections in `.github/agents/transcript-to-specs.md` — describe: how the user invokes the agent (Copilot Chat with transcript file path), what the agent does at a high level, which toolkit scripts it calls and when, what user confirmations are required at each gate
- [ ] T019 [US1] Write Workflow section in `.github/agents/transcript-to-specs.md` — define the 7-step sequential flow: (1) Accept transcript path, read file; (2) Load category catalog (read `specs.yaml` + all `_categories.yaml`); (3) Run transcript extraction using signal vocabulary from `transcript-analysis-template.md`; (4) Build proposed grouping plan (one spec per tier-category pair); (5) Present grouping plan to user in chat and wait for confirmation; (6) For each confirmed group: process conflicts, process existing-spec checks, then write via `write-spec.ps1`; (7) Post session summary
- [ ] T020 [P] [US1] Write Toolkit Script Integration section in `.github/agents/transcript-to-specs.md` — document the exact PowerShell call signature for each script the agent uses, the expected exit codes and outputs, and how the agent interprets those (e.g., exit 2 from `write-spec.ps1` = skip, not error); document that the agent MUST NOT perform direct `spec.md` writes — all spec file writes go through `write-spec.ps1` and all category registrations go through `register-category.ps1`; **exception**: amendment proposal files (`spec-amendment-*.md`) are written directly by the agent using its file editing tools, as they require contextual interpretation not suitable for a script
- [ ] T021 [P] [US1] Write Constraints section in `.github/agents/transcript-to-specs.md` — enumerate all behavioral constraints from spec.md Constraints & Guardrails section; add agent-operational constraints: max 5 clarifying questions per session, always present grouping plan before any write, never write an existing spec without user confirmation

---

## Phase 5: Agent Mode — Conflict Resolution (US2 P1)

**Purpose**: Author the per-conflict interactive resolution workflow section of the agent file

- [ ] T022 [US2] Write Conflict Resolution section in `.github/agents/transcript-to-specs.md` — define the detection algorithm: before writing each spec for target tier T, the agent reads all existing specs whose tier has a **lower priority number** than T per the constitution hierarchy (Platform=0 > Business=1 > Security=2 > Infrastructure=3 > DevOps=4 > Application=5; e.g., for a `devops` spec, check all `platform`, `business`, `security`, and `infrastructure` specs); a **conflict** is any MUST, MUST NOT, SHALL, or SHALL NOT normative statement in those higher-authority specs that directly contradicts a requirement or behavior in the proposed spec; define the exact 3-option prompt format the agent presents to the user (Block / Write-with-flag / Propose-amendment); define agent behavior for each choice: Block = log to session summary with reason, skip write; Write-with-flag = call `write-spec.ps1` with `conflict-flags` in frontmatter JSON; Propose-amendment = write new spec AND compose an amendment proposal markdown file targeting the upstream spec **directly using the agent's file editing tools** (not via `write-spec.ps1` — amendment proposals require contextual interpretation)
- [ ] T023 [P] [US2] Write amendment-proposal format in `.github/agents/transcript-to-specs.md` — define the format of the companion amendment-proposal file: path `specs/<upstream-tier>/<upstream-category>/spec-amendment-<new-spec-id>.md` (filed in the **upstream** spec's own directory, named by the spec-id of the spec proposing the change); the agent writes this file **directly using its file editing tools** — amendment proposals require free-form interpretation and contextual reasoning that is not suitable for script enforcement; frontmatter (`artifact-type: amendment-proposal`, `targets-spec-id`, `targets-version`, `proposed-by: "transcript-to-specs"`), body sections (Conflict Description, Proposed Change, Rationale)

---

## Phase 6: Agent Mode — Existing Spec Updates & New Categories (US3/US4 P2)

**Purpose**: Author the additive-update and new-category-registration workflows in the agent file

- [ ] T024 [US3] Write existing-spec handling section in `.github/agents/transcript-to-specs.md` — define the 4-step flow: (a) read the existing `spec.md` body in full; (b) compare newly extracted items against existing requirements — a transcript item is **additive** if it introduces a net-new requirement, constraint, decision, or rationale not semantically equivalent to any already-present item in the existing spec; (c) if net-new items exist, present them to user in chat with the question "Add these X items to `<path>`?"; (d) if user confirms, build the **full merged body** (original spec body with new requirements appended to the Requirements section) and pass the complete merged body to `write-spec.ps1 -Force`; the script replaces the file wholesale, so the agent is responsible for providing the complete merged content, not just the delta; if no net-new items, log "already covered" in session summary and skip
- [ ] T025 [US4] Write new-category-discovery section in `.github/agents/transcript-to-specs.md` — define the detection trigger (no existing category in catalog matches the topic), the confirmation prompt format (present proposed category name, spec-id, tier, and 1-sentence description to user), and the write sequence: (a) user confirms; (b) agent calls `register-category.ps1`; (c) agent calls `write-spec.ps1` to write the spec into the newly registered directory; if user declines, log to session summary and skip this topic

---

## Phase 7: Platform Registration & Validation

**Purpose**: Register the new `transcript-ingestion` category; lint all scripts; end-to-end test; tag

- [ ] T026 [P] Add `transcript-ingestion` entry to `specs/platform/_categories.yaml` — add entry: `name: "Transcript Ingestion"`, `spec-id: txin`, `description: "AI-assisted meeting transcript ingestion to generate categorized spec drafts"`, increment `category-count`
- [ ] T027 [P] Update `specs/specs.yaml` — confirm `category-count` for `platform` tier is correct after T026
- [ ] T028 [P] Run `Invoke-ScriptAnalyzer` on `register-category.ps1` and `write-spec.ps1` — zero errors required; fix any `PSUseApprovedVerbs` or `PSUseDeclaredVarsMoreThanAssignments` violations before proceeding
- [ ] T029 End-to-end smoke test — manually invoke the `transcript-to-specs` agent in VS Code Copilot Chat using the sample transcript from `research.md`; verify: grouping plan is presented before any write, all written specs have `status: draft` and `requested-by: "transcript-to-specs"`, session summary is posted in chat
- [ ] T030 [P] Create git tag `spec/txin/1.0.0-draft` on the final commit of this branch

---

## Phase Ordering & Parallelization

### Dependency graph

```
Phase 1 (scaffold) — unblocks all phases
  ├── Phase 2 (template) — T005, T006, T007 all in parallel
  ├── Phase 3 (scripts)
  │   ├── T008, T009 parallel → T010 → T011, T012 parallel
  │   └── T013, T014 parallel → T015 → T016, T017 parallel
  └── Phase 4 (agent core)
        ├── T018, T019 parallel
        └── T020, T021 parallel (after T019)
            └── Phase 5 (conflict) — T022, T023 parallel (after T020)
                └── Phase 6 (updates/categories) — T024, T025 parallel
                    └── Phase 7 (registration) — T026-T030
```

### Quick-start parallel set (after T001-T004 complete)

All of these can run simultaneously:
- T005, T006, T007 — template sections
- T008, T009, T013, T014 — script parameter validation and frontmatter generation in parallel across the two scripts
- T018, T019 — agent overview and workflow (can be drafted in parallel with scripts)

### MVP delivery

Complete Phase 3 (T008–T017) + Phase 4 (T018–T021) to have a working agent with toolkit scripts. US1 is end-to-end testable from this point. Phase 5/6 add conflict resolution and update handling. Phase 7 finalizes registration and tagging.

---

## Implementation Notes

- The `transcript-to-specs` agent handles ALL reasoning, judgment, Q&A, conflict presentation, and grouping confirmation. Scripts handle ONLY deterministic file operations.
- `common.ps1` provides `Get-RepoRoot`, `$script:SpecTiers`, and `Build-CategoryCatalog` — use these; do not hardcode paths or tier lists in the new scripts. **Before implementing T009**, verify that `Build-CategoryCatalog` exists in `common.ps1` and returns a hashtable of spec-id → tier/category pairs; if absent, add it to `common.ps1` as part of T009's scope.
- Both new scripts MUST be idempotent: `register-category.ps1` exits 0 silently if the spec-id is already registered; `write-spec.ps1` exits 2 (skip) if the file exists and `-Force` is not set.
- Conflict detection in the agent is heuristic (keyword + semantic similarity scanning of existing spec bodies) — false positives are acceptable and resolved interactively. False negatives (missed conflicts) are a risk; the agent should err on the side of surfacing more conflicts rather than fewer.
- **Tier precedence reminder**: "higher-tiered" means lower priority number. Platform=0 is the highest-authority tier; Application=5 is the lowest. A spec at priority N must only check tiers at priorities 0 through N-1 for conflicts.

