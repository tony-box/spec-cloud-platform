---
# YAML Frontmatter - Category-Based Spec System
tier: platform
category: iac-linting
spec-id: lint-001
version: 1.0.0-draft
status: draft
created: 2026-02-07
description: "IaC code quality standards for Bicep, Terraform, PowerShell, YAML"

# Dependencies
depends-on: []

# Precedence rules
precedence:
  note: "IaC linting is foundational platform standard; roughly equal priority with spec-system"

# Relationships
adhered-by:
  - app-id: mycoolapp
    version: "1.0.0"
    linting: "Bicep templates follow Azure Verified Module patterns"
---

# Specification: IaC Linting and Code Quality

**Tier**: platform  
**Category**: iac-linting  
**Spec ID**: lint-001  
**Created**: 2026-02-07  
**Status**: Draft  

## Executive Summary

**Problem**: Without code quality standards:
- Inconsistent code formatting
- Hard-to-maintain IaC templates
- Security vulnerabilities in code
- No automated quality checks

**Solution**: Enforce linting standards for Bicep, Terraform, PowerShell, and YAML with automated quality gates.

**Impact**: All IaC code is consistent, maintainable, secure, and automatically validated before deployment.

## Requirements

### Functional Requirements

- **REQ-001**: All Bicep templates MUST pass `bicep build` without errors
- **REQ-002**: All PowerShell scripts MUST pass PSScriptAnalyzer linting
- **REQ-003**: All YAML files MUST be valid YAML syntax
- **REQ-004**: All IaC code MUST follow naming conventions
- **REQ-005**: All linting results MUST be included in CI/CD pipeline

### Bicep Linting

**Linter Rules**:
- no-hardcoded-env-urls: No hardcoded endpoints
- no-unused-params: Remove unused parameters
- secure-parameter-default: No default values for secure parameters
- prefer-interpolation: Use string interpolation over concat()
- max-outputs: Limit outputs to 64
- no-loc-expr-outside-params: location expressions only in parameters

**Naming Conventions**:
- Resources: camelCase (e.g., `storageAccount`, `virtualNetwork`)
- Parameters: camelCase (e.g., `vmSku`, `location`)
- Variables: camelCase (e.g., `resourceGroupName`)
- Outputs: camelCase (e.g., `publicIpAddress`)

**Code Standards**:
- Indentation: 2 spaces (not tabs)
- Line length: 120 characters maximum
- Comments: Required for complex logic
- Modularity: Prefer modules over monolithic templates

### PowerShell Linting (PSScriptAnalyzer)

**Severity Levels**:
- Error: MUST fix before merge (e.g., PSAvoidUsingPlainTextForPassword)
- Warning: SHOULD fix (e.g., PSAvoidUsingWriteHost)
- Information: Optional (e.g., PSUseSingularNouns)

**Key Rules**:
- PSAvoidUsingPlainTextForPassword: Use SecureString
- PSAvoidUsingConvertToSecureStringWithPlainText: No plain text secrets
- PSUseDeclaredVarsMoreThanAssignments: Remove unused variables
- PSAvoidUsingCmdletAliases: Use full cmdlet names (not aliases)
- PSUseCmdletCorrectly: Follow cmdlet parameter patterns

**Code Standards**:
- Indentation: 4 spaces
- Line length: 120 characters maximum
- Comments: Required for functions and complex logic
- Error handling: Use try/catch blocks

### YAML Linting

**Validation Rules**:
- Valid YAML syntax (yamllint)
- Indentation: 2 spaces (consistent)
- No duplicate keys
- No trailing spaces
- Proper quoting (when needed)

**GitHub Actions YAML**:
- Use official actions (actions/* preferred)
- Pin action versions (not @main)
- Secrets via GitHub Secrets (not hardcoded)
- Environment variables properly scoped

### Automated Linting in CI/CD

**Pre-Commit Hooks**:
- Bicep: `bicep build --stdout`
- PowerShell: `Invoke-ScriptAnalyzer`
- YAML: `yamllint`

**GitHub Actions Integration**:
```yaml
- name: Lint Bicep Templates
  run: |
    az bicep build --file main.bicep
    
- name: Lint PowerShell Scripts
  run: |
    Install-Module PSScriptAnalyzer -Force
    Invoke-ScriptAnalyzer -Path ./scripts/ -Recurse
```

**Quality Gates**:
- Linting errors: Block merge (PR fails)
- Linting warnings: Allow merge but notify
- Linting information: Informational only

## Success Criteria

- **SC-001**: 100% Bicep templates pass bicep build (zero errors)
- **SC-002**: 100% PowerShell scripts pass PSScriptAnalyzer (zero errors)
- **SC-003**: 100% YAML files valid syntax
- **SC-004**: Linting integrated into CI/CD pipelines
- **SC-005**: Linting enforced via quality gates (PRs cannot merge with errors)

## Change Log

| Version | Date | Change | Approved By |
|---------|------|--------|------------|
| 1.0.0-draft | 2026-02-07 | Initial IaC linting spec | Platform Team |

---

**Spec Version**: 1.0.0-draft  
**Created**: 2026-02-07
