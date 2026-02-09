---
# YAML Frontmatter - Category-Based Spec System
tier: infrastructure
category: compute
spec-id: compute-001
version: 2.0.0
status: published
created: 2026-02-06
last-updated: 2026-02-09
description: "Approved VM SKUs per workload tier aligned with cost baselines, reserved instance strategies, multi-zone deployment guidance"

# Dependencies
depends-on:
  - tier: business
    category: cost
    spec-id: cost-001
    version: 2.0.0
    reason: "Compute SKU selection must align with cost baselines per workload tier ($150-250 critical, $50-100 non-critical, $20-50 dev/test)"
  - tier: security
    category: data-protection
    spec-id: dp-001
    reason: "Compute resources must support encryption requirements"

# Precedence rules
precedence:
  wins-over:
    - tier: infrastructure
      category: storage
      spec-id: stor-001
      reason: "Workload characteristics (determined by compute) drive storage tier selection"

# Relationships
adhered-by: []
---

# Specification: Compute SKUs & Reserved Instance Strategy by Workload Tier

**Tier**: infrastructure  
**Category**: compute  
**Spec ID**: compute-001  
**Created**: 2026-02-06  
**Updated**: 2026-02-09  
**Status**: Published  
**Derived From**: business/cost-001 v2.0.0 (cost baselines per tier) + security/data-protection

## Spec Source & Hierarchy

**Parent Tier Specs**:
- **business/cost-001** (v2.0.0) - Concrete cost baselines per workload tier
  - Critical: $150-250/month per VM (99.95% SLA, multi-zone, 3-year RI)
  - Non-Critical: $50-100/month per VM (99% SLA, single-zone, 1-year RI)
  - Dev/Test: $20-50/month per VM (95% SLA, single-zone, spot instances)
- **security/data-protection** (v1.0.0) - Encryption and security requirements

**Derived Downstream Specs**:
- Application-tier deployments must declare workload criticality and use appropriate SKUs

## User Scenarios & Testing

### User Story 1 - Application Team Selects Appropriate VM SKU for Workload (Priority: P1)

Application team planning deployment: *"My application needs moderate compute resources and 99% SLA is acceptable. What VM SKU should I use to stay within cost baselines?"*

**Why this priority**: Every application deployment must select appropriate compute SKU based on workload criticality and cost baseline constraints.

**Independent Test**: Application team can determine correct SKU tier from workload criticality; deployment stays within cost baseline.

**Acceptance Scenarios**:

1. **Given** workload is critical (99.95% SLA required), **When** team selects VM SKU, **Then** Standard_D4s_v5 with 3-year reserved instance and multi-zone deployment selected; cost $150-250/month
2. **Given** workload is non-critical (99% SLA acceptable), **When** team selects VM SKU, **Then** Standard_B4ms or Standard_D2s_v5 with 1-year reserved instance and single-zone deployment selected; cost $50-100/month
3. **Given** workload is dev/test (95% SLA acceptable), **When** team selects VM SKU, **Then** Standard_B2s or Standard_B2ms with spot instance and single-zone deployment selected; cost $20-50/month

## Requirements

### Functional Requirements

- **REQ-001**: System MUST define approved VM SKU list for each workload criticality tier
- **REQ-002**: System MUST enforce reserved instance strategy per tier (3-year critical, 1-year non-critical, spot dev/test)
- **REQ-003**: System MUST enforce multi-zone deployment for critical workloads only (cost optimization for non-critical)
- **REQ-004**: All production workloads MUST use reserved instances (1-year minimum) unless explicitly justified
- **REQ-005**: Infrastructure MUST be right-sized to workload requirements (no over-provisioning)
- **REQ-006**: Non-critical workloads SHOULD NOT use Premium SKUs or multi-zone deployment without business justification
- **REQ-007**: Development/test environments SHOULD use spot instances where applicable (up to 90% savings)
- **REQ-008**: Monthly cost reviews REQUIRED for workloads exceeding baseline by >20%

### Approved VM SKUs by Workload Tier

#### Critical Workloads (99.95% SLA)
**Target Monthly Cost per VM**: $150-250 USD  
**Approved SKUs**:
- **Standard_D4s_v5** (4 vCPU, 16GB RAM) - Recommended for general workloads
- Alternative: Standard_D4as_v5, Standard_E4s_v5 (for AMD or memory-intensive needs)

**Infrastructure Profile**:
- **Availability**: Multi-zone deployment (3 availability zones) - HIGH AVAILABILITY REQUIRED
- **Reserved Instances**: 3-year commitment (savings: ~60% vs on-demand)
- **Storage**: Premium SSD (see infrastructure/storage spec for details)
- **Backup**: Daily automated backups, 30-day retention
- **Monitoring**: Premium tier Azure Monitor with custom metrics

**Rationale**: Critical workloads require high availability and performance. Multi-zone deployment ensures resilience against datacenter failures. Reserved instances provide significant savings while maintaining premium capabilities.

#### Non-Critical Workloads (99% SLA)
**Target Monthly Cost per VM**: $50-100 USD  
**Approved SKUs**:
- **Standard_B4ms** (4 vCPU, 16GB RAM) - Burstable, cost-effective for variable workloads
- **Standard_D2s_v5** (2 vCPU, 8GB RAM) - General-purpose, predictable performance
- Alternative: Standard_B2ms (2 vCPU, 8GB RAM) for lower resource needs

**Infrastructure Profile**:
- **Availability**: Single-zone deployment - COST-OPTIMIZED
- **Reserved Instances**: 1-year commitment (savings: ~40% vs on-demand)
- **Storage**: Standard SSD (see infrastructure/storage spec for details)
- **Backup**: Daily automated backups, 7-day retention
- **Monitoring**: Standard tier Azure Monitor

