# Azure Key Vault Wrapper Module

**Purpose**: Compliant Azure Key Vault wrapper around Azure Verified Module  
**AVM Source**: `br/public:avm/res/key-vault/vault:0.9.0`  
**Spec**: infrastructure/iac-modules (iac-001)  
**Version**: 1.0.0  
**Status**: Ready for use

---

## Overview

This wrapper module provides a compliant Azure Key Vault with RBAC authorization, soft delete, and purge protection for production. It wraps the official Azure Verified Module (AVM) while enforcing platform standards.

**Key Features**:
- ✅ Standard SKU (dev), Premium HSM-backed (prod per dp-001)
- ✅ Azure RBAC authorization (no legacy access policies per ac-001)
- ✅ Soft delete with 90-day retention (production per dp-001)
- ✅ Purge protection (prevents accidental permanent deletion)
- ✅ Private endpoints for production (no public access per ac-001)
- ✅ US regions only per compliance-framework-001

---

## Compliance

| Spec | Requirement | Implementation |
|------|-------------|----------------|
| cost-001 | Cost-optimized secrets management | Standard SKU (dev), Premium only when HSM required (prod) |
| dp-001 | Encryption and key management | Premium HSM for prod, 90-day soft delete, purge protection |
| ac-001 | RBAC authorization | `enableRbacAuthorization: true`, no public access for prod |
| comp-001 | US regions only | `@allowed(['centralus', 'eastus'])` |
| lint-001 | Code quality | Passes `bicep build` validation |

---

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `keyVaultName` | string | Name of Key Vault (globally unique, 3-24 chars, alphanumeric + hyphens) |
| `environment` | string | Environment: `dev` or `prod` |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | `centralus` | Azure region (`centralus` or `eastus`) |
| `sku` | string | `standard` (dev), `premium` (prod) | Key Vault SKU |
| `enableSoftDelete` | bool | `true` | Enable soft delete (90-day retention) |
| `softDeleteRetentionDays` | int | `90` (prod), `7` (dev) | Soft delete retention (7-90 days) |
| `enablePurgeProtection` | bool | `true` (prod), `false` (dev) | Prevent permanent deletion |
| `enableRbacAuthorization` | bool | `true` | Use Azure RBAC (recommended) |
| `publicNetworkAccess` | string | `Disabled` (prod), `Enabled` (dev) | Public network access |
| `subnetIds` | array | `[]` | Subnet IDs for private endpoints |
| `additionalTags` | object | `{}` | Additional tags |

