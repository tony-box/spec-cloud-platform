---
# YAML Frontmatter - Category-Based Spec System
tier: platform
category: policy-as-code
spec-id: pac-001
version: 1.0.0-draft
status: draft
created: 2026-02-07
description: "Azure Policy definitions, enforcement rules, remediation, compliance automation"

# Dependencies
depends-on:
  - tier: business
    category: compliance-framework
    spec-id: comp-001
    reason: "Policies implement business compliance requirements"
  - tier: security
    category: access-control
    spec-id: ac-001
    reason: "Policies enforce access control decisions"

# Precedence rules
precedence:
  note: "Policy-as-Code is reactive enforcement; implements decisions made by higher tiers"

# Relationships
adhered-by:
  - app-id: mycoolapp
    version: "1.0.0"
    compliance: "Azure Policy scans enforcing encryption, NSG, tagging"
---

# Specification: Policy as Code

**Tier**: platform  
**Category**: policy-as-code  
**Spec ID**: pac-001  
**Created**: 2026-02-07  
**Status**: Draft  

## Executive Summary

**Problem**: Without automated policy enforcement:
- Manual compliance checks are slow and error-prone
- Non-compliant resources deployed without detection
- Remediation is reactive (after violations)
- No centralized policy visibility

**Solution**: Implement Azure Policy definitions for automated enforcement, remediation, and compliance reporting.

**Impact**: All resources are automatically validated against compliance policies; violations are detected immediately and remediated automatically.

## Requirements

### Functional Requirements

- **REQ-001**: All compliance requirements MUST have corresponding Azure Policy definitions
- **REQ-002**: All policies MUST be assigned at subscription or resource group scope
- **REQ-003**: Policy violations MUST trigger alerts (real-time detection)
- **REQ-004**: Remediable policies MUST include remediation tasks
- **REQ-005**: Policy compliance MUST be reported via dashboard

### Azure Policy Categories

**Security Policies** (from security tier specs):
- Encryption at-rest: Require AES-256 encryption on all storage
- Encryption in-transit: Require TLS 1.2+ on all endpoints
- SSH access: Prohibit password authentication (keys only)
- NSG rules: Require NSGs on all subnets
- Key Vault: Require Azure Key Vault for secrets (no hardcoded)

**Compliance Policies** (from business/compliance-framework):
- Data residency: Allowed regions only (US regions)
- Tagging: Require tags (environment, owner, cost-center)
- Retention: Require backup enabled on production VMs
- Audit logging: Require Azure Monitor diagnostic settings

**Cost Optimization Policies** (from business/cost):
- SKU restrictions: Prohibit premium SKUs unless justified
- Reserved instances: Recommend reserved instances for steady-state workloads
- Unused resources: Detect and alert on unused resources

### Policy Assignment Scopes

**Subscription-Level Policies** (apply to all resources):
- Allowed regions (data residency)
- Required tags (environment, owner)
- Audit logging requirements

**Resource Group-Level Policies** (apply to specific apps):
- Application-specific SKU restrictions
- Network security rules
- Storage replication requirements

**Policy Exemptions**:
- Process: Request exemption with business justification
- Approval: Security/compliance lead approval required
- Duration: Maximum 90 days (must renew)
- Audit: All exemptions logged and reviewed quarterly

### Policy Enforcement Modes

**Enforce** (deny non-compliant resources):
- Encryption requirements: Enforce (cannot deploy without encryption)
- Data residency: Enforce (cannot deploy outside allowed regions)
- SSH passwords: Enforce (cannot enable password auth)

**Audit** (detect but allow):
- Cost optimization: Audit (detect premium SKUs, alert but allow)
- Tagging: Audit initially, enforce after 90-day grace period
- Unused resources: Audit (detection only, manual cleanup)

**Disabled** (policy defined but not enforced):
- Development policies: Define but don't enforce in dev environments
- Testing policies: Disabled during migration/testing periods

### Remediation Tasks

**Automatic Remediation** (policy can fix non-compliant resources):
- Tagging: Add missing tags automatically
- Encryption: Enable encryption on storage accounts
- Diagnostic settings: Configure Azure Monitor logs

**Manual Remediation** (requires human intervention):
- SKU changes: Cannot automatically downgrade VM SKU (requires redeployment)
- NSG rules: Cannot automatically modify security rules (security risk)
- Data residency: Cannot move data across regions (manual migration)

**Remediation Workflow**:
1. Policy detects non-compliant resource
2. If remediable: Create remediation task (automatic or manual)
3. If manual: Create work item with remediation instructions
4. Track remediation progress via compliance dashboard
5. Re-scan after remediation to confirm compliance

### Policy Compliance Dashboard

**Metrics**:
- Total policies: Count of active policies
- Compliance rate: % of resources in compliance
- Violations: Count of non-compliant resources
- Remediation: Count of pending remediation tasks

**Alerts**:
- Critical violations: Immediate alert (email + Teams)
- High-priority violations: Daily summary
- Low-priority violations: Weekly summary

**Reporting**:
- Executive summary: Monthly compliance report (to leadership)
- Detailed report: All violations with remediation status
- Trend analysis: Compliance over time (improving or declining)

## Success Criteria

- **SC-001**: All compliance requirements have Azure Policy definitions
- **SC-002**: Policies assigned at appropriate scopes (subscription/RG)
- **SC-003**: Policy violations trigger alerts (real-time detection)
- **SC-004**: Remediable policies include remediation tasks
- **SC-005**: Compliance dashboard accessible to all stakeholders

## Change Log

| Version | Date | Change | Approved By |
|---------|------|--------|------------|
| 1.0.0-draft | 2026-02-07 | Initial policy-as-code spec | Platform Team |

---

**Spec Version**: 1.0.0-draft  
**Created**: 2026-02-07