**Rationale**: Non-critical workloads tolerate brief outages. Single-zone deployment acceptable for cost optimization. Right-sized SKUs (B-series burstable or smaller D-series) balance performance and cost. 1-year reserved instances provide flexibility while capturing savings.

#### Development/Test Workloads (95% SLA)
**Target Monthly Cost per VM**: $20-50 USD  
**Approved SKUs**:
- **Standard_B2s** (2 vCPU, 4GB RAM) - Minimum recommended for most dev/test workloads
- **Standard_B2ms** (2 vCPU, 8GB RAM) - For memory-intensive development
- **Standard_B1ms** (1 vCPU, 2GB RAM) - For lightweight testing only

**Infrastructure Profile**:
- **Availability**: Single-zone, can use spot instances for non-24/7 workloads - MINIMAL COST
- **Reserved Instances**: On-demand or spot instances (spot savings: up to 90%)
- **Storage**: Standard HDD or Standard SSD (see infrastructure/storage spec)
- **Backup**: Optional, on-demand snapshots only
- **Monitoring**: Basic tier Azure Monitor
- **Auto-Shutdown**: SHOULD be automatically shut down outside business hours (40% additional savings)

**Rationale**: Dev/test environments can tolerate interruptions and don't need high availability. B-series burstable VMs provide cost-effective compute for variable development workloads. Spot instances acceptable for non-production use. Auto-shutdown schedules reduce costs for environments used only during business hours.

### Reserved Instance Strategies

- **REQ-RI-001**: All production workloads (critical + non-critical) MUST use reserved instances (minimum 1-year commitment)
- **REQ-RI-002**: Critical workloads SHOULD use 3-year reserved instances to maximize savings (~60% vs on-demand)
- **REQ-RI-003**: Non-critical workloads SHOULD use 1-year reserved instances for flexibility (~40% vs on-demand)
- **REQ-RI-004**: Reserved instance utilization MUST be ≥85% (quarterly review and optimization)
- **REQ-RI-005**: Spot instances SHOULD be used for dev/test workloads that can tolerate interruptions

### Multi-Zone Deployment Requirements

- **REQ-AZ-001**: Critical workloads (99.95% SLA) MUST deploy across multiple availability zones (3 zones)
- **REQ-AZ-002**: Non-critical workloads (99% SLA) SHOULD deploy to single-zone (cost optimization)
- **REQ-AZ-003**: Dev/test workloads (95% SLA) MUST deploy to single-zone (minimal cost)
- **REQ-AZ-004**: Multi-zone deployment MAY NOT be reduced for critical workloads (SLA non-negotiable)

### Cost Governance

- **REQ-GOV-001**: All new deployments MUST document workload criticality (critical/non-critical/dev-test) before approval
- **REQ-GOV-002**: Deployments exceeding cost baseline by >20% REQUIRE documented business justification and approval
- **REQ-GOV-003**: Infrastructure MUST be right-sized to workload requirements (no over-provisioning beyond +20% headroom)
- **REQ-GOV-004**: Monthly cost reviews REQUIRED for any workload exceeding baseline

## Success Criteria

### Measurable Outcomes

- **SC-001**: All VM deployments use approved SKUs for declared workload tier (100% compliance)
- **SC-002**: Production workloads deployed within ±20% of cost baselines for their tier
- **SC-003**: Reserved instance utilization ≥85% for production workloads (measured quarterly)
- **SC-004**: Critical workloads achieve 99.95% SLA, non-critical achieve 99% SLA
- **SC-005**: Dev/test environments achieve 40% cost savings through auto-shutdown schedules
- **SC-006**: Infrastructure SKU selections match workload criticality (no over-provisioning detected)
- **SC-007**: Zero critical workloads deployed without multi-zone configuration

## Artifact Generation & Human Review

**Generated Outputs** (IaC modules aligned with cost baselines):
- Updated Bicep modules in artifacts/infrastructure/iac-modules/ with SKU parameters per tier
- Reserved instance deployment templates (1-year and 3-year commitment patterns)
- Cost estimation calculator for workload planning
- Azure Policy definitions enforcing approved SKUs per tier
- Cost variance monitoring alert templates
- Auto-shutdown schedules for dev/test environments

**Review Checklist**:
- [ ] Approved VM SKUs documented for all three workload tiers
- [ ] Reserved instance strategies specified (3-year/1-year/spot)
- [ ] Multi-zone vs single-zone deployment mapped to workload criticality
- [ ] Cost baselines referenced from business/cost v2.0.0 ($150-250, $50-100, $20-50)
- [ ] Non-negotiable constraints stated (security, compliance, multi-zone for critical)
- [ ] Success criteria measurable (±20% variance, 85% RI utilization, SLA levels)
- [ ] Cost governance processes defined (monthly reviews, >20% variance approvals)
- [ ] Spec traceable to business/cost v2.0.0

## Change Log

| Version | Date | Change | Approved By |
|---------|------|--------|------------|
| 1.0.0 | 2026-02-06 | Initial infrastructure spec: Cost-optimized compute modules | Infrastructure Lead |
| 2.0.0 | 2026-02-09 | **BREAKING**: Updated to align with business/cost v2.0.0; replaced percentage targets with concrete cost baselines per workload tier; added approved SKU lists; added reserved instance strategies; added multi-zone deployment requirements | Infrastructure Lead (cascade from business/cost) |

---

**Spec Version**: 2.0.0  
**Approved Date**: 2026-02-09  
**Depends On**: business/cost-001 (v2.0.0), security/data-protection (v1.0.0)  
**Artifacts Location**: artifacts/infrastructure/iac-modules/
