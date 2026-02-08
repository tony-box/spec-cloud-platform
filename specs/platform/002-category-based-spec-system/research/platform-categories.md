# Phase 0 Research: Platform Tier Categories

**Task**: T004 - Define platform tier categories  
**Created**: 2026-02-07  
**Status**: Research Document

---

## Overview

Platform tier categories represent platform-wide policies, standards, and utilities that apply to all applications and infrastructure. These are meta-specifications about how specs themselves are managed, how code is linted, how policies are enforced, etc.

---

## Proposed Categories

### 1. Artifact-Org (`artifact-org`)

**Spec ID**: `artifact-org-001`  
**Purpose**: Application artifact organization, directory structure, file placement standards

**Independent Decisions**:
- Directory structure for applications (iac/, scripts/, docs/, etc.)
- Naming conventions for files and folders
- Placeholder files (README.md requirements, LICENSE)
- Artifact inventory and discovery mechanisms
- Versioning of artifacts (semantic versioning in filenames? metadata?)
- Relationship between artifacts and specs
- CI/CD artifact storage and retention
- Template repository organization

**Examples**:
- "All applications follow structure: iac/, scripts/, pipelines/, docs/, modules/"
- "README.md required in every directory"
- "All files follow kebab-case naming (deploy-app.ps1, not deployApp.ps1)"
- "Semantic versioning in artifact.version file (v1.2.3)"
- "Specifications live in specs/ tier folders; artifacts in artifacts/"

**Conflicts**:
- With platform/spec-system (specs organize themselves; artifacts organize applications)
- Generally independent—can change org structure without changing tools

**Reason for Independence**:
- Artifact organization is about discoverability and consistency
- Distinct from IaC linting, policy-as-code, spec structure

**Current Spec**: platform/001-application-artifact-organization (will convert to platform/artifact-org)

---

### 2. IaC-Linting (`iac-linting`)

**Spec ID**: `iac-linting-001`  
**Purpose**: Code quality standards for Bicep, Terraform, PowerShell, etc.

**Independent Decisions**:
- Bicep linting rules (naming conventions, module structure, parameter validation)
- Terraform linting rules (variable naming, output naming, complexity limits)
- PowerShell linting rules (style, naming, error handling)
- Code formatting standards (indentation, line length)
- Security-focused linting (hardcoded secrets detection, unsafe functions)
- Complexity thresholds (max file size, max nesting depth)
- Documentation standards (comments, examples)
- Test coverage requirements

**Examples**:
- "All Bicep files must use camelCase for variables, PascalCase for resources"
- "No hardcoded secrets; all secrets via Key Vault"
- "PowerShell: -ErrorAction Stop on all commands"
- "Max 200 lines per Bicep file; split larger files into modules"
- "All parameters must have @description() metadata"

**Conflicts**:
- None typically; linting is a best-practice layer

**Reason for Independence**:
- IaC linting is about code quality
- Distinct from policy-as-code (which enforces organizational policy)
- Distinct from artifact-org (which organizes files)

**Current Spec**: None (new category; related to DevOps best practices)

---

### 3. Policy-as-Code (`policy-as-code`)

**Spec ID**: `policy-as-code-001`  
**Purpose**: Azure Policy definitions, governance rules, compliance enforcement

**Independent Decisions**:
- Policy requirements (what's enforced at Azure API level)
- Allowed resource types (which cannot be deployed)
- Tag requirements (mandatory tags on resources)
- Encryption enforcement (must-have-encryption policies)
- Firewall rules (must have NSG attached, etc.)
- Backup policies (mandatory backups)
- Audit and compliance policies
- Remediation actions (auto-remediate or audit-only)

**Examples**:
- "All storage accounts must have encryption enabled (policy)"
- "All resources must be tagged with 'project' and 'owner' (policy)"
- "Only Azure-managed images in VMs; no custom images (policy)"
- "All VMs must have boot diagnostics enabled (policy)"
- "Policies auto-remediate; no manual exceptions except approved"

**Conflicts**:
- With infrastructure/* (policies restrict what infra engineers can do)
- With platform/iac-linting (linting is recommendations; policies are enforcement)

**Reason for Independence**:
- Policy-as-code is about organizational enforcement
- Distinct from code linting (which is quality) and artifact organization

**Current Spec**: None (new category; governance enforcement)

---

### 4. Spec-System (`spec-system`)

**Spec ID**: `spec-system-001`  
**Purpose**: How specs themselves are organized, versioned, discovered, and validated

**Independent Decisions**:
- Spec file format (YAML frontmatter + Markdown)
- Semantic versioning rules (when to increment major/minor/patch)
- Frontmatter fields required (tier, category, spec-id, version, status, etc.)
- Hierarchy and precedence rules (tier precedence, conflict resolution)
- Dependency declaration format (depends-on, precedence.overrides fields)
- Spec lifecycle states (draft, approved, deprecated, archived)
- Validation rules (circular dependency detection, reference validation)
- Discovery mechanisms (manifests, indexes, searchers)

**Examples**:
- "All specs must have frontmatter with tier, category, spec-id, version"
- "Versions follow semver: 1.0.0-draft → 1.0.0 → 1.1.0 (minor changes)"
- "Tier precedence: business > security > infrastructure > platform > application"
- "Category conflicts resolved by precedence.overrides field"
- "Specs marked deprecated must have 6-month deprecation period"

**Conflicts**:
- None typically; this is meta (specs about specs)

**Reason for Independence**:
- Spec-system is about the meta-structure
- Distinct from all other platform categories
- Changes to spec system don't require changing all specs (only add new requirements)

**Current Spec**: None (new category; this very architecture is the spec-system)

---

## Summary Table

| Category | Spec ID | Focus | Examples |
|----------|---------|-------|----------|
| Artifact-Org | artifact-org-001 | File placement and naming | iac/, scripts/, kebab-case |
| IaC-Linting | iac-linting-001 | Code quality standards | 200 lines max, camelCase |
| Policy-as-Code | policy-as-code-001 | Azure enforcement | Encrypt storage, tag all |
| Spec-System | spec-system-001 | Meta-specs about specs | YAML frontmatter, semver |

---

## Meta Observation

**Spec-System is Meta**: 
- artifact-org, iac-linting, policy-as-code are all technical standards
- spec-system is a meta-standard about how ALL specs (including these) are defined
- Result: spec-system changes might affect all tiers
- But spec-system changes are rare; most work is in lower levels

---

## Validation

- [X] 4 categories defined
- [X] Each represents distinct platform concern
- [X] Examples provided
- [X] Conflicts identified  
- [X] Spec IDs assigned
- [X] Meta-layer (spec-system) properly positioned

---

## Next Steps

1. Peer review with platform team: Agree on these categories?
2. Integration with T005: Map existing platform/001 to platform/artifact-org
3. Integration with T006: Identify platform conflicts with other tiers
