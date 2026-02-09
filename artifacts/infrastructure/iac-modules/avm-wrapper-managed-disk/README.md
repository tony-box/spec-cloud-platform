# Azure Managed Disk Wrapper Module

**Purpose**: Compliant Azure Managed Disk wrapper around Azure Verified Module  
**AVM Source**: `br/public:avm/res/compute/disk:0.3.1`  
**Spec**: infrastructure/iac-modules (iac-001)  
**Version**: 1.0.0  
**Status**: Ready for use

---

## Overview

This wrapper module provides a compliant Azure Managed Disk with cost-optimized SKUs, encryption at rest, and optional zone redundancy. It wraps the official Azure Verified Module (AVM) while enforcing platform standards.

**Key Features**:
- ✅ Cost-optimized disk SKUs (StandardSSD_LRS dev, Premium_LRS prod)
- ✅ Encryption at rest for production (dp-001)
- ✅ Zone-redundant storage for high availability (ZRS)
- ✅ Public network access disabled (ac-001)
- ✅ US regions only per compliance-framework-001
- ✅ NIST 800-171 compliance tagging

---

## Compliance

| Spec | Requirement | Implementation |
|------|-------------|----------------|
| cost-001 | Cost-optimized storage | StandardSSD_LRS (dev), Premium_LRS (prod) |
| dp-001 | Encryption at rest | Platform-managed keys enabled for production |
| ac-001 | Network security | `publicNetworkAccess: Disabled`, `networkAccessPolicy: DenyAll` |
| comp-001 | US regions only | `@allowed(['centralus', 'eastus'])` |
| lint-001 | Code quality | Passes `bicep build` validation |

---

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `diskName` | string | Name of the disk (e.g., `mycoolapp-prod-data-disk`) |
| `environment` | string | Environment: `dev` or `prod` |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | `centralus` | Azure region (`centralus` or `eastus`) |
| `diskSizeGB` | int | `128` | Disk size in GiB (4-32767) |
| `diskSku` | string | `StandardSSD_LRS` (dev), `Premium_LRS` (prod) | Disk SKU |
| `createOption` | string | `Empty` | Create option: `Empty` (new disk) or `Copy` (from snapshot) |
| `sourceResourceId` | string | `''` (none) | Source snapshot ID if `createOption` is `Copy` |
| `enableEncryption` | bool | `true` (prod), `false` (dev) | Enable encryption at rest |
| `zone` | string | `''` (none) | Availability zone (1, 2, or 3) |
| `additionalTags` | object | `{}` | Additional tags |

---

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `diskId` | string | Resource ID of the disk |
| `diskName` | string | Name of the disk |
| `diskSizeGB` | int | Disk size in GiB |
| `diskSku` | string | Disk SKU |
| `location` | string | Location of the disk |
| `availabilityZone` | string | Availability zone (if configured) |
| `resourceGroupName` | string | Resource group name |

---

## Usage Examples

### Example 1: Basic Data Disk (Dev)

```bicep
module dataDisk '../../../infrastructure/iac-modules/avm-wrapper-managed-disk/main.bicep' = {
  name: 'data-disk-deployment'
  params: {
    diskName: 'mycoolapp-dev-data-disk'
    environment: 'dev'
    location: 'centralus'
    diskSizeGB: 128 // 128 GiB for application data
  }
}

// Output: StandardSSD_LRS, 128 GiB, ~$10/month
```

### Example 2: Production Disk with Premium SSD

```bicep
module dataDisk '../../../infrastructure/iac-modules/avm-wrapper-managed-disk/main.bicep' = {
  name: 'data-disk-deployment'
  params: {
    diskName: 'mycoolapp-prod-data-disk'
    environment: 'prod'
    location: 'centralus'
    diskSizeGB: 512 // 512 GiB for database storage
    diskSku: 'Premium_LRS'
    enableEncryption: true
  }
}

// Output: Premium_LRS, 512 GiB, encrypted, ~$82/month
```

### Example 3: Zone-Redundant Disk for HA

```bicep
module dataDisk '../../../infrastructure/iac-modules/avm-wrapper-managed-disk/main.bicep' = {
  name: 'data-disk-deployment'
  params: {
    diskName: 'mycoolapp-prod-zrs-disk'
    environment: 'prod'
    location: 'centralus'
    diskSizeGB: 256
    diskSku: 'StandardSSD_ZRS' // Zone-redundant for high availability
  }
}

// Output: StandardSSD_ZRS, 256 GiB, 99.99% availability, ~$40/month
```

