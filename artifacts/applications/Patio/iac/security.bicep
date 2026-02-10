targetScope = 'resourceGroup'

@description('Key Vault name.')
param keyVaultName string

@description('Principal ID for the Patio VM managed identity.')
param vmPrincipalId string

@description('Role definition ID for Key Vault Secrets User.')
param roleDefinitionId string = '4633458b-17de-408a-b874-0445c86b69e6'

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource keyVaultSecretsUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, vmPrincipalId, roleDefinitionId)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: vmPrincipalId
    principalType: 'ServicePrincipal'
  }
}

output keyVaultSecretsUserAssignmentId string = keyVaultSecretsUser.id
