# Research: AI Transcript Ingestion for Spec Generation

**Branch**: `003-transcript-to-spec` | **Date**: 2026-03-17 | **Phase**: 0 | **Location**: `specs/platform/003-transcript-to-spec/`

---

## Decision 1: Execution Model Split

**Decision**: Use a split-responsibility model — `transcripttospecs` agent mode (spec-interpreted) handles analysis, clarification Q&A, conflict resolution, and grouping confirmation; `register-category.ps1` and `write-spec.ps1` (script-enforced) handle all deterministic file operations.

> **Clarification update (2026-03-17)**: Original decision specified `ingest-transcript.ps1` as the script-enforced component. This was superseded by Q5 in the clarification session: no monolithic `ingest-transcript.ps1`; the deterministic operations are split into purpose-specific scripts (`register-category.ps1`, `write-spec.ps1`) called by the agent.

**Rationale**: The platform execution-mode policy (`specs.yaml`) already defines this exact split. The *content extraction* from a transcript is inherently interpretive (AI judgment, variation expected) — it must be spec-interpreted. The *file writing, registry updating, and validation* must produce deterministic, reproducible results — they must be script-enforced. Conflating both into a single script would violate the policy; conflating both into a template would lose the deterministic guarantees on file output.

**Alternatives considered**:
- All-in-script: Would require embedding AI invocation logic in `.ps1`, forcing API keys or subprocess calls into the deterministic script layer. Rejected — violates execution-mode policy and creates security surface.
- All-in-template: Produces consistent guidance but no deterministic file writing. Rejected — no CI gate, no idempotency, no exit code enforcement.
- External service: A separate REST API or function app. Rejected — over-engineered for a toolkit-local capability; adds infrastructure dependency.

---

## Decision 2: AI Invocation Pattern

**Decision**: ~~The script renders the analysis template as a context document and passes it to the user's current AI agent as a structured prompt. The AI returns a structured `IngestionManifest` JSON block. The script parses that JSON and acts on it.~~ **SUPERSEDED by clarification Q1 + Q2 (2026-03-17).**

**Superseded by**: A `transcripttospecs` VS Code agent mode. The user invokes the agent in Copilot Chat with a transcript file path. The agent handles analysis, clarification Q&A, and conflict resolution natively within the session — no manual AI handover step, no manifest JSON exchange between script and user. The split-responsibility principle from Decision 1 is preserved but the invocation boundary shifts: agent = reasoning layer, toolkit scripts = file I/O layer.

**Rationale**: The existing toolkit already operates AI-assisted in a human-in-the-loop pattern (speckit commands guide AI, AI generates content, human reviews). This feature follows the same pattern. Requiring an embedded AI API call would force credential management, network dependencies, and model versioning into the toolkit — all out of scope and fragile.

**Alternatives considered**:
- Direct Azure OpenAI SDK call inside the script: Requires API key injection, model endpoint config, retry logic. Rejected — scope creep, security surface, not portable.
- LangChain/semantic-kernel: External .NET/Python dependency. Rejected — adds runtime dependency, incompatible with pwsh-only toolkit.
- Manual analyst fills in template: defeats the automation goal. Rejected for primary path (retained as fallback if AI is unavailable).

**Consequence**: The `transcript-analysis-template.md` must be thorough enough that any capable LLM, when given transcript + catalog + template, produces a parseable `IngestionManifest` JSON block.

---

## Decision 3: IngestionManifest Format

