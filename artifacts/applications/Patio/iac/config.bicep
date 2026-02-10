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

var namePrefix = '${appName}-${environment}'

var baselineCost = workloadCriticality == 'critical' ? '150-250' : (workloadCriticality == 'non-critical' ? '50-100' : '20-50')

var tags = {
  application: appName
  environment: environment
  criticality: workloadCriticality
  baselineCost: baselineCost
  compliance: 'nist-800-171'
  costCenter: costCenter
}

output namePrefix string = namePrefix
output location string = location
output tags object = tags