### Example 4: Attach Disk to VM

```bicep
module dataDisk '../../../infrastructure/iac-modules/avm-wrapper-managed-disk/main.bicep' = {
  name: 'data-disk-deployment'
  params: {
    diskName: 'mycoolapp-dev-data-disk'
    environment: 'dev'
    diskSizeGB: 128
  }
}

// Attach disk to VM
resource vmDataDiskAttachment 'Microsoft.Compute/virtualMachines/dataDisks@2023-11-01' = {
  parent: vm
  name: 'data-disk-0'
  properties: {
    lun: 0 // Logical Unit Number (0-63)
    createOption: 'Attach'
    managedDisk: {
      id: dataDisk.outputs.diskId
    }
    caching: 'ReadWrite' // None, ReadOnly, ReadWrite
  }
}

// SSH into VM and format the disk:
// sudo fdisk /dev/sdc (create partition)
// sudo mkfs.ext4 /dev/sdc1 (format)
// sudo mkdir /mnt/data (create mount point)
// sudo mount /dev/sdc1 /mnt/data (mount)
// echo '/dev/sdc1 /mnt/data ext4 defaults 0 0' | sudo tee -a /etc/fstab (auto-mount on boot)
```

### Example 5: Create Disk from Snapshot

```bicep
// First, create a snapshot of an existing disk
resource snapshot 'Microsoft.Compute/snapshots@2023-11-01' = {
  name: 'mycoolapp-backup-snapshot'
  location: 'centralus'
  properties: {
    creationData: {
      createOption: 'Copy'
      sourceResourceId: existingDisk.id
    }
  }
}

// Then, create a new disk from the snapshot
module restoredDisk '../../../infrastructure/iac-modules/avm-wrapper-managed-disk/main.bicep' = {
  name: 'restored-disk-deployment'
  params: {
    diskName: 'mycoolapp-restored-disk'
    environment: 'prod'
    diskSizeGB: 256
    createOption: 'Copy'
    sourceResourceId: snapshot.id
  }
}

// Output: New disk with data from snapshot
```

---

## Disk SKU Comparison

### Standard HDD (Not Allowed)
**Not included**: Too slow for application workloads (cost-001 restriction)

### Standard SSD

| SKU | Redundancy | IOPS | Throughput | Use Case | Cost/Month (128 GiB) |
|-----|------------|------|------------|----------|---------------------|
| **Standard_LRS** | Local | 500 | 60 MB/s | Legacy, non-critical | ~$6 |
| **StandardSSD_LRS** | Local | 500 | 60 MB/s | Dev, test, web servers | ~$10 |
| **StandardSSD_ZRS** | Zone-redundant | 500 | 60 MB/s | HA web servers, shared storage | ~$13 |

### Premium SSD

| SKU | Redundancy | IOPS | Throughput | Use Case | Cost/Month (128 GiB) |
|-----|------------|------|------------|----------|---------------------|
| **Premium_LRS** | Local | 500 | 100 MB/s | Prod databases, critical apps | ~$20 |
| **Premium_ZRS** | Zone-redundant | 500 | 100 MB/s | HA databases, mission-critical | ~$25 |

**Performance Tiers** (Premium SSD):
- P10 (128 GiB): 500 IOPS, 100 MB/s
- P20 (512 GiB): 2300 IOPS, 150 MB/s
- P30 (1024 GiB): 5000 IOPS, 200 MB/s

---

## When to Use Each SKU

### StandardSSD_LRS (Dev Default)
- **Use for**: Development, test, non-critical workloads
- **Benefits**: Low cost (~$10/month for 128 GiB)
- **Drawbacks**: No zone redundancy

### Premium_LRS (Prod Default)
- **Use for**: Production databases, critical applications
- **Benefits**: Higher IOPS/throughput, SSD performance
- **Drawbacks**: Higher cost (~$20/month for 128 GiB)

### StandardSSD_ZRS / Premium_ZRS (High Availability)
- **Use for**: Mission-critical workloads requiring 99.99% SLA
- **Benefits**: Zone redundancy protects against datacenter failures
- **Drawbacks**: 30% higher cost than LRS

---

## Disk Sizes and IOPS

### Common Sizes

