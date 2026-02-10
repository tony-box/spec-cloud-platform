---
# YAML Frontmatter - Category-Based Spec System
tier: infrastructure
category: storage
spec-id: stor-001
version: 3.0.0
status: published
created: 2026-02-07
last-updated: 2026-02-10
description: "Premium+ storage tier selections for maximum performance: P30+ SSD, Ultra Disk with maximum throughput; unlimited performance strategy"

# Dependencies
depends-on:
  - tier: business
    category: cost
    spec-id: cost-001
    version: 3.0.0
    reason: "Storage tier selections must use Premium SSD (P30+) and Ultra Disk for maximum performance, no cost constraints"
  - tier: infrastructure
    category: compute
    spec-id: compute-001
    reason: "Compute workload determines required storage tier"
  - tier: business
    category: compliance-framework
    spec-id: comp-001
    reason: "Data residency and retention requirements constrain storage choices"

# Precedence rules
precedence:
  loses-to:
    - tier: platform
      category: "*"
      spec-id: "*"
      reason: "Platform tier (technical standards, code quality, spec system) is foundational and cannot be overridden"
    - tier: infrastructure
      category: compute
      spec-id: compute-001
      reason: "Workload characteristics (compute) drive storage tier selection"

# Relationships
adhered-by: []
---

# Specification: Storage Tiers & Backup Retention by Workload Tier

**Tier**: infrastructure  
**Category**: storage  
**Spec ID**: stor-001  
**Created**: 2026-02-07  
**Updated**: 2026-02-10  
**Status**: Published  
**Derived From**: business/cost-001 v3.0.0 (maximum performance strategy) + business/compliance-framework  

## Executive Summary

**Problem**: Without performance-optimized storage guidance:
- Under-provisioned storage (Standard when Premium SSD needed for speed)
- Inconsistent IOPS/throughput configurations
- Inadequate backup strategies for data integrity
- Compliance violations (retention requirements not met)

**Solution**: Define premium storage tier selections and throughput optimization strategies aligned with performance requirements.

**Performance Impact**: All workloads use high-performance storage:
- All Workloads: Premium SSD P30+ minimum, with Ultra Disk option for maximum throughput
- Replication: Zone-redundant where applicable for performance + availability
- Backup Retention: Aligned with critical data requirements, not cost minimization

**Impact**: All applications achieve maximum storage throughput and IOPS; data durability ensured with high-performance backup strategies.

## Requirements

### Functional Requirements

- **REQ-001**: All VMs MUST use managed disks (not unmanaged)
- **REQ-002**: Storage tier selection MUST prioritize performance (Premium SSD P30+ minimum for all workloads)
- **REQ-003**: Ultra Disk SHOULD be used for maximum throughput requirements (no cost constraints)
- **REQ-004**: Storage IOPS and throughput MUST be optimized for workload requirements
- **REQ-005**: Zone-redundant storage (ZRS) SHOULD be used where available (performance + availability)
- **REQ-006**: All storage MUST comply with data residency requirements (US regions only)
- **REQ-007**: Backup retention MUST ensure critical data durability (no cost-based reduction)

### Approved Storage Tiers by Workload Tier

#### Critical Workloads (99.95% SLA)
**Target**: Included in $150-250/month compute baseline  
**Approved Storage Tiers**:
- **Premium SSD (P10 or P15)** - RECOMMENDED for production databases and high-performance workloads
  - P10: 128 GB, 500 IOPS, 100 MB/s
  - P15: 256 GB, 1,100 IOPS, 125 MB/s
- Standard_SSD (E10 or E15) - Acceptable for less I/O-intensive critical workloads

**Replication Strategy**:
- **Zone-Redundant Storage (ZRS)** - REQUIRED for critical workloads
- 3 copies across availability zones (matches multi-zone VM deployment)
- Durability: 99.9999999999% (12 nines)
- Cost premium: +50% over LRS (acceptable for critical tier)

**Backup Retention**:
- **Daily backups**: REQUIRED
- **Retention**: 30 days minimum (disaster recovery)
- **Long-term**: Monthly snapshots for 12 months (compliance)
- **RPO**: 24 hours
- **RTO**: 4 hours

**Rationale**: Critical workloads require high-performance storage and zone-level redundancy to match 99.95% SLA requirements. Premium SSD provides consistent IOPS for production databases. Zone-redundant replication ensures storage survives datacenter failures.

#### Non-Critical Workloads (99% SLA)
**Target**: Included in $50-100/month compute baseline  
### Approved Storage Tiers by Workload Type

#### All Production Workloads (Maximum Performance)
**Principle**: Premium+ storage for maximum throughput and reliability

**Approved Storage Tiers**:
- **Ultra Disk** - RECOMMENDED for maximum IOPS/throughput
  - Up to 160,000 IOPS, 4,000 MB/s throughput
  - Ideal for high-performance databases, real-time analytics
- **Premium SSD P30-P80** - RECOMMENDED as minimum
  - P30: 1TB, 5,000 IOPS, 200 MB/s (minimum tier)
  - P80: 32TB, 20,000 IOPS, 750 MB/s (maximum)
- Choose based on workload throughput needs (not cost)

