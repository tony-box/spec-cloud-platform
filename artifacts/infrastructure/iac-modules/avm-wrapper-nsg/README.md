# Azure Network Security Group Wrapper Module

**Purpose**: Compliant Azure Network Security Group (NSG) wrapper around Azure Verified Module  
**AVM Source**: `br/public:avm/res/network/network-security-group:0.3.2`  
**Spec**: infrastructure/iac-modules (iac-001)  
**Version**: 1.0.0  
**Status**: Ready for use

---

## Overview

This wrapper module provides a compliant Azure Network Security Group with baseline security rules enforcing platform standards. It wraps the official Azure Verified Module (AVM) for NSGs while providing a secure-by-default configuration.

**Key Features**:
- ✅ Default deny all inbound traffic per access-control-001
- ✅ SSH access restricted to corporate VPN (or denied entirely)
- ✅ HTTP/HTTPS allowed for public web applications
- ✅ Custom application rules supported (priority 2000-4000)
- ✅ US regions only per compliance-framework-001
- ✅ NIST 800-171 compliance tagging

---

## Compliance

| Spec | Requirement | Implementation |
|------|-------------|----------------|
| cost-001 | Cost-optimized networking | NSG has no cost |
| dp-001 | Encryption in transit | HTTPS rule allows TLS traffic |
| ac-001 | Network access control | SSH restricted, default deny all inbound |
| comp-001 | US regions only | `@allowed(['centralus', 'eastus'])` |
| lint-001 | Code quality | Passes `bicep build` validation |

---

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `nsgName` | string | Name of the NSG (e.g., `mycoolapp-prod-nsg`) |
| `environment` | string | Environment: `dev` or `prod` |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | `centralus` | Azure region (restricted to `centralus` or `eastus`) |
| `customRules` | array | `[]` | Application-specific security rules (priority 2000-4000) |
| `sshSourceAddressPrefix` | string | `''` (deny) | IP/CIDR allowed for SSH (empty = deny all SSH) |
| `additionalTags` | object | `{}` | Additional tags to merge with default compliance tags |

---

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `nsgId` | string | Resource ID of the NSG |
| `nsgName` | string | Name of the NSG |
| `location` | string | Location of the NSG |
| `ruleCount` | int | Number of security rules configured |
| `resourceGroupName` | string | Resource group name containing the NSG |

---

## Default Security Rules

### Baseline Rules (Automatically Applied)

| Priority | Name | Direction | Access | Protocol | Ports | Source | Destination | Description |
|----------|------|-----------|--------|----------|-------|--------|-------------|-------------|
| 1000 | AllowSSH | Inbound | Allow/Deny | TCP | 22 | VPN or * | * | SSH (restricted or denied) |
| 1010 | AllowHTTP | Inbound | Allow | TCP | 80 | * | * | HTTP from internet |
| 1020 | AllowHTTPS | Inbound | Allow | TCP | 443 | * | * | HTTPS from internet |
| 4096 | DenyAllInbound | Inbound | Deny | * | * | * | * | Default deny |

**Note**: SSH is DENIED by default unless `sshSourceAddressPrefix` is provided.

---

## Usage Examples

### Example 1: Basic NSG (Deny SSH, Allow HTTP/HTTPS)

```bicep
module nsg '../../../infrastructure/iac-modules/avm-wrapper-nsg/main.bicep' = {
  name: 'nsg-deployment'
  params: {
    nsgName: 'mycoolapp-dev-nsg'
    environment: 'dev'
    location: 'centralus'
    // sshSourceAddressPrefix: '' (default: deny SSH)
  }
}
```

This creates an NSG that:
- ✅ Allows HTTP (port 80)
- ✅ Allows HTTPS (port 443)
- ❌ Denies SSH (port 22)
- ❌ Denies all other inbound traffic

### Example 2: Allow SSH from Corporate VPN

```bicep
module nsg '../../../infrastructure/iac-modules/avm-wrapper-nsg/main.bicep' = {
  name: 'nsg-deployment'
  params: {
    nsgName: 'mycoolapp-prod-nsg'
    environment: 'prod'
    location: 'centralus'
    sshSourceAddressPrefix: '203.0.113.0/24' // Corporate VPN CIDR
  }
}
```

