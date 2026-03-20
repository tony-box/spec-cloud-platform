# Getting Started

This repository is a **Spec-Cloud Platform Template** — a pre-wired workspace for
AI-assisted architecture specification using GitHub Copilot Chat.

## Prerequisites

- VS Code with GitHub Copilot Chat extension
- Git ≥ 2.25, PowerShell ≥ 7.0

## Quick Start

### 1. Run the prerequisites check

```powershell
.\.specify\scripts\powershell\check-prerequisites.ps1
```

### 2. Drop your meeting transcripts

Place `.md` or `.txt` meeting transcript files in the `meetings/` folder:

```
meetings/
  q1-planning-2026.md
  architecture-review-2026-02.md
```

### 3. Invoke the transcript ingestion agent

Open GitHub Copilot Chat and run:

```
@transcripttospecs process meetings/q1-planning-2026.md
```

The agent will:

1. Extract architectural decisions from the transcript
2. Classify each decision into the correct specification tier
3. Detect conflicts with existing higher-authority specs (surfaced for human review)
4. Write compliant spec drafts to `specs/`
5. Register new categories in `_categories.yaml` and `specs.yaml`

> On first run, any missing `_categories.yaml` skeletons are auto-created (bootstrap).

---

## Specification Tier Hierarchy

Tiers are ordered by authority — higher tiers win when conflicts arise.

| Priority | Tier           | Scope                                          |
|----------|----------------|------------------------------------------------|
| 0        | Platform       | Framework, tooling, templates, agent rules     |
| 1        | Business       | Cost governance, compliance, change management |
| 2        | Security       | Access control, audit logging, data protection |
| 3        | Infrastructure | Compute, networking, storage, IaC modules      |
| 4        | DevOps         | CI/CD, observability, deployment automation    |
| 5        | Application    | Application-level architecture                 |

---

## Repository Structure

```
.github/agents/          GitHub Copilot agent definitions
.specify/scripts/        PowerShell helper scripts
.specify/templates/      Spec, plan, and task scaffolding templates
artifacts/               IaC modules and application deliverables
meetings/                Drop transcript files here
specs/                   Generated specification documents
```

---

Generated from template **template/v1.0.9**.
