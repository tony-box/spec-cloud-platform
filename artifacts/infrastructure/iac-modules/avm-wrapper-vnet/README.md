# Azure Virtual Network Wrapper Module

**Purpose**: Compliant Azure Virtual Network (VNet) wrapper around Azure Verified Module  
**AVM Source**: `br/public:avm/res/network/virtual-network:0.5.1`  
**Spec**: infrastructure/iac-modules (iac-001)  
**Version**: 1.0.0  
**Status**: Ready for use

---

## Overview

This wrapper module provides a compliant Azure Virtual Network that enforces platform standards for cost, security, and compliance. It wraps the official Azure Verified Module (AVM) for VNets while restricting parameters to compliant options.

**Key Features**:
- ✅ US regions only (centralus, eastus) per compliance-framework-001
- ✅ /16 CIDR default per networking-001
- ✅ NIST 800-171 compliance tagging
- ✅ NSG association support for subnets
- ✅ DDoS Protection Standard for production
- ✅ Environment-aware defaults (dev vs prod)

---

## Compliance

| Spec | Requirement | Implementation |
|------|-------------|----------------|
| cost-001 | Cost-optimized networking | Standard tier, no premium features unless prod |
| dp-001 | Encryption | Prepared for VNet encryption (not yet GA) |
| ac-001 | Network isolation | NSG association required for all subnets |
| comp-001 | US regions only | `@allowed(['centralus', 'eastus'])` on location parameter |
| lint-001 | Code quality | Passes `bicep build` validation |

---

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vnetName` | string | Name of the virtual network (e.g., `mycoolapp-prod-vnet`) |
| `environment` | string | Environment: `dev` or `prod` |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `addressPrefix` | string | `10.0.0.0/16` | Address prefix for the VNet (CIDR notation) |
| `location` | string | `centralus` | Azure region (restricted to `centralus`  or `eastus`) |
| `subnets` | array | `[{ name: 'default', addressPrefix: '10.0.1.0/24' }]` | Subnets to create |
| `nsgIds` | object | `{}` | NSG resource IDs to associate with subnets (key = subnet name, value = NSG ID) |
| `enableDdosProtection` | bool | `true` (prod), `false` (dev) | Enable DDoS Protection Standard |
| `additionalTags` | object | `{}` | Additional tags to merge with default compliance tags |

---

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `vnetId` | string | Resource ID of the virtual network |
| `vnetName` | string | Name of the virtual network |
| `addressPrefix` | string | Address prefix of the virtual network |
| `subnetIds` | array | Subnet resource IDs |
| `subnetNames` | array | Subnet names |
| `location` | string | Location of the virtual network |
| `resourceGroupName` | string | Resource group name containing the virtual network |

---

## Usage Examples

### Example 1: Basic VNet (Dev Environment)

```bicep
module vnet '../../../infrastructure/iac-modules/avm-wrapper-vnet/main.bicep' = {
  name: 'vnet-deployment'
  params: {
    vnetName: 'mycoolapp-dev-vnet'
    environment: 'dev'
    location: 'centralus'
    addressPrefix: '10.0.0.0/16'
    subnets: [
      {
        name: 'app-subnet'
        addressPrefix: '10.0.1.0/24'
      }
      {
        name: 'db-subnet'
        addressPrefix: '10.0.2.0/24'
      }
    ]
  }
}
```

### Example 2: Production VNet with NSG Associations

```bicep
// First create NSG
module nsg '../../../infrastructure/iac-modules/avm-wrapper-nsg/main.bicep' = {
  name: 'nsg-deployment'
  params: {
    nsgName: 'mycoolapp-prod-nsg'
    environment: 'prod'
    location: 'centralus'
  }
}

