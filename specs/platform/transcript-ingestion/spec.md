---
tier: platform
category: transcript-ingestion
spec-id: txin
version: "1.2.0-draft"
status: draft
compliance-state: current
created: "2026-03-17"
description: "AI-assisted meeting transcript ingestion to automatically generate categorized platform specs"

role-context:
  declared-role: platform
  authority-scope: platform-meta-governance
  change-intent: "Add AI transcript ingestion capability to the .specify/ framework: transcripttospecs agent mode + register-category.ps1 + write-spec.ps1 toolkit scripts + transcript-analysis-template.md"
  requested-by: "Platform Dev"
  decision-mode: reviewed
  cascade-run-id: null
  approved-by: null

depends-on:
  - tier: platform
    category: spec-system
    spec-id: spec
    version: "1.0.0-draft"
    reason: "Defines the spec frontmatter schema, category registration, versioning, and tier hierarchy that all generated specs must conform to"
  - tier: platform
    category: artifact-org
    spec-id: artifact
    version: "1.0.0"
    reason: "Defines the directory structure and naming conventions used when writing output spec files to disk"

precedence:
  note: "Platform-meta-governance scope. As a framework addition to .specify/, this supersedes all content tiers."

version-history:
  - version: "1.2.0-draft"
    date: "2026-03-19"
    git-tag: null
    summary: "Add REQ-019 (privacy guardrail), REQ-020 (merge-into redirect), REQ-021 (3-phase sequential model), REQ-022 (Phase 1 context banner), REQ-023 (Phase 3 progress markers), REQ-024 (Phase 3 error resilience / continue on failure). Replace NFR-005 (was cross-tier check scope) with parallel reads requirement; add NFR-006 parallel write batching. Add Decisions 9 (privacy) and 10 (failure modes). Add large-batch safety-check constraint. Agent bumped to v2.0.0."
  - version: "1.1.0-draft"
    date: "2026-03-18"
    git-tag: null
    summary: "Add REQ-015 cross-tier consistency check: after all writes, validate every new/updated spec from lowest tier upward against all higher-authority tier specs. Renumber toolkit reqs to REQ-016/017/018. Add NFR-005 and two new guardrails."
  - version: "1.0.0-draft"
    date: "2026-03-17"
    git-tag: spec/txin/1.0.0-draft
    summary: "Initial draft. AI transcript ingestion capability via transcripttospecs agent mode."
---

# Specification: AI Transcript Ingestion for Spec Generation

**Tier**: platform
**Category**: transcript-ingestion
**Spec ID**: txin
**Created**: 2026-03-17
**Status**: Draft
**Authority**: platform-meta-governance (.specify/ framework extension)

---

## Summary

This category governs the `transcripttospecs` platform capability: a VS Code Copilot Chat agent mode that converts meeting transcripts into governed spec drafts. The agent reads a transcript, uses the tier signal vocabulary to extract architectural decisions, proposes a grouping plan to the user, conducts clarifying Q&A, detects conflicts with existing higher-authority specs, and writes compliant `spec.md` files via `register-category.ps1` and `write-spec.ps1` toolkit scripts — all within a single agent session.

---

## Deliverables

| Artifact | Path | Mode |
|---|---|---|
| Agent mode definition | `.github/agents/transcripttospecs.agent.md` | spec-interpreted |
| Tier signal vocabulary template | `.specify/templates/transcript-analysis-template.md` | spec-interpreted |
| Category registration script | `.specify/scripts/powershell/register-category.ps1` | script-enforced |
| Spec writer script | `.specify/scripts/powershell/write-spec.ps1` | script-enforced |
| This platform category spec | `specs/platform/transcript-ingestion/spec.md` | category spec |
| Shared catalog helper | `Build-CategoryCatalog` in `.specify/scripts/powershell/common.ps1` | script-enforced |

---

## Requirements

### Functional Requirements — Agent Behavior

