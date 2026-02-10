# Research Decisions: Patio App IaC

## Decision 1: IaC Language and Module Strategy

**Decision**: Use Bicep with Azure Verified Module (AVM) wrapper modules from the infrastructure/iac-modules catalog.

**Rationale**: The infrastructure/iac-modules spec requires AVM-based wrappers to enforce security, compliance, and cost defaults while keeping application teams within approved parameters.

**Alternatives considered**:
- Terraform modules: rejected because the upstream module catalog and linting standards are Bicep-focused.
- Raw ARM templates: rejected due to lack of standardized wrapper enforcement.

## Decision 2: CI/CD Orchestration

**Decision**: Use GitHub Actions pipelines aligned with infrastructure/cicd-pipeline standards, including workload criticality declaration and cost variance gates.

**Rationale**: The infrastructure/cicd-pipeline spec mandates GitHub Actions, cost validation, and approval gates tied to governance and business cost baselines.

**Alternatives considered**:
- Manual deployments: rejected by infrastructure/cicd-pipeline requirements.
- Other CI/CD platforms: deferred until devops/ci-cd-orchestration spec is finalized.

## Decision 3: Environment Baseline

**Decision**: Plan for development, testing, and production environments with workload criticality set per environment.

**Rationale**: The Patio spec assumes at least three environments and upstream compute/networking/storage specs are tiered by criticality.

**Alternatives considered**:
- Single environment: rejected because it cannot satisfy governance and separation requirements.
- Additional environments (staging, sandbox): deferred pending product owner confirmation.

## Decision 4: Region and Data Residency

**Decision**: Restrict deployments to US Azure regions only.

**Rationale**: The business/compliance-framework spec requires approved US-only regions unless legal approval is documented.

**Alternatives considered**:
- Multi-region outside US: rejected pending compliance approval.

## Decision 5: Security and Audit Defaults

**Decision**: Enforce AES-256 at-rest encryption, TLS 1.2+ in transit, Azure Key Vault Premium for production secrets, and 3-year audit log retention.

**Rationale**: Security/data-protection and security/audit-logging specs require these controls and declare them non-negotiable.

**Alternatives considered**:
- Standard Key Vault tier for production: rejected because HSM-backed keys are mandatory.

## Decision 6: Observability Baseline

**Decision**: Align with security/audit-logging requirements now and refine observability once devops/observability is finalized.

**Rationale**: DevOps observability is a placeholder, but audit logging requirements are active and binding.

**Alternatives considered**:
- Delay logging requirements: rejected because audit logging is mandatory.

## Open Confirmations (Assumptions Used)

- Production workload criticality: assumed non-critical unless product owner declares critical.
- Additional environments (staging/sandbox): not required unless product owner requests.
- Data classification specifics: assumed confidential by default per spec assumptions.
