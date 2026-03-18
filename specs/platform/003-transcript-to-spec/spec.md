---
# YAML Frontmatter - Category-Based Spec System
tier: platform
category: transcript-ingestion
spec-id: txin
version: 1.0.0-draft
status: draft
created: 2026-03-17
description: "AI-assisted meeting transcript ingestion to automatically generate categorized platform specs"

# Role Context (per governance v2.0.0)
role-context:
  declared-role: platform
  authority-scope: platform-meta-governance
  change-intent: "Add AI transcript ingestion capability to the .specify/ toolkit, extending the framework with a new script + template pair that generates compliant spec drafts from meeting transcripts"
  upstream-snapshot:
    - spec-id: spec
      version: "1.0.0-draft"
    - spec-id: artifact
      version: "1.0.0-draft"
  cascade-run-id: null
  decision-mode: reviewed
  requested-by: "Platform Dev"
  approved-by: null

# Version compliance
compliance-state: current
version-history:
  - version: "1.0.0-draft"
    date: "2026-03-17"
    git-tag: spec/txin/1.0.0-draft
    summary: "Initial draft. AI transcript ingestion capability for automatic spec generation from meeting conversations."

# Dependencies
depends-on:
  - tier: platform
    category: spec-system
    spec-id: spec
    version: "1.0.0-draft"
    reason: "Defines the spec frontmatter schema, category registration, versioning, and tier hierarchy that all generated specs must conform to"
  - tier: platform
    category: artifact-org
    spec-id: artifact
    version: "1.0.0-draft"
    reason: "Defines the directory structure and naming conventions used when writing output spec files to disk"

# Precedence rules
precedence:
  note: "Platform-meta-governance scope. As a framework addition to .specify/, this supersedes all content tiers. Generated spec output files are governed by the tier they are placed in."

# Relationships
defines:
  - "transcript-to-specs agent mode invocation contract and behavioral constraints"
  - "register-category.ps1 and write-spec.ps1 script-enforced toolkit interface"
  - "transcript-analysis-template.md spec-interpreted AI guidance and tier signal vocabulary"
  - "transcript-ingestion platform category registration"
---

## Clarifications

### Session 2026-03-17

- Q: How is the transcript ingestion capability invoked? → A: New VS Code agent mode named `transcript-to-specs`. User invokes in Copilot Chat, provides a transcript file path, and the agent reads the file, conducts conversation-style Q&A, and writes specs — all within a single agent session. No manual intermediary step between analysis and spec generation.
- Q: What is the execution model — does it require a user step between AI analysis and spec writing? → A: No. The previous two-step model (script renders prompt → user pastes to AI → user saves response → script reads response) is replaced. The `transcript-to-specs` agent handles the full flow autonomously: file read, analysis, clarifying questions, and spec writes all happen within the agent session.
- Q: When a newly identified spec conflicts with a higher-tiered existing spec, how should the agent handle it? → A: Per-conflict interactive resolution. For each conflict detected the agent pauses in chat and presents the user with three choices: (1) Block — do not write this spec until the upstream spec is amended; (2) Write-with-flag — write the draft spec with a `conflict-flags:` frontmatter field and an inline warning section noting the violation; (3) Propose amendment — write the conflicting draft AND generate a companion amendment proposal for the upstream spec. The user chooses per conflict before the agent continues.
- Q: How should transcript content be grouped into spec files? → A: One spec per tier-category pair. The agent maps each topic cluster to exactly one tier+category combination, presents the proposed grouping plan to the user in chat for confirmation, then writes one `spec.md` per pair. A single transcript may produce multiple specs across multiple tiers and categories.
- Q: When the transcript covers a topic already captured in an existing spec, what should the agent do? → A: Update if additive, skip if already covered. The agent reads the existing spec, checks whether the transcript adds new requirements, constraints, or decisions not already captured, then proposes additions in chat and asks for user confirmation before writing. If the existing spec fully covers the topic, the agent skips it with a note in the chat summary.
- Q: Does `ingest-transcript.ps1` still exist in the new agent-driven design, or does the agent handle everything? → A: Agent + scripts. The `transcript-to-specs` agent handles all analysis, clarification Q&A, conflict resolution, and grouping confirmation. It calls existing `.specify/scripts/powershell/` toolkit scripts for the deterministic operations (frontmatter generation, registry updates, `_categories.yaml` writes, output validation). The scripts remain independently usable from CI. No single monolithic `ingest-transcript.ps1`; the deterministic operations are split across purpose-specific scripts wired by the agent.

---

# Specification: AI Transcript Ingestion for Spec Generation