- **REQ-001**: The agent MUST accept a transcript file path and read the file using its file tools
- **REQ-002**: Before proposing any specs, the agent MUST load the live category catalog by reading `specs/specs.yaml` and all `specs/<tier>/_categories.yaml` files
- **REQ-003**: The agent MUST extract decisions, requirements, constraints, and architecturally significant items using the tier signal vocabulary in `transcript-analysis-template.md`
- **REQ-004**: Each extracted item MUST be mapped to exactly one tier and one category; the agent MUST present the full proposed grouping plan and wait for confirmation before writing any files
- **REQ-005**: The agent MUST ask clarifying questions for topics it cannot confidently resolve, one at a time, max 5 questions per session
- **REQ-006**: If a finding maps to no existing category, the agent MUST propose a new category and ask for user confirmation before calling `register-category.ps1`
- **REQ-007**: Before writing any spec, the agent MUST check all specs in higher-authority tiers (lower priority number) for conflicts; a conflict is a MUST/MUST NOT/SHALL/SHALL NOT statement that directly contradicts the proposed spec's content; per-conflict resolution is mandatory and interactive (Block / Write-with-flag / Propose-amendment)
- **REQ-008**: For a transcript topic mapping to an existing `spec.md`, the agent MUST read the existing spec; an item is additive if it introduces net-new content not semantically equivalent to any existing requirement; if additive propose additions and require user confirmation; if already covered skip with a chat note
- **REQ-009**: All `spec.md` writes MUST go through `write-spec.ps1`; amendment proposals are written directly by the agent
- **REQ-010**: Every generated spec MUST have `status: draft`, `compliance-state: current`, `requested-by: "transcripttospecs"`, `decision-mode: autonomous` (enforced by `write-spec.ps1`)
- **REQ-011**: When updating an existing spec, the agent MUST build the full merged body (original + additions) and pass it to `write-spec.ps1 -Force`; the script replaces wholesale
- **REQ-012**: Write-with-flag specs MUST include a `conflict-flags:` frontmatter array and a `## ⚠️ Conflict Flags` body section
- **REQ-013**: Registry updates MUST be idempotent — repeating on the same transcript MUST NOT create duplicates
- **REQ-014**: The agent MUST post a session summary after all writes: specs created, updated, skipped, conflicts, amendments, new categories, and the results of the cross-tier consistency check (REQ-015)
- **REQ-015**: After all spec writes are complete and before posting the session summary, the agent MUST perform a cross-tier consistency check across every spec created or updated in the session. The check proceeds from lowest-authority tier to highest-authority tier (application → devops → infrastructure → security → business); for each new/updated spec at tier N, the agent MUST read all specs in every tier with a lower priority number (higher authority) and verify that no MUST, MUST NOT, SHALL, or SHALL NOT statement in the new spec contradicts any requirement in a higher-authority spec. Each contradiction found MUST be surfaced to the user using the same interactive resolution flow as REQ-007 (Block / Write-with-flag / Propose-amendment), and the affected spec file updated accordingly before the session summary is posted. If no contradictions are found the agent MUST note "Cross-tier check: no conflicts detected" in the summary.

### Additional Agent Behavior Requirements

- **REQ-019**: The agent MUST NOT reproduce raw transcript excerpts, speaker names, or personal attribution in any generated spec file; all spec content MUST be expressed as requirements, constraints, and decisions only — no narrative, no attributed quotation
- **REQ-020**: If a user responds to a NEW CATEGORY proposal with `merge-into <existing-category>`, the agent MUST reclassify that group as an UPDATE targeting the named existing category and proceed via Existing Spec Handling; the `merge-into` redirect may be given at any point before Phase 3 begins for affected groups
- **REQ-021**: The agent MUST execute the session in three strictly sequential phases — Phase 1 (Context Build), Phase 2 (Plan & Clarification), Phase 3 (Parallel Write Execution) — and MUST NOT perform file writes before Phase 3 begins or reorder phase execution
- **REQ-022**: After completing all Phase 1 reads, the agent MUST post a structured "Context loaded" banner showing transcript filename, word count, tier/category counts, existing specs loaded, and UPDATE candidates identified, before beginning any extraction or grouping work
- **REQ-023**: During Phase 3, the agent MUST post a `▶ Processing N groups` header before executing the first group, a `▶ [tier/category] — <action>` start marker before invoking any tool or script for each individual group, and a `✓ [tier/category] — <outcome>` or `✗ [tier/category] — error: <reason>` completion marker after each group finishes
- **REQ-024**: Upon a script failure (exit code 1 or 2) for any group in Phase 3, the agent MUST post the `✗` marker for that group and MUST continue processing the remaining groups; it MUST NOT abort the session; all `✗` entries MUST be consolidated in the session summary

