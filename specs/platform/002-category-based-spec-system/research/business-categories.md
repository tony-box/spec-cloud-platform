# Phase 0 Research: Business Tier Categories

**Task**: T001 - Define business tier categories  
**Created**: 2026-02-07  
**Status**: Research Document

---

## Overview

Business tier categories represent strategic, cross-organizational decisions that impact cost, strategy, and organizational structure. These are the decisions that finance, executive leadership, and business stakeholders make—independent of how technology implements them.

---

## Proposed Categories

### 1. Cost (`cost`)

**Spec ID**: `cost-001`  
**Purpose**: Budget targets, cost reduction initiatives, financial constraints on infrastructure

**Independent Decisions** (decisions that can be made independently):
- Cost reduction targets (e.g., "reduce by 10%")
- Baseline spend and forecast
- Cost allocation models (chargeback, shared, centralized)
- Spending limits per department/project
- Reserved instance strategies (1-year vs 3-year)
- CapEx vs OpEx policies
- Cost forecasting methodology
- Budget approval workflows

**Examples of Cost Decisions**:
- "We need to reduce cloud costs by 10% year-over-year"
- "All infrastructure must use 3-year reserved instances"
- "Development environments limited to $500/month spend"
- "Finance requires cost forecasts updated monthly"
- "Chargeback model: 70% compute, 20% storage, 10% network"

**Conflicts This Might Have**:
- With infrastructure/compute (cost says "Standard SKUs only", but compute says "performance requires Premium")
- With security/compliance (cost says "no expensive audit logging", but security says "required for compliance")

**Reason for Independence**:
- Cost decisions are made by finance/CFO
- Can be updated independently of other business decisions
- Different from governance or compliance—purely financial

**Current Spec**: business/001-cost-reduction-targets/spec.md (will migrate to business/cost/spec.md)

---

### 2. Governance (`governance`)

**Spec ID**: `governance-001`  
**Purpose**: Organizational policies, approval workflows, decision-making authority

**Independent Decisions** (decisions that can be made independently):
- Change management processes (who approves changes?)
- Escalation procedures (when to escalate decisions)
- Service level expectations (availability targets by workload)
- Capacity planning cycles
- Budget approval authority and limits
- Infrastructure request workflows
- Communication and notification requirements
- Audit and compliance reporting procedures
- Disaster recovery and business continuity expectations

**Examples of Governance Decisions**:
- "All infrastructure changes require business owner approval"
- "Critical workloads must have 99.95% availability"
- "Non-critical workloads can have 99% availability"
- "Infrastructure requests must be submitted via ServiceNow with 2-week lead time"
- "Monthly cost reports required for all departments"

**Conflicts This Might Have**:
- With infrastructure/cicd-pipeline (governance says "manual approval", but cicd wants "automated deployment")
- With security/audit-logging (governance says "quarterly audits", but security says "continuous monitoring")

**Reason for Independence**:
- Governance is about organizational structure and workflows
- Can change without changing cost or compliance requirements
- Different stakeholders (CIO, business owners) own this

**Current Spec**: None (new category)

---

### 3. Compliance-Framework (`compliance-framework`)

**Spec ID**: `compliance-framework-001`  
**Purpose**: Strategic compliance requirements, regulatory scope, standards obligations

**Note**: This is *strategic compliance* (which regulations apply, which standards we must follow), NOT *operational compliance* (how we audit or monitor)—that's in security/audit-logging.

**Independent Decisions** (decisions that can be made independently):
- Which regulatory frameworks apply (HIPAA, PCI-DSS, SOC 2, NIST 800-171, etc.)
- Industry standards to follow (ISO 27001, ISO 9001, etc.)
- Data residency requirements (data must stay in region X)
- Data sovereignty requirements (specific data handling by specific nationalities)
- Third-party audit requirements (annual external audits, yes/no)
- Certification requirements (ISO certified, SOC 2 certified, etc.)
- Incident notification requirements (notify within X hours)
- Data retention policies (keep logs for X years)

**Examples of Compliance-Framework Decisions**:
- "We must comply with NIST 800-171 (government contracting requirement)"
- "All customer data must reside in US regions only"
- "Annual SOC 2 Type II audit required"
- "Incident notification to customers within 24 hours"
- "Audit logs retained for 7 years per regulatory requirement"

**Conflicts This Might Have**:
- With cost (compliance says "7-year retention", but cost says "no data lake storage")
- With infrastructure/storage (compliance says "data residency", but infra says "lowest cost is EU region")

**Reason for Independence**:
- Compliance-framework is decided by business/legal/regulatory affairs
- Can change when regulations change or business enters new market
- Different from operational compliance procedures

**Current Spec**: None (new category)

---

## Summary Table

| Category | Spec ID | Owner | Examples | Conflicts |
|----------|---------|-------|----------|-----------|
| Cost | cost-001 | Finance/CFO | Budget, spend limits, reserved instances | Infra (performance), Security (audit) |
| Governance | governance-001 | CIO/Business Owner | Approval workflows, availability targets, request processes | Platform (CI/CD), Security (monitoring) |
| Compliance-Framework | compliance-framework-001 | Legal/Compliance/Regulatory | Regulations, standards, residency, audit requirements | Cost (retention), Infra (residency) |

---

## Validation

- [X] 3+ categories defined
- [X] Each has clear independent decisions
- [X] Examples provided for each
- [X] Potential conflicts identified
- [X] Reason for independence documented
- [X] Current/future spec IDs assigned

---

## Next Steps

1. Peer review: Do other business stakeholders agree these are independent categories?
2. Integration with T005 (Migration Map): Map existing spec to `cost` category
3. Integration with T006 (Conflict Analysis): Document cost/governance/compliance conflicts
