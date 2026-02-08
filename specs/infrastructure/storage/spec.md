---
# YAML Frontmatter - Category-Based Spec System
tier: infrastructure
category: storage
spec-id: stor-001
version: 1.0.0-draft
status: draft
created: 2026-02-07
description: "Disk types (SSD/HDD), replication (LRS/GRS), backup retention, snapshots"

# Dependencies
depends-on:
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
adhered-by:
  - app-id: mycoolapp
    version: "1.0.0"
    storage: "Standard SSD managed disks, LRS replication"
---

# Specification: Storage Infrastructure

**Tier**: infrastructure  
**Category**: storage  
**Spec ID**: stor-001  
**Created**: 2026-02-07  
**Status**: Draft  

## Executive Summary

**Problem**: Without standardized storage patterns:
- Inconsistent disk performance
- Cost overruns from premium storage
- Inadequate backup/disaster recovery
- Compliance violations (data residency, retention)

**Solution**: Define standard disk tiers, replication patterns, backup policies, and compliance-based retention.

**Impact**: All applications use cost-optimized storage with appropriate performance and disaster recovery.

## Requirements

### Functional Requirements

- **REQ-001**: All VMs MUST use managed disks (not unmanaged)
- **REQ-002**: Disk tier selection MUST be based on workload IOPS/throughput needs
- **REQ-003**: Replication MUST be LRS (Locally Redundant) for cost optimization unless HA required
- **REQ-004**: All production disks MUST be backed up with 30-day retention minimum
- **REQ-005**: All storage MUST comply with data residency requirements

### Disk Tiers

**Standard HDD** (cost-optimized):
- Use case: Infrequent access, backup, archive
- Performance: Up to 500 IOPS, 60 MB/s
- Cost: ~$0.04/GB/month
- Example: Log archives, dev/test environments

**Standard SSD** (balanced):
- Use case: Web servers, low-traffic applications, dev/test
- Performance: Up to 6,000 IOPS, 750 MB/s
- Cost: ~$0.08/GB/month
- Example: LAMP servers, internal tools

**Premium SSD** (high performance):
- Use case: Production databases, high-traffic applications
- Performance: Up to 20,000 IOPS, 900 MB/s
- Cost: ~$0.12/GB/month
- **Note**: Prohibited by business/cost-001 unless justified

**Ultra Disk** (extreme performance):
- Use case: Mission-critical databases (SQL, SAP HANA)
- Performance: Up to 160,000 IOPS, 2,000 MB/s
- Cost: ~$0.24/GB/month + IOPS/throughput pricing
- **Note**: Requires business case approval

### Replication Patterns

**LRS (Locally Redundant Storage)**:
- Copies: 3 copies within single datacenter
- Durability: 99.999999999% (11 nines)
- Use case: Default for all workloads unless HA required
- Cost: Baseline (no extra cost)

**ZRS (Zone-Redundant Storage)**:
- Copies: 3 copies across availability zones
- Durability: 99.9999999999% (12 nines)
- Use case: Critical workloads requiring zone-level HA
- Cost: +50% over LRS

**GRS (Geo-Redundant Storage)**:
- Copies: 3 copies local + 3 copies in paired region
- Durability: 99.99999999999999% (16 nines)
- Use case: Disaster recovery requiring cross-region replication
- Cost: +100% over LRS (2x cost)

**Decision Matrix**:
- Non-critical workload: LRS
- Critical workload (99.95% SLA): ZRS
- Disaster recovery required: GRS
- Cost optimization: Always start with LRS

### Backup Policies

**Production Backup**:
- Frequency: Daily
- Retention: 30 days (disaster recovery)
- Long-term: Monthly snapshots for 12 months (compliance)
- RPO: 24 hours (daily backup)
- RTO: 4 hours (restore time)

**Dev/Test Backup**:
- Frequency: Weekly (optional)
- Retention: 7 days
- RPO: 7 days
- RTO: Not critical

**Backup Storage**:
- Type: Azure Backup (managed service)
- Replication: GRS (backup data replicated to paired region)
- Retention: Automatic expiration per policy

### Storage Compliance

**Data Residency** (from business/compliance-framework):
- Approved regions: US regions only (East US, West US, Central US)
- Storage accounts MUST be created in approved regions
- Geo-replication MUST use approved paired regions only
- Cross-border data transfer prohibited

**Data Retention** (from business/compliance-framework):
- Application data: 7 years
- Audit logs: 3 years
- Backup data: 30 days minimum
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
