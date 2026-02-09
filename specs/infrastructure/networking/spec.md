---
# YAML Frontmatter - Category-Based Spec System
tier: infrastructure
category: networking
spec-id: net-001
version: 2.0.0
status: published
created: 2026-02-07
last-updated: 2026-02-09
description: "Network architecture patterns aligned with cost baselines: multi-zone vs single-zone deployment, load balancer tiers, cost optimization"

# Dependencies
depends-on:
  - tier: business
    category: cost
    spec-id: cost-001
    version: 2.0.0
    reason: "Network architecture (multi-zone vs single-zone, load balancer tier) must align with cost baselines per workload tier"
  - tier: business
    category: governance
    spec-id: gov-001
    reason: "Network connectivity and SLA definitions from business governance"

# Precedence rules
precedence:
  note: "Networking priority varies by workload; latency-sensitive workloads elevate networking precedence"

# Relationships
adhered-by: []
---

# Specification: Network Architecture by Workload Tier

**Tier**: infrastructure  
**Category**: networking  
**Spec ID**: net-001  
**Created**: 2026-02-07  
**Updated**: 2026-02-09  
**Status**: Published  
**Derived From**: business/cost-001 v2.0.0 (cost baselines per tier) + business/governance  

## Executive Summary

**Problem**: Without tiered network architecture:
- Over-provisioned multi-zone deployments for non-critical workloads
- Inconsistent load balancer tier selection
- Cost overruns from unnecessary cross-zone bandwidth
- Security gaps in network isolation

**Solution**: Define network architecture patterns (multi-zone vs single-zone, load balancer tiers) aligned with workload criticality and cost baselines.

**Cost Impact**: Network costs included in compute cost baselines:
- Critical: Multi-zone deployment (3 zones), Standard Load Balancer - included in $150-250/month
- Non-Critical: Single-zone deployment, Standard Load Balancer - included in $50-100/month
- Dev/Test: Single-zone deployment, minimal networking - included in $20-50/month

**Impact**: All applications use appropriate network architecture for workload criticality; critical workloads get high availability, non-critical workloads optimize cost.

## Requirements

### Functional Requirements

- **REQ-001**: All applications MUST deploy in isolated VNets or subnets
- **REQ-002**: All network traffic MUST be filtered via NSGs (network security groups)
- **REQ-003**: Network architecture MUST be based on workload criticality (critical/non-critical/dev-test)
- **REQ-004**: Critical workloads MUST deploy across multiple availability zones (3 zones) for high availability
- **REQ-005**: Non-critical and dev/test workloads SHOULD deploy to single-zone for cost optimization
- **REQ-006**: All DNS resolution MUST use Azure private DNS zones
- **REQ-007**: Inter-VNet communication MUST use VNet peering (not public internet)
- **REQ-008**: Load balancer tier selection MUST align with workload criticality

### Network Architecture by Workload Tier

#### Critical Workloads (99.95% SLA)
**Target**: Included in $150-250/month compute baseline  
**Network Architecture**:

**Availability Zones**: MULTI-ZONE (3 zones) - HIGH AVAILABILITY REQUIRED
- VMs distributed across Availability Zones 1, 2, 3
- Subnet spans all zones (Azure automatically distributes)
- Zone-redundant load balancer frontend
- Survives datacenter-level failures

**Load Balancer**:
- **Standard Load Balancer** - REQUIRED
- Zone-redundant frontend IP (survives zone failure)
- Cross-zone load balancing enabled
- Health probes to all zones
- SLA: 99.99% (matches 99.95% compute SLA)
- Cost: ~$0.025/hour + $0.005/GB processed

**VNet Design**:
- Address space: /16 CIDR (e.g., 10.1.0.0/16)
- Subnet design:
  - Web tier: /24 subnet (spans 3 zones)
  - App tier: /24 subnet (spans 3 zones)
  - Data tier: /24 subnet (spans 3 zones)
- NSG: Standard NSG rules (see below)

