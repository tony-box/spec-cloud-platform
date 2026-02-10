# Patio IaC Usage

## Purpose

Describe how to deploy Patio infrastructure using the application IaC templates.

## Prerequisites

- Patio artifact structure exists under artifacts/applications/Patio/
- Approved wrapper modules are available under artifacts/infrastructure/iac-modules/
- Azure credentials configured for deployment

## Deploy Steps

1. Choose the target environment parameter file:
   - dev: artifacts/applications/Patio/iac/dev.bicepparam
   - test: artifacts/applications/Patio/iac/test.bicepparam
   - prod: artifacts/applications/Patio/iac/prod.bicepparam
2. Review parameters for location, workload criticality, and cost center.
3. Deploy using Azure CLI (example):
   - az deployment group create --resource-group <rg> --template-file artifacts/applications/Patio/iac/main.bicep --parameters artifacts/applications/Patio/iac/<env>.bicepparam

## Notes

- Locations are restricted to centralus and eastus.
- Workload criticality influences SKU selection and availability requirements.
- SSH public key parameters must be replaced with valid keys before deployment.
