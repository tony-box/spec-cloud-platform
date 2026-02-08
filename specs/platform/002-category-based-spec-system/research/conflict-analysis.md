# Phase 0 Research: Conflict Analysis

**Task**: T006 - Identify conflicts in existing specs  
**Created**: 2026-02-07  
**Status**: Research Document

---

## Overview

This document identifies conflicts between specs and proposes precedence rules to resolve them. These conflicts will be formalized in the precedence.overrides fields of category specs during Phase 2.

---

## Conflict Matrix

### High-Priority Conflicts (Must Resolve)

#### Conflict 1: Business/Cost vs Infrastructure/Compute

**Specs Involved**:
- business/cost: "Reduce costs by 10%"
- infrastructure/compute: "Optimize for performance"

**The Conflict**:
- Business says: "Use Standard_B2s (cheapest, burstable)"
- Infrastructure says: "Use Standard_D4s (better performance, more consistent)"

**Impact**: 
- Standard_B2s: ~$40/month on-demand, $18.43 reserved
- Standard_D4s: ~$250/month on-demand, $115 reserved
- Cost difference: 6x higher for D4s

**Resolution Decision**:
- **WINNER**: business/cost ⭐
- **Rationale**: Business sets cost targets; infrastructure must optimize *within* those targets
- **Implementation**: infrastructure/compute includes dependency on business/cost; cost is binding constraint
- **Exception path**: If infrastructure can document performance gap causing business loss > cost savings, can request override

**Formalization**:
```yaml
# In business/cost spec:
precedence:
  overrides:
    - tier: infrastructure
      category: compute
      on-conflicts: "Cost reduction targets (10%) override infrastructure performance preferences when choosing VM SKUs. Infrastructure must find optimal performance WITHIN cost constraints, not vice versa."

# In infrastructure/compute spec:
depends-on:
  - tier: business
    category: cost
    spec-id: cost-001
    reason: "Compute SKU selection must satisfy cost targets"
```

---

#### Conflict 2: Business/Cost vs Security/Data-Protection

**Specs Involved**:
- business/cost: "Reduce costs by 10%"
- security/data-protection: "All data encrypted AES-256, key rotation 90 days"

**The Conflict**:
- Business says: "No expensive key management hardware"
- Security says: "Keys must be in HSM with automatic rotation"

**Impact**:
- Azure Key Vault (software): ~$0.34/month
- Azure Key Vault (HSM): ~$15/month
- Cost difference: 44x higher for HSM; $174/year

**Resolution Decision**:
- **WINNER**: security/data-protection ⭐
- **Rationale**: Security requirements are non-negotiable; cost optimization happens elsewhere
- **Implementation**: business/cost includes exception for security; security specs always win on data protection
- **Exception path**: None (data protection is non-negotiable)

**Formalization**:
```yaml
# In business/cost spec:
dependencies:
  - tier: security
    category: data-protection
    reason: "Cost targets are subject to security requirements; security always wins"

# In security/data-protection spec:
precedence:
  overrides:
    - tier: business
      category: cost
      on-conflicts: "Data protection requirements are non-negotiable. HSM, encryption, key rotation take precedence over cost optimization."
```

---

#### Conflict 3: Business/Governance vs Infrastructure/CI/CD-Pipeline

**Specs Involved**:
- business/governance: "All infrastructure changes require human approval"
- infrastructure/cicd-pipeline: "Automated deployment on commit"

**The Conflict**:
- Business (governance) says: "No auto-deploy; manual approval mandatory"
- Infrastructure says: "Auto-deploy to dev on PR merges; auto-deploy to prod after approval"

**Impact**:
- Manual-only: Slow (24-48 hours), reliable for high-stakes
- Auto-deploy: Fast (5 minutes), but risky if humans aren't checking

**Resolution Decision**:
- **WINNER**: business/governance ⭐ (for prod), infrastructure/cicd-pipeline (for dev)
- **Rationale**: Business governance sets approval requirements; infrastructure can auto-deploy within those constraints
- **Implementation**: cicd-pipeline includes deployment gates (auto for dev, manual for prod) matching governance
- **Exception path**: Infrastructure can request fast-track approval for urgent hotfixes

