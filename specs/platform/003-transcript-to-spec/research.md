# Research: AI Transcript Ingestion for Spec Generation

**Branch**: `003-transcript-to-spec` | **Date**: 2026-03-17 | **Phase**: 0 | **Location**: `specs/platform/003-transcript-to-spec/`

---

## Decision 1: Execution Model Split

**Decision**: Use a split-responsibility model — `transcript-to-specs` agent mode (spec-interpreted) handles analysis, clarification Q&A, conflict resolution, and grouping confirmation; `register-category.ps1` and `write-spec.ps1` (script-enforced) handle all deterministic file operations.

> **Clarification update (2026-03-17)**: Original decision specified `ingest-transcript.ps1` as the script-enforced component. This was superseded by Q5 in the clarification session: no monolithic `ingest-transcript.ps1`; the deterministic operations are split into purpose-specific scripts (`register-category.ps1`, `write-spec.ps1`) called by the agent.

**Rationale**: The platform execution-mode policy (`specs.yaml`) already defines this exact split. The *content extraction* from a transcript is inherently interpretive (AI judgment, variation expected) — it must be spec-interpreted. The *file writing, registry updating, and validation* must produce deterministic, reproducible results — they must be script-enforced. Conflating both into a single script would violate the policy; conflating both into a template would lose the deterministic guarantees on file output.

**Alternatives considered**:
- All-in-script: Would require embedding AI invocation logic in `.ps1`, forcing API keys or subprocess calls into the deterministic script layer. Rejected — violates execution-mode policy and creates security surface.
- All-in-template: Produces consistent guidance but no deterministic file writing. Rejected — no CI gate, no idempotency, no exit code enforcement.
- External service: A separate REST API or function app. Rejected — over-engineered for a toolkit-local capability; adds infrastructure dependency.

---

## Decision 2: AI Invocation Pattern

**Decision**: ~~The script renders the analysis template as a context document and passes it to the user's current AI agent as a structured prompt. The AI returns a structured `IngestionManifest` JSON block. The script parses that JSON and acts on it.~~ **SUPERSEDED by clarification Q1 + Q2 (2026-03-17).**

**Superseded by**: A `transcript-to-specs` VS Code agent mode. The user invokes the agent in Copilot Chat with a transcript file path. The agent handles analysis, clarification Q&A, and conflict resolution natively within the session — no manual AI handover step, no manifest JSON exchange between script and user. The split-responsibility principle from Decision 1 is preserved but the invocation boundary shifts: agent = reasoning layer, toolkit scripts = file I/O layer.

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

## Summary of Resolved Unknowns

| Unknown | Resolution |
|---|---|
| How does AI get invoked? | Human-in-the-loop: template rendered as context, AI returns JSON manifest |
| What format does AI return? | Fenced JSON block (`IngestionManifest`) |
| How are tiers mapped? | Signal vocabulary in template anchors AI classification |
| How are new categories handled? | Script validates name/spec-id, updates `_categories.yaml` + `specs.yaml` idempotently |
| How is idempotency enforced? | Existence check on spec file path; spec-id dedup in category registry |
| Where does the script live? | `.specify/scripts/powershell/ingest-transcript.ps1` (per toolkit conventions) |
| Where does the template live? | `.specify/templates/transcript-analysis-template.md` (per execution-mode policy) |
| What's the platform category? | `transcript-ingestion`, spec-id `txin`, registered in `specs/platform/_categories.yaml` |
