---
tier: platform
category: transcript-ingestion
spec-id: txin
artifact-type: template
execution-mode: spec-interpreted
version: "1.0.0-draft"
description: "Tier signal vocabulary and extraction guidance for the transcripttospecs agent"
created: 2026-03-17
---

# Transcript Analysis Template

**Purpose**: Guide the `transcripttospecs` agent through structured extraction, tier-category mapping, conflict detection, and grouping of meeting transcript content into compliant spec drafts.

This template is **spec-interpreted** — it provides structure, vocabulary, and guardrails. The agent applies judgment within those constraints. Variation in extraction is intentional and expected.

---

## Execution Model Overview

The `transcripttospecs` agent operates in three sequential phases. No phase may be skipped.

| Phase | Steps | Activity | File Writes? |
|---|---|---|---|
| **Phase 1 — Context Build** | 1–2 | Parallel read of transcript + catalog + existing specs; post ✅ Context loaded banner | ❌ None |
| **Phase 2 — Plan & Clarification** | 3–6b | Tier extraction, semantic matching, conflict detection, grouping plan, user confirmation | ❌ None |
| **Phase 3 — Parallel Write Execution** | 6c–7 | Execute confirmed writes with ▶ / ✓ / ✗ progress markers; post session summary | ✅ Yes |

**Phase 3 gate**: the agent MUST NOT begin Phase 3 until the user explicitly confirms the grouping plan presented at the end of Phase 2.

---

## 1. Tier Signal Vocabulary

Use these signals to map each extracted statement to exactly one tier + category pair. When multiple signals apply, use context to disambiguate (see "Disambiguation Rules" below).

### Platform Tier (priority 0 — highest authority)
> Covers: the spec system itself, code quality standards, artifact structure, governance framework

| Signal keywords | Likely category |
|---|---|
| spec system, spec template, category catalog, tier hierarchy, spec-id, frontmatter, specs.yaml | `spec-system` |
| PSScriptAnalyzer, linting, approved-verbs, bicep lint, checkov, eslint, code quality standard | `iac-linting` |
| artifact directory, naming convention, app directory structure, scaffolding script | `artifact-org` |
| Azure Policy, policy-as-code, deny effect, compliance audit, remediation task | `policy-as-code` |
| transcript ingestion, spec generation from meetings, agent mode, write-spec, register-category | `transcript-ingestion` |

### Business Tier (priority 1)
> Covers: budgets, SLAs, operational mandates, compliance obligations, approval processes

| Signal keywords | Likely category |
|---|---|
| budget, cost target, cloud spend, reserved instance, savings plan, FinOps, cost reduction, TCO | `cost` |
| approval workflow, change board, SLA, audit trail, policy gate, governance process | `governance` |
| NIST, ISO 27001, SOC 2, regulatory, compliance framework, FedRAMP, HIPAA, PCI | `compliance-framework` |

### Security Tier (priority 2)
> Covers: authentication, authorization, encryption, audit logging, threat management

| Signal keywords | Likely category |
|---|---|
| RBAC, role assignment, MFA, conditional access, zero-trust, privileged identity, identity, authentication | `access-control` |
| encryption at rest, TLS, key rotation, Key Vault, confidentiality, certificate management | `data-protection` |
| audit log, diagnostic setting, SIEM, activity log, log retention, security monitoring | `audit-logging` |

### Infrastructure Tier (priority 3)
> Covers: compute, networking, storage, IaC modules, CI/CD pipeline infrastructure

| Signal keywords | Likely category |
|---|---|
| VM size, SKU, scale set, virtual machine, reserved capacity, spot instance, burst | `compute` |
| VNet, subnet, NSG, peering, ExpressRoute, load balancer, DNS, firewall, private endpoint | `networking` |
| disk type, storage account, replication, backup, blob, lifecycle policy, archive | `storage` |
| Bicep module, AVM, Azure Verified Module, reusable module, IaC wrapper, module catalog | `iac-modules` |
| GitHub Actions pipeline, build agent, deployment pipeline, CI infrastructure, runner | `cicd-pipeline` |

### DevOps Tier (priority 4)
> Covers: deployment practices, observability, environment lifecycle, CI/CD orchestration

