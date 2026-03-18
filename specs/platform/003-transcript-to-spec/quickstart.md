# Quickstart: transcript-to-specs Agent

**Branch**: `003-transcript-to-spec` | **Date**: 2026-03-17 | **Phase**: 1 | **Location**: `specs/platform/003-transcript-to-spec/`

---

## Prerequisites

- VS Code with GitHub Copilot Chat extension
- A meeting transcript saved as `.md` or `.txt` anywhere in the repo
- The `transcript-to-specs` agent mode installed (`.github/agents/transcript-to-specs.md` present in repo)

---

## Walkthrough: Q2 Planning Meeting -> Specs

### Step 1 - Prepare your transcript

Save the meeting transcript to a file. Markdown and plain text are both supported:

```
meetings/
L-- q2-planning-2026.md
```

The transcript can be a raw conversation dump, meeting notes, or an AI-generated summary. Participant names and roles help the agent produce better spec attribution, but are not required.

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

### Step 2 - Invoke the agent in Copilot Chat

Open Copilot Chat in VS Code and type:

```
@transcript-to-specs Please process this transcript: meetings/q2-planning-2026.md
```

The agent reads the file, loads the live category catalog, and analyzes the transcript using the tier signal vocabulary.

---

### Step 3 - Confirm the grouping plan

The agent presents a proposed grouping plan in chat before writing any files:

```
Here is my proposed grouping plan for the transcript:

1. business/cost -- Monthly cloud spend cap $50k, two-quarter target
2. infrastructure/compute -- VM SKU policy: DS3_v2 max without platform approval
3. business/compliance-framework -- GDPR Q3 audit: encryption at rest + 90-day log retention

Shall I proceed with this grouping? Reply yes to confirm, or describe any changes.
```

Reply **yes** (or request adjustments) to proceed.

---

### Step 4 - Answer clarifying questions (if any)

If the agent cannot fully resolve a topic from the transcript alone, it asks up to 5 clarifying questions, one at a time:

```
The transcript mentions "VM SKU policy" -- should this apply to all workloads
or only production environments?
```

Answer briefly and the agent continues.

---

### Step 5 - Resolve conflicts (if any)

If a proposed spec conflicts with an existing higher-tiered spec, the agent pauses:

```
WARNING Conflict detected: Proposed `devops/ci-cd-orchestration` spec conflicts
with `security/access-control` v1.0.0 (REQ-AC-007: production deployments require
change-board approval).

Choose:
(1) Block -- skip this spec until the security spec is amended
(2) Write with conflict flag
(3) Propose upstream amendment to security/access-control
```

Reply with 1, 2, or 3 for each conflict. The agent handles each conflict independently.

---

### Step 6 - Review the session summary

After all writes, the agent posts a summary:

```
Session complete

Path                                         Action   Conflict flag
----                                         ------   -------------
specs/business/cost/spec.md                  created  --
specs/infrastructure/compute/spec.md         created  --
specs/business/compliance-framework/spec.md  created  --

New categories registered: none
Conflicts handled: none
Topics skipped: none
```

Open any generated spec to review. Each has:
- Correct YAML frontmatter (tier, category, spec-id, version, `status: draft`)
- `role-context.requested-by: "transcript-to-specs"` and `decision-mode: autonomous`
- Executive Summary, Requirements, and Constraints derived from the meeting

Edit and refine as needed before committing.

---

## New Category Discovery

If the transcript mentions a topic not covered by any existing category:

```
Bob: We should define our disaster recovery strategy -- RPO 4 hours, RTO 8 hours.
```

The agent detects no matching category and proposes a new one:

```
No existing category matches the disaster-recovery topic.

Proposed new category:
- Tier: business
- Category name: Disaster Recovery
- Spec-id: dr
- Description: Business continuity objectives: RPO, RTO, failover strategy

Confirm this new category? Reply yes to register it and create the spec.
```

Reply yes. The agent calls `register-category.ps1` and then `write-spec.ps1` to create the spec.

---

## Updating an Existing Spec

If the transcript adds new requirements to an existing `business/cost/spec.md`:

```
Alice: Also add a quarterly reserved-instance review to the cost process.
```

The agent reads the existing spec, determines the transcript is additive, and proposes the addition:

```
business/cost/spec.md already exists. The transcript adds 1 new requirement
not currently captured:

- Quarterly reserved-instance review cadence

Add this to the existing spec? Reply yes to confirm, or no to skip.
```

Reply yes. The agent appends the addition via `write-spec.ps1 -Force`.

---

## Bootstrapping an Empty Project

If you are starting a new platform project with no existing specs, invoke the agent on your founding-vision document:

```
@transcript-to-specs Please process this transcript: docs/founding-vision.md
```

The agent creates all referenced `_categories.yaml` files and spec stubs from scratch. Confirm each grouping and new-category proposal in chat. You will have a complete initial spec tree in a single Copilot Chat session.
