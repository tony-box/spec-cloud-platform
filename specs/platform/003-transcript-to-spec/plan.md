---
# YAML Frontmatter
tier: platform
category: transcript-ingestion
spec-id: txin
artifact-type: plan
version: "1.2.0-draft"
created: 2026-03-17
last-updated: 2026-03-17

# Role Context (per governance v2.0.0)
role-context:
  declared-role: platform
  authority-scope: platform-meta-governance
  change-intent: "Add semantic category matching with hysteresis bias to the transcripttospecs agent and back-fill the requirements into spec.md; add Phase 6 implementation plan with verification procedures and T031 smoke test"
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

# Implementation Plan: Hysteresis Category Matching — transcripttospecs Agent

**Branch**: `003-transcript-to-spec` | **Date**: 2026-03-17 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `specs/platform/003-transcript-to-spec/spec.md`

---

## Summary

The `transcripttospecs` agent (v1.0.0) creates or updates specs but always proposes a new category when the transcript mentions a topic not found by exact name in the catalog. This produces unnecessary category proliferation when the transcript simply discusses something already covered under a slightly different label. 

This plan adds **semantic category matching with hysteresis bias** to the agent: a 4-tier classification algorithm that prefers extending existing categories and only proposes new ones when one of three concrete split conditions is clearly met. The change is purely agent-behavioral (spec-interpreted) — no changes to toolkit scripts or YAML schemas.

**Scope**: Update `transcripttospecs.agent.md` (done), back-fill requirements into `spec.md` (REQ-018 to REQ-020), update User Story 4, and add a worked example to `research.md`.

## Technical Context

**Language/Version**: PowerShell 7 (scripts — unchanged), Markdown (agent definition)  
**Primary Dependencies**: Existing `.specify/` toolkit scripts (`register-category.ps1`, `write-spec.ps1`), `transcript-analysis-template.md` — no new dependencies  
**Storage**: File system only (`_categories.yaml`, `specs.yaml`, `spec.md` — unchanged)  
**Testing**: Manual smoke test via Copilot Chat session (`@transcripttospecs`) on a sample transcript  
**Target Platform**: VS Code Copilot Chat agent mode  
**Performance Goals**: N/A — agent reasoning time is user-facing latency  
**Constraints**: Must not change the agent's external invocation interface or toolkit script contracts  
**Scale/Scope**: One agent file changed; spec.md gains 3 new requirements and 1 updated requirement

## Constitution Check: Tier Alignment & Spec Cascading

*GATE: Verified — no violations.*

- **Spec Tier**: `platform` (priority 0 — highest authority; no upstream tiers to check against)
- **Parent Tier Specs**: None (platform tier has no higher-authority upstream)
- **Derived Constraints**:
  - `platform/spec-system` (spec v1.0.0-draft): Generated specs must conform to frontmatter schema — **not affected** by this change (hysteresis logic is pre-write, during grouping plan only)
  - `platform/artifact-org` (artifact v1.0.0-draft): Output paths must follow `specs/<tier>/<category>/spec.md` — **not affected**
- **Artifact Traceability**:
  - Updated: `.github/agents/transcripttospecs.agent.md` (done — commit 9d68f7e)
  - Updated: `specs/platform/003-transcript-to-spec/spec.md` (3 new REQs, 1 updated REQ)
  - Updated: `specs/platform/003-transcript-to-spec/research.md` (worked example section)
  - No new files, no script changes, no schema changes

*Re-check post-Phase 1: PASS — all generated spec outputs remain identical in structure; only agent decision logic changes.*

## Spec Organization

```text
specs/platform/003-transcript-to-spec/
├── plan.md          ← this file (updated)
├── spec.md          ← Phase 1 output: add REQ-018, REQ-019, REQ-020; update REQ-006; update User Story 4
├── research.md      ← Phase 0 output: add hysteresis decision record + worked example
├── tasks.md         ← existing (no changes needed)
└── contracts/
    └── ingest-transcript-cli.md   ← existing (no changes needed — interface unchanged)
```

---

## Phase 0: Research

> **All questions resolved. No NEEDS CLARIFICATION items remain.**

See [research.md](research.md) — "Hysteresis Category Matching" section (to be appended).

**Key decisions recorded in research.md**:

| Question | Decision | Rationale |
|---|---|---|
| What is "close enough" for category reuse? | 4-tier classifier: EXACT / CLOSE (≥60% concept overlap) / AMBIGUOUS / NO MATCH | Avoids both false merges and false splits |
| What is the default for AMBIGUOUS? | Extend existing (option A); user must explicitly choose B to split | Implements the hysteresis bias — inertia toward existing state |
| When is a new category clearly justified? | One of 3 conditions: distinct lifecycle phase, distinct actor/authority boundary, or zero normative overlap requiring radical scope expansion | Gives the agent a checklist rather than an unconstrained judgment call |
| Does "merge-into" need a new script? | No — reclassify as UPDATE and route through existing Existing Spec Handling flow | Reuses infrastructure already in place |

---

## Phase 1: Design Artifacts

### spec.md Changes

