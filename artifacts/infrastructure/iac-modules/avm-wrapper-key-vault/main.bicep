// ============================================================================
// Azure Key Vault Wrapper Module
// ============================================================================
// Purpose: Compliant Azure Key Vault wrapper around Azure Verified Module
// AVM Source: br/public:avm/res/key-vault/vault:0.13.3
// Spec: infrastructure/iac-modules (iac-001)
// Compliance: cost-001, dp-001, ac-001, comp-001, lint-001
// ============================================================================

@description('Name of the Key Vault (globally unique, 3-24 chars, alphanumeric and hyphens only)')
@maxLength(24)
param keyVaultName string

@description('Environment: dev or prod')
@allowed(['dev', 'prod'])
param environment string

@description('Azure region (restricted to US regions per comp-001)')
@allowed(['centralus', 'eastus'])
param location string = 'centralus'

@description('Key Vault SKU (standard for dev, premium HSM-backed for prod per dp-001)')
@allowed(['standard', 'premium'])
param sku string = (environment == 'prod') ? 'premium' : 'standard'

@description('Enable soft delete (90-day retention, required per dp-001)')
param enableSoftDelete bool = true

@description('Soft delete retention days (7-90, 90 for prod per dp-001)')
@minValue(7)
@maxValue(90)
param softDeleteRetentionDays int = (environment == 'prod') ? 90 : 7

@description('Enable purge protection (prevents permanent deletion, required for prod per dp-001)')
param enablePurgeProtection bool = (environment == 'prod')

@description('Enable Azure RBAC for data plane (recommended per ac-001)')
param enableRbacAuthorization bool = true

@description('Public network access (Disabled for prod per ac-001)')
@allowed(['Enabled', 'Disabled'])
param publicNetworkAccess string = (environment == 'prod') ? 'Disabled' : 'Enabled'

@description('Virtual Network subnet IDs for private endpoint (required if publicNetworkAccess is Disabled)')
param subnetIds array = []

@description('Additional tags to merge with default compliance tags')
param additionalTags object = {}

// ============================================================================
// Variables
// ============================================================================

var defaultTags = {
  compliance: 'nist-800-171'
  environment: environment
  managedBy: 'bicep'
  tier: 'infrastructure'
  module: 'avm-wrapper-key-vault'
  version: '1.0.0'
}

var tags = union(defaultTags, additionalTags)

// ============================================================================
// Azure Verified Module - Key Vault
// ============================================================================

module keyVault 'br/public:avm/res/key-vault/vault:0.13.3' = {
  name: '${keyVaultName}-deployment'
  params: {
    name: keyVaultName
    location: location
    tags: tags
    
    // SKU
    sku: sku
    
    // Soft delete and purge protection
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionDays
    enablePurgeProtection: enablePurgeProtection
    
    // RBAC authorization (recommended over access policies)
    enableRbacAuthorization: enableRbacAuthorization
    
    // Network configuration
    publicNetworkAccess: publicNetworkAccess
    networkAcls: publicNetworkAccess == 'Disabled' ? {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    } : null
    
    // Private endpoints (if public access disabled)
    privateEndpoints: publicNetworkAccess == 'Disabled' && !empty(subnetIds) ? [
      {
        name: '${keyVaultName}-pe'
        subnetResourceId: subnetIds[0]
        privateDnsZoneGroups: [
          {
            name: 'default'
            privateDnsZoneResourceIds: [] // Configure DNS zones separately
          }
        ]
      }
    ] : []
    
    // Disable access policies (use RBAC instead)
    accessPolicies: []
    
    // Diagnostic settings (optional, can be configured separately)
    diagnosticSettings: []
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('Resource ID of the Key Vault')
output keyVaultId string = keyVault.outputs.resourceId

@description('Name of the Key Vault')
output keyVaultName string = keyVault.outputs.name

@description('URI of the Key Vault')
output keyVaultUri string = keyVault.outputs.uri

@description('Location of the Key Vault')
output location string = location

@description('SKU of the Key Vault')
output sku string = sku

@description('Soft delete enabled')
output softDeleteEnabled bool = enableSoftDelete

@description('Purge protection enabled')
output purgeProtectionEnabled bool = enablePurgeProtection

@description('Resource group name containing the Key Vault')
output resourceGroupName string = resourceGroup().name