**Replication Strategy**:
- **Zone-Redundant Storage (ZRS)** - RECOMMENDED for performance + availability
- 3 copies across availability zones with automatic failover
- Minimal latency impact (<5ms between zones within region)
- Ensures data availability during zone failures

**Backup Retention**:
- **Continuous** or **Daily backups**: REQUIRED for critical data
- **Retention**: 30 days minimum for production workloads
- **Long-term**: Snapshots retained per compliance requirements
- **RPO**: 4 hours or better (near real-time)
- **RTO**: 1 hour or better (rapid recovery for service continuity)

**Rationale**: Premium+ storage eliminates I/O bottlenecks. Zone-redundant replication ensures high availability without compromise. Continuous/near-real-time backups ensure critical data durability.

#### AI/ML & Data Processing Workloads (Maximum Throughput)
**Approved Storage Tiers**:
- **Ultra Disk with Maximum Throughput**: RECOMMENDED
  - 160,000 IOPS, 4,000 MB/s configuration
  - High-throughput data pipelines
- **Premium SSD P80** (32TB, max config): Alternative

**Replication Strategy**:
- **Zone-Redundant Storage (ZRS)**: REQUIRED
- Automatic failover across zones ensures uninterrupted data access

**Backup Retention**:
- **Continuous real-time backup**: REQUIRED
- **Retention**: 30+ days
- **RPO**: <1 hour for near real-time recovery

**Rationale**: Maximum throughput storage for data-intensive workloads. Continuous backups protect against data loss during processing. Zone redundancy ensures data pipeline resilience.

#### Development/Test Workloads (Premium Tier for Accuracy)
**Approved Storage Tiers**:
- **Premium SSD P20-P30**: MINIMUM (must match production tier)
  - P20: 512GB, 2,300 IOPS, 150 MB/s
  - P30: 1TB, 5,000 IOPS, 200 MB/s (recommended)
- Ensures dev/test performance matches production for accurate testing

**Replication Strategy**:
- **Zone-Redundant Storage (ZRS)**: RECOMMENDED
- Matches production replication strategy for test accuracy

**Backup Retention**:
- **Daily backups**: REQUIRED
- **Retention**: 14 days (sufficient for dev/test testing cycles)
- **RPO**: 24 hours

**Rationale**: Dev/test should use premium storage matching production to enable accurate performance testing. Prevents dev storage from becoming bottleneck.

### Storage Performance Optimization

- **REQ-OPT-001**: All storage SHOULD be monitored for throughput and IOPS utilization
- **REQ-OPT-002**: Ultra Disk SHOULD be selected when workload requires >5,000 IOPS or >200 MB/s throughput
- **REQ-OPT-003**: Zone-redundant replication SHOULD be standard (no cost constraints)
- **REQ-OPT-004**: Continuous backup SHOULD be used for critical data (no retention cost optimization)

### Data Residency & Compliance

**Data Residency** (from business/compliance-framework):
- Approved regions: US regions only (East US, West US, Central US)
- Storage accounts MUST be created in approved regions
- Geo-replication MUST use approved paired regions only
- Cross-border data transfer prohibited

**Data Retention** (from business/compliance-framework):
- Application data: 7 years
- Audit logs: 3 years (immutable storage)
- Backup data: 30+ days for production, 14 days for dev/test

## Change Log

| Version | Date | Change | Approved By |
|---------|------|--------|------------|
| 1.0.0-draft | 2026-02-07 | Initial infrastructure storage spec | Infrastructure Lead |
| 2.0.0 | 2026-02-09 | **BREAKING**: Updated to align with business/cost v2.0.0; added storage tier selections per workload tier; added backup retention guidance; published | Infrastructure Lead (cascade from business/cost) |
| 3.0.0 | 2026-02-10 | **BREAKING**: Shifted to performance-first strategy from business/cost v3.0.0; changed to premium-only storage (P30+ minimum, Ultra Disk for max throughput); zone-redundant replication standard; continuous backup for critical data; removed cost governance; prioritize IOPS/throughput over cost | Infrastructure Lead (cascade from business/cost) |

---

**Spec Version**: 3.0.0  
**Approved Date**: 2026-02-10  
**Depends On**: business/cost-001 (v3.0.0), business/compliance-framework (comp-001), infrastructure/compute (compute-001 v3.0.0)  
**Artifacts Location**: artifacts/infrastructure/iac-modules/
**Approved Date**: 2026-02-09  
**Depends On**: business/cost-001 (v3.0.0), business/compliance-framework (comp-001), infrastructure/compute (compute-001 v3.0.0)  
**Artifacts Location**: artifacts/infrastructure/iac-modules/

## Success Criteria

- **SC-001**: All VMs use managed disks with Premium SSD P30+ minimum (100% adoption)
- **SC-002**: Storage tier selection prioritizes performance (Ultra Disk for >5,000 IOPS workloads)
- **SC-003**: Zone-redundant replication standard across all workloads
- **SC-004**: All production disks backed up with continuous backup and 30+ day retention
- **SC-005**: Zero data residency violations (all storage in approved regions)
- **SC-006**: Storage throughput exceeds workload requirements (no bottlenecks at storage I/O layer)
