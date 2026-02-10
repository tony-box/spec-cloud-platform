---
# YAML Frontmatter - Category-Based Spec System
tier: infrastructure
category: compute
spec-id: compute-001
version: 3.0.0
status: published
created: 2026-02-06
last-updated: 2026-02-10
description: "Premium VM SKU selections for maximum performance: D96ds_v5+, M-series, GPU-accelerated instances; unlimited performance strategy"

# Dependencies
depends-on:
  - tier: business
    category: cost
    spec-id: cost-001
    version: 3.0.0
    reason: "Compute SKU selection must use premium/ultra tiers for maximum performance (D96ds_v5+, M192idms_v2+, GPU acceleration)"
  - tier: security
    category: data-protection
    spec-id: dp-001
    reason: "Compute resources must support encryption requirements"

# Precedence rules
precedence:
  loses-to:
    - tier: platform
      category: "*"
      spec-id: "*"
      reason: "Platform tier (technical standards, code quality, spec system) is foundational and cannot be overridden"
  
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
**Updated**: 2026-02-10
**Status**: Published
**Derived From**: business/cost-001 v3.0.0 (unlimited performance strategy) + security/data-protection

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

### User Story 1 - Application Team Deploys Maximum Performance Compute (Priority: P1)

Application team planning deployment: *"We want maximum computational speed and throughput. Deploy the most powerful VM SKU available."*

**Why this priority**: All application deployments must use premium-tier SKUs to achieve maximum performance and competitive computational advantage.

**Independent Test**: Application team provisioning compute gets highest-tier SKUs with GPU acceleration where applicable; performance metrics confirm optimization.

**Acceptance Scenarios**:

1. **Given** workload requires high performance, **When** team deploys compute, **Then** Standard_D96ds_v5 (96 vCPU, 384GB RAM) or equivalent premium tier is provisioned
2. **Given** memory-intensive workload required, **When** team deploys compute, **Then** M192idms_v2 (192 vCPU, 4TB RAM) or equivalent is provisioned
3. **Given** AI/ML workload, **When** team deploys compute, **Then** GPU-accelerated SKU (Standard_ND96amsr_A100_v4) is provisioned with 8x NVIDIA A100 GPUs

## Requirements

### Functional Requirements

- **REQ-001**: System MUST provision premium-tier VM SKUs for all workloads (D96ds_v5+, M-series 192+ vCPU)
- **REQ-002**: System MUST enable GPU acceleration for applicable workloads (H100/A100 or latest equivalents)
- **REQ-003**: System MUST provision maximum vCPU and memory specifications (no cost-based right-sizing)
- **REQ-004**: Reserved instance and cost optimization strategies are NOT applicable (on-demand pricing acceptable)
- **REQ-005**: Multi-zone deployment SHOULD be used for latency reduction in multi-region scenarios (not HA/DR)
- **REQ-006**: Dev/test workloads SHOULD use same premium SKU tier as production (for accurate performance testing)
- **REQ-007**: All available performance accelerators SHOULD be enabled (no feature filtering)
- **REQ-008**: Monthly performance reviews REQUIRED for all compute workloads (latency, throughput, CPU utilization)

### Approved VM SKUs by Workload Type

#### General Purpose Workloads (Maximum Performance)
**Principle**: Deploy highest-tier SKUs prioritizing speed  
**Approved SKUs**:
- **Standard_D96ds_v5** (96 vCPU, 384GB RAM) - RECOMMENDED for general workloads
- **Standard_D64ds_v5** (64 vCPU, 256GB RAM) - Alternative for slightly lower resource needs
- **AMD Alternative**: Standard_D96as_v5 (AMD equivalent, same performance)

**Infrastructure Profile**:
- **Availability**: Multi-region option for latency optimization (not HA/DR)
- **On-Demand Pricing**: Cost optimization not applicable
- **Storage**: Premium SSD P30+ or Ultra Disk (see infrastructure/storage spec)
- **Backup**: Continuous real-time backup for critical data
- **Monitoring**: Premium tier Azure Monitor with ultra-granular metrics

**Rationale**: Maximum computational power for general processing. 96+ vCPU eliminates compute bottlenecks. Ultra-premium SKUs provide consistent performance.

#### Memory-Intensive Workloads (Maximum Performance)
**Approved SKUs**:
- **Standard_M192idms_v2** (192 vCPU, 4TB RAM) - RECOMMENDED for large-scale in-memory computing
- **Standard_M128ms** (128 vCPU, 3.89TB RAM) - Alternative

**Infrastructure Profile**:
- **Availability**: Multi-region for latency optimization
- **On-Demand Pricing**: Cost optimization not applicable
- **Storage**: Premium SSD P30+ or Ultra Disk with maximum throughput
- **Monitoring**: Premium tier Azure Monitor

**Rationale**: Maximum memory capacity for big data, SAP HANA, and in-memory databases. TB-scale RAM eliminates memory bottlenecks.

#### AI/ML & GPU-Accelerated Workloads (Maximum Performance)
**Approved SKUs**:
- **Standard_ND96amsr_A100_v4** (96 vCPU, 8x NVIDIA A100 GPUs, 1.46TB RAM) - RECOMMENDED for cutting-edge AI/ML
- **Standard_ND120rs_v2** (120 vCPU, 8x NVIDIA V100 GPUs) - Alternative
- **Standard_NC96ads_A100_v4** (96 vCPU, 8x NVIDIA A100 GPUs) - Alternative

