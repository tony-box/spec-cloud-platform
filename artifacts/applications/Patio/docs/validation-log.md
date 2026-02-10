# Patio Validation Log

## Structure Validation

- Date: 2026-02-10
- Command: ./artifacts/.templates/scripts/validate-artifact-structure.ps1 -AppName "Patio"
- Result: Failed - parameter 'Verbose' defined multiple times

## IaC Linting

- Date: 2026-02-10
- Command: az bicep build --file artifacts/applications/Patio/iac/main.bicep
- Result: Succeeded with warnings in shared AVM wrappers (no-unused-params, BCP081, BCP321, use-safe-access)

## Notes

Update this log after each validation run.
