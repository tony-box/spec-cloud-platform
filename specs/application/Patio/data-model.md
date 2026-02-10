# Data Model: Patio App IaC

## Entity: Environment Profile

**Purpose**: Defines each Patio environment and its operational constraints.

**Key Fields**:
- name (dev, test, prod)
- purpose
- workload_criticality (critical, non-critical, dev-test)
- isolation_boundary (VNet/subnet scope)
- region_policy (US-only)
- approval_requirements

## Entity: Access Model

**Purpose**: Defines roles, permissions, and approvers for Patio infrastructure access.

**Key Fields**:
- role_name
- scope (subscription, resource group, resource)
- permissions
- approver
- mfa_required (true/false)

## Entity: Data Classification Profile

**Purpose**: Captures data types and required protections.

**Key Fields**:
- data_type
- classification (confidential/default)
- encryption_requirement
- retention_policy
- residency_requirement

## Entity: Artifact Bundle

**Purpose**: Represents the IaC artifacts for Patio following platform organization standards.

**Key Fields**:
- path
- artifact_type (iac, modules, scripts, pipelines, docs)
- naming_convention
- validation_status

## Relationships

- Environment Profile references Access Model and Data Classification Profile.
- Artifact Bundle is scoped to Environment Profile and must align with Access Model and Data Classification Profile.
