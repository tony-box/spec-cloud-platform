---
# YAML Frontmatter - Category-Based Spec System
tier: infrastructure
category: networking
spec-id: net-001
version: 1.0.0-draft
status: draft
created: 2026-02-07
description: "VNets, subnets, NSGs (network security groups), load balancing, DNS, connectivity"

# Dependencies
depends-on:
  - tier: business
    category: governance
    spec-id: gov-001
    reason: "Network connectivity and SLA definitions from business governance"

# Precedence rules
precedence:
  note: "Networking priority varies by workload; latency-sensitive workloads elevate networking precedence"

# Relationships
adhered-by:
  - app-id: mycoolapp
    version: "1.0.0"
    networking: "Azure VNet with NSGs, Standard Load Balancer"
---

# Specification: Networking Infrastructure

**Tier**: infrastructure  
**Category**: networking  
**Spec ID**: net-001  
**Created**: 2026-02-07  
**Status**: Draft  

## Executive Summary

**Problem**: Without standardized networking:
- Inconsistent network segmentation
- Security gaps in network isolation
- Unpredictable latency and availability
- No standardized load balancing patterns

**Solution**: Define standard VNet architecture, NSG rules, load balancing patterns, and DNS configuration.

**Impact**: All applications follow consistent networking patterns enabling security, performance, and cost optimization.

## Requirements

### Functional Requirements

- **REQ-001**: All applications MUST deploy in isolated VNets or subnets
- **REQ-002**: All network traffic MUST be filtered via NSGs (network security groups)
- **REQ-003**: Production applications MUST use Standard Load Balancer (not Basic)
- **REQ-004**: All DNS resolution MUST use Azure private DNS zones
- **REQ-005**: Inter-VNet communication MUST use VNet peering (not public internet)

### VNet Architecture

**Standard VNet Design**:
- Address space: /16 CIDR block per VNet (e.g., 10.1.0.0/16)
- Subnets:
  - Web tier: /24 subnet (e.g., 10.1.1.0/24)
  - App tier: /24 subnet (e.g., 10.1.2.0/24)
  - Data tier: /24 subnet (e.g., 10.1.3.0/24)
  - Management: /28 subnet (e.g., 10.1.255.0/28)
- Region: Single region (avoid cross-region for cost)
- Redundancy: Availability Zones for critical workloads

**Network Segmentation**:
- Production: Separate VNet (10.1.0.0/16)
- Dev/Test: Separate VNet (10.2.0.0/16)
- Management: Separate VNet (10.255.0.0/16)
- No cross-environment peering (production isolated)

### Network Security Groups (NSGs)

**Default NSG Rules**:
- Inbound:
  - Allow: HTTPS (443) from internet (public-facing apps only)
  - Allow: SSH (22) from management VNet only
  - Allow: VNet-to-VNet traffic (application tier communication)
  - Deny: All other inbound traffic (default deny)
- Outbound:
  - Allow: HTTPS (443) to internet (API calls, updates)
  - Allow: VNet-to-VNet traffic
  - Deny: All other outbound traffic (default deny)

**Application-Specific NSG**:
- Web tier: Allow 80/443 inbound from internet
- App tier: Allow application ports from web tier only
- Data tier: Allow database ports from app tier only
- Management: Allow SSH/RDP from bastion host only

### Load Balancing

**Standard Load Balancer** (Production):
- Type: Standard SKU (supports Availability Zones)
- Frontend: Public IP (static) or internal (private subnet)
- Backend pool: VMs in availability set or zone
- Health probe: HTTP/HTTPS health endpoint
- Rules: TCP/HTTP/HTTPS forwarding
- Cost: ~$0.025/hour + $0.005/GB processed

**Basic Load Balancer** (Dev/Test):
- Not recommended (no SLA, no zones)
- Use Standard Load Balancer with smaller backend pool

**Traffic Manager** (Multi-Region):
- Only if multi-region deployment required
- Routing: Priority (primary/failover) or Performance (latency-based)

### DNS Configuration

**Azure Private DNS Zones**:
- Zone name: app.internal (private zone)
- Records: A records for VMs, CNAME for services
- Resolution: Automatic from VNet (no manual DNS config)

**Public DNS**:
- Use Azure DNS zones or external provider
- CNAME to Azure Front Door or Application Gateway
- TTL: 300 seconds (5 minutes)

## Success Criteria

- **SC-001**: All applications deployed in isolated VNets/subnets
- **SC-002**: All network traffic filtered via NSGs (zero unfiltered traffic)
- **SC-003**: Production uses Standard Load Balancer (SLA guarantee)
- **SC-004**: DNS resolution via Azure private DNS zones
- **SC-005**: VNet peering used for inter-VNet communication (no public routing)

## Change Log

| Version | Date | Change | Approved By |
|---------|------|--------|------------|
| 1.0.0-draft | 2026-02-07 | Initial networking spec | Infrastructure Lead |

---

**Spec Version**: 1.0.0-draft  
**Created**: 2026-02-07
