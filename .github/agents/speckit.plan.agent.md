---
description: Execute the implementation planning workflow using the plan template to generate design artifacts.
handoffs: 
  - label: Create Tasks
    agent: speckit.tasks
    prompt: Break the plan into tasks
    send: true
  - label: Create Checklist
    agent: speckit.checklist
    prompt: Create a checklist for the following domain...
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Role Continuity
- Preserve the last declared role for the session unless the user explicitly changes it.
- If the role is Application, preserve the last declared application target (NEW/EXISTING + app name) unless the user explicitly changes it.
- If the role is Platform/Business/Security/Infrastructure/DevOps, preserve the last declared category target unless the user explicitly changes it.
- If role, category target, or application target is unclear, ask for clarification rather than switching implicitly.
- **MANDATORY**: Before processing ANY request, validate that:
  - If role is Application: application target is declared (NEW: app-name or EXISTING: app-name)
  - If role is any other tier (Platform/Business/Security/Infrastructure/DevOps): category target is declared

## Outline

1. **Setup**: Run `.specify/scripts/powershell/setup-plan.ps1 -Json` from repo root and parse JSON for FEATURE_SPEC, IMPL_PLAN, SPECS_DIR, BRANCH. Only include `-AppName <name>` when the user is operating as **Role: Application** with a specified application target (NEW or EXISTING). For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

1a. **Application Artifact Organization** (MANDATORY for Application role only, per Constitution v2.1.0):
   - If role is **Application: NEW: [app-name]**:
     - Run script: `./.artifacts/.templates/scripts/create-app-directory.ps1 -AppName "[app-name]"`
     - This creates `/artifacts/applications/[app-name]/` with required subdirectories: `iac/`, `modules/`, `scripts/`, `pipelines/`, `docs/`
     - Validates directory structure and provides status
   - If role is **Application: EXISTING: [app-name]**:
     - Run script: `./.artifacts/.templates/scripts/validate-artifact-structure.ps1 -AppName "[app-name]"`
     - Validates that existing `/artifacts/applications/[app-name]/` structure is compliant
     - Provides validation report and next steps
     - If directory does NOT exist: Create using create-app-directory.ps1 and warn that it was auto-created
   - **If role is any other tier (Platform/Business/Security/Infrastructure/DevOps)**: Skip this step
   - **STOP and REPORT** if artifact organization script fails - do not proceed to step 2

2. **Load context**: Read FEATURE_SPEC and `.specify/memory/constitution.md`. Load IMPL_PLAN template (already copied).

2a. **Mandatory Tier Validation & Cascading Enforcement** (per Constitution v2.1.0 Principle III):
   - **Purpose**: Validate that all upstream tier specifications are compliant BEFORE creating downstream artifacts
   - **Process**:
     - Identify current role tier (Platform/Business/Security/Infrastructure/DevOps/Application)
     - For each upstream tier (higher priority):
       - Load all upstream tier specs using glob pattern: `specs/<upstream-tier>/**/spec.md`
       - For Application role: Load Platform → Business → Security → Infrastructure → DevOps specs
       - For DevOps role: Load Platform → Business → Security → Infrastructure specs
       - For Infrastructure role: Load Platform → Business → Security specs
       - For Security role: Load Platform → Business specs
       - For Business role: Load Platform specs
       - For Platform role: No upstream validation required
     - **Validation**: Ensure current spec does NOT violate any upstream tier specification constraints
     - **Documentation**: Add upstream spec versions to frontmatter `depends-on` field
   - **Failure Protocol**: If upstream violations found:
     - List violating upstream specs (tier, category, spec-id, version, specific constraint violated)
     - DO NOT proceed to phase execution
     - Return ERROR with remediation guidance
   - **Success**: All upstream specs validated, depends-on field documented, proceed to Phase 0

3. **Execute plan workflow**: Follow the structure in IMPL_PLAN template to:
   - Fill Technical Context (mark unknowns as "NEEDS CLARIFICATION")
   - Fill Constitution Check section from constitution
   - Evaluate gates (ERROR if violations unjustified)
   - Phase 0: Generate research.md (resolve all NEEDS CLARIFICATION)
   - Phase 1: Generate data-model.md, contracts/, quickstart.md
   - Phase 1: Update agent context by running the agent script
   - Re-evaluate Constitution Check post-design

4. **Stop and report**: Command ends after Phase 2 planning. Report branch, IMPL_PLAN path, and generated artifacts.

## Phases

### Phase 0: Outline & Research

1. **Extract unknowns from Technical Context** above:
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices task
   - For each integration → patterns task

2. **Generate and dispatch research agents**:

   ```text
   For each unknown in Technical Context:
     Task: "Research {unknown} for {feature context}"
   For each technology choice:
     Task: "Find best practices for {tech} in {domain}"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all NEEDS CLARIFICATION resolved

### Phase 1: Design & Contracts

**Prerequisites:** `research.md` complete

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Generate API contracts** from functional requirements:
   - For each user action → endpoint
   - Use standard REST/GraphQL patterns
   - Output OpenAPI/GraphQL schema to `/contracts/`

3. **Agent context update**:
   - Run `.specify/scripts/powershell/update-agent-context.ps1 -AgentType copilot`
   - These scripts detect which AI agent is in use
   - Update the appropriate agent-specific context file
   - Add only new technology from current plan
   - Preserve manual additions between markers

**Output**: data-model.md, /contracts/*, quickstart.md, agent-specific file

## Key rules

- Use absolute paths
- ERROR on gate failures or unresolved clarifications
