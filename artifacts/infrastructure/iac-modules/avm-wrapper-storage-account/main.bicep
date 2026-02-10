// ============================================================================
// Azure Storage Account Wrapper Module
// ============================================================================
// Purpose: Premium-tier Storage Account wrapper for unlimited performance per business/cost v3.0.0
// AVM Source: br/public:avm/res/storage/storage-account:0.31.0
// Spec: infrastructure/iac-modules (iac-001)
// Compliance: cost-001 v3.0.0, dp-001, ac-001, comp-001, lint-001
// Performance: Premium ZRS replication with maximum throughput for all environments
// ============================================================================

@description('Name of the storage account (globally unique, 3-24 chars, lowercase alphanumeric only)')
@maxLength(24)
@minLength(3)
param storageAccountName string

@description('Environment: dev or prod')
@allowed(['dev', 'prod'])
param environment string

@description('Azure region (restricted to US regions per comp-001)')
@allowed(['centralus', 'eastus'])
param location string = 'centralus'

@description('Storage account SKU (Premium_ZRS for all environments per cost-001 v3.0.0 - maximum performance)')
@allowed(['Premium_LRS', 'Premium_ZRS', 'PremiumV2_LRS', 'PremiumV2_ZRS', 'Standard_ZRS', 'StandardV2_ZRS'])
param sku string = 'Premium_ZRS'

@description('Storage account kind (StorageV2 is general-purpose v2)')
@allowed(['StorageV2'])
param kind string = 'StorageV2'

@description('Access tier (Hot for frequently accessed data, Cool for infrequent)')
@allowed(['Hot', 'Cool'])
param accessTier string = 'Hot'

@description('Minimum TLS version (1.2 minimum per dp-001)')
@allowed(['TLS1_2'])
param minimumTlsVersion string = 'TLS1_2'

@description('Enable blob soft delete (30-day retention for prod per dp-001)')
param enableBlobSoftDelete bool = (environment == 'prod')

@description('Blob soft delete retention days (7-365, 30 for prod)')
@minValue(1)
@maxValue(365)
param blobSoftDeleteRetentionDays int = (environment == 'prod') ? 30 : 7

@description('Enable HTTPS traffic only (required per ac-001)')
param supportsHttpsTrafficOnly bool = true

@description('Public network access (Disabled for prod per ac-001)')
@allowed(['Enabled', 'Disabled'])
param publicNetworkAccess string = (environment == 'prod') ? 'Disabled' : 'Enabled'

@description('Allow Azure services bypass (AzureServices for VNet firewall)')
@allowed(['None', 'AzureServices'])
param networkAclsBypass string = 'AzureServices'

@description('Default network action (Deny for prod, Allow for dev)')
@allowed(['Allow', 'Deny'])
param networkAclsDefaultAction string = (environment == 'prod') ? 'Deny' : 'Allow'

@description('Virtual Network subnet IDs for service endpoints')
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
  module: 'avm-wrapper-storage-account'
  version: '2.0.0'
  performanceSpec: 'business/cost-001 v3.0.0'
}

var tags = union(defaultTags, additionalTags)

// ============================================================================
// Azure Verified Module - Storage Account
// ============================================================================

module storageAccount 'br/public:avm/res/storage/storage-account:0.31.0' = {
  name: '${storageAccountName}-deployment'
  params: {
    name: storageAccountName
    location: location
    tags: tags
    
    // SKU and kind
    skuName: sku
    kind: kind
    
    // Access tier
    accessTier: accessTier
    
    // Security settings
    minimumTlsVersion: minimumTlsVersion
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    allowBlobPublicAccess: false // No anonymous blob access per ac-001
    
    // Encryption (enabled by default with platform-managed keys)
    requireInfrastructureEncryption: environment == 'prod' // Double encryption for prod
    
    // Network rules
    publicNetworkAccess: publicNetworkAccess
    networkAcls: {
      bypass: networkAclsBypass
      defaultAction: networkAclsDefaultAction
      virtualNetworkRules: [for subnetId in subnetIds: {
        id: subnetId
        action: 'Allow'
      }]
    }
    
    // Blob service configuration
    blobServices: {
      deleteRetentionPolicyEnabled: enableBlobSoftDelete
      deleteRetentionPolicyDays: enableBlobSoftDelete ? blobSoftDeleteRetentionDays : null
      containerDeleteRetentionPolicyEnabled: enableBlobSoftDelete
      containerDeleteRetentionPolicyDays: enableBlobSoftDelete ? blobSoftDeleteRetentionDays : null
      containerDeleteRetentionPolicyAllowPermanentDelete: false
    }
    
    // File service configuration (disabled for LAMP stack)
    fileServices: null
    
    // Queue service configuration (disabled for LAMP stack)
    queueServices: null
    
    // Table service configuration (disabled for LAMP stack)
    tableServices: null
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('Resource ID of the storage account')
output storageAccountId string = storageAccount.outputs.resourceId

@description('Name of the storage account')
output storageAccountName string = storageAccount.outputs.name

@description('Primary blob endpoint')
output primaryBlobEndpoint string = storageAccount.outputs.primaryBlobEndpoint

@description('Location of the storage account')
output location string = location

@description('SKU of the storage account')
output sku string = sku

@description('Access tier')
output accessTier string = accessTier

@description('Resource group name containing the storage account')
output resourceGroupName string = resourceGroup().name
