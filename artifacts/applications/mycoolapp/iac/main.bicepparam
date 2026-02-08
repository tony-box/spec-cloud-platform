using './main.bicep'

// Development Environment Parameters
param environment = 'dev'
param appName = 'mycoolapp'
param location = 'centralus'
param vmSku = 'Standard_B2s'  // Cost-optimized dev SKU
param adminUsername = 'azureuser'
param tags = {
  environment: 'dev'
  application: 'mycoolapp'
  tier: 'application'
  phase: 'foundational-iac'
  deployment: 'bicep'
}
