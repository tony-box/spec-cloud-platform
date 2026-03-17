# To-Do: Tiered Spec UX + Role Cascade Improvements (Revised Draft)

## 1. Align Canonical Hierarchy (Highest Priority)

- [x] Reconcile tier precedence across constitution, root manifest, and tier indexes.
- [x] Update root manifest tier order and priorities to match constitution as source of truth.
- [x] Remove contradictory precedence notes from tier index files.
- [x] Add a single canonical hierarchy section in one registry file and reference it everywhere else.
- [x] Introduce two explicit platform scopes:
- [x] `platform-meta-governance` (framework control, highest authority)
- [x] `platform-content-standards` (content-tier constraints)
- [x] Define enforcement rule: meta-governance can override every tier; content-standards still participate in normal cascade.
- [ ] Add examples showing platform framework changes affecting business/security/infrastructure/devops/application.

Notes Expanded:
- Goal confirmed: platform-owned spec-system design should govern all downstream tiers.
- Proposed technical shape: keep one canonical registry for precedence, add a separate authority-scope model.
- Design option A (recommended): one registry with two fields per tier: `priority` and `authority-scope`.
- Design option B: two linked registries, one for precedence and one for governance authority.
- Notes: go with option A

Discussion Prompts:
- Decide if platform-content should always win over business-content, or only platform-meta should always win.
- Decide whether manual override is ever allowed for emergency cases.
- Notes: Platform meta should always win. BUT yes, there should be an override mechanism allowed

## 1A. Deterministic Script-Driven Controls (Platform-Meta)

- [x] Add a platform-meta decision policy: deterministic outputs must be script-driven.
- [x] Add a companion policy: interpretation-friendly outputs may be spec/template-driven.
- [x] Mirror Speckit split of responsibilities:
- [x] scripts own deterministic scaffolding, validation, and gating
- [x] templates own structured content guidance and human/AI interpretation zones
- [x] Create a classification matrix for each toolkit component:
- [x] `execution-mode: script-enforced` (no AI/user interpretation in output shape)
- [x] `execution-mode: spec-interpreted` (AI/user interpretation allowed within constraints)
- [x] Require every platform toolkit component to declare one execution mode in metadata.
- [x] Require every script-enforced component to provide:
- [x] deterministic input contract
- [x] deterministic output contract
- [x] idempotency behavior
- [x] validation checks
- [x] Add CI gate: fail if a script-enforced component is implemented via template-only flow.
- [x] Add CI gate: fail if component metadata is missing `execution-mode`.
- [x] Add script interface standard (aligned with Speckit patterns):
- [x] predictable CLI parameters (`-Json`, `-Help`, explicit required args)
- [x] deterministic machine-readable output mode (`-Json`)
- [x] prerequisite checks before mutation
- [x] explicit non-zero exit on gate failures
- [x] idempotent rerun behavior for same inputs

Mandatory Script-Enforced Example:
- [x] Application registration is script-enforced only.
- [x] Add/confirm script path for registration workflow (create/update/retire) under `.specify/scripts/powershell/`.
- [x] Ensure registration script writes all lifecycle/history only to `specs/application/_index.yaml`.
- [x] Ensure registration script behavior is deterministic across runs with identical inputs.
- [x] Add a paired validation script/gate for registry integrity, following Speckit prerequisite-check style.

Decision Rule (Platform Toolkit):
- If output must always be consistent and non-interpretable, use scripts.
- If output benefits from guided interpretation and variation, use specs/templates.

Speckit Reference Patterns To Reuse:
- Script-first orchestration with common helpers and path resolution (`common.ps1`).
- Deterministic setup scripts that create/update files in a known location (`setup-plan.ps1`, `setup-application-artifacts.ps1`).
- Mandatory preflight checks and fail-fast gates before downstream operations (`check-prerequisites.ps1`).
- Template copy/fill for human-authored or AI-assisted content, not deterministic state changes (`spec-template.md`, `plan-template.md`, `tasks-template.md`).
- Optional JSON output mode for automation and CI consumption.

Discussion Prompts:
- Confirm where this policy lives as canonical source (constitution vs specs/specs.yaml vs both).
- Confirm if emergency override can bypass script-enforced mode, and how it is audited.
- Confirm naming convention for deterministic platform scripts (e.g., `platform-<capability>.ps1`).

## 2. Complete DevOps Tier Coverage

- [x] Add `devops` tier to `specs/specs.yaml` tiers and precedence rules.
- [x] Add `devops` category entries to the root manifest categories map.
- [x] Add/verify conflict and precedence examples involving `devops`.
- [ ] Verify all lower tiers validate against `specs/devops/**/spec.md`.
- [x] Add at least two real conflict scenarios:
- [x] observability vs cost constraints
- [x] deployment automation vs governance approval gates

## 3. Fix Application Registry Accuracy

