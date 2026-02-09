// ============================================================================
// Azure Public IP Address Wrapper Module
// ============================================================================
// Purpose: Compliant Public IP wrapper around Azure Verified Module
// AVM Source: br/public:avm/res/network/public-ip-address:0.12.0
// Spec: infrastructure/iac-modules (iac-001)
// Compliance: cost-001, dp-001, ac-001, comp-001, lint-001
// ============================================================================

@description('Name of the public IP address')
param publicIpName string

@description('Environment: dev or prod')
@allowed(['dev', 'prod'])
param environment string

@description('Azure region (restricted to US regions per comp-001)')
@allowed(['centralus', 'eastus'])
param location string = 'centralus'

@description('DNS label for the public IP (creates <label>.<location>.cloudapp.azure.com)')
param dnsLabel string = ''

@description('Availability zones for zone-redundant public IP')
param zones array = (environment == 'prod') ? ['1', '2', '3'] : []

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
  module: 'avm-wrapper-public-ip'
  version: '1.0.0'
}

var tags = union(defaultTags, additionalTags)

// Standard SKU required for zone redundancy and DDoS Protection Standard
var publicIpSku = 'Standard'

// Static allocation required for Standard SKU
var allocationMethod = 'Static'

// ============================================================================
// Azure Verified Module - Public IP Address
// ============================================================================

module publicIp 'br/public:avm/res/network/public-ip-address:0.12.0' = {
  name: '${publicIpName}-deployment'
  params: {
    name: publicIpName
    location: location
    tags: tags
    
    // SKU and allocation
    skuName: publicIpSku
    publicIPAllocationMethod: allocationMethod
    
    // IP version
    publicIPAddressVersion: 'IPv4'
    
    // Availability zones (prod only for zone redundancy)
    availabilityZones: zones
    
    // DNS label (optional)
    dnsSettings: dnsLabel != '' ? {
      domainNameLabel: dnsLabel
    } : null
    
    // Idle timeout (4-30 minutes, default 4)
    idleTimeoutInMinutes: 4
    
    // DDoS Protection (Standard SKU includes Basic DDoS, Standard DDoS requires plan)
    ddosSettings: {
      protectionMode: 'VirtualNetworkInherited' // Inherits from VNet DDoS Protection Plan
    }
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('Resource ID of the public IP address')
output publicIpId string = publicIp.outputs.resourceId

@description('Name of the public IP address')
output publicIpName string = publicIp.outputs.name

@description('IP address value (static)')
output ipAddress string = publicIp.outputs.ipAddress

@description('FQDN if DNS label was provided')
output fqdn string = dnsLabel != '' ? '${dnsLabel}.${location}.cloudapp.azure.com' : ''

@description('Location of the public IP')
output location string = location

@description('SKU of the public IP')
output sku string = publicIpSku

@description('Availability zones')
output availabilityZones array = zones

@description('Resource group name containing the public IP')
output resourceGroupName string = resourceGroup().name
