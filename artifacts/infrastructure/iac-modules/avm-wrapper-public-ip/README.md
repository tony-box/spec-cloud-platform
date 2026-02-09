# Azure Public IP Address Wrapper Module

**Purpose**: Compliant Azure Public IP Address wrapper around Azure Verified Module  
**AVM Source**: `br/public:avm/res/network/public-ip-address:0.4.0`  
**Spec**: infrastructure/iac-modules (iac-001)  
**Version**: 1.0.0  
**Status**: Ready for use

---

## Overview

This wrapper module provides a compliant Azure Public IP Address with Standard SKU and static allocation enforced for zone redundancy and DDoS protection. It wraps the official Azure Verified Module (AVM) while enforcing platform standards.

**Key Features**:
- ✅ Standard SKU (zone-redundant, DDoS Protection Basic included)
- ✅ Static allocation (no dynamic IPs)
- ✅ Zone redundancy for production (zones 1, 2, 3)
- ✅ US regions only per compliance-framework-001
- ✅ NIST 800-171 compliance tagging
- ✅ Optional DNS label for FQDN

---

## Compliance

| Spec | Requirement | Implementation |
|------|-------------|----------------|
| cost-001 | Cost-optimized networking | Standard SKU (minimal cost, $3-4/month) |
| dp-001 | DDoS Protection | Standard SKU includes Basic DDoS Protection |
| ac-001 | Network security | Static IP enables consistent firewall rules |
| comp-001 | US regions only | `@allowed(['centralus', 'eastus'])` |
| lint-001 | Code quality | Passes `bicep build` validation |

---

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `publicIpName` | string | Name of the public IP (e.g., `mycoolapp-prod-pip`) |
| `environment` | string | Environment: `dev` or `prod` |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | `centralus` | Azure region (restricted to `centralus` or `eastus`) |
| `dnsLabel` | string | `''` (none) | DNS label (creates `<label>.<location>.cloudapp.azure.com`) |
| `zones` | array | `['1','2','3']` (prod), `[]` (dev) | Availability zones for redundancy |
| `additionalTags` | object | `{}` | Additional tags to merge with default compliance tags |

---

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `publicIpId` | string | Resource ID of the public IP |
| `publicIpName` | string | Name of the public IP |
| `ipAddress` | string | Static IP address value |
| `fqdn` | string | Fully qualified domain name (if DNS label provided) |
| `location` | string | Location of the public IP |
| `sku` | string | SKU of the public IP (always `Standard`) |
| `availabilityZones` | array | Availability zones configured |
| `resourceGroupName` | string | Resource group name |

---

## Usage Examples

### Example 1: Basic Public IP (Dev Environment)

```bicep
module publicIp '../../../infrastructure/iac-modules/avm-wrapper-public-ip/main.bicep' = {
  name: 'pip-deployment'
  params: {
    publicIpName: 'mycoolapp-dev-pip'
    environment: 'dev'
    location: 'centralus'
  }
}

// Output: Static IP without zone redundancy (dev doesn't need HA)
```

### Example 2: Production Public IP with DNS Label

```bicep
module publicIp '../../../infrastructure/iac-modules/avm-wrapper-public-ip/main.bicep' = {
  name: 'pip-deployment'
  params: {
    publicIpName: 'mycoolapp-prod-pip'
    environment: 'prod'
    location: 'centralus'
    dnsLabel: 'mycoolapp-prod'
  }
}

// Output: 
// - IP Address: e.g., 20.12.34.56
// - FQDN: mycoolapp-prod.centralus.cloudapp.azure.com
// - Zones: [1, 2, 3] (zone-redundant)
```

### Example 3: Use Public IP with Load Balancer

```bicep
module publicIp '../../../infrastructure/iac-modules/avm-wrapper-public-ip/main.bicep' = {
  name: 'pip-deployment'
  params: {
    publicIpName: 'mycoolapp-prod-lb-pip'
    environment: 'prod'
    location: 'centralus'
    dnsLabel: 'mycoolapp-lb'
  }
}

// Reference in Load Balancer frontend config
resource loadBalancer 'Microsoft.Network/loadBalancers@2023-11-01' = {
  name: 'mycoolapp-prod-lb'
  location: 'centralus'
  properties: {
    frontendIPConfigurations: [
      {
        name: 'frontend-config'
        properties: {
          publicIPAddress: {
            id: publicIp.outputs.publicIpId
          }
        }
      }
    ]
  }
}
```

### Example 4: Use Public IP with VM

```bicep
module publicIp '../../../infrastructure/iac-modules/avm-wrapper-public-ip/main.bicep' = {
  name: 'pip-deployment'
  params: {
    publicIpName: 'mycoolapp-dev-vm-pip'
    environment: 'dev'
    location: 'centralus'
  }
}

module vm '../../../infrastructure/iac-modules/avm-wrapper-linux-vm/main.bicep' = {
  name: 'vm-deployment'
  params: {
    vmName: 'mycoolapp-dev-vm'
    environment: 'dev'
    publicIpId: publicIp.outputs.publicIpId // Associate public IP with VM NIC
  }
}
```

