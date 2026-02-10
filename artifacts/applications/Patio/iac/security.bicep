// Patio IaC Security Module - v3.0.0 (Unlimited Performance Strategy)
// RBAC, Key Vault Premium (HSM), and customer-managed encryption key (CMK) for production
// Source Spec: security/access-control-001, security/data-protection-001 v1.0.0, infrastructure/iac-modules-001 v2.0.0
// Date: February 10, 2026

targetScope = 'resourceGroup'

@description('Key Vault name.')
param keyVaultName string

@description('Principal ID for the Patio VM managed identity.')
param vmPrincipalId string

@description('Enable customer-managed encryption key (CMK) for production')
param enableCmk bool = false

@description('Key Vault SKU - Premium for production (v3.0.0 mandatory)')
@allowed([
  'standard'
  'premium'
])
param keyVaultSku string = 'premium'

@description('Role definition ID for Key Vault Secrets User.')
param roleDefinitionId string = '4633458b-17de-408a-b874-0445c86b69e6'

// Key Vault with Premium SKU for HSM backing (production)
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

// RBAC: VM managed identity → Key Vault Secrets User
resource keyVaultSecretsUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, vmPrincipalId, roleDefinitionId)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: vmPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Key Vault access policy for Key Vault Administrator (if CMK enabled in production)
resource keyVaultAdminPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2023-07-01' = if (enableCmk) {
  name: 'replace'
  parent: keyVault
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: vmPrincipalId
        permissions: {
          keys: [
            'get'
            'list'
            'decrypt'
            'encrypt'
          ]
          secrets: [
            'get'
            'list'
          ]
          certificates: [
            'get'
            'list'
          ]
        }
      }
    ]
  }
}

// Customer-managed encryption key (CMK) for disk encryption
resource cmkKey 'Microsoft.KeyVault/vaults/keys@2023-07-01' = if (enableCmk) {
  parent: keyVault
  name: 'patio-cmk'
  properties: {
    kty: 'RSA'
    keySize: 4096
    attributes: {
      enabled: true
    }
    keyOps: [
      'encrypt'
      'decrypt'
      'sign'
      'verify'
      'wrapKey'
      'unwrapKey'
    ]
  }
}

// Key rotation policy (4-week rotation for production)
resource keyRotationPolicy 'Microsoft.KeyVault/vaults/keys/rotationPolicies@2023-07-01' = if (enableCmk) {
  parent: cmkKey
  name: 'default'
  properties: {
    lifetimeActions: [
      {
        trigger: {
          timeAfterCreate: 'P28D'
        }
        action: {
          type: 'Rotate'
        }
      }
    ]
    attributes: {
      expiresIn: 'P2Y'
    }
  }
}

output keyVaultSecretsUserAssignmentId string = keyVaultSecretsUser.id
output keyVaultAdminPolicyId string = enableCmk ? keyVaultAdminPolicy.id : ''
output cmkKeyId string = enableCmk ? cmkKey.id : ''
output cmkKeyVersion string = enableCmk ? cmkKey.properties.version : ''
output keyRotationPolicyId string = enableCmk ? keyRotationPolicy.id : ''
output keyVaultName string = keyVault.name
output keyVaultSku string = keyVaultSku

