targetScope = 'resourceGroup'

@description('Application name used for naming resources.')
param appName string

@description('Deployment environment name (dev, test, prod).')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string

@description('Azure region for deployment. US regions only.')
@allowed([
  'centralus'
  'eastus'
])
param location string

@description('Workload criticality tier.')
@allowed([
  'critical'
  'non-critical'
  'dev-test'
])
param workloadCriticality string

@description('Optional cost center tag value.')
param costCenter string

@description('Admin username for SSH access (Linux VM).')
param adminUsername string = 'azureuser'

@description('SSH public key for VM access (required, no password auth).')
@secure()
param sshPublicKey string

module config './config.bicep' = {
  name: 'patio-config-${environment}'
  params: {
    appName: appName
    environment: environment
    location: location
    workloadCriticality: workloadCriticality
    costCenter: costCenter
  }
}

var namePrefix = '${appName}-${environment}'

var moduleEnvironment = environment == 'prod' ? 'prod' : 'dev'

var subnetDefinitions = [
  {
    name: '${namePrefix}-app'
    addressPrefix: '10.10.1.0/24'
  }
]

module nsg '../../../infrastructure/iac-modules/avm-wrapper-nsg/main.bicep' = {
  name: '${namePrefix}-nsg'
  params: {
    nsgName: '${namePrefix}-nsg'
    environment: moduleEnvironment
    location: location
    customRules: []
    sshSourceAddressPrefix: ''
    additionalTags: config.outputs.tags
  }
}

module vnet '../../../infrastructure/iac-modules/avm-wrapper-vnet/main.bicep' = {
  name: '${namePrefix}-vnet'
  params: {
    vnetName: '${namePrefix}-vnet'
    workloadCriticality: workloadCriticality
    addressPrefix: '10.10.0.0/16'
    environment: moduleEnvironment
    location: location
    subnets: subnetDefinitions
    nsgIds: {
      '${namePrefix}-app': nsg.outputs.nsgId
    }
    additionalTags: config.outputs.tags
  }
}

module publicIp '../../../infrastructure/iac-modules/avm-wrapper-public-ip/main.bicep' = {
  name: '${namePrefix}-pip'
  params: {
    publicIpName: '${namePrefix}-pip'
    environment: moduleEnvironment
    location: location
    dnsLabel: ''
    additionalTags: config.outputs.tags
  }
}

module managedDisk '../../../infrastructure/iac-modules/avm-wrapper-managed-disk/main.bicep' = {
  name: '${namePrefix}-disk'
  params: {
    diskName: '${namePrefix}-disk'
    workloadCriticality: workloadCriticality
    environment: moduleEnvironment
    location: location
    diskSizeGB: 128
    additionalTags: config.outputs.tags
  }
}

var storageAccountName = toLower('patio${uniqueString(resourceGroup().id, environment)}')

module storageAccount '../../../infrastructure/iac-modules/avm-wrapper-storage-account/main.bicep' = {
  name: '${namePrefix}-storage'
  params: {
    storageAccountName: storageAccountName
    environment: moduleEnvironment
    location: location
    subnetIds: [vnet.outputs.subnetIds[0]]
    additionalTags: config.outputs.tags
  }
}

module keyVault '../../../infrastructure/iac-modules/avm-wrapper-key-vault/main.bicep' = {
  name: '${namePrefix}-kv'
  params: {
    keyVaultName: '${namePrefix}-kv'
    environment: moduleEnvironment
    location: location
    subnetIds: [vnet.outputs.subnetIds[0]]
    additionalTags: config.outputs.tags
  }
}

module security './security.bicep' = {
  name: '${namePrefix}-security'
  params: {
    keyVaultName: keyVault.outputs.keyVaultName
    vmPrincipalId: linuxVm.outputs.identityPrincipalId
  }
}

module monitoring './monitoring.bicep' = {
  name: '${namePrefix}-monitoring'
  params: {
    namePrefix: namePrefix
    location: location
    keyVaultName: keyVault.outputs.keyVaultName
    tags: config.outputs.tags
  }
}

module linuxVm '../../../infrastructure/iac-modules/avm-wrapper-linux-vm/main.bicep' = {
  name: '${namePrefix}-vm'
  params: {
    vmName: '${namePrefix}-vm'
    workloadCriticality: workloadCriticality
    environment: moduleEnvironment
    location: location
    availabilityZone: workloadCriticality == 'critical' ? 1 : -1
    adminUsername: adminUsername
    sshPublicKey: sshPublicKey
    subnetId: vnet.outputs.subnetIds[0]
    publicIpId: publicIp.outputs.publicIpId
    nsgId: nsg.outputs.nsgId
    additionalTags: config.outputs.tags
  }
}

var enableAutoShutdown = environment != 'prod'

module automation './automation.bicep' = {
  name: '${namePrefix}-automation'
  params: {
    namePrefix: namePrefix
    location: location
    vmResourceId: linuxVm.outputs.vmId
    enableAutoShutdown: enableAutoShutdown
    tags: config.outputs.tags
  }
}

output namePrefix string = config.outputs.namePrefix
output deploymentTags object = config.outputs.tags
output vnetId string = vnet.outputs.vnetId
output subnetIds array = vnet.outputs.subnetIds
output nsgId string = nsg.outputs.nsgId
output publicIpId string = publicIp.outputs.publicIpId
output vmId string = linuxVm.outputs.vmId
output managedDiskId string = managedDisk.outputs.diskId
output storageAccountId string = storageAccount.outputs.storageAccountId
output keyVaultId string = keyVault.outputs.keyVaultId
output logAnalyticsWorkspaceId string = monitoring.outputs.logAnalyticsWorkspaceId
output shutdownScheduleId string = automation.outputs.shutdownScheduleId
