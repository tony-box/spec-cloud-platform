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

@description('Tags to apply to automation resources.')
param tags object

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

output shutdownScheduleId string = shutdownSchedule.id