**Formalization**:
```yaml
# In business/governance spec:
precedence:
  overrides:
    - tier: infrastructure
      category: cicd-pipeline
      on-conflicts: "Approval workflows defined by governance are binding. CI/CD pipelines must enforce these gates (e.g., 'prod requires human approval before deploy')."

# In infrastructure/cicd-pipeline spec:
depends-on:
  - tier: business
    category: governance
    reason: "Deployment approval gates determined by business governance"
```

---

#### Conflict 4: Business/Compliance-Framework vs Infrastructure/Storage

**Specs Involved**:
- business/compliance-framework: "Data residency in US only; 7-year retention"
- infrastructure/storage: "Use lowest-cost storage tier"

**The Conflict**:
- Compliance says: "Data in US regions; geo-redundant (GRS) backup; 7-year archive"
- Infrastructure says: "Use standard LRS locally; delete after 1 year to save costs"

**Impact**:
- GRS + 7-year: ~$500/month for 1TB
- LRS + 1-year: ~$30/month for 1TB
- Cost difference: 17x higher for compliance

**Resolution Decision**:
- **WINNER**: business/compliance-framework ⭐
- **Rationale**: Regulatory requirements are binding; infrastructure must comply regardless of cost
- **Implementation**: infrastructure/storage includes dependency on compliance; compliance is binding
- **Exception path**: Infrastructure can file variance request if compliance requirement conflicts with other critical requirement

**Formalization**:
```yaml
# In business/compliance-framework spec:
precedence:
  overrides:
    - tier: infrastructure
      category: storage
      on-conflicts: "Data residency, retention, and replication requirements from compliance take precedence over storage cost optimization."

# In infrastructure/storage spec:
depends-on:
  - tier: business
    category: compliance-framework
    reason: "Storage decisions must comply with data residency and retention requirements"
```

---

#### Conflict 5: Security/Access-Control vs Business/Governance

**Specs Involved**:
- security/access-control: "SSH keys only; no passwords; MFA mandated"
- business/governance: "Approval workflows must be human-speed (not real-time)"

**The Conflict**:
- Security says: "MFA on every access for maximum security"
- Governance says: "MFA might slow down emergency hotfixes"

**Impact**:
- MFA mandatory: Safer but slower (2-3 minutes per login for MFA)
- MFA optional: Faster but riskier (password guessing possible)

**Resolution Decision**:
- **WINNER**: security/access-control ⭐
- **Rationale**: Access control is foundational security; governance works around it
- **Implementation**: governance includes exception process for MFA bypass (emergency break-glass)
- **Exception path**: Governance defines break-glass procedure (documented, audited override)

**Formalization**:
```yaml
# In security/access-control spec:
precedence:
  overrides:
    - tier: business
      category: governance
      on-conflicts: "MFA and key-based auth are non-negotiable. Break-glass procedures defined by governance are the only exception."

# In business/governance spec:
depends-on:
  - tier: security
    category: access-control
    reason: "Governance workflows must work within security access controls; cannot bypass"
```

---

### Medium-Priority Conflicts (Should Resolve)

#### Conflict 6: Infrastructure/Compute vs Infrastructure/Storage

**Specs Involved**:
- infrastructure/compute: "VM I/O patterns: high throughput, low latency"
- infrastructure/storage: "Use cheapest storage tier (Standard HDD)"

**The Conflict**:
- Compute says: "Database workloads need Premium SSD (fast, consistent)"
- Storage says: "Standard SSD or HDD is cheaper"

**Impact**:
- Premium SSD: ~$1.23/month per GB
- Standard SSD: ~$0.08/month per GB
- Standard HDD: ~$0.03/month per GB
- Cost difference: 40x between Premium and HDD

**Resolution Decision**:
- **WINNER**: infrastructure/compute (workload-dependent)
- **Rationale**: Compute requirements determine storage type; not a business/security override
- **Implementation**: Compute spec declares dependency on storage; storage accommodates workload types
- **Exception path**: Storage can optimize tier choice within compute requirements (e.g., "Premium SSD minimum" but can pick P10, P20, or P30)

**Formalization**:
```yaml
# In infrastructure/compute spec:
precedence:
  overrides:
    - tier: infrastructure
      category: storage
      on-conflicts: "Compute workload requirements (e.g., 'database needs low-latency storage') override storage cost minimization on storage tier selection."
```

---

#### Conflict 7: Business/Cost vs Infrastructure/Networking

