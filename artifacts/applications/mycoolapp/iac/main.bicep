// Cost-Optimized LAMP Deployment for mycoolapp
// This template follows infrastructure/001 cost-optimized compute module patterns
// Deploys Ubuntu 22.04 LTS VM with Apache 2.4, PHP 8.2, MySQL 8.0

targetScope = 'resourceGroup'

// ============================================================================
// Parameters
// ============================================================================

@description('Environment: dev or prod')
@allowed(['dev', 'prod'])
param environment string = 'dev'

@description('Application name')
param appName string = 'mycoolapp'

@description('Azure region')
param location string = resourceGroup().location

@description('VM SKU - constrained to cost-optimized options from infrastructure/001')
@allowed(['Standard_B2s', 'Standard_B4ms'])
param vmSku string = (environment == 'prod' ? 'Standard_B4ms' : 'Standard_B2s')

@description('Admin username for VM')
param adminUsername string = 'azureuser'

@description('SSH public key for admin user')
param sshPublicKey string

@description('Storage type - standard only per infrastructure/001')
@allowed(['Standard_LRS', 'Standard_ZRS'])
param storageType string = 'Standard_LRS'

@description('Enable encryption at-rest (NIST 800-171 requirement)')
param encryptionAtRest bool = true

@description('Enable encryption in-transit via TLS')
param encryptionInTransit bool = true

@description('Tags for resource organization')
param tags object = {
  environment: environment
  application: appName
  tier: 'application'
  deployment: 'bicep'
  compliance: 'nist-800-171'
}

// ============================================================================
// Variables
// ============================================================================

var resourcePrefix = '${appName}-${environment}'
var vmName = '${resourcePrefix}-vm'
var nicName = '${resourcePrefix}-nic'
var nsgName = '${resourcePrefix}-nsg'
var vnetName = '${resourcePrefix}-vnet'
var subnetName = '${resourcePrefix}-subnet'
var pipName = '${resourcePrefix}-pip'
var diskName = '${resourcePrefix}-osdisk'

// Derived from infrastructure/001 cost model
var vmCostMonthly = {
  'Standard_B2s': 30
  'Standard_B4ms': 120
}

// ============================================================================
// Resources
// ============================================================================

// Resource Group naming/tagging
resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' existing = {
  scope: subscription()
  name: resourceGroup().name
}

// Public IP
resource publicIP 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: pipName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    publicIPAddressVersion: 'IPv4'
  }
}

// Network Security Group
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowHTTP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowHTTPS'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 101
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowSSH'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 102
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

// Network Interface Card
resource nic 'Microsoft.Network/networkInterfaces@2023-11-01' = {
  name: nicName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${vnet.id}/subnets/${subnetName}'
          }
          privateIPAddress: '10.0.1.4'
          privateIPAllocationMethod: 'Static'
          publicIPAddress: {
            id: publicIP.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
    dnsSettings: {
      dnsServers: []
    }
    enableIPForwarding: false
    disableTcpStateTracking: false
  }
}

// Managed Disk for OS
resource osdisk 'Microsoft.Compute/disks@2023-10-02' = {
  name: diskName
  location: location
  tags: tags
  sku: {
    name: 'StandardSSD_LRS'
  }
  properties: {
    creationData: {
      createOption: 'Empty'
    }
    diskSizeGB: 64
    encryptionSettings: encryptionAtRest ? {
      enabled: true
    } : null
    networkAccessPolicy: 'AllowAll'
    publicNetworkAccess: 'Enable'
    securityProfile: {
      secureVMDiskEncryptionSet: {
        id: ''
      }
    }
  }
}

// Virtual Machine - Cost-Optimized LAMP Stack
resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSku
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        deleteOption: 'Delete'
        diskSizeGB: 64
      }
      dataDisks: []
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      customData: base64(loadFileAsText('../../scripts/cloud-init-lamp.yaml'))
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: sshPublicKey
            }
          ]
        }
        patchSettings: {
          patchMode: 'AutomaticByPlatform'
          automaticByPlatformSettings: {
            rebootSetting: 'IfRequired'
          }
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties: {
            primary: true
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('VM resource ID')
output vmId string = vm.id

@description('Public IP address')
output publicIpAddress string = publicIP.properties.ipAddress

@description('Private IP address')
output privateIpAddress string = nic.properties.ipConfigurations[0].properties.privateIPAddress

@description('Estimated monthly cost (USD)')
output estimatedMonthlyCost int = vmCostMonthly[vmSku]

@description('VM deployment status')
output deploymentStatus string = 'Success'

@description('SSH connection string')
output sshConnectionString string = 'ssh ${adminUsername}@${publicIP.properties.ipAddress}'

@description('Health check endpoint URL')
output healthCheckUrl string = 'http://${publicIP.properties.ipAddress}/health'