**Tier**: platform  
**Category**: transcript-ingestion  
**Spec ID**: txin  
**Created**: 2026-03-17  
**Status**: Draft  
**Authority**: platform-meta-governance (.specify/ framework extension)

---

## Spec Source & Hierarchy

**Parent Tier Specs** (constraints that apply to this spec):
- `platform/spec-system` (spec v1.0.0-draft): All generated specs MUST conform to the YAML frontmatter schema, tier/category/spec-id structure, versioning convention, and category registration process
- `platform/artifact-org` (artifact v1.0.0-draft): Output spec files MUST be placed in the correct `specs/<tier>/<category>/spec.md` structure

**Derived Downstream Specs** (specs created BY this tool):
- Any tier/category spec generated from a transcript. The tool creates drafts; human review promotes them to the appropriate status.

---

## Executive Summary

**Problem**: Valuable architectural and business decisions are made in meetings but never captured as formal platform specs. Translating meeting notes into correctly-structured, categorized spec files is manual, error-prone, and requires deep knowledge of the six-tier hierarchy, category registration, frontmatter schema, and cross-tier conflict rules.

**Solution**: A new VS Code agent mode named **`transcript-to-specs`** that a user invokes in Copilot Chat. The user provides a transcript file path; the agent:
1. Reads the transcript and the live category catalog (`specs.yaml` + all `_categories.yaml` files)
2. Identifies decisions, requirements, and constraints across all tiers using the tier signal vocabulary
3. Proposes a grouping plan — one spec per tier-category pair — and asks the user to confirm before writing
4. Asks clarifying questions in chat for any topics it cannot fully resolve from the transcript alone
5. Detects conflicts with existing higher-tiered specs and presents per-conflict resolution options: block, write-with-flag, or propose an upstream amendment
6. For existing categories: reads the current spec and proposes additions if the transcript is additive; skips with a note if already covered
7. Writes compliant `spec.md` draft files and updates `_categories.yaml` / `specs.yaml` via toolkit scripts

All analysis, clarification, and conflict resolution happen in a single agent session with no manual intermediary steps.

**Impact**: Time from meeting to first spec draft is minutes, not days. Decisions are captured consistently, conflicts are surfaced immediately, and every generated spec is immediately part of the governed tier hierarchy.

---

## Execution Mode Classification

Per the platform execution-mode policy (`specs.yaml`):

| Component | Type | Mode | Rationale |
|---|---|---|---|
| `transcript-to-specs` agent mode | `.agent.md` under `.github/agents/` | **spec-interpreted** | AI-driven analysis, clarification Q&A, conflict resolution, grouping confirmation — variation is intentional and desirable |
| `transcript-analysis-template.md` | `.md` under `.specify/templates/` | **spec-interpreted** | Tier signal vocabulary and extraction guidance for the agent — guidance document, not executable |
| Toolkit scripts (e.g., `register-category.ps1`, `write-spec.ps1`) | `.ps1` under `.specify/scripts/` | **script-enforced** | Deterministic operations: frontmatter generation, `_categories.yaml` writes, `specs.yaml` updates, output validation, exit codes |

The split: *analysis, judgment, and interaction* (agent, spec-interpreted) vs *file writes, registry updates, and validation* (toolkit scripts, script-enforced). The agent orchestrates the scripts; the scripts are also independently usable from CI.

---

## Requirements

### Functional Requirements — Agent Behavior