| Signal keywords | Likely category |
|---|---|
| blue-green, canary, rollback, deployment strategy, ship fast, zero-downtime deploy | `deployment-automation` |
| logging, metrics, tracing, alerting, SLI, SLO, dashboard, Application Insights, OpenTelemetry | `observability` |
| environment promotion, staging, dev/test/prod parity, configuration management, secrets management | `environment-management` |
| CI/CD workflow, pipeline orchestration, GitOps, branch strategy, pull request gate, release cadence | `ci-cd-orchestration` |

### Application Tier (priority 5 — lowest authority)
> Covers: features, APIs, SLAs, and architecture for a specific application

| Signal keywords | Likely category / application |
|---|---|
| user story, feature request, API endpoint, application SLA, response time, retry | Application-specific spec |
| [app name] architecture, [app name] deployment, [app name] integration | Existing application update |

---

### Disambiguation Rules

Some keywords appear across multiple tiers. Use these rules to resolve ambiguity:

| Ambiguous term | Resolution rule |
|---|---|
| "CI/CD" | If discussing **pipeline infrastructure** (agents, runners, tooling) → `infrastructure/cicd-pipeline`. If discussing **workflow orchestration** (flow, branching, gates) → `devops/ci-cd-orchestration`. |
| "deployment" | If discussing **deployment automation patterns** (blue-green, canary, rollback) → `devops/deployment-automation`. If discussing a **specific application**'s deployment plan → Application tier. |
| "cost" | If a **business budget target or mandate** → `business/cost`. If a **resource SKU choice** for cost reasons → `infrastructure/compute` or `infrastructure/storage`. |
| "compliance" | If a **regulatory framework obligation** → `business/compliance-framework`. If **policy enforcement tooling** → `platform/policy-as-code`. If **security controls** → `security/access-control` or `security/data-protection`. |
| "monitoring" | If discussing **application-level observability** (SLI, SLO, tracing) → `devops/observability`. If discussing **security audit trails** → `security/audit-logging`. |
| "environment" | If discussing **environment lifecycle and config** → `devops/environment-management`. If discussing **Azure regions/availability zones** → `infrastructure/networking` or `infrastructure/compute`. |
| Platform signal in application context | A transcript for a specific application mentioning "we need to follow the spec system" is an acknowledgment of constraints, **not** a platform spec item. Do not generate a platform spec from it. |

---

## 2. Extraction Algorithm

Follow these steps in order for every transcript.

### Step 1 — Extract Meeting Metadata

Record the following at the start of the session:
- **Date**: of the meeting (from transcript header or context clues)
- **Participants**: roles mentioned (e.g., Platform Eng, Security Lead, App Owner)
- **Purpose**: one-sentence summary of the meeting's stated goal

This metadata informs tone, urgency signals, and context for ambiguous statements.

### Step 2 — Extract Raw Statements

Scan the full transcript and extract every:
- **Decision**: "we agreed to...", "the standard will be...", "from now on..."
- **Requirement**: "we must...", "we need...", "it is required that...", "the system shall..."
- **Constraint**: "we cannot...", "never do...", "there is a hard limit of..."
- **Observation**: "the current state is...", "we noticed that..." (may inform requirements)
- **Action item with architectural implications**: "create a policy for...", "document the rule..."

Ignore: pure social/process chat, meeting logistics, scheduling, and items without architectural significance.

### Step 3 — Map Each Statement to Tier + Category

For each raw statement:
1. Apply the signal vocabulary table
2. Apply disambiguation rules if multiple tiers match
3. If confident: record `{ tier, category, statement }`
4. If not confident (signal absent or ambiguous after applying rules): mark as `{ tier: unknown, statement, reason_for_gap }`

**Precision over recall**: It is better to surface a statement as a gap (unclear) and ask one clarifying question than to misassign it to the wrong tier.

### Step 4 — Identify Gaps

Collect all `{ tier: unknown }` items. These become clarifying questions. Ask at most **5 questions total per session**, prioritized by impact (statements that could affect the most downstream tiers first).

Format for each clarifying question:
> ❓ "The transcript mentions [statement]. Should this be treated as a [tier A] constraint governing [category X], or a [tier B] constraint governing [category Y]?"

### Step 5 — Identify Conflicts with Existing Specs

