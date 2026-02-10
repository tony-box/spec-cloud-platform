using './main.bicep'

param appName = 'patio'
param environment = 'dev'
param location = 'centralus'
param workloadCriticality = 'dev-test'
param costCenter = 'tbd'
param adminUsername = 'azureuser'
param sshPublicKey = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDplaceholder patio-dev'
