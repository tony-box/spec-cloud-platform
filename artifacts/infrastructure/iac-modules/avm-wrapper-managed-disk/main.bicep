// ============================================================================
// Azure Managed Disk Wrapper Module
// ============================================================================
// Purpose: Premium-tier Managed Disk wrapper for unlimited performance per business/cost v3.0.0
// AVM Source: br/public:avm/res/compute/disk:0.6.0
// Spec: infrastructure/iac-modules (iac-001)
// Compliance: cost-001 v3.0.0, dp-001, ac-001, comp-001, lint-001
// Performance: Premium SSD minimum with ZRS replication for all environments; Ultra Disk option for maximum throughput
// ============================================================================

@description('Name of the managed disk')
param diskName string

@description('Workload criticality tier per business/cost v2.0.0')
@allowed(['critical', 'non-critical', 'dev-test'])
param workloadCriticality string = 'non-critical'

@description('Environment: dev or prod')
@allowed(['dev', 'prod'])
param environment string

@description('Azure region (restricted to US regions per comp-001)')
@allowed(['centralus', 'eastus'])
param location string = 'centralus'

@description('Disk size in GiB (4-32767)')
@minValue(4)
@maxValue(32767)
param diskSizeGB int = 128

@description('Disk SKU per performance requirements (Premium_ZRS minimum for all tiers per cost-001 v3.0.0; UltraSSD_LRS for maximum throughput)')
@allowed(['Premium_LRS', 'Premium_ZRS', 'PremiumV2_LRS', 'UltraSSD_LRS'])
param diskSku string = 'Premium_ZRS'

@description('Create option: Empty for new disk, Copy for snapshot copy')
@allowed(['Empty', 'Copy'])
param createOption string = 'Empty'

@description('Source resource ID if createOption is Copy (snapshot ID)')
param sourceResourceId string = ''

@description('Enable encryption at rest (required for all environments per dp-001 and cost-001 v3.0.0)')
param enableEncryption bool = true

@description('Availability zone for zone-redundant disk (1, 2, 3, or empty for LRS)')
param zone string = ''

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
  module: 'avm-wrapper-managed-disk'
  version: '3.0.0'
  workloadCriticality: workloadCriticality
  performanceSpec: 'business/cost-001 v3.0.0'
}

var tags = union(defaultTags, additionalTags)

// ============================================================================
// Azure Verified Module - Managed Disk
// ============================================================================

module disk 'br/public:avm/res/compute/disk:0.6.0' = {
  name: '${diskName}-deployment'
  params: {
    name: diskName
    location: location
    tags: tags
    
    // Disk SKU
    sku: diskSku
    
    // Disk size
    diskSizeGB: diskSizeGB
    
    // Create option
    createOption: createOption
    
    // Source resource (if copying from snapshot)
    sourceResourceId: createOption == 'Copy' ? sourceResourceId : null
    
    // Availability zone (optional)
    availabilityZone: zone != '' ? int(zone) : -1
    
    // OS type (None for data disks)
    osType: null
    
    // Public network access (disabled per ac-001)
    publicNetworkAccess: 'Disabled'
    
    // Network access policy (deny all)
    networkAccessPolicy: 'DenyAll'
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('Resource ID of the managed disk')
output diskId string = disk.outputs.resourceId

@description('Name of the managed disk')
output diskName string = disk.outputs.name

@description('Disk size in GiB')
output diskSizeGB int = diskSizeGB

@description('Disk SKU')
output diskSku string = diskSku

@description('Location of the disk')
output location string = location

@description('Availability zone')
output availabilityZone string = zone

@description('Resource group name containing the disk')
output resourceGroupName string = resourceGroup().name
