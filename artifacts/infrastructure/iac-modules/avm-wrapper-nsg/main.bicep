// ============================================================================
// Azure Network Security Group Wrapper Module
// ============================================================================
// Purpose: Compliant NSG wrapper around Azure Verified Module
// AVM Source: br/public:avm/res/network/network-security-group:0.5.2
// Spec: infrastructure/iac-modules (iac-001)
// Compliance: cost-001, dp-001, ac-001, comp-001, lint-001
// ============================================================================

@description('Name of the network security group')
param nsgName string

@description('Environment: dev or prod')
@allowed(['dev', 'prod'])
param environment string

@description('Azure region (restricted to US regions per comp-001)')
@allowed(['centralus', 'eastus'])
param location string = 'centralus'

@description('Custom security rules (application-specific ports)')
param customRules array = []

@description('Allow SSH from specific IP/CIDR (default: deny all)')
param sshSourceAddressPrefix string = '' // Empty = deny SSH from internet

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
  module: 'avm-wrapper-nsg'
  version: '1.0.0'
}

var tags = union(defaultTags, additionalTags)

// Default security rules (compliant baseline per ac-001)
var baselineRules = [
  // SSH access (restricted or denied per ac-001)
  {
    name: 'AllowSSH'
    priority: 1000
    direction: 'Inbound'
    access: sshSourceAddressPrefix != '' ? 'Allow' : 'Deny'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '22'
    sourceAddressPrefix: sshSourceAddressPrefix != '' ? sshSourceAddressPrefix : '*'
    destinationAddressPrefix: '*'
    description: 'SSH access (restricted to corporate VPN or denied)'
  }
  // HTTP access (typically allowed for web apps)
  {
    name: 'AllowHTTP'
    priority: 1010
    direction: 'Inbound'
    access: 'Allow'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '80'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    description: 'HTTP access from internet'
  }
  // HTTPS access (typically allowed for web apps)
  {
    name: 'AllowHTTPS'
    priority: 1020
    direction: 'Inbound'
    access: 'Allow'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    description: 'HTTPS access from internet'
  }
  // Deny all other inbound (default deny per ac-001)
  {
    name: 'DenyAllInbound'
    priority: 4096
    direction: 'Inbound'
    access: 'Deny'
    protocol: '*'
    sourcePortRange: '*'
    destinationPortRange: '*'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    description: 'Deny all other inbound traffic (default deny)'
  }
]

// Merge baseline rules with custom application-specific rules
// Custom rules should use priorities 2000-4000 to avoid conflicts
var allRules = concat(baselineRules, customRules)

// ============================================================================
// Azure Verified Module - Network Security Group
// ============================================================================

module nsg 'br/public:avm/res/network/network-security-group:0.5.2' = {
  name: '${nsgName}-deployment'
  params: {
    name: nsgName
    location: location
    tags: tags
    
    // Security rules
    securityRules: allRules
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('Resource ID of the network security group')
output nsgId string = nsg.outputs.resourceId

@description('Name of the network security group')
output nsgName string = nsg.outputs.name

@description('Location of the network security group')
output location string = location

@description('Number of security rules configured')
output ruleCount int = length(allRules)

@description('Resource group name containing the NSG')
output resourceGroupName string = resourceGroup().name
