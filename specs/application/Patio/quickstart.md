# Patio IaC Quickstart

## Purpose

This quickstart helps you locate Patio IaC artifacts and confirm required structure before implementation.

## Steps

1. Review the Patio specification and plan:
   - specs/application/Patio/spec.md
   - specs/application/Patio/plan.md
2. Confirm the artifact directory exists:
   - artifacts/applications/Patio/
3. Validate the artifact structure:
   - `./artifacts/.templates/scripts/validate-artifact-structure.ps1 -AppName "Patio"`
4. Place Patio IaC artifacts under:
   - artifacts/applications/Patio/iac/
5. Use approved wrapper modules from:
   - artifacts/infrastructure/iac-modules/
6. Align pipeline configuration with:
   - specs/infrastructure/cicd-pipeline/spec.md

## Notes

- US regions only unless compliance approval is documented.
- Encryption, RBAC, and audit logging requirements are mandatory.
- Workload criticality must be declared for each environment.