| Size | Standard SSD IOPS | Premium SSD IOPS | Use Case |
|------|-------------------|------------------|----------|
| 32 GiB | 500 | 500 (P4) | Small app cache |
| 64 GiB | 500 | 500 (P6) | Application logs |
| 128 GiB | 500 | 500 (P10) | Small database |
| 256 GiB | 500 | 1100 (P15) | Medium database |
| 512 GiB | 500 | 2300 (P20) | Large database |
| 1024 GiB | 500 | 5000 (P30) | Enterprise database |

**Note**: Premium SSD IOPS scale with size, Standard SSD does not.

---

## Encryption at Rest

### How It Works
- **Encryption**: AES-256 encryption
- **Key Management**: Platform-managed keys (default) or customer-managed keys (CMK)
- **Performance**: No impact on IOPS or throughput
- **Cost**: No additional cost

### Default Encryption (Platform-Managed Keys)
- **Enabled by default**: All disks encrypted automatically
- **Key rotation**: Automatic by Azure
- **No configuration needed**

### Customer-Managed Keys (Advanced)
```bicep
// Requires Key Vault and encryption set configuration
// Not covered by this wrapper (use case too advanced for defaults)
```

---

## Zone Redundancy

### Local Redundancy (LRS)
- **Replication**: 3 copies within single datacenter
- **SLA**: 99.9% availability
- **Use case**: Dev, test, non-critical workloads

### Zone Redundancy (ZRS)
- **Replication**: 3 copies across 3 availability zones
- **SLA**: 99.99% availability
- **Use case**: Production, mission-critical databases

**Cost Impact**: ZRS is ~30% more expensive than LRS.

---

## Disk Caching

When attaching a disk to a VM, choose caching mode:

| Mode | Use Case | Read Performance | Write Performance |
|------|----------|------------------|-------------------|
| **None** | Write-heavy workloads, databases with WAL | Direct to disk | Direct to disk |
| **ReadOnly** | Read-heavy workloads, static content | Cached | Direct to disk |
| **ReadWrite** | General purpose, balanced workloads | Cached | Cached (write-back) |

**Default**: `ReadWrite` for data disks.

---

## Cost Considerations

### Development Environment
- **Disk**: StandardSSD_LRS 128 GiB (~$10/month)
- **Snapshots**: Incremental snapshots (~$2/month per snapshot)
- **Total**: ~$12/month

### Production Environment
- **Disk**: Premium_LRS 512 GiB (~$82/month)
- **Snapshots**: Daily incremental (~$10/month)
- **Zone Redundancy**: +30% (~$107/month for Premium_ZRS)
- **Total**: ~$92-117/month

**Cost Optimization**:
- **Delete unused snapshots** (billed at $0.05/GiB/month)
- **Use Standard SSD for non-critical data** (70% cheaper than Premium)
- **Right-size disks** (don't over-provision)

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

### Verify Disk Created

```powershell
az disk show --name mycoolapp-dev-data-disk --resource-group rg-mycoolapp-dev
```

---

## Troubleshooting

### Issue: "Disk SKU not available in region"
**Cause**: Selected SKU not supported in region  
**Solution**: Use `centralus` or `eastus` (both support all SKUs)

### Issue: "Cannot attach disk to VM in different zone"
**Cause**: Disk and VM must be in same zone  
**Solution**: Create disk without zone or in same zone as VM

### Issue: "Disk size cannot be decreased"
**Cause**: Azure doesn't support shrinking disks  
**Solution**: Create new smaller disk, copy data, delete old disk

---

## Related Modules

- **avm-wrapper-linux-vm**: Attach managed disk to Linux VM
- **avm-wrapper-key-vault**: Store encryption keys for customer-managed encryption
- **avm-wrapper-storage-account**: Alternative to managed disks for blob storage

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-02-07 | Initial release wrapping AVM Disk module v0.3.1 |

---

## Upstream Specs

- **infrastructure/iac-modules** (iac-001): Wrapper module specification
- **business/cost** (cost-001): Cost optimization (StandardSSD/Premium only)
- **security/data-protection** (dp-001): Encryption at rest requirements
- **security/access-control** (ac-001): Public network access disabled
- **business/compliance-framework** (comp-001): US regions and tagging
- **platform/iac-linting** (lint-001): Code quality standards

---

**Module Owner**: Infrastructure Engineering Team  
**Support**: platform-team@company.com  
**License**: Internal use only