- **REQ-001**: The `transcript-to-specs` agent MUST accept a transcript file path as its primary input and read the file using its file tools
- **REQ-002**: Before proposing any specs, the agent MUST load the live category catalog by reading `specs/specs.yaml` and all `specs/<tier>/_categories.yaml` files
- **REQ-003**: The agent MUST extract decisions, requirements, constraints, cost/budget signals, security requirements, infrastructure choices, governance/process rules, and DevOps practices from the transcript using the tier signal vocabulary in `transcript-analysis-template.md`
- **REQ-004**: Each extracted item MUST be mapped to exactly one tier and one category; the agent MUST present the full proposed grouping plan to the user in chat and wait for confirmation before writing any files
- **REQ-005**: The agent MUST ask clarifying questions in chat for any topic it cannot fully resolve from the transcript alone, using a sequential one-question-at-a-time pattern (max 5 questions per session)
- **REQ-006**: If a finding does not map to any existing category, the agent MUST propose a new category (name, spec-id, tier, justification) and ask the user to confirm before registering it
- **REQ-007**: Before writing any spec, the agent MUST check all higher-tiered existing specs for conflicts. A **conflict** is a MUST, MUST NOT, SHALL, or SHALL NOT normative statement in a higher-authority tier spec (i.e., a spec whose tier has a lower priority number per the constitution: Platform=0 > Business=1 > Security=2 > Infrastructure=3 > DevOps=4 > Application=5) that directly contradicts a requirement or behavior stated in the proposed spec. For each conflict detected the agent MUST pause and offer the user three options: (1) Block, (2) Write-with-flag, (3) Propose upstream amendment
- **REQ-008**: For a transcript topic that maps to an existing `spec.md`, the agent MUST read the existing spec and determine if the transcript is **additive**. A transcript item is additive if it introduces a net-new requirement, constraint, decision, or rationale not semantically equivalent to any already-present item in the existing spec's Requirements or Constraints sections. If additive, propose the net-new items in chat and ask for confirmation; if already covered, skip with a chat note
- **REQ-009**: All output spec files MUST be written via toolkit scripts to enforce deterministic frontmatter, registry updates, and PSScriptAnalyzer compliance
- **REQ-010**: Every generated spec file MUST include compliant YAML frontmatter with all required fields per `spec-system`: `tier`, `category`, `spec-id`, `version: "1.0.0-draft"`, `status: draft`, `compliance-state: current`
- **REQ-011**: Generated specs MUST record `requested-by: "transcript-to-specs"` and `decision-mode: autonomous` in role-context
- **REQ-012**: If the user chose Write-with-flag for a conflict, the generated spec MUST include a `conflict-flags:` frontmatter field listing each upstream spec violated and the reason
- **REQ-013**: Registry updates (`_categories.yaml`, `specs.yaml`) MUST be idempotent — re-running on the same transcript MUST NOT create duplicate entries
- **REQ-014**: The agent MUST produce a session summary in chat after all writes: specs created, specs updated, specs skipped, new categories registered, conflicts flagged, amendment proposals written

### Functional Requirements — Toolkit Scripts

- **REQ-015**: Toolkit scripts called by the agent MUST pass PSScriptAnalyzer with zero errors
- **REQ-016**: Toolkit scripts MUST exit non-zero if required inputs are missing or output validation fails
- **REQ-017**: File scaffolding and registry update scripts MUST complete within 10 seconds per operation

### Non-Functional Requirements

- **NFR-001**: All toolkit scripts MUST pass PSScriptAnalyzer (`PSUseApprovedVerbs`, `PSUseDeclaredVarsMoreThanAssignments`) with zero errors
- **NFR-002**: File scaffolding and validation operations MUST complete within 10 seconds each (excluding agent reasoning time)
- **NFR-003**: Generated spec files MUST be human-readable and immediately editable without tooling
- **NFR-004**: The agent interaction MUST complete a full single-transcript session (analysis + Q&A + conflict resolution + writes) without requiring the user to leave the Copilot Chat interface

### Out of Scope (v1)

- Real-time audio transcription (audio → text is a separate concern)
- Automatic publishing or promotion of generated specs (all outputs are `status: draft` requiring human review)
- Multi-language transcript support
- Batch processing of multiple transcript files in a single agent session

---

## User Scenarios & Testing

### User Story 1 — Multi-tier spec generation from a business strategy meeting (Priority: P1)

A platform engineer opens Copilot Chat and invokes the `transcript-to-specs` agent, pointing it at a transcript of a quarterly planning meeting where stakeholders discussed cost targets, reserved instances, Azure Policy for billing alerts, default SKUs, and faster time to market via CI/CD maturity.

The agent:
1. Reads the file and loads the current category catalog
2. Proposes a grouping plan in chat: `business/cost` (cost management practices), `infrastructure/compute` (reserved instances + default SKUs), `infrastructure/cicd-pipeline` (billing policy), `devops/ci-cd-orchestration` (deployment velocity), `business/governance` (competitive velocity mandate) — and asks for confirmation
3. After confirmation, asks 1–2 clarifying questions (e.g., "The transcript mentions 'default SKUs' — should these apply to all workloads or only production?")
4. Checks existing specs for conflicts, surfaces any that exist, and resolves per-conflict with the user
5. Writes all confirmed spec files via toolkit scripts and posts a session summary

**Acceptance criteria**:
- Agent presents grouping plan before writing any files
- Agent asks at most 5 clarifying questions in the session
- Each written spec has correct YAML frontmatter (`status: draft`, `requested-by: "transcript-to-specs"`, `decision-mode: autonomous`)
- Session summary lists every spec created/updated/skipped and every conflict handled