**REQ-006** (existing — UPDATED): Changes from "if no category matches, propose new" to "evaluate semantic proximity first; only propose new when none of the existing categories is a sufficiently close match." Full updated text in spec.md.

**REQ-018** (new): The agent MUST evaluate each extracted group against all existing categories in the same tier using a 4-tier semantic classifier:
- EXACT MATCH (identical name) → UPDATE
- CLOSE MATCH (≥60% concept overlap: same primary domain, overlapping nouns/verbs/subjects) → UPDATE, noting which existing category absorbs the group
- AMBIGUOUS (same broad domain but orthogonal concern — different lifecycle, actor, or enforcement boundary) → flag for Step 5 user disambiguation
- NO MATCH (different primary domain, no meaningful concept overlap) → NEW CATEGORY

**REQ-019** (new): The agent MUST apply a hysteresis bias toward existing categories. A new category MUST NOT be proposed unless at least one of the following conditions is clearly met:
- (a) The extracted items address a lifecycle phase not present in any existing same-tier category
- (b) The extracted items introduce a distinct actor or authority boundary not represented in any existing same-tier category
- (c) The extracted items have zero normative overlap with all existing same-tier categories AND the closest category would require renaming or radical scope expansion to accommodate them

**REQ-020** (new): In the grouping plan (Step 5), the agent MUST:
- For CLOSE MATCH groups: show the match rationale (e.g., "70% concept overlap — adding to `governance`")
- For AMBIGUOUS groups: present an inline A/B choice with A (extend existing) as the explicit default; the user must type "B" to override
- For NEW CATEGORY proposals: state which existing category was the closest considered and why it was rejected per the hysteresis conditions in REQ-019

**User Story 4** (existing — UPDATED): Updated to reflect that the agent evaluates existing categories before proposing a new one, shows its reasoning, and offers `merge-into` as a user response for cases the user wants to redirect to an existing category even after the agent proposed new.

### research.md Addition

Append a new section "Hysteresis Category Matching" to the existing research.md with:
- The decision record (what was chosen, rationale, alternatives)
- A worked example showing all 4 classifier outcomes for a realistic transcript scenario

### No Changes Required

- `contracts/ingest-transcript-cli.md` — CLI interface is unchanged
- `register-category.ps1` — script behavior unchanged
- `write-spec.ps1` — script behavior unchanged
- `transcript-analysis-template.md` — template unchanged (hysteresis is agent-level logic, not template vocabulary)

---

## Phase 2: Implementation Plan — Phase 6 (Hysteresis Category Matching)

**Status of T026–T028**: Already implemented in `.github/agents/transcripttospecs.agent.md` (commit `9d68f7e`). Phase 6 is in **verify-and-test** state. No new agent file changes are required unless a gap is found in T029/T030.

### Pre-Implementation State Audit

Before running any verification task, confirm the following sections exist in the agent file:

| Check | Location in agent file | Expected content |
|---|---|---|
| 4-tier classifier table | Step 3 "Semantic category matching" | Rows for EXACT / CLOSE / AMBIGUOUS / NO MATCH |
| Hysteresis rule | Step 3 "Hysteresis rule" | Conditions (a), (b), (c) explicitly listed |
| AMBIGUOUS display format | Step 5 grouping plan | Option A shown as default; user must enter `B` to override |
| CLOSE MATCH rationale display | Step 5 grouping plan | Inline `*(close match: N% concept overlap — ...)*` shown per group |
| NEW CATEGORY hysteresis justification | New Category Discovery section | Fields: "Why a new category" + "Closest existing category considered" |
| `merge-into` response handling | New Category Discovery section | Redirect to UPDATE flow when user responds `merge-into <category>` |

### T029 — Verification Procedure (REQ-018 vs research.md Decision 7)

**Goal**: Confirm the agent's classifier logic produces the same outcome as the worked example in `research.md` Decision 7.

**Input** (from Decision 7 worked example):
- Transcript topic: *"cost-allocation tags on all new resource groups, flag untagged resources monthly"*
- Tier: `platform`
- Existing same-tier categories: `governance`, `spec-system`, `artifact-org`, `transcript-ingestion`

**Expected agent classification**:
1. Evaluate `governance` — shared subject: policy mandate, compliance enforcement, resource tagging → concept overlap ≥60% → `CLOSE MATCH`
2. Check split conditions: (a) same lifecycle as existing governance requirements (ongoing enforcement) — does NOT meet condition (a); (b) same actor (platform governance) — does NOT meet condition (b); (c) normative overlap exists — does NOT meet condition (c)
3. Action: mark as `UPDATE specs/platform/governance/spec.md`
4. Grouping plan entry: `UPDATE specs/platform/governance/spec.md` *(close match: ~65% concept overlap — adding cost-allocation tagging enforcement)*
5. **NOT** proposed as new category `platform/cost-tagging` or `platform/cost-governance`

**Pass criteria**: Agent output for this input matches the above. If agent proposes a new category instead → gap in T026/T027 implementation.

### T030 — Verification Procedure (AMBIGUOUS default bias)

**Goal**: Confirm A (extend existing) is always the default for AMBIGUOUS groups and that no new category is created without explicit user choice.

