---
tier: platform
category: transcript-ingestion
spec-id: txin
version: "1.1.0-draft"
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

### Functional Requirements — Toolkit Scripts

- **REQ-016**: Both scripts MUST pass PSScriptAnalyzer with zero errors (`PSUseApprovedVerbs`, `PSUseDeclaredVarsMoreThanAssignments`)
- **REQ-017**: Both scripts MUST exit non-zero when required inputs are missing or output validation fails
- **REQ-018**: Each script operation MUST complete within 10 seconds

### Non-Functional Requirements

- **NFR-001**: All toolkit scripts MUST pass PSScriptAnalyzer with zero errors
- **NFR-002**: File operations MUST complete within 10 seconds each (excluding agent reasoning time)
- **NFR-003**: Generated spec files MUST be human-readable and immediately editable without tooling
- **NFR-004**: The agent interaction MUST complete a full single-transcript session without requiring the user to leave Copilot Chat
- **NFR-005**: The cross-tier consistency check (REQ-015) MUST cover all tiers that contain specs which were written or updated in the session; tiers with no session output may be skipped

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
