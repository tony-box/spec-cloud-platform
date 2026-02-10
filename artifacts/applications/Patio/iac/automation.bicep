// Patio IaC Automation Module - v3.0.0 (Unlimited Performance Strategy)
// GPU monitoring extensions and network/disk I/O tuning for maximum throughput
// Source Spec: infrastructure/compute-001 v3.0.0, infrastructure/networking-001 v3.0.0
// Date: February 10, 2026

targetScope = 'resourceGroup'

@description('Name prefix for Patio resources.')
param namePrefix string

@description('Azure region for deployment.')
param location string

@description('Target VM resource ID for auto-shutdown.')
param vmResourceId string

@description('Enable auto-shutdown schedule (true for dev/test).')
param enableAutoShutdown bool

@description('Daily shutdown time in HHmm (24-hour clock).')
param shutdownTime string = '1900'

@description('Time zone for shutdown schedule.')
param timeZoneId string = 'UTC'

@description('Enable GPU monitoring extension (ND96amsr_A100_v4 required)')
param enableGpuMonitoring bool = false

@description('Enable accelerated networking for maximum throughput (cost-001 v3.0.0)')
param enableAcceleratedNetworking bool = true

@description('Enable disk I/O tuning for Premium storage performance')
param enableDiskIoTuning bool = true

@description('Tags to apply to automation resources.')
param tags object

// Dev/Test auto-shutdown schedule
resource shutdownSchedule 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: '${namePrefix}-shutdown'
  location: location
  tags: tags
  properties: {
    status: enableAutoShutdown ? 'Enabled' : 'Disabled'
    taskType: 'ComputeVmShutdownTask'
    targetResourceId: vmResourceId
    dailyRecurrence: {
      time: shutdownTime
    }
    timeZoneId: timeZoneId
    notificationSettings: {
      status: 'Disabled'
    }
  }
}

// GPU monitoring extension (if enabled)
resource gpuMonitoringExtension 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = if (enableGpuMonitoring) {
  name: '${last(split(vmResourceId, '/'))}/GpuMonitoring'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.HpcCompute'
    type: 'AmdGpuDriver'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    settings: {
      isLinux: true
    }
  }
}

// Network tuning for accelerated networking
resource networkTuningExtension 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = if (enableAcceleratedNetworking) {
  name: '${last(split(vmResourceId, '/'))}/NetworkTuning'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      commandToExecute: 'bash /tmp/network-tuning.sh'
      fileUris: [
        'https://raw.githubusercontent.com/Azure/azure-hpc/master/Compute/Optimization/network-tuning.sh'
      ]
    }
  }
}

// Disk I/O tuning for Premium storage
resource diskIoTuningExtension 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = if (enableDiskIoTuning) {
  name: '${last(split(vmResourceId, '/'))}/DiskIoTuning'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      commandToExecute: 'bash -c "echo vm.max_map_count=262144 >> /etc/sysctl.conf && sysctl -p && fdisk -l && mkfs.ext4 -F /dev/sdb && mount /dev/sdb /mnt/data"'
    }
  }
}

output shutdownScheduleId string = shutdownSchedule.id
output gpuMonitoringExtensionId string = enableGpuMonitoring ? gpuMonitoringExtension.id : ''
output networkTuningExtensionId string = enableAcceleratedNetworking ? networkTuningExtension.id : ''
output diskIoTuningExtensionId string = enableDiskIoTuning ? diskIoTuningExtension.id : ''