// Then create VNet with NSG association
module vnet '../../../infrastructure/iac-modules/avm-wrapper-vnet/main.bicep' = {
  name: 'vnet-deployment'
  params: {
    vnetName: 'mycoolapp-prod-vnet'
    environment: 'prod'
    location: 'centralus'
    addressPrefix: '10.1.0.0/16'
    subnets: [
      {
        name: 'app-subnet'
        addressPrefix: '10.1.1.0/24'
      }
      {
        name: 'db-subnet'
        addressPrefix: '10.1.2.0/24'
      }
    ]
    nsgIds: {
      'app-subnet': nsg.outputs.nsgId
      'db-subnet': nsg.outputs.nsgId
    }
    enableDdosProtection: true
  }
}
```

### Example 3: Custom Tagging

```bicep
module vnet '../../../infrastructure/iac-modules/avm-wrapper-vnet/main.bicep' = {
  name: 'vnet-deployment'
  params: {
    vnetName: 'mycoolapp-prod-vnet'
    environment: 'prod'
    location: 'eastus'
    additionalTags: {
      costCenter: 'Engineering'
      project: 'LAMP-Modernization'
      owner: 'platform-team@company.com'
    }
  }
}
```

---

## Default Tags

All VNets are automatically tagged with:

```json
{
  "compliance": "nist-800-171",
  "environment": "<dev|prod>",
  "managedBy": "bicep",
  "tier": "infrastructure",
  "module": "avm-wrapper-vnet",
  "version": "1.0.0"
}
```

---

## Subnet Configuration

### Subnet Object Structure

```typescript
{
  name: string              // Subnet name (e.g., 'app-subnet')
  addressPrefix: string     // CIDR (e.g., '10.0.1.0/24')
}
```

### NSG Association

To associate NSGs with subnets, provide the `nsgIds` parameter:

```bicep
nsgIds: {
  'subnet-name': 'nsg-resource-id'
}
```

The wrapper automatically applies NSGs to matching subnet names.

---

## Networking Best Practices

### Address Planning
- **Dev**: Use `10.0.x.x/16` range
- **Prod**: Use `10.1.x.x/16` range
- **Subnet sizing**: /24 supports 251 usable IPs (adequate for most workloads)
- **Reserved subnets**: Plan for GatewaySubnet (/27), AzureBastionSubnet (/26) if needed

### Subnet Design
- **app-subnet**: Application tier (VMs, containers)
- **db-subnet**: Database tier (Azure MySQL, etc.)
- **mgmt-subnet**: Management/jump servers
- **gateway-subnet**: VPN/ExpressRoute gateway (if required)

### Security
- **Always use NSGs**: No subnet should be without NSG protection
- **Least privilege**: Default deny all inbound; allow only required ports
- **Segmentation**: Separate app and data tiers into different subnets

---

## Cost Considerations

- **VNet**: No cost for VNet itself
- **DDoS Protection Standard**: ~$2944/month (prod only, optional)
- **VNet peering**: ~$0.01/GB if peering with other VNets
- **Data transfer**: Standard Azure egress charges apply

**Dev Cost**: $0/month (no DDoS Protection)  
**Prod Cost**: ~$2944/month (if DDoS Protection enabled)

**Cost Optimization**: Disable DDoS Protection if not required by business SLA.

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
  --parameters parameters.dev.json
```

### Deploy to Prod

```powershell
az deployment group create `
  --resource-group rg-mycoolapp-prod `
  --template-file main.bicep `
  --parameters parameters.prod.json
```

---

## Troubleshooting

### Issue: "Location not allowed"
**Cause**: Attempted deployment to non-US region  
**Solution**: Use `location: 'centralus'` or `location: 'eastus'` only

### Issue: "Address space overlaps"
**Cause**: VNet CIDR conflicts with existing VNets  
**Solution**: Choose non-overlapping address space (e.g., 10.2.0.0/16)

### Issue: "NSG association failed"
**Cause**: NSG ID in `nsgIds` doesn't exist or subnet name mismatch  
**Solution**: Verify NSG is deployed first and subnet names match exactly

---

## Related Modules

- **avm-wrapper-nsg**: Network Security Group for subnet protection
- **avm-wrapper-public-ip**: Public IP addresses for internet-facing resources
- **avm-wrapper-linux-vm**: Virtual machines to deploy into VNet subnets

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-02-07 | Initial release wrapping AVM VNet module v0.5.1 |

---

##  Upstream Specs

- **infrastructure/iac-modules** (iac-001): Wrapper module specification
- **business/cost** (cost-001): Cost optimization requirements
- **security/data-protection** (dp-001): Encryption requirements
- **security/access-control** (ac-001): Network isolation requirements
- **business/compliance-framework** (comp-001): US regions and tagging requirements
- **platform/iac-linting** (lint-001): Code quality standards

---

**Module Owner**: Infrastructure Engineering Team  
**Support**: platform-team@company.com  
**License**: Internal use only
