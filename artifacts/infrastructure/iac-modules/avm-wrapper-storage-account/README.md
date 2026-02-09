# Azure Storage Account Wrapper Module

**Purpose**: Compliant Azure Storage Account wrapper around Azure Verified Module  
**AVM Source**: `br/public:avm/res/storage/storage-account:0.14.3`  
**Spec**: infrastructure/iac-modules (iac-001)  
**Version**: 1.0.0  
**Status**: Ready for use

---

## Overview

This wrapper module provides a compliant Azure Storage Account with TLS 1.2+, blob soft delete, and zone redundancy for production. It wraps the official Azure Verified Module (AVM) while enforcing platform standards.

**Key Features**:
- ✅ Cost-optimized SKUs (Standard_LRS dev, Standard_ZRS prod)
- ✅ TLS 1.2 minimum (dp-001)
- ✅ Blob soft delete with 30-day retention (production per dp-001)
- ✅ HTTPS-only traffic (ac-001)
- ✅ No anonymous blob access (ac-001)
- ✅ VNet integration for production (private access)
- ✅ US regions only per compliance-framework-001

---

## Compliance

| Spec | Requirement | Implementation |
|------|-------------|----------------|
| cost-001 | Cost-optimized storage | Standard_LRS (dev), Standard_ZRS (prod) |
| dp-001 | Encryption and data protection | TLS 1.2+, blob soft delete 30-day prod, double encryption prod |
| ac-001 | Secure access | HTTPS only, no public blob access, VNet rules |
| comp-001 | US regions only | `@allowed(['centralus', 'eastus'])` |
| lint-001 | Code quality | Passes `bicep build` validation |

---

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `storageAccountName` | string | Name (globally unique, 3-24 chars, lowercase alphanumeric only) |
| `environment` | string | Environment: `dev` or `prod` |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | `centralus` | Azure region (`centralus` or `eastus`) |
| `sku` | string | `Standard_LRS` (dev), `Standard_ZRS` (prod) | Storage SKU |
| `kind` | string | `StorageV2` | Storage account kind (general-purpose v2) |
| `accessTier` | string | `Hot` | Access tier (`Hot` or `Cool`) |
| `minimumTlsVersion` | string | `TLS1_2` | Minimum TLS version (`TLS1_2` or `TLS1_3`) |
| `enableBlobSoftDelete` | bool | `true` (prod), `false` (dev) | Enable blob soft delete |
| `blobSoftDeleteRetentionDays` | int | `30` (prod), `7` (dev) | Soft delete retention (1-365 days) |
| `supportsHttpsTrafficOnly` | bool | `true` | HTTPS-only traffic |
| `publicNetworkAccess` | string | `Disabled` (prod), `Enabled` (dev) | Public network access |
| `networkAclsBypass` | string | `AzureServices` | Bypass for Azure services |
| `networkAclsDefaultAction` | string | `Deny` (prod), `Allow` (dev) | Default network action |
| `subnetIds` | array | `[]` | VNet subnet IDs for service endpoints |
| `additionalTags` | object | `{}` | Additional tags |

---

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `storageAccountId` | string | Resource ID of the storage account |
| `storageAccountName` | string | Name of the storage account |
| `primaryBlobEndpoint` | string | Primary blob endpoint URL |
| `primaryEndpoints` | object | All primary endpoints (blob, file, queue, table) |
| `location` | string | Location of the storage account |
| `sku` | string | SKU of the storage account |
| `accessTier` | string | Access tier (Hot/Cool) |
| `resourceGroupName` | string | Resource group name |

---

## Usage Examples

### Example 1: Basic Dev Storage Account

```bicep
module storage '../../../infrastructure/iac-modules/avm-wrapper-storage-account/main.bicep' = {
  name: 'storage-deployment'
  params: {
    storageAccountName: 'mycoolappdevstorage'
    environment: 'dev'
    location: 'centralus'
  }
}

// Output: Standard_LRS, Hot tier, public access, ~$20/month (1 TB)
```

### Example 2: Production Storage with Zone Redundancy

```bicep
module storage '../../../infrastructure/iac-modules/avm-wrapper-storage-account/main.bicep' = {
  name: 'storage-deployment'
  params: {
    storageAccountName: 'mycoolappprodstorage'
    environment: 'prod'
    location: 'centralus'
    sku: 'Standard_ZRS' // Zone-redundant
    enableBlobSoftDelete: true
    blobSoftDeleteRetentionDays: 30
    publicNetworkAccess: 'Disabled'
    subnetIds: [vnet.outputs.subnetIds[0]] // VNet service endpoint
  }
}

// Output: Standard_ZRS, 30-day soft delete, private access only, ~$25/month (1 TB)
```

### Example 3: Create Blob Container for Uploads