**Test scenario**:
- Transcript topic: *"we should define a process for rotating platform team access credentials"*
- Existing same-tier categories: `governance`, `spec-system`
- Expected classification: `AMBIGUOUS` (same platform-governance domain, but credential rotation could be orthogonal security-operations concern or could extend `governance`)

**Expected agent behavior**:
1. Does NOT immediately propose a new category `platform/access-rotation`
2. Presents an inline A/B choice in the grouping plan with A as the explicit default
3. If user does not respond or responds `yes` → agent proceeds with A (extend `governance`)
4. Only if user explicitly enters `B` → agent proceeds to propose new category (subject to hysteresis conditions check)

**Pass criteria for AMBIGUOUS default**:
- [ ] Grouping plan shows Option A labeled as "Default"
- [ ] Agent processes Group as UPDATE if user confirms grouping plan without specifying B
- [ ] Agent does NOT call `register-category.ps1` for an AMBIGUOUS group unless user chose B

### T031 — Smoke Test Procedure (US4 Disaster-Recovery Scenario)

**Goal**: End-to-end test of the complete hysteresis evaluation path, including the `merge-into` shortcut, using the scenario from spec.md User Story 4.

#### Test Transcript

Save the following as `meetings/test-hysteresis-dr-2026-03-17.md`:

```markdown
# Q1 Business Resilience Review — 2026-03-17
Attendees: Alice (CTO), Bob (Platform Lead), Carol (Business Continuity Lead)

Alice: We need to formally define our disaster recovery strategy.
       Recovery Point Objective should be 4 hours and Recovery Time Objective 8 hours.

Bob: We should also require that all tier-1 services have a validated failover runbook
     before going to production. That runbook needs to be reviewed quarterly.

Carol: Agreed. And we need an owner assigned to each failover path,
       separate from the normal on-call rotation.

Alice: Let's also revisit our cost governance for reserved instances.
       We're paying for capacity we don't use and should set a quarterly right-sizing review.
```

#### Expected Agent Behavior at Each Step

**Step 2 — Catalog load**: Agent reads `specs/<tier>/_categories.yaml` for all 6 tiers.

**Step 3 — Extraction and classification**:

Extracted groups and expected classifications:

| Group | Tier | Extracted topic | Expected classification | Expected action |
|---|---|---|---|---|
| A | business | Disaster recovery: RPO 4h, RTO 8h, failover runbook, quarterly review, owner per failover path | `NO MATCH` after hysteresis → NEW CATEGORY | Propose `business/disaster-recovery` (spec-id `dr`) — cite condition (a): distinct lifecycle phase (incident response/recovery) not present in any existing business category |
| B | business | Reserved instance cost governance, quarterly right-sizing review | `CLOSE MATCH` with `business/cost` | UPDATE `specs/business/cost/spec.md` — match rationale: reserved instance right-sizing is an existing cost-management concern |

**Step 5 — Grouping plan** (expected display):

```
Here is my proposed grouping plan:

1. UPDATE specs/business/cost/spec.md
   (close match: ~70% concept overlap — reserved-instance right-sizing is a cost management requirement)

2. 🆕 NEW CATEGORY: business/disaster-recovery (spec-id: dr)
   Closest evaluated: business/governance — rejected: distinct lifecycle phase (incident response/recovery) not present in governance
   Hysteresis condition met: (a) distinct lifecycle phase
   Confirm? (yes / no / merge-into governance)
```

**T031 pass/fail checklist**:
- [ ] Group A classified as NEW CATEGORY with condition (a) cited
- [ ] Group B classified as CLOSE MATCH with `business/cost` (not proposed as new category)
- [ ] Grouping plan shows "Closest evaluated: business/governance — rejected: distinct lifecycle phase"
- [ ] Grouping plan shows `merge-into governance` as a valid response option
- [ ] When user responds `merge-into governance`: agent reclassifies Group A as UPDATE and routes through Existing Spec Handling (does NOT call `register-category.ps1`)
- [ ] When user confirms Group A as-is: agent calls `register-category.ps1 -Tier business -CategoryName disaster-recovery -SpecId dr` and then `write-spec.ps1`
- [ ] Session summary correctly identifies 1 new category registered and 1 spec updated

#### Cleanup After T031

```powershell
# Remove test artifacts if created during smoke test
Remove-Item -Path "specs/business/disaster-recovery" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "meetings/test-hysteresis-dr-2026-03-17.md" -ErrorAction SilentlyContinue
# Revert any _categories.yaml changes
git checkout HEAD -- "specs/business/_categories.yaml" "specs/specs.yaml"
```

### Phase 6 Completion Gate

Phase 6 is complete when:
1. T029 verification: researched worked example matches agent classification ✓
2. T030 verification: AMBIGUOUS default is A in all tested cases ✓
3. T031 smoke test: all 7 checklist items pass ✓
4. No gaps found that require agent file changes → tasks T026/T027/T028 can be marked `[X]`

If gaps are found during T029/T030: document the specific deviation, update the agent file to close the gap, re-run the relevant sub-check before marking complete.
