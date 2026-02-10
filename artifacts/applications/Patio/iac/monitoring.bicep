// Patio IaC Monitoring Module - v3.0.0 (Unlimited Performance Strategy)
// Performance metrics collection: latency, throughput, GPU utilization
// Source Spec: devops/observability-001, infrastructure/compute-001 v3.0.0
// Date: February 10, 2026

targetScope = 'resourceGroup'

@description('Name prefix for Patio resources.')
param namePrefix string

@description('Azure region for deployment.')
param location string

@description('Key Vault name for diagnostic settings.')
param keyVaultName string

@description('Enable GPU performance metrics collection')
param enableGpuMetrics bool = false

@description('Tags to apply to monitoring resources.')
param tags object

// Log Analytics Workspace with 3-year retention
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${namePrefix}-law'
  location: location
  tags: tags
  properties: {
    retentionInDays: 1095
    sku: {
      name: 'PerGB2018'
    }
  }
}

// Application Insights for latency and throughput tracking
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${namePrefix}-ai'
  location: location
  kind: 'web'
  tags: tags
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    RetentionInDays: 1095
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Existing Key Vault reference for diagnostics
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

// Key Vault diagnostics
resource keyVaultDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${namePrefix}-kv-diag'
  scope: keyVault
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// Performance metrics alert rule: latency > 100ms
resource latencyAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${namePrefix}-latency-alert'
  location: 'global'
  tags: tags
  properties: {
    description: 'Alert when latency exceeds 100ms (v3.0.0 target: <50ms)'
    severity: 2
    enabled: true
    scopes: [
      appInsights.id
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'Latency'
          metricName: 'performanceCounters/processorCpuTime'
          operator: 'GreaterThan'
          threshold: 100
          timeAggregation: 'Average'
          criterionType: 'StaticThresholdCriterion'
          dimensions: []
        }
      ]
    }
  }
}

// Performance metrics alert rule: throughput < baseline
resource throughputAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${namePrefix}-throughput-alert'
  location: 'global'
  tags: tags
  properties: {
    description: 'Alert when throughput drops below baseline (v3.0.0 target: Premium storage 3-10x improvement)'
    severity: 2
    enabled: true
    scopes: [
      appInsights.id
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'Throughput'
          metricName: 'performanceCounters/networkIOBytesPerSecond'
          operator: 'LessThan'
          threshold: 1000000
          timeAggregation: 'Average'
          criterionType: 'StaticThresholdCriterion'
          dimensions: []
        }
      ]
    }
  }
}

// GPU metrics alert (if enabled)
resource gpuAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = if (enableGpuMetrics) {
  name: '${namePrefix}-gpu-utilization-alert'
  location: 'global'
  tags: tags
  properties: {
    description: 'GPU utilization monitor (ND96amsr_A100_v4)'
    severity: 3
    enabled: true
    scopes: [
      appInsights.id
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'GpuUtilization'
          metricName: 'performanceCounters/gpuUtilization'
          operator: 'GreaterThan'
          threshold: 90
          timeAggregation: 'Average'
          criterionType: 'StaticThresholdCriterion'
          dimensions: []
        }
      ]
    }
  }
}

output logAnalyticsWorkspaceId string = logAnalytics.id
output logAnalyticsWorkspaceName string = logAnalytics.name
output appInsightsId string = appInsights.id
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output latencyAlertId string = latencyAlert.id
output throughputAlertId string = throughputAlert.id
output gpuAlertId string = enableGpuMetrics ? gpuAlert.id : ''