This allows SSH only from the corporate VPN IP range.

### Example 3: Custom Application Rules

```bicep
module nsg '../../../infrastructure/iac-modules/avm-wrapper-nsg/main.bicep' = {
  name: 'nsg-deployment'
  params: {
    nsgName: 'mycoolapp-prod-nsg'
    environment: 'prod'
    location: 'centralus'
    sshSourceAddressPrefix: '203.0.113.0/24'
    customRules: [
      {
        name: 'AllowMySQL'
        priority: 2000
        direction: 'Inbound'
        access: 'Allow'
        protocol: 'Tcp'
        sourcePortRange: '*'
        destinationPortRange: '3306'
        sourceAddressPrefix: '10.0.1.0/24' // App subnet only
        destinationAddressPrefix: '10.0.2.0/24' // DB subnet
        description: 'Allow MySQL from app subnet to DB subnet'
      }
      {
        name: 'AllowRedis'
        priority: 2010
        direction: 'Inbound'
        access: 'Allow'
        protocol: 'Tcp'
        sourcePortRange: '*'
        destinationPortRange: '6379'
        sourceAddressPrefix: '10.0.1.0/24' // App subnet
        destinationAddressPrefix: '10.0.3.0/24' // Cache subnet
        description: 'Allow Redis from app subnet'
      }
    ]
  }
}
```

**Custom Rule Priorities**: Use 2000-4000 to avoid conflicts with baseline rules (1000-1999) and default deny (4096).

---

## Security Best Practices

### SSH Access
- **Production**: Only allow SSH from corporate VPN or Azure Bastion
- **Development**: Can be more permissive but document justification
- **Best practice**: Use Azure Bastion for zero-trust SSH access (no public IP)

### Rule Priority Guidelines
- **1000-1999**: Reserved for baseline platform rules
- **2000-3999**: Application-specific custom rules
- **4000-4095**: Reserved for future platform rules
- **4096**: Default deny (do not override)

### Least Privilege
- **Default deny**: Start with deny all, explicitly allow only required ports
- **Source filtering**: Restrict sources to specific IPs/subnets when possible
- **Protocol specificity**: Use `Tcp` or `Udp` instead of `*` where applicable

### Common Application Ports
- **HTTP**: 80 (already allowed in baseline)
- **HTTPS**: 443 (already allowed in baseline)
- **MySQL**: 3306 (add custom rule, restrict to app subnet)
- **PostgreSQL**: 5432 (add custom rule, restrict to app subnet)
- **Redis**: 6379 (add custom rule, restrict to app  subnet)
- **SSH**: 22 (denied by default, enable with VPN restriction only)

---

## Cost Considerations

- **NSG**: Free (no cost)
- **Flow logs**: ~$0.50/GB (optional, production monitoring)

**Total Cost**: $0/month (flow logs disabled by default)

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

---

## Troubleshooting

### Issue: "SSH not working"
**Cause**: SSH denied by default  
**Solution**: Set `sshSourceAddressPrefix` to your VPN CIDR or use Azure Bastion

### Issue: "Custom rule not applied"
**Cause**: Priority conflict with baseline rules  
**Solution**: Use priority 2000-4000 for custom rules

### Issue: "Application port blocked"
**Cause**: Default deny rule blocks unspecified ports  
**Solution**: Add custom rule for your application port with appropriate source restriction

---

## Related Modules

- **avm-wrapper-vnet**: Associate NSG with VNet subnets
- **avm-wrapper-linux-vm**: VMs protected by NSG rules
- **avm-wrapper-mysql-flexibleserver**: Database protected by NSG (VNet integration)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-02-07 | Initial release wrapping AVM NSG module v0.3.2 |

---

## Upstream Specs

- **infrastructure/iac-modules** (iac-001): Wrapper module specification
- **security/access-control** (ac-001): Network access control requirements (SSH keys, default deny)
- **business/compliance-framework** (comp-001): US regions and tagging requirements
- **platform/iac-linting** (lint-001): Code quality standards

---

**Module Owner**: Infrastructure Engineering Team  
**Support**: platform-team@company.com  
**License**: Internal use only
