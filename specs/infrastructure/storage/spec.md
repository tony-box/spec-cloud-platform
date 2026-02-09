---
# YAML Frontmatter - Category-Based Spec System
tier: infrastructure
category: storage
spec-id: stor-001
version: 2.0.0
status: published
created: 2026-02-07
last-updated: 2026-02-09
description: "Storage tier selections, backup retention, and replication strategies aligned with cost baselines per workload tier"

# Dependencies
depends-on:
  - tier: business
    category: cost
    spec-id: cost-001
    version: 2.0.0
    reason: "Storage tier selections must align with cost baselines per workload tier"
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
**Updated**: 2026-02-09  
**Status**: Published  
**Derived From**: business/cost-001 v2.0.0 (cost baselines per tier) + business/compliance-framework  

## Executive Summary

**Problem**: Without tiered storage guidance:
- Over-provisioned storage (Premium SSD when Standard SSD sufficient)
- Inconsistent backup retention across workloads
- Cost overruns from inappropriate replication strategies
- Compliance violations (retention requirements not met)

**Solution**: Define storage tier selections, replication strategies, and backup retention policies aligned with workload criticality and cost baselines.

**Cost Impact**: Storage included in compute cost baselines:
- Critical: Premium SSD (P10/P15), zone-redundant - included in $150-250/month
- Non-Critical: Standard SSD (E10/E15), locally-redundant - included in $50-100/month
- Dev/Test: Standard HDD or Standard SSD (E6), locally-redundant - included in $20-50/month

**Impact**: All applications use appropriate storage tier for workload criticality; backups aligned with recovery requirements.

## Requirements

### Functional Requirements

- **REQ-001**: All VMs MUST use managed disks (not unmanaged)
- **REQ-002**: Storage tier selection MUST be based on workload criticality (critical/non-critical/dev-test)
- **REQ-003**: Storage costs MUST stay within cost baselines for workload tier (included in compute baseline)
- **REQ-004**: Critical workloads MUST use zone-redundant storage (ZRS) for high availability
- **REQ-005**: Non-critical and dev/test workloads SHOULD use locally-redundant storage (LRS) for cost optimization
- **REQ-006**: Backup retention MUST align with workload tier (30-day critical, 7-day non-critical, optional dev/test)
- **REQ-007**: All storage MUST comply with data residency requirements (US regions only)
- **REQ-008**: Premium SSD SHOULD NOT be used for non-critical or dev/test without business justification

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
**Approved Storage Tiers**:
- **Standard SSD (E10 or E15)** - RECOMMENDED for balanced performance and cost
  - E10: 128 GB, 500 IOPS, 60 MB/s
  - E15: 256 GB, 500 IOPS, 60 MB/s
- Standard HDD (S10 or S15) - Acceptable for infrequent access workloads

**Replication Strategy**:
- **Locally Redundant Storage (LRS)** - RECOMMENDED for cost optimization
- 3 copies within single datacenter
- Durability: 99.999999999% (11 nines) - sufficient for non-critical
- Cost: Baseline (no replication premium)

**Backup Retention**:
- **Daily backups**: REQUIRED
- **Retention**: 7 days (short-term recovery)
- **Long-term**: Optional (not required for non-critical)
- **RPO**: 24 hours
- **RTO**: 8 hours (less stringent than critical)

**Rationale**: Non-critical workloads tolerate brief outages. Standard SSD provides adequate performance at lower cost than Premium. Locally-redundant storage acceptable (single-zone deployment). 7-day backup retention balances recovery capability with storage costs.

#### Development/Test Workloads (95% SLA)
**Target**: Included in $20-50/month compute baseline  
**Approved Storage Tiers**:
- **Standard HDD (S10)** - RECOMMENDED for minimal cost
  - S10: 128 GB, 500 IOPS, 60 MB/s
- **Standard SSD (E6 or E10)** - Acceptable for performance-sensitive development
  - E6: 64 GB, 500 IOPS, 60 MB/s

**Replication Strategy**:
- **Locally Redundant Storage (LRS)** - REQUIRED for cost minimization
- 3 copies within single datacenter
- Durability: 99.999999999% (11 nines)

**Backup Retention**:
- **Backups**: OPTIONAL (on-demand snapshots only)
- **Retention**: 7 days if backups configured
- **RPO/RTO**: Not critical (can recreate dev/test environments)

**Rationale**: Dev/test environments can tolerate data loss (can recreate from source control). Standard HDD provides minimum cost storage. Backups optional since environments are non-production. LRS replication sufficient.

### Storage Cost Governance

- **REQ-GOV-001**: Storage costs MUST NOT exceed compute cost baseline for workload tier
- **REQ-GOV-002**: Premium SSD usage for non-critical/dev-test workloads REQUIRES documented justification
- **REQ-GOV-003**: Zone-redundant storage (ZRS) for non-critical/dev-test workloads REQUIRES approval
- **REQ-GOV-004**: Monthly storage cost reviews REQUIRED for workloads exceeding baseline

### Data Residency & Compliance

**Data Residency** (from business/compliance-framework):
- Approved regions: US regions only (East US, West US, Central US)
- Storage accounts MUST be created in approved regions
- Geo-replication MUST use approved paired regions only
- Cross-border data transfer prohibited

**Data Retention** (from business/compliance-framework):
- Application data: 7 years
- Audit logs: 3 years (immutable storage)
- Backup data: Per workload tier (30-day critical, 7-day non-critical, optional dev/test)

## Change Log

| Version | Date | Change | Approved By |
|---------|------|--------|------------|
| 1.0.0-draft | 2026-02-07 | Initial infrastructure storage spec | Infrastructure Lead |
| 2.0.0 | 2026-02-09 | **BREAKING**: Updated to align with business/cost v2.0.0; added storage tier selections per workload tier; added backup retention guidance; published | Infrastructure Lead (cascade from business/cost) |

---

**Spec Version**: 2.0.0  
**Approved Date**: 2026-02-09  
**Depends On**: business/cost-001 (v2.0.0), business/compliance-framework (comp-001), infrastructure/compute (compute-001 v2.0.0)  
**Artifacts Location**: artifacts/infrastructure/iac-modules/
- Automatic deletion after retention period

## Success Criteria

- **SC-001**: All VMs use managed disks (100% adoption)
- **SC-002**: Disk tier selection based on workload needs (documented)
- **SC-003**: LRS replication used by default (cost optimization)
- **SC-004**: All production disks backed up with 30-day retention
- **SC-005**: Zero data residency violations (all storage in approved regions)

## Change Log

| Version | Date | Change | Approved By |
|---------|------|--------|------------|
| 1.0.0-draft | 2026-02-07 | Initial storage spec | Infrastructure Lead |

---

**Spec Version**: 1.0.0-draft  
**Created**: 2026-02-07