---

## DNS Configuration

### DNS Label Benefits
- **Friendly FQDN**: `mycoolapp-prod.centralus.cloudapp.azure.com` instead of IP
- **SSL/TLS certificates**: Can use FQDN for certificate validation
- **Documentation**: Easier for teams to remember than IP addresses

### DNS Label Constraints
- **Length**: 3-63 characters
- **Characters**: Lowercase letters, numbers, hyphens (no underscores)
- **Must start**: With letter or number
- **Uniqueness**: Must be unique within the Azure region

### Example FQDNs
- `mycoolapp-prod.centralus.cloudapp.azure.com`
- `webapp-001.eastus.cloudapp.azure.com`
- `api-gateway.centralus.cloudapp.azure.com`

---

## Zone Redundancy

### Availability Zones Explained
- **Zone 1, 2, 3**: Physically separate datacenters within same region
- **Protection**: Protects against datacenter-level failures
- **SLA**: 99.99% availability (vs 99.95% for single-zone)

### When to Use Zones
- **Production**: Always use zones for critical workloads (enabled by default)
- **Development**: Can skip zones to simplify deployment (disabled by default)

### Cost Impact
- **Zone-redundant Public IP**: Same cost as non-zoned ($3-4/month)
- **No additional charge** for zone redundancy

---

## DDoS Protection

### Standard SKU DDoS Features
- **Basic DDoS Protection**: Included free with Standard SKU
  - Layer 3/4 volumetric attack mitigation
  - Automatic traffic monitoring
  - Instant mitigation

### DDoS Protection Standard (Optional)
- **Cost**: ~$2944/month (requires DDoS Protection Plan)
- **Features**: Layer 7 protection, attack analytics, rapid response team
- **When to use**: High-value production workloads with strict SLAs

**Default**: This module uses Basic DDoS (free), inherits from VNet DDoS Protection Plan if configured.

---

## Cost Considerations

- **Public IP Standard SKU**: ~$3.65/month (static, zone-redundant)
- **Outbound data transfer**: $0.087/GB (first 100GB free/month)
- **Idle IP charges**: None (Standard SKU always billed, even if unused)

**Dev Cost**: ~$3.65/month  
**Prod Cost**: ~$3.65/month (same, zone redundancy included)

**Cost Optimization**: 
- Delete unused public IPs (billed even when not attached)
- Use single public IP with Load Balancer for multiple VMs

---

## Static vs Dynamic Allocation

### Why Static Only?
- **Standard SKU requirement**: Standard SKU only supports static allocation
- **Firewall rules**: Static IPs enable consistent allow-listing
- **DNS stability**: FQDN always resolves to same IP
- **Certificate pinning**: SSL certificates can reference stable IP

### Migration from Dynamic
If migrating from Basic SKU (dynamic):
1. Note current IP address (if needed for firewall updates)
2. Deallocate resource using the IP
3. Delete Basic SKU public IP
4. Create Standard SKU public IP (static)
5. Reassociate with resource

---

## Deployment Validation

### Validate Bicep

```powershell
bicep build main.bicep
```

### Deploy to Dev

```powershell
az deployment group create `
  --resource-group rg-mycoolapp-dev `
  --template-file main.bicep `
  --parameters parameters.json
```

### Get IP Address

```powershell
az network public-ip show `
  --name mycoolapp-dev-pip `
  --resource-group rg-mycoolapp-dev `
  --query ipAddress --output tsv
```

---

## Troubleshooting

### Issue: "SKU mismatch"
**Cause**  : Trying to associate Standard public IP with Basic Load Balancer  
**Solution**: Use Standard Load Balancer with Standard public IP

### Issue: "DNS label already in use"
**Cause**: Another resource in same region using same DNS label  
**Solution**: Choose unique DNS label or use different region

### Issue: "Zone not available"
**Cause**: Selected region doesn't support availability zones  
**Solution**: Use centralus or eastus (both support zones)

---

## Related Modules

- **avm-wrapper-linux-vm**: Attach public IP to VM network interface
- **avm-wrapper-vnet**: Public IP typically used with resources in VNet
- **avm-wrapper-nsg**: NSG rules control access to public IP

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-02-07 | Initial release wrapping AVM Public IP module v0.4.0 |

---

## Upstream Specs

- **infrastructure/iac-modules** (iac-001): Wrapper module specification
- **business/cost** (cost-001): Cost optimization requirements
- **security/data-protection** (dp-001): DDoS Protection requirements
- **business/compliance-framework** (comp-001): US regions and tagging requirements
- **platform/iac-linting** (lint-001): Code quality standards

---

**Module Owner**: Infrastructure Engineering Team  
**Support**: platform-team@company.com  
**License**: Internal use only