---

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `keyVaultId` | string | Resource ID of the Key Vault |
| `keyVaultName` | string | Name of the Key Vault |
| `keyVaultUri` | string | URI of the Key Vault (https://<name>.vault.azure.net/) |
| `location` | string | Location of the Key Vault |
| `sku` | string | SKU of the Key Vault |
| `softDeleteEnabled` | bool | Soft delete enabled |
| `purgeProtectionEnabled` | bool | Purge protection enabled |
| `resourceGroupName` | string | Resource group name |

---

## Usage Examples

### Example 1: Basic Dev Key Vault

```bicep
module keyVault '../../../infrastructure/iac-modules/avm-wrapper-key-vault/main.bicep' = {
  name: 'kv-deployment'
  params: {
    keyVaultName: 'mycoolapp-dev-kv'
    environment: 'dev'
    location: 'centralus'
  }
}

// Output: Standard SKU, public access, 7-day soft delete, ~$0/month (secrets only)
```

### Example 2: Production Key Vault with Premium SKU

```bicep
module keyVault '../../../infrastructure/iac-modules/avm-wrapper-key-vault/main.bicep' = {
  name: 'kv-deployment'
  params: {
    keyVaultName: 'mycoolapp-prod-kv'
    environment: 'prod'
    location: 'centralus'
    sku: 'premium' // HSM-backed keys
    enablePurgeProtection: true // Cannot be disabled once enabled
    softDeleteRetentionDays: 90
    publicNetworkAccess: 'Disabled'
    subnetIds: [vnet.outputs.subnetIds[0]] // Private endpoint subnet
  }
}

// Output: Premium SKU, private access only, 90-day soft delete, purge protection
```

### Example 3: Grant VM Managed Identity Access to Secrets

```bicep
module keyVault '../../../infrastructure/iac-modules/avm-wrapper-key-vault/main.bicep' = {
  name: 'kv-deployment'
  params: {
    keyVaultName: 'mycoolapp-dev-kv'
    environment: 'dev'
  }
}

// Grant VM managed identity "Key Vault Secrets User" role
resource secretsUserRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.outputs.keyVaultId, vm.outputs.identityPrincipalId, 'Key Vault Secrets User')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6') // Key Vault Secrets User
    principalId: vm.outputs.identityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// VM can now access secrets:
// az keyvault secret show --vault-name mycoolapp-dev-kv --name db-password
```

### Example 4: Store Database Connection String

```bicep
module keyVault '../../../infrastructure/iac-modules/avm-wrapper-key-vault/main.bicep' = {
  name: 'kv-deployment'
  params: {
    keyVaultName: 'mycoolapp-dev-kv'
    environment: 'dev'
  }
}

// Store MySQL connection string as secret
resource dbConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'mysql-connection-string'
  properties: {
    value: 'Server=${mysqlServer.outputs.fqdn};Database=mycoolapp;Uid=mysqladmin;Pwd=${mysqlPassword};'
    contentType: 'text/plain'
  }
}

// Retrieve in application:
// az keyvault secret show --vault-name mycoolapp-dev-kv --name mysql-connection-string --query value -o tsv
```

---

## Standard vs Premium SKU

### Standard SKU (Dev Default)

| Feature | Standard | Cost |
|---------|----------|------|
| **Software-protected keys** | ✅ Yes | $0.03/10k operations |
| **Secrets** | ✅ Yes | $0.03/10k operations |
| **Certificates** | ✅ Yes | $0.03/10k operations |
| **HSM-protected keys** | ❌ No | N/A |
| **Monthly cost** | ~$0 | Typically <$5/month |

### Premium SKU (Prod Default)

| Feature | Premium | Cost |
|---------|---------|------|
| **Software-protected keys** | ✅ Yes | $0.03/10k operations |
| **Secrets** | ✅ Yes | $0.03/10k operations |
| **Certificates** | ✅ Yes | $0.03/10k operations |
| **HSM-protected keys** | ✅ Yes (FIPS 140-2 Level 2) | $1/key/month + $0.03/10k ops |
| **Monthly cost** | ~$1-10 | Depends on HSM key count |

**When to use Premium**:
- Production encryption keys for databases
- Certificate signing keys
- Compliance requiring HSM (e.g., PCI-DSS, HIPAA)

---

## RBAC Roles

### Built-in Roles

| Role | Permissions | Use Case |
|------|-------------|----------|
| **Key Vault Administrator** | Full access (keys, secrets, certificates, RBAC) | Platform admins |
| **Key Vault Secrets User** | Read secrets only | Applications, VMs |
| **Key Vault Secrets Officer** | Create, update, delete secrets | DevOps, automation |
| **Key Vault Crypto User** | Encrypt/decrypt with keys | Applications using encryption |
| **Key Vault Crypto Officer** | Create, update, delete keys | Security team |

### Grant Access Example

```powershell
# Get VM managed identity principal ID
$vmPrincipalId = (az vm show --name mycoolapp-dev-vm --resource-group rg-mycoolapp-dev --query identity.principalId -o tsv)

# Grant "Key Vault Secrets User" role
az role assignment create `
  --role "Key Vault Secrets User" `
  --assignee $vmPrincipalId `
  --scope "/subscriptions/.../resourceGroups/rg-mycoolapp-dev/providers/Microsoft.KeyVault/vaults/mycoolapp-dev-kv"
```

---

## Soft Delete and Purge Protection

### Soft Delete (Enabled by Default)
- **Retention**: 7 days (dev) or 90 days (prod)
- **Recovery**: Deleted secrets/keys can be recovered within retention period
- **Permanent deletion**: After retention period, secrets are permanently deleted

**Recover deleted secret**:
```powershell
az keyvault secret recover --vault-name mycoolapp-dev-kv --name db-password
```

**List deleted secrets**:
```powershell
az keyvault secret list-deleted --vault-name mycoolapp-dev-kv
```

### Purge Protection (Prod Only)
- **Prevents**: Permanent deletion during retention period
- **Required for**: Production Key Vaults (dp-001)
- **Cannot be disabled**: Once enabled, purge protection is permanent

**Why purge protection?**
- Prevents accidental or malicious deletion of critical keys/secrets
- Meets compliance requirements (NIST 800-171, GDPR)

---

## Managing Secrets

### Create Secret

```powershell
az keyvault secret set --vault-name mycoolapp-dev-kv --name db-password --value "MySecurePassword123!"
```

### Retrieve Secret

```powershell
az keyvault secret show --vault-name mycoolapp-dev-kv --name db-password --query value -o tsv
```

### List Secrets

```powershell
az keyvault secret list --vault-name mycoolapp-dev-kv --query "[].name" -o tsv
```

### Delete Secret (Soft Delete)

```powershell
az keyvault secret delete --vault-name mycoolapp-dev-kv --name db-password
# Secret is soft-deleted, can be recovered within retention period
```

### Recover Deleted Secret

```powershell
az keyvault secret recover --vault-name mycoolapp-dev-kv --name db-password
```

---

## Managing Keys (HSM-Protected, Premium SKU Only)

### Create HSM-Protected Key

```powershell
az keyvault key create --vault-name mycoolapp-prod-kv --name encryption-key --protection hsm --kty RSA --size 2048
```

### Encrypt Data

```powershell
az keyvault key encrypt --vault-name mycoolapp-prod-kv --name encryption-key --algorithm RSA-OAEP --value "SensitiveData"
```

### Decrypt Data

```powershell
az keyvault key decrypt --vault-name mycoolapp-prod-kv --name encryption-key --algorithm RSA-OAEP --value "<encrypted-value>"
```

### List Keys

```powershell
az keyvault key list --vault-name mycoolapp-prod-kv --query "[].name" -o tsv
```

---

## Private Endpoints (Prod)

### When to Use
- **Production**: Always use private endpoints (no public access)
- **Development**: Public access acceptable for convenience

### Configuration

```bicep
module keyVault '../../../infrastructure/iac-modules/avm-wrapper-key-vault/main.bicep' = {
  params: {
    keyVaultName: 'mycoolapp-prod-kv'
    environment: 'prod'
    publicNetworkAccess: 'Disabled'
    subnetIds: [vnet.outputs.subnetIds[0]] // Private endpoint subnet
  }
}

// DNS resolution required for private endpoint:
// 1. Create Private DNS Zone: privatelink.vaultcore.azure.net
// 2. Link DNS Zone to VNet
// 3. Configure DNS records for Key Vault private endpoint
```

### Access from VM in Same VNet

```bash
# From VM in same VNet (private access):
az keyvault secret show --vault-name mycoolapp-prod-kv --name db-password
# Resolves to private IP (e.g., 10.0.1.5)
```

---

## Cost Considerations

### Development Environment
- **Key Vault**: Standard SKU (~$0/month base)
- **Secrets**: ~1000 operations/month (~$0.03)
- **Total**: <$1/month

### Production Environment
- **Key Vault**: Premium SKU (~$0/month base)
- **HSM-protected keys**: 3 keys (~$3/month)
- **Secrets**: ~10,000 operations/month (~$0.30)
- **Certificate renewals**: 2/year (~$0)
- **Total**: ~$5-10/month

**Cost Optimization**:
- Use Standard SKU for dev (no HSM needed)
- Minimize secret operations (cache secrets in applications)
- Delete unused secrets (no storage cost, but best practice)

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

### Verify Key Vault Created

```powershell
az keyvault show --name mycoolapp-dev-kv
```

---

## Troubleshooting

### Issue: "Key Vault name already exists"
**Cause**: Key Vault names are globally unique across all Azure subscriptions  
**Solution**: Choose different name or recover soft-deleted vault with same name

```powershell
az keyvault list-deleted --query "[?name=='mycoolapp-dev-kv']"
az keyvault recover --name mycoolapp-dev-kv
```

### Issue: "Access denied" when accessing secrets
**Cause**: Missing RBAC role assignment  
**Solution**: Grant "Key Vault Secrets User" role to user/managed identity

```powershell
az role assignment create --role "Key Vault Secrets User" --assignee <user-or-principal-id> --scope <key-vault-id>
```

### Issue: "Cannot purge Key Vault"
**Cause**: Purge protection enabled (prod default)  
**Solution**: Wait for soft delete retention period (90 days) or recover vault

```powershell
az keyvault recover --name mycoolapp-prod-kv
```

---

## Related Modules

- **avm-wrapper-linux-vm**: Grant VM managed identity access to Key Vault
- **avm-wrapper-mysql-flexibleserver**: Store database passwords in Key Vault
- **avm-wrapper-storage-account**: Store storage account keys in Key Vault

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-02-07 | Initial release wrapping AVM Key Vault module v0.9.0 |

---

## Upstream Specs

- **infrastructure/iac-modules** (iac-001): Wrapper module specification
- **business/cost** (cost-001): Cost optimization (Standard dev, Premium prod only when needed)
- **security/data-protection** (dp-001): HSM-backed keys, 90-day retention, purge protection
- **security/access-control** (ac-001): RBAC authorization, private endpoints for prod
- **business/compliance-framework** (comp-001): US regions and tagging
- **platform/iac-linting** (lint-001): Code quality standards

---

**Module Owner**: Infrastructure Engineering Team  
**Support**: platform-team@company.com  
**License**: Internal use only
