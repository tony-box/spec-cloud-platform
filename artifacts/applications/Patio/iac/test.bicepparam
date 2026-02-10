using './main.bicep'

param appName = 'patio'
param environment = 'test'
param location = 'centralus'
param workloadCriticality = 'non-critical'
param costCenter = 'tbd'
param adminUsername = 'azureuser'
param sshPublicKey = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDplaceholder patio-test'