For each confirmed tier+category mapping:
1. Check whether a spec already exists at `specs/<tier>/<category>/spec.md`
2. If it exists:
   a. **Additive check**: Read the existing spec's Requirements section. An item from the transcript is additive if it is NOT semantically equivalent to any already-present requirement
   b. **Conflict check**: Check all specs in tiers with lower priority numbers than the target tier. A conflict is a MUST / MUST NOT / SHALL / SHALL NOT statement in those specs that directly contradicts the proposed spec's content
3. Record for each: `{ existing: bool, additive: bool, conflicts: [ { spec-id, version, violated-statement } ] }`

---

## 3. Grouping Rules

**One spec per tier-category pair.**

- If a transcript produces 3 business/cost statements and 2 devops/observability statements → 2 spec files
- If 5 statements all map to `infrastructure/compute` → 1 spec file with all 5 requirements
- If topics span multiple categories within the same tier → separate spec per category (do NOT merge across categories)
- If a statement is partially business and partially security → create entries in both tiers; each spec references the other in `depends-on`

**Proposed grouping plan format** (present to user before writing anything):

```
📋 Proposed grouping plan — [N] spec(s) from this transcript:

1. specs/business/cost/spec.md  [NEW]
   Tier: business | Category: cost | Spec-id: cost (existing)
   Covers: 3 statements about reserved instance targets and budget alerts

2. specs/devops/ci-cd-orchestration/spec.md  [NEW]
   Tier: devops | Category: ci-cd-orchestration | Spec-id: cicd-orch (existing)
   Covers: 2 statements about deployment velocity and PR gate removal

3. specs/infrastructure/compute/spec.md  [UPDATE — additive]
   Tier: infrastructure | Category: compute | Spec-id: compute (existing)
   Covers: 1 new SKU constraint not yet in existing spec

Confirm this grouping plan? (yes / modify / cancel)
```

If a proposed spec has conflicts:
```
   ⚠️  Conflict with security/access-control v1.0.0 (REQ-AC-007)
```

---

## 4. Output Format

### Per-spec frontmatter JSON (pass to `write-spec.ps1 -FrontmatterJson`)

```json
{
  "tier": "<tier>",
  "category": "<category>",
  "spec-id": "<spec-id>",
  "version": "1.0.0-draft",
  "status": "draft",
  "compliance-state": "current",
  "description": "<one-line description of what this spec covers>",
  "role-context": {
    "declared-role": "platform",
    "authority-scope": "platform-meta-governance",
    "requested-by": "transcripttospecs",
    "decision-mode": "autonomous",
    "cascade-run-id": null,
    "approved-by": null
  },
  "depends-on": [],
  "conflict-flags": []
}
```

The `conflict-flags` array is empty unless the user chose "Write-with-flag" for one or more conflicts. Each flag entry:
```json
{
  "upstream-spec-id": "<spec-id>",
  "reason": "Brief description of the contradiction"
}
```

### Per-spec body skeleton

```markdown
# Specification: <Title>

**Tier**: <tier>
**Category**: <category>
**Spec ID**: <spec-id>
**Created**: <date>
**Status**: Draft

---

## Summary

<One paragraph describing what this spec governs and why it was produced from this transcript.>

---

## Requirements

<!-- Generated from transcript dated <date>. Review and refine before promoting from draft. -->

- **REQ-001**: <First requirement extracted from transcript>
- **REQ-002**: <Second requirement>

---

## Constraints

- <Any hard constraints or prohibitions extracted from the transcript>

---

## Decisions Captured

| Decision | Made by | Date | Rationale |
|---|---|---|---|
| <decision text> | <role/person> | <date> | <rationale if stated> |

---

## Open Questions

<!-- Items to resolve before promoting this spec from draft -->

- [ ] <Any open question that emerged during extraction or clarification>
```

### Session summary (post to chat after all writes complete)

```markdown
## 📋 transcripttospecs Session Summary

**Transcript**: `<file path>`
**Session date**: <date>

| Path | Action | Spec-id | Conflict flags |
|---|---|---|---|
| specs/business/cost/spec.md | created | cost | — |
| specs/devops/ci-cd-orchestration/spec.md | created | cicd-orch | — |
| specs/infrastructure/compute/spec.md | updated (additive) | compute | — |
| specs/devops/deployment-automation/spec.md | blocked | deploy | Conflict with security/access-control: REQ-AC-007 |

**New categories registered**: 0
**Amendment proposals written**: 0
**Topics skipped (already covered)**: 1 — `security/access-control` (fully covered)
**Clarifying questions asked**: 2 of 5
```