**Infrastructure Profile**:
- **GPU Acceleration**: 8x NVIDIA latest-generation GPUs enabled
- **Storage**: Ultra Disk with maximum IOPS/throughput for data pipeline feeds
- **On-Demand Pricing**: Cost optimization not applicable
- **Monitoring**: GPU utilization tracking, real-time performance metrics

**Rationale**: 8x GPU configuration for maximum parallel processing. Latest-generation GPUs (A100s) provide absolute peak performance for AI/ML workloads. Ultra Disk feeds models with maximum data throughput.

#### Development/Test Workloads (Premium Tier for Accuracy)
**Approved SKUs**:
- **Standard_D32ds_v5** (32 vCPU, 128GB RAM) - Minimum for dev/test (must match production tier)
- **Standard_D48ds_v5** (48 vCPU, 192GB RAM) - Recommended for staging environments

**Infrastructure Profile**:
- **Availability**: Matches production deployment pattern for accurate testing
- **Storage**: Premium SSD P20+ to replicate production storage performance
- **GPU Access**: Available for performance testing

**Rationale**: Dev/test should match production SKU tier to enable accurate performance testing and validation. Prevents dev bottlenecks from masking production issues.

### Performance Procurement & Optimization

- **REQ-PER-001**: All production workloads MUST use on-demand pricing (cost constraints not applicable)
- **REQ-PER-002**: Premium/ultra-tier SKUs MUST be selected as defaults (no cost-based down-sizing)
- **REQ-PER-003**: GPU resources, high-memory instances, and specialized compute MUST be available for all workload types
- **REQ-PER-004**: Dev/test workloads SHOULD use premium SKU tiers matching production for accurate testing (no tier-based differentiation)
- **REQ-PER-005**: Multi-region deployment SHOULD be used to minimize latency for user-facing applications

### Deployment Patterns

- **REQ-DEP-001**: All workloads SHOULD default to highest-performance SKU in their category (unless specific performance requirements suggest otherwise)
- **REQ-DEP-002**: No down-sizing recommendations based on cost (cost is not a constraint)
- **REQ-DEP-003**: Performance monitoring SHOULD confirm CPU/GPU utilization is high (validates choosing appropriately powerful SKUs)
- **REQ-DEP-004**: Workloads with ≥70% average CPU utilization considered well-matched to SKU tier

## Success Criteria

### Measurable Performance Outcomes

- **SC-001**: All VM deployments use premium-tier SKUs (D96ds_v5+ or M192idms_v2+ or GPU-accelerated)
- **SC-002**: General-purpose workloads achieve 60%+ reduction in application latency vs cost-optimized infrastructure
- **SC-003**: GPU-accelerated workloads achieve 300%+ throughput improvement for AI/ML model training
- **SC-004**: Data processing workloads achieve 80%+ improvement in job completion time
- **SC-005**: Average CPU utilization across deployed instances ≥70% (confirms appropriate SKU selection)
- **SC-006**: All AI/ML workloads utilize GPU acceleration (H100/A100 or latest equivalent)
- **SC-007**: Dev/test environments achieve production-equivalent performance for accurate testing

## Artifact Generation & Human Review

**Generated Outputs** (IaC modules for premium-tier deployments):
- Updated Bicep modules in artifacts/infrastructure/iac-modules/ with premium SKU parameters (D96ds_v5 minimum)
- GPU-accelerated module templates (H100/A100 provisioning)
- Performance baseline documentation (latency, throughput targets)
- Azure Policy definitions requiring premium SKUs for all deployments
- Performance monitoring and optimization dashboards
- Multi-region latency optimization guidance

**Review Checklist**:
- [ ] Premium-tier VM SKUs documented (D96ds_v5+, M192idms_v2+, GPU-accelerated)
- [ ] GPU acceleration configured for applicable workloads (H100/A100)
- [ ] Performance targets specified (latency reduction 60%+, throughput improvement 80%+)
- [ ] Dev/test workloads use premium SKU tier (not cost-optimized)
- [ ] On-demand pricing acceptable (reserved instances not required)
- [ ] Multi-region deployment considered for latency optimization
- [ ] Success criteria focused on performance metrics (latency, throughput, GPU utilization)
- [ ] Spec traceable to business/cost v3.0.0 (unlimited performance strategy)

## Change Log

| Version | Date | Change | Approved By |
|---------|------|--------|------------|
| 1.0.0 | 2026-02-06 | Initial infrastructure spec: Cost-optimized compute modules | Infrastructure Lead |
| 2.0.0 | 2026-02-09 | **BREAKING**: Updated to align with business/cost v2.0.0; replaced percentage targets with concrete cost baselines per workload tier; added approved SKU lists; added reserved instance strategies; added multi-zone deployment requirements | Infrastructure Lead (cascade from business/cost) |
| 3.0.0 | 2026-02-10 | **BREAKING**: Shifted to performance-first strategy from business/cost v3.0.0; removed all cost constraints; changed to premium-only SKUs (D96ds_v5+, M192idms_v2+); added GPU acceleration (H100/A100); prioritize raw speed over cost; updated success criteria to measure performance improvements (60%+ latency reduction, 300%+ throughput for GPU workloads) | Infrastructure Lead (cascade from business/cost) |

---

**Spec Version**: 3.0.0  
**Approved Date**: 2026-02-10  
**Depends On**: business/cost-001 (v3.0.0), security/data-protection (v1.0.0)  
**Artifacts Location**: artifacts/infrastructure/iac-modules/
