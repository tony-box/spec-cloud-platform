// Patio IaC Configuration Module - v3.0.0 (Unlimited Performance Strategy)
// Source Spec: business/cost-001 v3.0.0, infrastructure/compute-001 v3.0.0, infrastructure/storage-001 v3.0.0
// Branch: patio-unlimited-performance
// Date: February 10, 2026

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

@description('VM SKU for compute resources - Premium only (cost-001 v3.0.0)')
@allowed([
  'Standard_D32ds_v5'
  'Standard_D48ds_v5'
  'Standard_D64ds_v5'
  'Standard_D96ds_v5'
  'Standard_M128ms'
  'Standard_M192idms_v2'
  'Standard_ND96amsr_A100_v4'
])
param vmSku string

@description('Storage account SKU - Premium only (cost-001 v3.0.0)')
@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'PremiumV2_LRS'
  'PremiumV2_ZRS'
  'UltraSSD_LRS'
])
param storageSku string

@description('Enable GPU acceleration for workload (ND96amsr_A100_v4)')
param enableGpuAcceleration bool = false

@description('Enable Ultra Disk for maximum throughput (160k IOPS, 4000 MB/s)')
param enableUltraDisk bool = false

@description('Ultra Disk IOPS provisioning (160000 max)')
param ultraDiskIops int = 160000

@description('Ultra Disk throughput in MB/s (4000 max)')
param ultraDiskThroughput int = 4000

@description('Enable disk encryption for all environments (cost-001 v3.0.0 mandatory)')
param enableDiskEncryption bool = true

@description('Enable customer-managed encryption key (CMK) for production')
param enableCmk bool = environment == 'prod'

@description('Cost profile strategy')
@allowed([
  'unlimited-performance'
  'cost-optimized'
])
param costProfile string = 'unlimited-performance'

var namePrefix = '${appName}-${environment}'

var tags = {
  application: appName
  environment: environment
  criticality: workloadCriticality
  performanceSpec: 'business/cost-001 v3.0.0'
  computeSpec: 'infrastructure/compute-001 v3.0.0'
  storageSpec: 'infrastructure/storage-001 v3.0.0'
  networkSpec: 'infrastructure/networking-001 v3.0.0'
  iamSpec: 'infrastructure/iac-modules-001 v2.0.0'
  costProfile: costProfile
  compliance: 'nist-800-171'
  costCenter: costCenter
}

output namePrefix string = namePrefix
output location string = location
output tags object = tags
output vmSku string = vmSku
output storageSku string = storageSku
output enableGpuAcceleration bool = enableGpuAcceleration
output enableUltraDisk bool = enableUltraDisk
output enableDiskEncryption bool = enableDiskEncryption
output enableCmk bool = enableCmk
output costProfile string = costProfile

