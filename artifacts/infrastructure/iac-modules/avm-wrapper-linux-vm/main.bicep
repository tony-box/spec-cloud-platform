// ============================================================================
// Azure Linux Virtual Machine Wrapper Module
// ============================================================================
// Purpose: Premium-tier Linux VM wrapper for unlimited performance per business/cost v3.0.0
// AVM Source: br/public:avm/res/compute/virtual-machine:0.21.0
// Spec: infrastructure/iac-modules (iac-001)
// Compliance: cost-001 v3.0.0, dp-001, ac-001, comp-001, lint-001
// Performance: Premium-only SKUs (D32+, M192+) with GPU acceleration option; on-demand pricing
// Instance Types: Regular on-demand instances; Spot instances DEPRECATED (use on-demand for maximum performance)
// ============================================================================

@description('Name of the virtual machine')
param vmName string

@description('Workload criticality tier per business/cost v2.0.0')
@allowed(['critical', 'non-critical', 'dev-test'])
param workloadCriticality string = 'non-critical'

@description('Environment: dev or prod')
@allowed(['dev', 'prod'])
param environment string

@description('Azure region (restricted to US regions per comp-001)')
@allowed(['centralus', 'eastus'])
param location string = 'centralus'

@description('Availability zone (-1 for none, 1-3 for zonal deployment, 1-3+ for multi-zone per criticality)')
@allowed([-1, 1, 2, 3])
param availabilityZone int = -1

@description('VM size (premium-tier per cost-001 v3.0.0: D32+ for general, D96 for general-purpose max, M192 for memory-intensive, ND96 for GPU)')
@allowed(['Standard_D32ds_v5', 'Standard_D48ds_v5', 'Standard_D64ds_v5', 'Standard_D96ds_v5', 'Standard_M128ms', 'Standard_M192idms_v2', 'Standard_ND96amsr_A100_v4'])
param vmSize string = 'Standard_D32ds_v5'

@description('Admin username for SSH access')
param adminUsername string = 'azureuser'

@description('SSH public key for admin user (required, no password auth per ac-001)')
@secure()
param sshPublicKey string

@description('Subnet resource ID for VM network interface')
param subnetId string

@description('Optional: Public IP resource ID to associate with VM')
param publicIpId string = ''

@description('Optional: Network Security Group resource ID')
param nsgId string = ''

@description('Enable accelerated networking (enabled for all premium-tier VMs per cost-001 v3.0.0)')
param enableAcceleratedNetworking bool = true

@description('OS disk size in GB (>=30)')
@minValue(30)
@maxValue(1024)
param osDiskSizeGB int = 64

@description('OS disk type (Premium_LRS for all environments per cost-001 v3.0.0)')
@allowed(['Premium_LRS', 'PremiumV2_LRS'])
param osDiskType string = 'Premium_LRS'

@description('Enable Azure Disk Encryption (required for all environments per dp-001 and cost-001 v3.0.0)')
param enableDiskEncryption bool = true

@description('Cloud-init script for VM provisioning (e.g., LAMP stack installation)')
param customData string = ''

@description('Additional tags to merge with default compliance tags')
param additionalTags object = {}

@description('[DEPRECATED per cost-001 v3.0.0] VM priority: Always use Regular (on-demand) for maximum performance. Spot instances DEPRECATED.')
@allowed(['Regular'])
param vmPriority string = 'Regular'

// ============================================================================
// Variables
// ============================================================================

var defaultTags = {
  compliance: 'nist-800-171'
  environment: environment
  managedBy: 'bicep'
  tier: 'infrastructure'
  module: 'avm-wrapper-linux-vm'
  version: '3.0.0'
  workloadCriticality: workloadCriticality
  performanceSpec: 'business/cost-001 v3.0.0'
  instanceType: 'on-demand-premium'
}

var tags = union(defaultTags, additionalTags)

// Ubuntu 22.04 LTS image (stable, 5-year support)
var imageReference = {
  publisher: 'Canonical'
  offer: '0001-com-ubuntu-server-jammy'
  sku: '22_04-lts-gen2'
  version: 'latest'
}

// Network interface configuration
var nicName = '${vmName}-nic'

// Managed identity (required for Azure Disk Encryption and Azure RBAC per ac-001)
var enableSystemManagedIdentity = true

// ============================================================================
// Network Interface
// ============================================================================

resource networkInterface 'Microsoft.Network/networkInterfaces@2023-11-01' = {
  name: nicName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: publicIpId != '' ? {
            id: publicIpId
          } : null
        }
      }
    ]
    networkSecurityGroup: nsgId != '' ? {
      id: nsgId
    } : null
    enableAcceleratedNetworking: enableAcceleratedNetworking
  }
}

// ============================================================================
// Azure Verified Module - Virtual Machine
// ============================================================================

module vm 'br/public:avm/res/compute/virtual-machine:0.21.0' = {
  name: '${vmName}-deployment'
  params: {
    name: vmName
    location: location
    tags: tags
    osType: 'Linux'
    availabilityZone: availabilityZone
    
    // VM size
    vmSize: vmSize
    
    // OS image
    imageReference: imageReference
    
    // OS disk configuration
    osDisk: {
      createOption: 'FromImage'
      diskSizeGB: osDiskSizeGB
      managedDisk: {
        storageAccountType: osDiskType
      }
      deleteOption: 'Delete' // Delete disk when VM is deleted
    }
    
    // Admin credentials (SSH only, no password per ac-001)
    adminUsername: adminUsername
    disablePasswordAuthentication: true
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: sshPublicKey
      }
    ]
    
    // Network configuration
    nicConfigurations: [
      {
        nicSuffix: '-nic'
        deleteOption: 'Delete'
        ipConfigurations: [
          {
            name: 'ipconfig1'
            subnetResourceId: subnetId
            pipConfiguration: publicIpId != '' ? {
              publicIpNameSuffix: '-pip'
              publicIPAddressResourceId: publicIpId
            } : null
          }
        ]
        enableAcceleratedNetworking: enableAcceleratedNetworking
      }
    ]
    
    // Managed identity (for Azure RBAC and Disk Encryption)
    managedIdentities: {
      systemAssigned: enableSystemManagedIdentity
    }
    
    // Azure Disk Encryption (prod only per dp-001)
    encryptionAtHost: enableDiskEncryption
    
    // Cloud-init custom data (for LAMP stack provisioning)
    customData: customData != '' ? base64(customData) : null
    
    // Note: Spot instance support (priority, evictionPolicy, billingProfile) requires AVM version >= 0.22.0
    // Currently using AVM 0.21.0 - Spot parameters defined above for future compatibility
    // See: VM_INSTANCE_TYPE_CONSOLIDATION_PLAN.md for implementation status
    
    // Boot diagnostics (enabled for troubleshooting)
    bootDiagnostics: true
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('Resource ID of the virtual machine')
output vmId string = vm.outputs.resourceId

@description('Name of the virtual machine')
output vmName string = vm.outputs.name

@description('Private IP address of the VM')
output privateIpAddress string = networkInterface.properties.ipConfigurations[0].properties.privateIPAddress

@description('Resource ID of the network interface')
output nicId string = networkInterface.id

@description('System-assigned managed identity principal ID')
output identityPrincipalId string = vm.outputs.systemAssignedMIPrincipalId

@description('Location of the VM')
output location string = location

@description('VM size (SKU)')
output vmSize string = vmSize

@description('Resource group name containing the VM')
output resourceGroupName string = resourceGroup().name
