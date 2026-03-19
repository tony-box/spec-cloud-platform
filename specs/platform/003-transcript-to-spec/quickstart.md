# Quickstart: transcripttospecs Agent

**Branch**: `003-transcript-to-spec` | **Date**: 2026-03-17 (updated 2026-03-19) | **Phase**: 1 | **Location**: `specs/platform/003-transcript-to-spec/`

---

## Prerequisites

- VS Code with GitHub Copilot Chat extension
- A meeting transcript saved as `.md` or `.txt` anywhere in the repo
- The `transcripttospecs` agent mode installed (`.github/agents/transcripttospecs.agent.md` present in repo)

---

## Walkthrough: Q2 Planning Meeting → Specs

### Step 1 — Prepare your transcript

Save the meeting transcript to a file. Markdown and plain text are both supported:

```
meetings/
└── q2-planning-2026.md
```

The transcript can be a raw conversation dump, meeting notes, or an AI-generated summary. The agent extracts *decisions, requirements, and constraints* only — speaker names and personal attribution are never reproduced in generated spec files.

**Example transcript excerpt**:
```
Q2 Platform Planning 2026-03-15
Attendees: Alice (CTO), Bob (Platform Lead), Carol (Security Lead)

Alice: We need to keep cloud spend under $50k/month for the next two quarters.
Bob: Agreed. Let's also mandate all new VMs use DS3_v2 or smaller unless
     approved by the platform team.
Carol: We have a GDPR audit coming in Q3. All data at rest must be encrypted
       and we need a 90-day audit log retention minimum.
```

---

### Step 2 — Invoke the agent in Copilot Chat

Open Copilot Chat in VS Code and type:

```
@transcripttospecs Please process this transcript: meetings/q2-planning-2026.md
```

**Phase 1 begins immediately.** The agent issues all file reads in a single parallel batch and posts a context banner when complete:

```
✅ Context loaded
└─ Transcript:   q2-planning-2026.md (847 words)
└─ Tiers:        6 tiers in catalog
└─ Categories:   14 categories registered
└─ Existing specs loaded: 14
└─ UPDATE candidates: business/cost, business/governance
```

This banner confirms the agent has loaded all existing specs before proposing anything.

---

### Step 3 — Confirm the grouping plan

**Phase 2 begins.** The agent presents a proposed grouping plan in chat before writing any files:

```
Here is my proposed grouping plan for the transcript:

1. UPDATE business/cost — close match: adds monthly spend cap $50k + two-quarter target
2. infrastructure/compute — NEW: VM SKU policy: DS3_v2 max without platform approval
3. business/compliance-framework — UPDATE: GDPR Q3 audit: encryption at rest + 90-day log retention

Shall I proceed with this grouping? Reply yes to confirm, or describe any changes.
```

Reply **yes** (or request adjustments) to proceed.

---

### Step 4 — Answer clarifying questions (if any)

If the agent cannot fully resolve a topic from the transcript alone, it asks up to 5 clarifying questions, one at a time:

```
The transcript mentions "VM SKU policy" — should this apply to all workloads
or only production environments?
```

Answer briefly and the agent continues.

---

### Step 5 — Resolve conflicts (if any)

If a proposed spec conflicts with an existing higher-tiered spec, the agent pauses:

```
⚠️ Conflict detected: Proposed `devops/ci-cd-orchestration` spec conflicts
with `security/access-control` v1.0.0 (REQ-AC-007: production deployments require
change-board approval).

Choose:
(1) Block — skip this spec until the security spec is amended
(2) Write with conflict flag
(3) Propose upstream amendment to security/access-control
```

Reply with 1, 2, or 3 for each conflict. The agent handles each conflict independently.

---

### Step 6 — Watch Phase 3 progress

**Phase 3 begins** after conflicts are resolved. The agent posts a progress header then writes all groups — independent groups are batched in parallel:

```
▶ Processing 3 groups

▶ business/cost — update
▶ business/compliance-framework — update
✓ business/cost — updated (specs/business/cost/spec.md)
✓ business/compliance-framework — updated
▶ infrastructure/compute — create
✓ infrastructure/compute — created (specs/infrastructure/compute/spec.md)
```

If a write fails, you see a ✗ marker with the reason, and the agent continues with remaining groups.

---

### Step 7 — Review the session summary

After all writes, the agent posts a summary:

```
Session complete

Path                                         Action   Conflict flag
----                                         ------   -------------
specs/business/cost/spec.md                  updated  --
specs/infrastructure/compute/spec.md         created  --
specs/business/compliance-framework/spec.md  updated  --

New categories registered: none
Conflicts handled: none
Topics skipped: none
Errors: none

📝 All output specs are status: draft and require human review before promotion.
```

Open any generated spec to review. Each has:
- Correct YAML frontmatter (tier, category, spec-id, version, `status: draft`)
- `role-context.requested-by: "transcripttospecs"` and `decision-mode: autonomous`
- Executive Summary, Requirements, and Constraints derived from the meeting
- No raw transcript text, speaker names, or personal attribution

Edit and refine as needed before committing.

---

## New Category Discovery

If the transcript mentions a topic not covered by any existing category:

```
Bob: We should define our disaster recovery strategy — RPO 4 hours, RTO 8 hours.
```

The agent detects no matching category and proposes a new one:

```
No existing category matches the disaster-recovery topic.

Proposed new category:
- Tier: business
- Category name: disaster-recovery
- Spec-id: dr
- Description: Business continuity objectives: RPO, RTO, failover strategy
- Closest evaluated: business/governance — rejected: distinct lifecycle phase (incident response)
- Hysteresis condition met: (a) distinct lifecycle phase

Confirm? (yes / no / merge-into governance)
```

Reply **yes**. The agent calls `register-category.ps1` then `write-spec.ps1` and posts the ▶ / ✓ markers.

---

## Updating an Existing Spec

If the transcript adds new requirements to an existing `business/cost/spec.md`:

```
Alice: Also add a quarterly reserved-instance review to the cost process.
```

The agent reads the existing spec (during Phase 1, since it was flagged as an UPDATE candidate), determines the transcript is additive, and proposes the addition in Phase 2:

```
business/cost/spec.md already exists. The transcript adds 1 new requirement
not currently captured:

- Quarterly reserved-instance review cadence

Add this to the existing spec? Reply yes to confirm, or no to skip.
```

Reply **yes**. In Phase 3 the agent calls `write-spec.ps1 -Force` and posts the ▶ / ✓ markers.

---

## Bootstrapping an Empty Project

If you are starting a new platform project with no existing specs, invoke the agent on your founding-vision document:

```
@transcripttospecs Please process this transcript: docs/founding-vision.md
```

Phase 1 will load very quickly (no existing specs to read). The grouping plan will propose all new categories. Confirm each one in Phase 2, then watch Phase 3 create all `_categories.yaml` entries and spec stubs in parallel. You will have a complete initial spec tree in a single Copilot Chat session.