### User Story 2 — Conflict detection and per-conflict resolution (Priority: P1)

A transcript discusses deploying applications as fast as possible. The agent detects this conflicts with an existing `security/access-control` spec requiring change-board approval for production deployments.

The agent pauses and presents the conflict in chat:
> ⚠️ **Conflict detected**: Proposed `devops/ci-cd-orchestration` spec (zero-friction deployment) conflicts with `security/access-control` v1.0.0 (REQ-AC-007: production deployments require change-board approval).
> Choose: **(1) Block** this spec until security spec is amended · **(2) Write with conflict flag** · **(3) Propose upstream amendment to security/access-control**

User chooses option 3. Agent writes the `devops/ci-cd-orchestration` draft and a companion `security/access-control` amendment proposal.

**Acceptance criteria**:
- Agent surfaces the conflict with specific upstream spec-id, version, and violated requirement before writing
- All three resolution options are presented and honored
- Write-with-flag produces a spec with `conflict-flags:` in frontmatter and an inline `## ⚠️ Conflict Flags` section
- Amendment proposal is a well-formed spec change targeting the correct upstream spec

### User Story 3 — Additive update to an existing spec (Priority: P2)

The transcript introduces new cost-reduction requirements. `business/cost/spec.md` already exists. The agent reads it and determines the transcript adds two new requirements not currently captured (quarterly reserved-instance review cadence, alert threshold at 90% budget consumption).

The agent proposes the additions in chat and asks for confirmation before writing.

**Acceptance criteria**:
- Agent does not overwrite the existing spec wholesale — the agent reads the existing spec body in full, builds a merged body (original content plus proposed additions appended to the Requirements section), and passes the complete merged body to `write-spec.ps1 -Force`
- If the existing spec already fully covers the transcript content, agent skips with a note (no write)
- User confirmation is required before any change to an existing spec file

### User Story 4 — New category discovery (Priority: P2)

The transcript discusses a disaster-recovery strategy that has no matching category in the catalog. The agent proposes a new category `business/disaster-recovery` (spec-id `dr`), asks for user confirmation, then creates the spec and updates `specs/business/_categories.yaml` and `specs.yaml`.

**Acceptance criteria**:
- New `_categories.yaml` entry includes all required fields (`name`, `spec-id`, `description`)
- `specs.yaml` `category-count` for the tier is incremented
- The new spec has compliant frontmatter
- Agent does not create the category without explicit user confirmation

### User Story 5 — Empty project bootstrap (Priority: P3)

Invoking the agent on a repo with no existing category specs generates a full initial spec catalog from a single founding-vision transcript, creating specs across all mentioned tiers and bootstrapping all `_categories.yaml` files.

**Acceptance criteria**:
- Missing tier `_categories.yaml` files are created with correct skeleton structure
- All created specs are compliant with spec-system frontmatter rules
- Session summary identifies which categories were newly registered vs pre-existing

---

## Deliverables

| Artifact | Path | Execution Mode |
|---|---|---|
| Agent mode definition | `.github/agents/transcript-to-specs.md` | spec-interpreted |
| Analysis & signal vocabulary template | `.specify/templates/transcript-analysis-template.md` | spec-interpreted |
| Category registration script | `.specify/scripts/powershell/register-category.ps1` | script-enforced |
| Spec writer script | `.specify/scripts/powershell/write-spec.ps1` | script-enforced |
| Platform category spec | `specs/platform/transcript-ingestion/spec.md` | spec (this document, promoted) |
| Data model | `specs/platform/003-transcript-to-spec/data-model.md` | reference |

---

## Constraints & Guardrails

- Generated specs MUST NOT be auto-published — `status: draft` is the only valid initial state
- The agent MUST NOT write any spec file before the user confirms the grouping plan
- The agent MUST NOT modify an existing spec file without explicit user confirmation of the proposed additions
- New categories MUST follow naming convention: `lowercase-kebab-case` directory, spec-id 2–8 characters matching `^[a-z][a-z0-9-]{1,7}$` (begins with letter, may contain lowercase alphanumeric and hyphens), globally unique across the entire catalog
- The analysis template MUST include the full tier signal vocabulary so the agent produces correct tier-category mappings even on an empty project
- Role-context in generated specs MUST record `requested-by: "transcript-to-specs"` and `decision-mode: autonomous`
- Conflict resolution MUST be per-conflict and interactive — the agent MUST NOT silently skip or silently block conflicting specs
- The `transcript-to-specs` agent MUST NOT embed API keys or make direct LLM API calls from toolkit scripts; all AI reasoning happens within the agent session