```bicep
module storage '../../../infrastructure/iac-modules/avm-wrapper-storage-account/main.bicep' = {
  name: 'storage-deployment'
  params: {
    storageAccountName: 'mycoolappdevstorage'
    environment: 'dev'
  }
}

// Create blob container for user uploads
resource uploadsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storage.outputs.storageAccountName}/default/uploads'
  properties: {
    publicAccess: 'None' // No anonymous access
  }
}

// Upload file from VM:
// az storage blob upload --account-name mycoolappdevstorage --container-name uploads --name photo.jpg --file ~/photo.jpg --auth-mode login
```

### Example 4: Use with VM Managed Identity

```bicep
module storage '../../../infrastructure/iac-modules/avm-wrapper-storage-account/main.bicep' = {
  name: 'storage-deployment'
  params: {
    storageAccountName: 'mycoolappdevstorage'
    environment: 'dev'
  }
}

// Grant VM managed identity "Storage Blob Data Contributor" role
resource blobContributorRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storage
  name: guid(storage.outputs.storageAccountId, vm.outputs.identityPrincipalId, 'Storage Blob Data Contributor')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe') // Storage Blob Data Contributor
    principalId: vm.outputs.identityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// VM can now upload/download blobs:
// az storage blob upload --account-name mycoolappdevstorage --container-name uploads --name file.txt --file ~/file.txt --auth-mode login
```

---

## SKU Comparison

### Standard LRS (Dev Default)

| Feature | Standard_LRS | Cost (1 TB) |
|---------|--------------|-------------|
| **Redundancy** | 3 copies in single datacenter | ~$20/month |
| **Availability SLA** | 99.9% | Hot tier |
| **Use Case** | Dev, test, non-critical data | ~$0.0184/GB |

### Standard ZRS (Prod Default)

| Feature | Standard_ZRS | Cost (1 TB) |
|---------|--------------|-------------|
| **Redundancy** | 3 copies across 3 zones | ~$25/month |
| **Availability SLA** | 99.99% | Hot tier |
| **Use Case** | Production, critical data | ~$0.024/GB |

**Cost Comparison for 1 TB storage (Hot tier)**:
- Standard_LRS: ~$20/month
- Standard_ZRS: ~$25/month (+25% for zone redundancy)

---

## Access Tiers

### Hot Tier (Default)

| Feature | Hot Tier |
|---------|----------|
| **Storage cost** | $0.0184/GB/month (LRS) |
| **Transaction cost** | Low ($0.004/10k writes) |
| **Use case** | Frequently accessed data (images, uploads) |

### Cool Tier

| Feature | Cool Tier |
|---------|-----------|
| **Storage cost** | $0.01/GB/month (LRS, ~45% cheaper) |
| **Transaction cost** | Higher ($0.10/10k writes) |
| **Minimum retention** | 30 days (early deletion fee) |
| **Use case** | Infrequently accessed data (backups, logs older than 30 days) |

**When to use Cool tier**:
- Backups retained for 30+ days
- Archive logs older than 1 month
- Data accessed less than once per month

---

## Blob Soft Delete

### How It Works
- **Retention**: 7 days (dev), 30 days (prod)
- **Recovery**: Deleted blobs can be recovered within retention period
- **Cost**: No additional cost (still billed for storage during retention)

### Recover Deleted Blob

```powershell
# Enable soft delete (if not enabled)
az storage account blob-service-properties update --account-name mycoolappdevstorage --enable-delete-retention true --delete-retention-days 7

# List deleted blobs
az storage blob list --account-name mycoolappdevstorage --container-name uploads --include d --auth-mode login

# Undelete blob
az storage blob undelete --account-name mycoolappdevstorage --container-name uploads --name photo.jpg --auth-mode login
```

---

## Network Rules and VNet Integration

### Public Access (Dev Default)
- **Access**: From any IP address
- **Use case**: Development, testing
- **Security**: HTTPS-only, no anonymous blob access

### VNet Service Endpoints (Prod)
```bicep
module storage '../../../infrastructure/iac-modules/avm-wrapper-storage-account/main.bicep' = {
  params: {
    storageAccountName: 'mycoolappprodstorage'
    environment: 'prod'
    publicNetworkAccess: 'Disabled'
    subnetIds: [vnet.outputs.subnetIds[0]] // Allow app subnet
  }
}

// Only VMs in allowed subnet can access storage account
```

### Bypass Azure Services
- **AzureServices**: Allows Azure Backup, Azure Monitor, Azure Functions to access storage
- **Required for**: Logs, diagnostics, managed backups

---

## Common Use Cases

### Use Case 1: User Uploads (Photos, Documents)

