// ============================================================================
// Azure Database for MySQL Flexible Server Wrapper Module
// ============================================================================
// Purpose: Compliant Azure MySQL wrapper around Azure Verified Module
// AVM Source: br/public:avm/res/db-for-my-sql/flexible-server:0.10.1
// Spec: infrastructure/iac-modules (iac-001)
// Compliance: cost-001, dp-001, ac-001, comp-001, lint-001
// ============================================================================

@description('Name of the MySQL server (globally unique)')
param serverName string

@description('Environment: dev or prod')
@allowed(['dev', 'prod'])
param environment string

@description('Azure region (restricted to US regions per comp-001)')
@allowed(['centralus', 'eastus'])
param location string = 'centralus'

@description('MySQL SKU (Burstable_B1ms for dev, GeneralPurpose_D2ds_v4 for prod per cost-001)')
@allowed(['Burstable_B1ms', 'GeneralPurpose_D2ds_v4'])
param sku string = (environment == 'dev') ? 'Burstable_B1ms' : 'GeneralPurpose_D2ds_v4'

@description('MySQL version (8.0 LTS)')
@allowed(['8.0.21'])
param mysqlVersion string = '8.0.21'

@description('Administrator username')
param administratorLogin string = 'mysqladmin'

@description('Administrator password (secure, min 8 chars)')
@secure()
@minLength(8)
param administratorPassword string

@description('Subnet resource ID for VNet integration (required per ac-001)')
param delegatedSubnetId string

@description('Private DNS zone resource ID for MySQL (required for VNet integration)')
param privateDnsZoneId string

@description('Storage size in GiB (20-16384)')
@minValue(20)
@maxValue(16384)
param storageSizeGB int = (environment == 'dev') ? 20 : 100

@description('Storage IOPS (360-20000, auto-scale for GeneralPurpose)')
@minValue(360)
@maxValue(20000)
param storageIops int = (environment == 'dev') ? 360 : 3000

@description('Storage autogrow (enabled for prod)')
param storageAutogrow bool = (environment == 'prod')

@description('Backup retention days (7 for dev, 30 for prod per dp-001)')
@minValue(1)
@maxValue(35)
param backupRetentionDays int = (environment == 'prod') ? 30 : 7

@description('Geo-redundant backup (disabled for cost optimization per cost-001)')
param geoRedundantBackup bool = false

@description('Zone-redundant high availability (enabled for prod per dp-001)')
param highAvailability bool = (environment == 'prod')

@description('Standby availability zone for HA (-1 for none, 1-3 for zonal)')
@allowed([-1, 1, 2, 3])
param standbyAvailabilityZone int = highAvailability ? 2 : -1

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
  module: 'avm-wrapper-mysql-flexibleserver'
  version: '1.0.0'
}

var tags = union(defaultTags, additionalTags)

// SKU tier (Burstable or GeneralPurpose)
var skuTier = startsWith(sku, 'Burstable') ? 'Burstable' : 'GeneralPurpose'

// ============================================================================
// Azure Verified Module - MySQL Flexible Server
// ============================================================================

module mysqlServer 'br/public:avm/res/db-for-my-sql/flexible-server:0.10.1' = {
  name: '${serverName}-deployment'
  params: {
    name: serverName
    location: location
    tags: tags
    
    // SKU
    skuName: sku
    tier: skuTier
    availabilityZone: standbyAvailabilityZone
    
    // MySQL version
    version: mysqlVersion
    
    // Administrator credentials
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorPassword
    
    // Storage configuration
    storageSizeGB: storageSizeGB
    storageIOPS: storageIops
    storageAutoGrow: storageAutogrow ? 'Enabled' : 'Disabled'
    
    // Backup configuration
    backupRetentionDays: backupRetentionDays
    geoRedundantBackup: geoRedundantBackup ? 'Enabled' : 'Disabled'
    
    // High availability (zone-redundant for prod)
    highAvailability: highAvailability ? 'ZoneRedundant' : 'Disabled'
    highAvailabilityZone: highAvailability ? standbyAvailabilityZone : -1
    
    // Network configuration (VNet integration only, no public access per ac-001)
    delegatedSubnetResourceId: delegatedSubnetId
    privateDnsZoneResourceId: privateDnsZoneId
    publicNetworkAccess: 'Disabled'
    
    // SSL/TLS enforcement (required per dp-001)
    // Note: Flexible Server requires SSL by default, cannot disable
    
    // Server parameters (optional customization)
    configurations: [
      {
        name: 'require_secure_transport'
        value: 'ON' // Force SSL/TLS connections
      }
      {
        name: 'max_connections'
        value: (environment == 'dev') ? '50' : '200'
      }
    ]
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('Resource ID of the MySQL server')
output serverId string = mysqlServer.outputs.resourceId

@description('Name of the MySQL server')
output serverName string = mysqlServer.outputs.name

@description('Fully qualified domain name (FQDN) of the MySQL server')
output fqdn string = mysqlServer.outputs.fqdn

@description('Location of the MySQL server')
output location string = location

@description('SKU of the MySQL server')
output sku string = sku

@description('MySQL version')
output mysqlVersion string = mysqlVersion

@description('Backup retention days')
output backupRetentionDays int = backupRetentionDays

@description('High availability enabled')
output highAvailabilityEnabled bool = highAvailability

@description('Resource group name containing the MySQL server')
output resourceGroupName string = resourceGroup().name