### Functional Requirements — Toolkit Scripts

- **REQ-016**: Both scripts MUST pass PSScriptAnalyzer with zero errors (`PSUseApprovedVerbs`, `PSUseDeclaredVarsMoreThanAssignments`)
- **REQ-017**: Both scripts MUST exit non-zero when required inputs are missing or output validation fails
- **REQ-018**: Each script operation MUST complete within 10 seconds

### Non-Functional Requirements

- **NFR-001**: All toolkit scripts MUST pass PSScriptAnalyzer with zero errors
- **NFR-002**: File operations MUST complete within 10 seconds each (excluding agent reasoning time)
- **NFR-003**: Generated spec files MUST be human-readable and immediately editable without tooling
- **NFR-004**: The agent interaction MUST complete a full single-transcript session without requiring the user to leave Copilot Chat
- **NFR-005**: During Phase 1, ALL file reads (transcript, `specs/specs.yaml`, all `_categories.yaml` files, all anticipated UPDATE candidate `spec.md` files) MUST be issued as a single parallel tool call batch; sequential Phase 1 reads are not permitted
- **NFR-006**: During Phase 3, the agent MUST issue write operations for logically independent groups (non-overlapping output paths AND non-overlapping `_categories.yaml` registry targets) as parallel tool call batches; same-tier `register-category.ps1` calls MUST remain sequential to prevent double-increment of the category counter

---

## Constraints & Guardrails

- Generated specs MUST NOT be auto-published — `status: draft` is the only valid initial state
- The agent MUST NOT write any spec file before the user confirms the grouping plan
- The agent MUST NOT modify an existing spec file without explicit user confirmation of proposed additions
- New categories MUST follow: `lowercase-kebab-case` directory, spec-id matching `^[a-z][a-z0-9-]{1,7}$`, globally unique spec-id
- Conflict resolution MUST be per-conflict and interactive — silent skip or silent block is not permitted
- The cross-tier consistency check MUST run against the final committed state of each spec file on disk, not an in-memory draft; if a spec was written then subsequently blocked/updated in conflict resolution, the check reads the updated file
- Platform-tier specs are authoritative but are NOT modified by transcript ingestion sessions; they inform the cross-tier check as read-only higher-authority sources
- The `transcripttospecs` agent MUST NOT embed API keys or make direct LLM API calls from toolkit scripts
- If the confirmed grouping plan contains more than 10 spec write operations, the agent MUST warn the user with the total count before entering Phase 3 and ask for explicit confirmation to proceed; the agent MUST NOT begin Phase 3 writes until confirmation is received

---

## Decisions

| ID | Decision | Rationale |
|---|---|---|
| D-001 | PowerShell for toolkit scripts | Cross-platform (Windows/Linux/macOS via pwsh), standard in .specify/ toolchain |
| D-002 | Agent mode over standalone script | Enables interactive Q&A, conflict resolution, and judgment calls that scripts cannot handle |
| D-003 | write-spec.ps1 for all spec writes | Single enforcement point for frontmatter schema, status enforcement, idempotency |
| D-004 | Parallel file reads in Phase 1 | Reduces session latency; all context is fixed at invocation time (NFR-005) |
| D-005 | Hysteresis bias toward existing categories | Prevents category sprawl; a new category is only created when clearly justified |
| D-006 | Interactive per-conflict resolution | Automated merge logic cannot reliably arbitrate policy conflicts across tiers |
| D-007 | Phase gate: no writes before plan confirmation | Prevents partial writes when user cancels or revises the plan mid-session |
| D-008 | Session summary always posted | Provides an audit trail of agent actions within the Copilot Chat window |
| D-009 | Privacy guardrail: no raw transcript content in specs | Transcripts may contain personal statements, speaker attribution, or off-the-record remarks; specs are governance artifacts that must contain only normative, de-personalized requirements (REQ-019) |
| D-010 | Continue on Phase 3 error (no abort) | A failure writing one spec MUST NOT prevent other groups from being written; the session summary consolidates all failures for human review (REQ-024) |