```bicep
// 1. Create storage account
module storage '../../../infrastructure/iac-modules/avm-wrapper-storage-account/main.bicep' = {
  params: {
    storageAccountName: 'mycoolappuploads'
    environment: 'prod'
    sku: 'Standard_ZRS'
    enableBlobSoftDelete: true
  }
}

// 2. Create container
resource uploadsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storage.outputs.storageAccountName}/default/uploads'
  properties: {
    publicAccess: 'None'
  }
}

// 3. Upload from application
// az storage blob upload --account-name mycoolappuploads --container-name uploads --name user123/photo.jpg --file ~/photo.jpg --auth-mode login
```

### Use Case 2: Database Backups

```bash
# MySQL backup to blob storage
mysqldump -u root -p mycoolapp > backup-$(date +%Y%m%d).sql
az storage blob upload --account-name mycoolappbackups --container-name db-backups --name backup-$(date +%Y%m%d).sql --file backup-$(date +%Y%m%d).sql --auth-mode login
```

### Use Case 3: Static Website Hosting

```bicep
// Enable static website hosting
resource staticWebsite 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storage.outputs.storageAccountName}/default/$web'
  properties: {
    publicAccess: 'Blob' // Public read for static website
  }
}

// Upload index.html:
// az storage blob upload --account-name mycoolappstatic --container-name '$web' --name index.html --file index.html
// Access: https://mycoolappstatic.z19.web.core.windows.net/
```

---

## RBAC Roles

### Built-in Roles

| Role | Permissions | Use Case |
|------|-------------|----------|
| **Storage Blob Data Reader** | Read blobs | Applications reading uploads |
| **Storage Blob Data Contributor** | Read, write, delete blobs | Applications with full access |
| **Storage Blob Data Owner** | Full access + set ownership | Admins |

### Grant Access

```powershell
# Get VM managed identity principal ID
$vmPrincipalId = (az vm show --name mycoolapp-dev-vm --resource-group rg-mycoolapp-dev --query identity.principalId -o tsv)

# Grant "Storage Blob Data Contributor" role
az role assignment create `
  --role "Storage Blob Data Contributor" `
  --assignee $vmPrincipalId `
  --scope "/subscriptions/.../resourceGroups/rg-mycoolapp-dev/providers/Microsoft.Storage/storageAccounts/mycoolappdevstorage"
```

---

## Cost Considerations

### Development Environment
- **Storage**: Standard_LRS 100 GB (~$2/month)
- **Transactions**: ~10k writes/month (~$0.01)
- **Total**: ~$3/month

### Production Environment
- **Storage**: Standard_ZRS 1 TB (~$25/month)
- **Transactions**: ~100k writes/month (~$0.40)
- **Soft delete retention**: 30 days (~$5/month extra for deleted blobs)
- **Total**: ~$30-35/month

**Cost Optimization**:
- **Lifecycle policies**: Move old blobs to Cool tier after 30 days (45% storage cost reduction)
- **Delete old backups**: Retain backups for 30-90 days only
- **Use Cool tier for archives**: ~$10/TB/month vs ~$20/TB/month for Hot

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

### Verify Storage Account

```powershell
az storage account show --name mycoolappdevstorage --resource-group rg-mycoolapp-dev
```

---

## Troubleshooting

### Issue: "Storage account name already exists"
**Cause**: Storage account names are globally unique  
**Solution**: Choose different name (cannot recover deleted storage accounts with same name)

### Issue: "Access denied" when accessing blobs
**Cause**: Missing RBAC role or network rules blocking access  
**Solution**: 
1. Grant RBAC role: `az role assignment create --role "Storage Blob Data Reader" ...`
2. Check network rules: `az storage account show --name ... --query networkRuleSet`

### Issue: "Cannot access storage from VM"
**Cause**: VNet service endpoint not configured or VM subnet not allowed  
**Solution**: Add VM subnet to storage account network rules:

```powershell
az storage account network-rule add --account-name mycoolappprodstorage --subnet <subnet-id>
```

---

## Related Modules

- **avm-wrapper-linux-vm**: Grant VM managed identity access to storage
- **avm-wrapper-vnet**: Configure VNet service endpoints for storage
- **avm-wrapper-key-vault**: Store storage account access keys in Key Vault

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-02-07 | Initial release wrapping AVM Storage Account module v0.14.3 |

---

## Upstream Specs

- **infrastructure/iac-modules** (iac-001): Wrapper module specification
- **business/cost** (cost-001): Cost optimization (Standard_LRS/ZRS, Hot tier)
- **security/data-protection** (dp-001): TLS 1.2+, soft delete 30-day, double encryption
- **security/access-control** (ac-001): HTTPS only, no public blob access, VNet rules
- **business/compliance-framework** (comp-001): US regions and tagging
- **platform/iac-linting** (lint-001): Code quality standards

---

**Module Owner**: Infrastructure Engineering Team  
**Support**: platform-team@company.com  
**License**: Internal use only