**Specs Involved**:
- business/cost: "10% cost reduction"
- infrastructure/networking: "High availability requires dual routing, ExpressRoute"

**The Conflict**:
- Cost says: "No ExpressRoute; too expensive"
- Networking says: "ExpressRoute needed for guaranteed connectivity"

**Impact**:
- ExpressRoute: $0.30 per hour (~$216/month)
- Internet VPN: Free

**Resolution Decision**:
- **WINNER**: business/governance (via SLA requirements) → gates networking design
- **Rationale**: Networking designs are optimized *within* business-approved availability targets
- **Implementation**: governance sets SLA (99% = VPN OK; 99.9% = needs ExpressRoute); networking builds accordingly
- **Exception path**: Networking can document customer requirement for higher availability; business approves exception

**Formalization**:
```yaml
# In business/governance spec:
  defines SLA targets which gate infrastructure/networking choices
  
# In infrastructure/networking spec:
depends-on:
  - tier: business
    category: governance
    reason: "SLA requirements from governance determine networking design (ExpressRoute vs VPN)"
```

---

## Precedence Summary Table

| Conflict | Winner | Loser | Rationale |
|----------|--------|-------|-----------|
| Cost vs Compute | **Cost** | Compute | Business sets budget; infrastructure optimizes within it |
| Cost vs Data-Protection | **Security** | Cost | Data protection non-negotiable |
| Governance vs CI/CD | **Governance** | CI/CD | Business approval gates are binding |
| Compliance vs Storage | **Compliance** | Storage | Regulatory requirements binding |
| Access-Control vs Governance | **Security** | Governance | Security foundational; governance works around it |
| Compute vs Storage | **Compute** | Storage | Workload requirements determine tier |
| Cost vs Networking | *Business-SLA* | Both | Governance SLA gates both |

---

## Formalized Hierarchy (Complete)

### Tier-Level Hierarchy (Primary)
```
business > security > infrastructure > platform > application
```

### Category-Level Overrides (Secondary)

When tiers conflict, use tier hierarchy. When same-tier categories conflict, use these overrides:

**Within Business Tier**:
- Compliance-framework > Governance > Cost
- (Strategic compliance > organizational workflows > financial targets)

**Within Security Tier**:
- Data-protection ≈ Access-control > Audit-logging
- (Confidentiality and authentication > detection/response)

**Within Infrastructure Tier**:
- Compute > Storage (workload needs determine storage)
- Networking = Storage (independent; depends on governance SLA)

**Within Platform Tier**:
- Spec-system ≈ IaC-linting > Artifact-org > Policy-as-Code
- (Meta-specs and quality standards > organization > enforcement)

---

## Dependency Graph (Formalized)

```
business/cost
  ↓ (constrains)
infrastructure/compute, infrastructure/networking, infrastructure/storage

business/governance
  ↓ (gates)
infrastructure/cicd-pipeline, security/access-control (break-glass)

business/compliance-framework
  ↓ (enforces)
infrastructure/storage, infrastructure/networking (residency)

security/data-protection
  ↓ (overrides)
business/cost (for encryption), infrastructure/storage (key mgmt)

security/access-control
  ↓ (enforces)
business/governance (break-glass), platform/iac-linting (secret detection)

security/audit-logging
  ↓ (requires)
infrastructure/cicd-pipeline (audit trail), platform/policy-as-code (audit logs)

infrastructure/compute
  ↓ (depends on)
business/cost, infrastructure/storage (tier selection)

infrastructure/cicd-pipeline
  ↓ (depends on)
business/governance (approval gates), security/access-control (auth), security/audit-logging (audit trail)

platform/spec-system
  ↓ (meta: all specs follow this format)
all other specs
```

---

## Validation

- [X] 7 major conflicts identified (5 high-priority, 2 medium)
- [X] Resolution (winner) determined for each
- [X] Rationale documented
- [X] Formalizations provided
- [X] Dependency graph acyclic (no circular conflicts)
- [X] Clear exception paths defined

---

## Next Steps

1. Validate with stakeholders: Agree on precedence decisions?
2. Formalize in Phase 1 (manifests, precedence.overrides fields)
3. Implement validation in Phase 3 (specs-hierarchy.ps1 tool)
4. Test in Phase 4 (end-to-end test scenarios)
