---
# YAML Frontmatter - Category-Based Spec System
tier: infrastructure
category: networking
spec-id: net-001
version: 3.0.0
status: published
created: 2026-02-07
last-updated: 2026-02-10
description: "Premium network architecture for maximum performance: ExpressRoute Direct, multi-region, performance optimization; unlimited performance strategy"

# Dependencies
depends-on:
  - tier: business
    category: cost
    spec-id: cost-001
    version: 3.0.0
    reason: "Network architecture must prioritize performance optimization (multi-region, ExpressRoute Direct) with unlimited spending for speed"
  - tier: business
    category: governance
    spec-id: gov-001
    reason: "Network connectivity and SLA definitions from business governance"

# Precedence rules
precedence:
  loses-to:
    - tier: platform
      category: "*"
      spec-id: "*"
      reason: "Platform tier (technical standards, code quality, spec system) is foundational and cannot be overridden"
  
  note: "Networking priority varies by workload; latency-sensitive workloads elevate networking precedence"

# Relationships
adhered-by: []
---

# Specification: Network Architecture by Workload Tier

**Tier**: infrastructure  
**Category**: networking  
**Spec ID**: net-001  
**Created**: 2026-02-07  
**Updated**: 2026-02-10  
**Status**: Published  
**Derived From**: business/cost-001 v3.0.0 (maximum performance strategy) + business/governance  

## Executive Summary

**Problem**: Without performance-optimized networking:
- High latency for user-facing applications
- Suboptimal inter-region communication
- Network bottlenecks limiting throughput
- Inconsistent performance across deployments

**Solution**: Define premium network architecture and connectivity patterns optimized for speed and throughput.

**Performance Impact**: All workloads use high-performance networking:
- All Workloads: Multi-region deployment option for latency optimization, ExpressRoute Direct for maximum bandwidth
- Premium Load Balancer: Zone-redundant with cross-zone load balancing for zero-latency failover
- Network Optimization: Ultra-high-performance networking tier enabled for all applications

**Impact**: All applications achieve minimum latency and maximum throughput; multi-region deployments reduce user-facing latency by 60%+.

## Requirements

### Functional Requirements

- **REQ-001**: All applications MUST deploy in isolated VNets or subnets
- **REQ-002**: All network traffic MUST be filtered via NSGs (network security groups)
- **REQ-003**: Network architecture MUST prioritize performance and latency optimization
- **REQ-004**: Multi-region deployment SHOULD be used for geographically distributed user bases (latency optimization)
- **REQ-005**: All DNS resolution MUST use Azure private DNS zones
- **REQ-006**: Inter-VNet communication MUST use VNet peering (not public internet)
- **REQ-007**: Load balancer tier selection MUST support premium performance requirements
- **REQ-008**: ExpressRoute Direct SHOULD be used for on-premises connectivity (maximum bandwidth, minimum latency)

### Network Architecture by Workload Tier

#### Critical Workloads (99.95% SLA)
**Target**: Included in $150-250/month compute baseline  
**Network Architecture**:

**Availability Zones**: MULTI-ZONE (3 zones) - HIGH AVAILABILITY REQUIRED
- VMs distributed across Availability Zones 1, 2, 3
- Subnet spans all zones (Azure automatically distributes)
- Zone-redundant load balancer frontend
- Survives datacenter-level failures

### Network Architecture by Workload Type

#### All Production Workloads (Maximum Performance)
**Principle**: Multi-region deployment for latency optimization

**Availability Zones & Regions**: MULTI-REGION (2+ regions) - LATENCY OPTIMIZATION
- Primary region: Closest to main user base
- Secondary region: Alternate geographic region for low-latency serving
- Multi-zone within each region for local redundancy
- Automatic failover between regions via traffic manager

**Network Connectivity**: PREMIUM TIER
- **ExpressRoute Direct**: RECOMMENDED for on-premises connectivity
  - Ultra-high bandwidth (10Gbps or 100Gbps circuits)
  - Private, low-latency connectivity
  - Consistent, predictable network performance
- **Azure Virtual WAN**: RECOMMENDED for multi-region hub-and-spoke
  - Optimized inter-region connectivity
  - Automatic failover across regions
  - ExpressRoute integration

**Load Balancer**:
- **Standard Load Balancer** - REQUIRED
- Zone-redundant frontend IP in each region
- Cross-zone load balancing within region
- Health probes to all zones
- SLA: 99.99%
- Premium networking tier enabled for maximum throughput

