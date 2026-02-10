# Application: Patio

**Created**: 2026-02-10  
**Source Spec**: /specs/application/Patio/spec.md  
**Parent Specs**:
- /specs/platform/001-application-artifact-organization/spec.md
- /specs/business/cost/spec.md
- /specs/security/access-control/spec.md
- /specs/security/data-protection/spec.md
- /specs/security/audit-logging/spec.md
- /specs/infrastructure/compute/spec.md
- /specs/infrastructure/networking/spec.md
- /specs/infrastructure/storage/spec.md

## Overview

Patio is a new application with infrastructure deployed via IaC templates. Artifacts in this directory define the environment topology, security controls, and deployment automation required to provision Patio in Azure.

## Directory Structure

- **iac/**: Infrastructure-as-Code templates (Bicep, ARM, Terraform)
- **modules/**: Reusable IaC modules
- **scripts/**: Deployment, validation, operations scripts
- **pipelines/**: GitHub Actions workflows
- **docs/**: Documentation, runbooks, architecture diagrams

## Key Components

- IaC entrypoint for Patio environment provisioning
- Environment parameter files for dev, test, and production
- Security and audit logging configuration
- Deployment pipeline and rollout documentation

## How to Deploy

See docs/iac-usage.md

## Architecture

See docs/environment-matrix.md

## Operations

See docs/rollout.md

## Links

- **Specification**: [/specs/application/Patio/spec.md](/specs/application/Patio/spec.md)
- **Platform Guide**: [ARTIFACT_ORGANIZATION_GUIDE.md](/ARTIFACT_ORGANIZATION_GUIDE.md)

---

Created per Constitution v1.1.0 and /specs/platform/001-application-artifact-organization/

