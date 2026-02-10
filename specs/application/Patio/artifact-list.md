# Patio IaC Artifact Inventory

## Purpose

Track Patio IaC artifacts, versions, and locations for traceability.

## IaC Templates

- artifacts/applications/Patio/iac/main.bicep
- artifacts/applications/Patio/iac/config.bicep
- artifacts/applications/Patio/iac/security.bicep
- artifacts/applications/Patio/iac/monitoring.bicep
- artifacts/applications/Patio/iac/automation.bicep
- artifacts/applications/Patio/iac/dev.bicepparam
- artifacts/applications/Patio/iac/test.bicepparam
- artifacts/applications/Patio/iac/prod.bicepparam

## Scripts

- artifacts/applications/Patio/scripts/cost-estimate.ps1 (planned)
- artifacts/applications/Patio/scripts/verify-tier-compliance.ps1 (planned)

## Pipelines

- artifacts/applications/Patio/pipelines/deploy-infrastructure.yml (planned)

## Documentation

- artifacts/applications/Patio/docs/environment-matrix.md
- artifacts/applications/Patio/docs/iac-usage.md
- artifacts/applications/Patio/docs/security-controls.md
- artifacts/applications/Patio/docs/rollout.md
- artifacts/applications/Patio/docs/validation-log.md

## Versioning Notes

- Track AVM wrapper versions in module references once implementation begins.
- Update this inventory when artifacts are created or changed.