**VNet Design**:
- Address space: /16 CIDR per region (e.g., primary: 10.1.0.0/16, secondary: 10.2.0.0/16)
- Subnet design:
  - Web tier: /24 subnet (spans 3 zones)
  - App tier: /24 subnet (spans 3 zones)
  - Data tier: /24 subnet (spans 3 zones)
- NSG: Zero-trust network rules (least privilege)
- Network acceleration: Enabled for premium performance

**Rationale**: Multi-region deployment reduces user-facing latency for geographically distributed users. ExpressRoute Direct provides maximum bandwidth and predictable performance for hybrid connectivity. Zone-redundant within each region ensures local high availability. Premium networking keeps data within Azure backbone.

#### AI/ML & Data-Intensive Workloads (Maximum Throughput)
**Network Connectivity**: ULTRA-HIGH PERFORMANCE
- **ExpressRoute Direct (100Gbps)**: REQUIRED for data pipeline feeds
  - Maximum bandwidth for data ingestion
  - Ultra-low latency for real-time processing pipelines
- **Azure Virtual WAN Premium**: For multi-region data movement

**Load Balancer**:
- **Standard Load Balancer** with Premium networking
- Cross-region load balancing for distributed GPU clusters

**Rationale**: Maximum bandwidth for data-intensive workloads. 100Gbps ExpressRoute ensures data pipeline doesn't bottleneck GPUs. Ultra-performance networking tier optimizes inter-node communication.

#### Development/Test Workloads (Premium Tier for Accuracy)
**Network Architecture**: Matches production pattern for accurate testing

**Availability Zones & Regions**: MULTI-ZONE within single primary region
- Distributed across 3 zones (matches production test accuracy)
- Single region deployment acceptable for dev/test

**Network Connectivity**:
- **ExpressRoute Standard**: Available for dev/test if needed
- Standard VNet peering for multi-region dev-to-prod connectivity (for smoke tests)

**Load Balancer**:
- **Standard Load Balancer** - REQUIRED (matches production)
- Zone-redundant to replicate production topology

**Rationale**: Dev/test should match production networking to enable accurate performance testing. Prevents networking from becoming bottleneck during testing. Supports realistic failover and multi-region scenarios.

### Network Performance Optimization

- **REQ-OPT-001**: All applications SHOULD use ExpressRoute Direct for on-premises connectivity (maximum bandwidth)
- **REQ-OPT-002**: Multi-region deployment SHOULD be used for geographically distributed users (latency <50ms to any user)
- **REQ-OPT-003**: Premium networking tier SHOULD be enabled for all workloads
- **REQ-OPT-004**: Cross-region VNet peering SHOULD be used for multi-region communication
- **REQ-OPT-005**: Network acceleration SHOULD be enabled for all virtual machines (faster packet processing)

## Success Criteria

- **SC-001**: All applications deployed in isolated VNets/subnets (100% compliance)
- **SC-002**: All network traffic filtered via NSGs (zero unfiltered traffic)
- **SC-003**: User-facing applications deployed across 2+ regions for latency optimization
- **SC-004**: ExpressRoute Direct used for on-premises connectivity (where applicable)
- **SC-005**: DNS resolution via Azure private DNS zones
- **SC-006**: VNet peering used for inter-VNet communication (no public routing)
- **SC-007**: Load balancer tier supports premium performance requirements
- **SC-008**: Average latency to users reduced by 60%+ via multi-region deployment

## Change Log

| Version | Date | Change | Approved By |
|---------|------|--------|------------|
| 1.0.0-draft | 2026-02-07 | Initial networking spec | Infrastructure Lead |
| 2.0.0 | 2026-02-09 | **BREAKING**: Updated to align with business/cost v2.0.0; added multi-zone vs single-zone deployment guidance; added load balancer tier selection; added cost optimization strategies; published | Infrastructure Lead (cascade from business/cost) |
| 3.0.0 | 2026-02-10 | **BREAKING**: Shifted to performance-first strategy from business/cost v3.0.0; changed to multi-region deployment for latency optimization; ExpressRoute Direct for maximum connectivity; premium tier networking mandatory; removed cost optimization; focus on 60%+ latency reduction | Infrastructure Lead (cascade from business/cost) |

---

**Spec Version**: 3.0.0  
**Approved Date**: 2026-02-10  
**Depends On**: business/cost-001 (v3.0.0), business/governance (gov-001)  
**Artifacts Location**: artifacts/infrastructure/iac-modules/
