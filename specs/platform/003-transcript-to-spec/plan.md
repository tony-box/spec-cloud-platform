---
# YAML Frontmatter
tier: platform
category: transcript-ingestion
spec-id: txin
artifact-type: plan
version: "1.1.0-draft"
created: 2026-03-17
last-updated: 2026-03-17

# Role Context (per governance v2.0.0)
role-context:
  declared-role: platform
  authority-scope: platform-meta-governance
  change-intent: "Add semantic category matching with hysteresis bias to the transcripttospecs agent and back-fill the requirements into spec.md"
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
