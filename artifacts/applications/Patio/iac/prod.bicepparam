using './main.bicep'

// Patio Production Environment Parameters - v3.0.0 Unlimited Performance
// Note: SKUs, encryption, and cost profile are auto-configured by main.bicep based on environment
// Updated: February 10, 2026

param appName = 'patio'
param environment = 'prod'
param location = 'centralus'
param workloadCriticality = 'critical'
param costCenter = 'tbd'
param adminUsername = 'azureuser'
param sshPublicKey = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDplaceholder patio-prod'