**Decision**: The AI outputs a JSON block (fenced as ` ```json `) embedded in its response. The script extracts it using a regex pattern.

**Rationale**: JSON is universally parseable in PowerShell (`ConvertFrom-Json`). A fenced code block is a reliable extraction target even if the AI adds prose around it. This pattern is already used by `setup-plan.ps1 -Json` and other toolkit scripts.

**Alternatives considered**:
- YAML block: Requires external YAML parser or fragile regex. Rejected.
- Markdown table: Difficult to parse reliably. Rejected.
- Structured output mode (OpenAI API feature): Not available in human-in-the-loop pattern. Deferred to future AI API integration.

**IngestionManifest schema** (resolved):
```json
{
  "transcript_file": "string (path)",
  "meeting_date": "string (ISO date or inferred)",
  "participants": ["string"],
  "purpose": "string (one sentence)",
  "spec_entries": [
    {
      "tier": "platform|business|security|infrastructure|devops|application",
      "category": "string (existing or proposed)",
      "spec_id": "string (2-8 chars)",
      "is_new_category": true,
      "title": "string",
      "summary": "string (one sentence for dry-run display)",
      "decisions": ["string (verbatim or paraphrased from transcript)"],
      "requirements": ["string (REQ-NNN: ...)"],
      "constraints": ["string"]
    }
  ],
  "new_categories": [
    {
      "tier": "string",
      "category": "string",
      "spec_id": "string",
      "description": "string",
      "justification": "string"
    }
  ]
}
```

---

## Decision 4: Tier Signal Vocabulary

**Decision**: The analysis template provides a per-tier keyword vocabulary to guide the AI's classification. This prevents tier-mapping hallucination on ambiguous transcript segments.

**Rationale**: Without explicit signals, an AI might map "we need to track audit logs" to infrastructure/compute instead of security/audit-logging, or "under budget" to governance instead of business/cost. A curated signal vocabulary anchors the AI's classification to the platform's specific tier definitions.

**Resolved vocabulary**:

| Tier | Signal words / phrases |
|---|---|
| **business/cost** | budget, spend, OPEX, CAPEX, cost target, savings, pricing, licens*, invoice, allocation |
| **business/governance** | approval, SLA, escalation, change board, sign-off, policy, audit committee, ownership, accountability |
| **business/compliance-framework** | regulation, GDPR, HIPAA, ISO 27001, SOC 2, data residency, data sovereignty, certification, audit standard |
| **security/data-protection** | encrypt*, key management, TLS, certificate, secret, vault, at-rest, in-transit, PII, sensitive data |
| **security/access-control** | RBAC, role, permission, MFA, SSO, authentication, authorization, least privilege, identity, service principal |
| **security/audit-logging** | audit trail, log retention, SIEM, monitoring, alert, incident response, forensic, log aggregation |
| **infrastructure/compute** | VM, virtual machine, node, SKU, auto-scale, reserved instance, spot, CPU, memory, instance type |
| **infrastructure/networking** | VNet, subnet, NSG, firewall, load balancer, DNS, peering, private endpoint, routing, bandwidth |
| **infrastructure/storage** | disk, blob, storage account, retention, backup, replication, tier, archive, data lake |
| **infrastructure/cicd-pipeline** | pipeline, deployment, release, rollback, approval gate, staging, production, artifact, build |
| **infrastructure/iac-modules** | module, template, bicep, terraform, reusable, wrapper, catalog, IaC |
| **devops/deployment-automation** | deploy script, automation, blue-green, canary, feature flag, zero-downtime, runbook |
| **devops/observability** | metric, trace, log, dashboard, alert, SLO, SLI, latency, error rate, health check |
| **devops/environment-management** | environment, dev, staging, prod, secret, config, env var, parameter, environment parity |
| **devops/ci-cd-orchestration** | workflow, trigger, CI, CD, GitOps, branch strategy, PR, merge, gate, dependency chain |
| **platform/spec-system** | spec format, frontmatter, versioning, tier hierarchy, category, precedence, spec-id |
| **platform/iac-linting** | lint, code quality, PSScriptAnalyzer, bicep lint, style, naming convention |
| **platform/artifact-org** | directory, folder structure, naming, convention, organization, repository layout |
| **platform/policy-as-code** | Azure Policy, policy definition, initiative, remediation, compliance report, deny effect |

---

## Decision 5: Idempotency Mechanism

**Decision**: Before writing any spec file, the script checks if `specs/<tier>/<category>/spec.md` already exists. If it does and `-Force` is not set, the file is skipped with a warning (not an error). Category entries in `_categories.yaml` are deduped by `spec_id` field.

**Rationale**: Re-running after a partial failure must be safe. A user should be able to run the tool on the same transcript twice without corrupting the spec tree.

**Alternatives considered**:
- Always overwrite: Destroys human edits made to drafts. Rejected.
- Hash-based: Compare content hash; only overwrite if changed. Too complex for v1, deferred.
- Bail on first conflict: Too fragile for normal use. Rejected.

---

## Decision 6: New category naming guardrails

**Decision**: The script validates AI-proposed new category names against the following rules before writing:
- Directory name: `^[a-z][a-z0-9-]+$` (lowercase kebab-case)
- Spec-id: `^[a-z][a-z0-9-]{1,7}$` (2–8 chars, lowercase alphanumeric + hyphen)
- Must not conflict with an existing spec-id across the entire spec tree (global uniqueness)

If validation fails, the entry is skipped with an error report; the script continues for remaining entries (non-blocking failure, but exit code = 1).

---

## Decision 7: Semantic Category Matching with Hysteresis Bias

**Decision**: The agent evaluates each extracted group against all existing categories in the same tier using a 4-tier semantic classifier before deciding whether to create a new category. The classifier has a built-in bias toward reusing existing categories.

**Classifier outcomes**:

| Signal | Classification | Action |
|---|---|---|
| Identical category name | EXACT MATCH | UPDATE existing spec |
| Same primary domain, ≥60% concept overlap (shared nouns/verbs/subjects) | CLOSE MATCH | UPDATE existing spec; show match rationale in grouping plan |
| Same broad domain, but orthogonal concern — different lifecycle phase, different actor, or different enforcement boundary | AMBIGUOUS | Present A/B choice in Step 5; A (extend existing) is the default |
| Different primary domain, no meaningful concept overlap | NO MATCH | Propose NEW CATEGORY; requires explicit user confirmation |

**Hysteresis rule** — a new category MUST NOT be proposed unless at least one of the following split conditions is clearly met:
- (a) The extracted items address a **lifecycle phase** not present in any existing same-tier category
- (b) The extracted items introduce a **distinct actor or authority boundary** not represented in any existing same-tier category
- (c) The extracted items have **zero normative overlap** with all existing same-tier categories AND the closest existing category would require renaming or radical scope expansion to accommodate them

**Rationale**: Without a bias toward existing categories, the agent exhibits "category proliferation" — every transcript produces new categories for topics that already belong to existing ones, just under slightly different names. The hysteresis rule makes the stable state (existing category) the path of least resistance, requiring a concrete justification to break out.

**Alternatives considered**:
- Simple name-match only (original v1.0.0 behavior): Rejects everything not found by exact name. Produces excessive new categories for synonymous or closely related topics. Rejected.
- Pure semantic similarity threshold (no explicit split conditions): Gives the agent a single judgment call with no checklist. Inconsistent across sessions. Rejected — the three split conditions make the decision auditable and reproducible.
- Fully automatic merge with no AMBIGUOUS category: Would silently merge distinct concerns. Rejected — the AMBIGUOUS path preserves user authority over genuinely unclear cases.

**Worked example**:

Transcript excerpt: *"We discussed requiring cost-allocation tags on all new resource groups and flagging untagged resources monthly."*

Existing same-tier (platform) categories: `governance`, `spec-system`, `artifact-org`, `category-spec-system`, `transcript-ingestion`

Evaluation:
- `governance` — shares subject matter (resource tagging, compliance enforcement, policy mandate). Concept overlap: tagging policy, governance review, platform mandate. **→ CLOSE MATCH** (≥60% overlap with governance). Action: UPDATE `specs/platform/governance/spec.md`, match rationale: *"65% concept overlap — cost-allocation tagging is a governance enforcement requirement."*
- No split condition applies: (a) same lifecycle as existing governance requirements (ongoing enforcement); (b) same actor (platform governance); (c) normative overlap exists.
- Result shown in grouping plan: `UPDATE specs/platform/governance/spec.md` *(close match: 65% concept overlap — adding cost-allocation tagging enforcement)*
- NOT proposed as new category `platform/cost-tagging`.

---

| Unknown | Resolution |
|---|---------|
| How does AI get invoked? | Human-in-the-loop: agent mode, no API calls in scripts |
| What format does AI return? | The agent writes specs directly via toolkit scripts — no manifest export required |
| How are tiers mapped? | Signal vocabulary in template anchors AI classification |
| How are new categories handled? | `register-category.ps1` validates name/spec-id, updates `_categories.yaml` + `specs.yaml` idempotently |
| How is idempotency enforced? | Existence check on spec file path; spec-id dedup in category registry |
| Where do scripts live? | `.specify/scripts/powershell/register-category.ps1`, `write-spec.ps1` |
| Where does the template live? | `.specify/templates/transcript-analysis-template.md` |
| What's the platform category? | `transcript-ingestion`, spec-id `txin`, registered in `specs/platform/_categories.yaml` |
| What is "close enough" for category reuse? | CLOSE MATCH (≥60% concept overlap) → UPDATE; AMBIGUOUS → user choice (default: extend existing); NO MATCH → NEW CATEGORY with hysteresis check |
| How does the agent give progress feedback? | Three-phase model (Phase 1: parallel context build, Phase 2: plan/clarify, Phase 3: parallel write with per-group ▶/✓/✗ markers) |
| How is PII/privacy handled in spec outputs? | Agent MUST NOT reproduce raw transcript text, speaker names, or attribution — see Decision 9 |
| What happens on unreadable/corrupt/empty transcript? | Abort with chat error, no writes — see Decision 10 |
| What happens on zero tier-signal extraction? | Warn user and ask for explicit confirmation before ending session — see Decision 10 |

---

## Decision 8: Phased Execution Model & Parallel Tool Call Batching

**Decision**: The agent processes every transcript in exactly three phases that cannot be reordered:
- **Phase 1 — Context Build**: All file reads (transcript, specs.yaml, every `_categories.yaml`, all UPDATE-candidate spec.md files) are issued as a single parallel tool call batch. Upon completion the agent posts a "Context loaded" banner.
- **Phase 2 — Plan & Clarification**: Extraction, grouping plan proposal, clarifying Q&A (max 5), conflict resolution. No file writes.
- **Phase 3 — Parallel Write Execution**: Each confirmed group gets a ▶ start marker before its first tool call and a ✓/✗ completion marker after. Independent groups (non-overlapping file paths and registry targets) are batched as parallel tool calls.

**Rationale**: Without the context-build phase, the agent may begin writing before it has read all relevant existing specs, causing missed UPDATE candidates and false-new-category proposals. Batching reads in Phase 1 provides a concrete, visible "loaded" checkpoint the user can see before analysis begins. Phase 3 parallelism is the largest performance opportunity — a 5-group transcript involves at least 10 I/O operations that can mostly overlap. The per-group progress markers give the user immediate feedback without waiting for the full session to complete.

**Alternatives considered**:
- Lazy reads (read only specs needed as groups are confirmed): Defers reads to Phase 3, eliminating the context banner and making conflict detection incomplete (agent hasn't read all upstream specs upfront). Rejected.
- Sequential Phase 3 writes (one group at a time): Guaranteed safe but 3–5× slower. Rejected in favor of parallelism with path-overlap check.
- Progress via agent "thinking" dots only: No structured markers, user cannot distinguish between slow reasoning and slow I/O. Rejected in favor of explicit ▶/✓/✗ markers.

**Constraint on parallelism**: Phase 3 groups sharing a `_categories.yaml` write target MUST be serialized (the `register-category.ps1` call for tier A's new categories must complete before another new-category registration for the same tier begins, to avoid double-increment of `category-count`). Groups writing to different tiers are always safe to parallelize.

---

## Decision 9: Privacy Guardrail — No Raw Transcript Content in Spec Files

**Decision**: The agent MUST NOT reproduce raw transcript excerpts, speaker names, or personal attribution in any generated spec file. All spec content MUST be expressed as requirements, constraints, and decisions only — no narrative, no attributed quotation.

**Rationale**: Meeting transcripts may contain personal names, off-the-record remarks, sensitive business information discussed informally, and PII (participant names, roles, contact information). Spec files are committed to version-controlled repositories and may be shared broadly. Leaking transcript source text into specs would (a) violate reasonable speaker privacy expectations, (b) create a corporate record of informal remarks that were not intended as policy, and (c) potentially include PII in public repositories.

**Scope of the guardrail**:
- Prohibited: Direct quotes, paraphrased sentences attributing a decision to a named speaker, meeting summary prose
- Required: Requirements phrased as "The system MUST...", constraints phrased as "X MUST NOT exceed Y", decisions phrased as "Decision: [what was decided]"
- The `requested-by: "transcripttospecs"` field records provenance at the system level without attributing to individuals

**Alternatives considered**:
- Allow paraphrased attribution only: Still creates a discoverable link from a named person to a decision. Rejected.
- Allow attribution with an opt-in flag: Adds complexity, easy to misuse. Rejected for v1.

---

## Decision 10: Failure Mode Differentiation

**Decision**: The agent applies differentiated handling based on failure type:
1. **Unreadable, empty, or corrupt transcript file**: Abort immediately with a clear error message in chat. MUST NOT attempt any spec writes, registry updates, or Phase 2/3 processing.
2. **Zero tier-signal content extracted** (file is readable but contains no classifiable decisions, requirements, or constraints): MUST NOT silently exit. Warn the user with a brief explanation (e.g., "No tier-relevant content found in this transcript") and ask for explicit confirmation before ending the session — giving the user a chance to clarify or re-point to a different file.

**Rationale**: These two failure modes require different responses. An unreadable file is a hard precondition failure — no further processing is meaningful. A zero-signal result is a soft outcome — the file may be a valid transcript of a non-architectural meeting, or the user may have pointed to the wrong file, or the tier vocabulary may need expanding. Silent exit on zero-signal would leave the user with no feedback and no recourse.

**Exit behavior in each case**:
- Unreadable/empty/corrupt: Agent ends Phase 1 with error banner; session terminates; no writes
- Zero signal: Agent ends Phase 2 with warning; prompts user; if user confirms, session ends without writes; if user provides correction, agent re-runs Phase 1 from scratch with the corrected input
