# Phase 0 Research: Infrastructure Tier Categories

**Task**: T003 - Define infrastructure tier categories  
**Created**: 2026-02-07  
**Status**: Research Document

---

## Overview

Infrastructure tier categories represent technical infrastructure decisions and patterns. These are made by cloud architects and infrastructure engineers implementing the business, security, and compliance requirements.

---

## Proposed Categories

### 1. Compute (`compute`)

**Spec ID**: `compute-001`  
**Purpose**: Virtual machines, VM sizing, SKU selection, VM scale sets, autoscaling

**Independent Decisions**:
- VM SKU choices (Standard_B, Standard_D, Standard_E families)
- vCPU and memory sizing for workloads
- CPU credit models (burstable vs dedicated)
- VM generation and capabilities (gen1, gen2, confidential computing)
- Autoscaling policies (scale-out/scale-in thresholds)
- Spot instances vs on-demand vs reserved
- Orchestration (single VMs, scale sets, AKS)
- Image selection (base OS, pre-configured images)

**Examples**:
- "Non-critical workloads use Standard_B2s (burstable, lowest cost)"
- "Critical workloads use Standard_D4s_v3+ (dedicated resources)"
- "Autoscale out when CPU > 80%, scale in when < 30%"
- "3-year reserved instances for production; on-demand for dev"
- "Proprietary workloads on single VMs; containerized on AKS"

**Conflicts**:
- With business/cost (cost says "minimum SKU"; compute says "performance needs larger")
- With security/data-protection (compute infrastructure affects encryption scope)

**Reason for Independence**:
- Compute decisions are independent from networking, storage, database choices
- Can change VM SKU without changing network or storage

**Current Spec**: infrastructure/001-cost-optimized-compute-modules (will extract compute portions)

---

### 2. Networking (`networking`)

**Spec ID**: `networking-001`  
**Purpose**: Virtual networks, subnets, NSGs, routing, connectivity, load balancing

**Independent Decisions**:
- VNet design (address spaces, subnets, CIDR ranges)
- Network security groups (NSG rules, port allow/deny)
- Routing policies (user-defined routes, route tables)
- Connectivity patterns (ExpressRoute, VPN, direct internet)
- Load balancing (Azure LB, Application Gateway, Traffic Manager)
- Network peering (VNet-to-VNet connectivity)
- Network monitoring and flow logs
- Firewall policies (Azure Firewall, third-party)

**Examples**:
- "VNet 10.0.0.0/16 with subnets /24 (256 IPs each)"
- "NSG allows only SSH (22), HTTP (80), HTTPS (443)"
- "No direct internet access; all traffic through Azure Firewall"
- "Multi-region apps use Traffic Manager for failover"
- "Internal apps use internal load balancer; public via ALB"

**Conflicts**:
- With infrastructure/compute (placement requirements affect networking)
- With business/governance (availability targets affect load balancing design)

**Reason for Independence**:
- Networking is independent from compute, storage, and database
- Can design network without knowing exact VM sizing

**Current Spec**: None (new category)

---

### 3. Storage (`storage`)

**Spec ID**: `storage-001`  
**Purpose**: Storage accounts, disk types, replication, lifecycle, backup

**Independent Decisions**:
- Storage account types (Standard, Premium, FileStorage)
- Disk types (Standard HDD, Standard SSD, Premium SSD, Ultra)
- Replication strategy (LRS, GRS, RA-GRS, GZRS)
- Storage lifecycle policies (archive after X days)
- Backup frequency and retention
- Snapshots (automated, on-demand)
- Blob tiering (hot, cool, archive)
- File share types (SMB, NFS)

**Examples**:
- "OS disks: Premium SSD (P10, 128GB)"
- "Data disks: Standard SSD (E20, 512GB)"
- "Boot diagnostics: Standard LRS (lowest cost)"
- "Database backups: GRS (geo-redundant) with 30-day retention"
- "Archive blobs older than 1 year to Archive tier"

**Conflicts**:
- With business/cost (cost wants cheapest storage; performance wants fast)
- With business/compliance-framework (compliance requires high availability; cost objects)

**Reason for Independence**:
- Storage decisions independent from networking and compute
- Can change storage tier without affecting VM connectivity

**Current Spec**: None (new category)

---

### 4. CI/CD-Pipeline (`cicd-pipeline`)

**Spec ID**: `cicd-pipeline-001`  
**Purpose**: Deployment automation, release processes, infrastructure automation, testing

**Independent Decisions**:
- CI/CD platform (GitHub Actions, Azure Pipelines, GitLab CI)
- Deployment triggering (on push, manual, scheduled)
- Deployment environments (dev, staging, production)
- Approval gates (automated, manual approvals)
- Infrastructure-as-Code approach (Bicep, Terraform, ARM)
- Test automation (unit, integration, E2E)
- Rollback procedures
- Deployment frequency and risk policies

**Examples**:
- "GitHub Actions triggered on push to main"
- "Workflow run validated build, test, deploy to dev auto; prod requires approval"
- "Use Bicep for all infrastructure"
- "All merge requests require passing E2E tests"
- "Deployment history stored with audit trail"

**Conflicts**:
- With security/access-control (who can approve deployments)
- With business/governance (how long between request and deployment)

**Reason for Independence**:
- CI/CD is about automation and process
- Distinct from compute, networking, storage infrastructure decisions

**Current Spec**: None (new category; related to platform/001 but infrastructure-focused)

---

## Summary Table

| Category | Spec ID | Focus | Examples |
|----------|---------|-------|----------|
| Compute | compute-001 | VM sizing, SKUs, autoscaling | B2s, D4s, reserved instances |
| Networking | networking-001 | VNets, NSGs, load balancing | 10.0.0.0/16, port rules |
| Storage | storage-001 | Disks, replication, backup | SSD, GRS, 30-day retention |
| CI/CD-Pipeline | cicd-pipeline-001 | Automation, deployments, testing | GitHub Actions, Bicep, E2E tests |

---

## Key Observation

**Compute and Cost Coupling**: 
- Compute SKU choices directly affect cost (biggest driver)
- But compute also depends on business/cost precedence
- Resolution: infrastructure/compute spec declares dependency on business/cost
- When conflict: "business/cost > infrastructure/compute" (cost wins)

---

## Validation

- [X] 4+ categories defined
- [X] Each covers distinct infrastructure domain
- [X] Examples provided
- [X] Conflicts identified
- [X] Spec IDs assigned
- [X] Dependencies modeled

---

## Next Steps

1. Peer review with infrastructure leaders: Do these decompose infrastructure correctly?
2. Integration with T005: Map existing infrastructure/001 to these categories
3. Integration with T006: Document infrastructure conflicts with business/security
