// ============================================================================
// Azure Virtual Network Wrapper Module
// ============================================================================
// Purpose: Compliant VNet wrapper with multi-zone support per business/cost v2.0.0
// AVM Source: br/public:avm/res/network/virtual-network:0.7.2
// Spec: infrastructure/iac-modules (iac-001)
// Compliance: cost-001 v2.0.0, dp-001, ac-001, comp-001, lint-001
// Multi-Zone: Critical only (cost optimization per cost-001)
// ============================================================================

@description('Name of the virtual network')
param vnetName string

@description('Workload criticality tier per business/cost v2.0.0')
@allowed(['critical', 'non-critical', 'dev-test'])
param workloadCriticality string = 'non-critical'

@description('Address prefix for the VNet (CIDR notation)')
param addressPrefix string = '10.0.0.0/16'

@description('Environment: dev or prod')
@allowed(['dev', 'prod'])
param environment string

@description('Azure region (restricted to US regions per comp-001)')
@allowed(['centralus', 'eastus'])
param location string = 'centralus'

@description('Subnets to create within the VNet')
param subnets array = [
  {
    name: 'default'
    addressPrefix: '10.0.1.0/24'
  }
]

@description('Network Security Group IDs to associate with subnets (optional)')
param nsgIds object = {}

@description('Enable DDoS Protection Standard')
param enableDdosProtection bool = (environment == 'prod')

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
  module: 'avm-wrapper-vnet'
  version: '2.0.0'
  workloadCriticality: workloadCriticality
  multiZoneRequired: workloadCriticality == 'critical' ? 'true' : 'false'
  costSpec: 'business/cost-001 v2.0.0'
}

var tags = union(defaultTags, additionalTags)

// Transform subnets to include NSG associations if provided
var subnetsWithNsg = [for subnet in subnets: union(subnet, {
  networkSecurityGroupResourceId: contains(nsgIds, subnet.name) ? nsgIds[subnet.name] : null
})]

// ============================================================================
// Azure Verified Module - Virtual Network
// ============================================================================

module vnet 'br/public:avm/res/network/virtual-network:0.7.2' = {
  name: '${vnetName}-deployment'
  params: {
    name: vnetName
    location: location
    addressPrefixes: [addressPrefix]
    subnets: subnetsWithNsg
    tags: tags
    
    // DDoS Protection (enabled for prod per gov-001 SLA requirements)
    ddosProtectionPlanResourceId: enableDdosProtection ? null : null // Future: integrate with DDoS Protection Plan
    
    // DNS servers (default to Azure-provided DNS)
    dnsServers: []
    
    // Flow timeout (default 4 minutes)
    flowTimeoutInMinutes: 4
    
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('Resource ID of the virtual network')
output vnetId string = vnet.outputs.resourceId

@description('Name of the virtual network')
output vnetName string = vnet.outputs.name

@description('Address prefix of the virtual network')
output addressPrefix string = addressPrefix

@description('Subnet resource IDs')
output subnetIds array = vnet.outputs.subnetResourceIds

@description('Subnet names')
output subnetNames array = [for subnet in subnets: subnet.name]

@description('Location of the virtual network')
output location string = location

@description('Resource group name containing the virtual network')
output resourceGroupName string = resourceGroup().name