- [x] Keep `specs/application/_index.yaml` intentionally empty until first application exists.
- [x] Add explicit state metadata: `registry-state: empty-initialized`.
- [x] Register app at spec creation time (trigger: create `specs/application/<app-id>/spec.md`).
- [x] Auto-create registry entry with initial `status: draft` when app spec is created (script-enforced path, not template interpretation).
- [x] Add lifecycle statuses: `draft`, `active`, `retired`.
- [x] Add required fields for each app entry: `app-id`, `status`, `created`, `depends-on`, `compliance-state`.
- [x] Add retirement metadata fields: `retired-on`, `retired-by`, `retirement-reason`.
- [x] Store all application lifecycle metadata/history only in `specs/application/_index.yaml` (no sidecar files, no duplicate history stores).
- [x] Enforce soft-delete as the default behavior through prompt-driven workflows.
- [x] Allow manual hard-delete (registry entry removal by hand) as a clean purge path.
- [x] Ensure hard-delete requires no metadata cleanup outside the registry file.
- [x] Add CI check: fail if app directories exist but registry has no corresponding app entries.
- [x] Add CI check: fail if `active` app entries are missing required metadata.
- [x] Add CI check: warn (not fail) when `retired` apps have unresolved dependency references.

Notes Expanded:
- Current assumption is correct: no applications yet.
- Improvement focus should be auto-registration and drift prevention instead of manual population now.
- Decision: registration happens at spec creation time, not at deploy-ready milestone.
- Decision: soft-delete is the prompt-driven default path.
- Decision: manual hard-delete is allowed and should be a one-file clean action (no extra metadata cleanup elsewhere).
- Decision: application history must be self-contained in the registry file.

Discussion Prompts:
- Confirm exact trigger implementation path (template hook vs validation script auto-fix).
- Confirm CI behavior for manual hard-delete: should unregistered app folders be warning-only or fail-fast.

## 4. Standardize Role Context Metadata

- [x] Define a required role context block for specs, plans, and tasks.
- [x] Add fields: `declared-role`, `authority-scope`, `upstream-snapshot`, `cascade-run-id`.
- [x] Add fields: `change-intent`, `decision-mode`, `requested-by`, `approved-by` (optional for early phase).
- [x] Update templates so new artifacts always include role context metadata.
- [x] Backfill key existing files with the new metadata format.

Definition Clarifications:
- `upstream-snapshot`: a pinned reference to upstream spec versions used during decision time (for reproducibility).
- `role context metadata` purpose: proves who made the change, under what authority, and against which upstream constraints.

Discussion Prompts:
- Snapshot format decision: explicit version map vs hash only.
- Decide if `approved-by` is mandatory for production-impacting changes.

## 6. Add Explainability + Audit Trail

- [ ] Record why decisions were made (rule + source reference).
- [ ] Track lineage: source spec change -> impacted specs -> generated artifacts.
- [ ] Store cascade run metadata for each change request.
- [ ] Add a lightweight report output for reviewer sign-off.
- [ ] Add two outputs:
- [ ] human-readable summary report
- [ ] machine-readable JSON trace report

## 7. Integrate Agent Workflow with Spec-Driven Pattern

- [ ] Define role-locked orchestration flow: clarify -> specify -> plan -> tasks -> analyze -> implement.
- [ ] Enforce consistent role context across all agent steps.
- [ ] Add a handoff payload schema between steps (role, snapshot, conflicts, approvals).
- [ ] Block implementation if upstream validation or role authority checks fail.
- [ ] Add required checkpoint after `analyze`: explicit pass/fail gate before `implement`.

## 8. Validation + Tooling Enhancements

- [ ] Implement/finish `specs/specs-validate.ps1` for hierarchy, dependencies, and schema checks.
- [ ] Implement/finish `specs/specs-hierarchy.ps1` to explain precedence decisions.
- [ ] Implement/finish `specs/specs-discovery.ps1` for dependency and impact queries.
- [ ] Add CI checks that fail when hierarchy contradictions are introduced.
- [ ] Add CI checks that fail when app registry drift is detected.
- [ ] Add a quick local pre-commit validation command for contributor UX.
- [ ] Add deterministic workflow checks aligned to Speckit conventions:
- [ ] verify script-enforced components expose `-Json` mode for automation
- [ ] verify prerequisite gate runs before any mutating script action
- [ ] verify template-only paths are not used for script-enforced components

## 9. UX Review Checklist (For Final Sign-Off)

- [ ] Role switching is explicit and visible in every change workflow.
- [ ] Users can preview cascade impact before writing files.
- [ ] Conflicts are auto-explained with references to governing rules.
- [ ] App registry and manifest stay synchronized automatically.
- [ ] Agent-assisted flow works without bypassing governance rules.
- [ ] Audit report is understandable by both engineers and non-engineering stakeholders.

## 10. Next Conversation Agenda (To Hammer Out Details)

1. Confirm authority model: platform-meta always wins vs platform-content behavior.
2. Confirm script-enforced vs spec-interpreted policy and component classification matrix.
3. Choose role metadata schema and upstream-snapshot format.
4. Choose logging defaults, retention, and report mandatory scope.
5. Confirm application registration lifecycle triggers.
6. Lock acceptance criteria for first implementation milestone.

## Suggested Execution Order

1. Align canonical hierarchy and authority model.
2. Complete DevOps coverage and app registry lifecycle rules.
3. Finalize role metadata schema and snapshot format.
4. Implement role-switch preview UX, explainability, and shared logging.
5. Integrate agent gating flow and complete tooling/CI enforcement.