**Rationale**: Critical workloads require zone-level redundancy to achieve 99.95% SLA. Multi-zone deployment ensures VMs survive datacenter failures. Standard Load Balancer with zone-redundant frontend provides automatic failover across zones. Cross-zone bandwidth costs acceptable for critical tier.

#### Non-Critical Workloads (99% SLA)
**Target**: Included in $50-100/month compute baseline  
**Network Architecture**:

**Availability Zones**: SINGLE-ZONE - COST-OPTIMIZED
- All VMs in single availability zone (e.g., Zone 1)
- No cross-zone bandwidth costs
- Tolerates brief outages (matches 99% SLA)

**Load Balancer**:
- **Standard Load Balancer** - RECOMMENDED (better features, minimal cost difference)
- Single-zone frontend IP
- Backend pool in same zone (no cross-zone traffic)
- Health probes within zone
- SLA: 99.9% (exceeds 99% compute SLA)
- Cost: ~$0.025/hour + $0.005/GB processed

**VNet Design**:
- Address space: /16 CIDR (e.g., 10.2.0.0/16)
- Subnet design: Same as critical (single-zone subnets)
- NSG: Standard NSG rules

**Rationale**: Non-critical workloads tolerate brief outages. Single-zone deployment eliminates cross-zone bandwidth costs while maintaining adequate availability. Standard Load Balancer provides better features than Basic with minimal cost difference.

#### Development/Test Workloads (95% SLA)
**Target**: Included in $20-50/month compute baseline  
**Network Architecture**:

**Availability Zones**: SINGLE-ZONE - MINIMAL COST
- All VMs in single availability zone
- No redundancy required

**Load Balancer**:
- **Standard Load Balancer** - OPTIONAL (only if load balancing needed)
- Single-zone design
- Basic Load Balancer acceptable for dev/test (legacy support only)
- Consider: No load balancer for single-VM dev/test environments

**VNet Design**:
- Address space: /16 CIDR (e.g., 10.3.0.0/16)
- Simplified subnet design: Single subnet acceptable for dev/test
- NSG: Basic rules (allow SSH from management subnet)

**Rationale**: Dev/test environments can tolerate outages and don't need high availability. Single-zone, single-VM deployments minimize networking costs. Load balancer optional (many dev/test workloads are single-VM).

### Network Cost Optimization

- **REQ-OPT-001**: Non-critical workloads SHOULD NOT use multi-zone deployment (avoid cross-zone bandwidth costs)
- **REQ-OPT-002**: Dev/test workloads SHOULD use single-VM design where possible (no load balancer required)
- **REQ-OPT-003**: Cross-region traffic SHOULD be minimized (use region-local resources)
- **REQ-OPT-004**: VNet peering SHOULD be within same region (avoid global peering costs)
- **REQ-OPT-005**: NAT gateways SHOULD be used sparingly (prefer service endpoints for Azure services)

## Success Criteria

- **SC-001**: All applications deployed in isolated VNets/subnets (100%compliance)
- **SC-002**: All network traffic filtered via NSGs (zero unfiltered traffic)
- **SC-003**: Critical workloads deployed across 3 availability zones (multi-zone)
- **SC-004**: Non-critical and dev/test workloads deployed to single-zone (cost optimization)
- **SC-005**: DNS resolution via Azure private DNS zones
- **SC-006**: VNet peering used for inter-VNet communication (no public routing)
- **SC-007**: Load balancer tier matches workload criticality

## Change Log

| Version | Date | Change | Approved By |
|---------|------|--------|------------|
| 1.0.0-draft | 2026-02-07 | Initial networking spec | Infrastructure Lead |
| 2.0.0 | 2026-02-09 | **BREAKING**: Updated to align with business/cost v2.0.0; added multi-zone vs single-zone deployment guidance; added load balancer tier selection; added cost optimization strategies; published | Infrastructure Lead (cascade from business/cost) |

---

**Spec Version**: 2.0.0  
**Approved Date**: 2026-02-09  
**Depends On**: business/cost-001 (v2.0.0), business/governance (gov-001)  
**Artifacts Location**: artifacts/infrastructure/iac-modules/
