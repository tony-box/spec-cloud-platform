// Alert Rules for mycoolapp Monitoring
// Integrated with Azure Monitor for LAMP stack health monitoring

targetScope = 'resourceGroup'

param (
    [string]$environment = 'dev'
    [string]$appName = 'mycoolapp'
    [string]$location = resourceGroup().location
    [string]$workspaceResourceId = ''  // Optional: Log Analytics workspace ID
)

var alertPrefix = '${appName}-${environment}'

// ============================================================================
// Action Group (for notifications)
// ============================================================================

resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
    name: '${alertPrefix}-action-group'
    location: 'global'
    properties: {
        groupShortName: 'mycoolapp'
        enabled: true
        emailReceivers: [
            {
                name: 'Admin Email'
                emailAddress: 'admin@example.com'
                useCommonAlertSchema: true
            }
        ]
        webhookReceivers: []
        smsReceivers: []
        pushNotificationReceivers: []
        armRoleReceivers: []
        automationRunbookReceivers: []
        voiceReceivers: []
        eventHubReceivers: []
        itsmReceivers: []
    }
}

// ============================================================================
// Metric Alerts
// ============================================================================

// CPU Percentage Alert
resource cpuPercentageAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
    name: '${alertPrefix}-cpu-alert'
    location: 'global'
    properties: {
        description: 'Alert when CPU exceeds 80% for 5 minutes'
        severity: 2
        enabled: true
        scopes: [
            resourceId('Microsoft.Compute/virtualMachines', '${appName}-${environment}-vm')
        ]
        evaluationFrequency: 'PT5M'
        windowSize: 'PT5M'
        criteria: {
            'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
            allOf: [
                {
                    name: 'Percentage CPU'
                    metricName: 'Percentage CPU'
                    operator: 'GreaterThan'
                    threshold: 80
                    timeAggregation: 'Average'
                    criterionType: 'StaticThresholdCriterion'
                }
            ]
        }
        actions: [
            {
                actionGroupId: actionGroup.id
                webHookProperties: {}
            }
        ]
    }
}

// Memory Available Alert
resource memoryAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
    name: '${alertPrefix}-memory-alert'
    location: 'global'
    properties: {
        description: 'Alert when memory availability drops below 20%'
        severity: 2
        enabled: true
        scopes: [
            resourceId('Microsoft.Compute/virtualMachines', '${appName}-${environment}-vm')
        ]
        evaluationFrequency: 'PT5M'
        windowSize: 'PT5M'
        criteria: {
            'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
            allOf: [
                {
                    name: 'Available Memory Bytes'
                    metricName: 'Available Memory Bytes'
                    operator: 'LessThan'
                    threshold: 859993600  // ~820 MB on 4GB VM
                    timeAggregation: 'Average'
                    criterionType: 'StaticThresholdCriterion'
                }
            ]
        }
        actions: [
            {
                actionGroupId: actionGroup.id
                webHookProperties: {}
            }
        ]
    }
}

// Disk Read Alert
resource diskReadAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
    name: '${alertPrefix}-disk-alert'
    location: 'global'
    properties: {
        description: 'Alert when disk read rate is anomalously high'
        severity: 3
        enabled: true
        scopes: [
            resourceId('Microsoft.Compute/virtualMachines', '${appName}-${environment}-vm')
        ]
        evaluationFrequency: 'PT5M'
        windowSize: 'PT15M'
        criteria: {
            'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
            allOf: [
                {
                    name: 'Disk Read Bytes/sec'
                    metricName: 'Disk Read Bytes/sec'
                    operator: 'GreaterThan'
                    threshold: 104857600  // 100 MB/s
                    timeAggregation: 'Average'
                    criterionType: 'StaticThresholdCriterion'
                }
            ]
        }
        actions: [
            {
                actionGroupId: actionGroup.id
                webHookProperties: {}
            }
        ]
    }
}

// Network In Alert
resource networkInAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
    name: '${alertPrefix}-network-in-alert'
    location: 'global'
    properties: {
        description: 'Alert when inbound network traffic exceeds 1 GB'
        severity: 3
        enabled: true
        scopes: [
            resourceId('Microsoft.Network/networkInterfaces', '${appName}-${environment}-nic')
        ]
        evaluationFrequency: 'PT5M'
        windowSize: 'PT5M'
        criteria: {
            'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
            allOf: [
                {
                    name: 'Bytes Received'
                    metricName: 'Bytes Received'
                    operator: 'GreaterThan'
                    threshold: 1099511627776  // 1 TB
                    timeAggregation: 'Total'
                    criterionType: 'StaticThresholdCriterion'
                }
            ]
        }
        actions: [
            {
                actionGroupId: actionGroup.id
                webHookProperties: {}
            }
        ]
    }
}

// ============================================================================
// Activity Log Alerts
// ============================================================================

// VM Stop/Deallocate Alert
resource vmStopAlert 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
    name: '${alertPrefix}-vm-stop-alert'
    location: 'global'
    properties: {
        description: 'Alert when VM is stopped or deallocated'
        enabled: true
        scopes: [
            subscription().id
        ]
        condition: {
            allOf: [
                {
                    field: 'category'
                    equals: 'Administrative'
                }
                {
                    field: 'operationName'
                    equals: 'Microsoft.Compute/virtualMachines/powerOff/action'
                }
                {
                    field: 'operationName'
                    equals: 'Microsoft.Compute/virtualMachines/deallocate/action'
                }
                {
                    field: 'resourceType'
                    equals: 'Microsoft.Compute/virtualMachines'
                }
                {
                    field: 'resourceId'
                    contains: '${appName}-${environment}-vm'
                }
            ]
        }
        actions: {
            actionGroups: [
                {
                    actionGroupId: actionGroup.id
                }
            ]
        }
    }
}

// ============================================================================
// Outputs
// ============================================================================

output actionGroupId string = actionGroup.id
output cpuAlertId string = cpuPercentageAlert.id
output memoryAlertId string = memoryAlert.id
output diskAlertId string = diskReadAlert.id
output networkAlertId string = networkInAlert.id
output vmStopAlertId string = vmStopAlert.id
