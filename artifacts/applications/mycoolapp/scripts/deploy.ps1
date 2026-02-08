#!/usr/bin/env pwsh
<#
.SYNOPSIS
Deploy mycoolapp LAMP stack to Azure using Bicep templates

.DESCRIPTION
This script orchestrates the deployment of mycoolapp to Azure using the cost-optimized
Bicep templates. It handles resource group creation, parameter validation, and deployment.

.PARAMETER Environment
Environment to deploy to: 'dev' or 'prod'

.PARAMETER ResourceGroupName
Azure resource group name for deployment

.PARAMETER SubscriptionId
Azure subscription ID (optional, uses current subscription if not specified)

.PARAMETER TemplateFile
Path to Bicep template file

.PARAMETER ParameterFile
Path to Bicep parameter file

.EXAMPLE
./deploy.ps1 -Environment dev -ResourceGroupName mycoolapp-dev-rg

.EXAMPLE
./deploy.ps1 -Environment prod -ResourceGroupName mycoolapp-prod-rg -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
#>

param(
    [ValidateSet('dev', 'prod')]
    [string]$Environment = 'dev',

    [string]$ResourceGroupName = "mycoolapp-$Environment-rg",

    [string]$SubscriptionId,

    [string]$TemplateFile = './main.bicep',

    [string]$ParameterFile = './main.bicepparam',

    [string]$Location = 'centralus'
)

# ============================================================================
# Configuration
# ============================================================================
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

# ============================================================================
# Functions
# ============================================================================

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "=================================================================================" -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Cyan
    Write-Host "=================================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Test-Prerequisites {
    Write-Header "Testing Prerequisites"

    # Check Azure CLI
    try {
        $azVersion = az version --output json | ConvertFrom-Json
        Write-Host "✓ Azure CLI version: $($azVersion.'azure-cli')" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Azure CLI not found. Install from https://aka.ms/azcli" -ForegroundColor Red
        exit 1
    }

    # Check Bicep CLI
    try {
        $bicepVersion = az bicep version | ConvertFrom-Json
        Write-Host "✓ Bicep CLI version: $($bicepVersion.bicep)" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Bicep not found. Run: az bicep install" -ForegroundColor Red
        exit 1
    }

    # Check template files
    if (-not (Test-Path $TemplateFile)) {
        Write-Host "✗ Template file not found: $TemplateFile" -ForegroundColor Red
        exit 1
    }
    Write-Host "✓ Template file exists: $TemplateFile" -ForegroundColor Green

    if (-not (Test-Path $ParameterFile)) {
        Write-Host "✗ Parameter file not found: $ParameterFile" -ForegroundColor Red
        exit 1
    }
    Write-Host "✓ Parameter file exists: $ParameterFile" -ForegroundColor Green
}

function Validate-Bicep {
    Write-Header "Validating Bicep Template"

    try {
        az bicep build --file $TemplateFile
        Write-Host "✓ Bicep template validation passed" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Bicep template validation failed: $_" -ForegroundColor Red
        exit 1
    }
}

function Create-ResourceGroup {
    Write-Header "Creating Resource Group"

    Write-Host "Resource Group: $ResourceGroupName"
    Write-Host "Location: $Location"

    try {
        # Create resource group
        $rg = az group create --name $ResourceGroupName --location $Location --output json | ConvertFrom-Json
        Write-Host "✓ Resource group created: $($rg.id)" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Failed to create resource group: $_" -ForegroundColor Red
        exit 1
    }
}

function Deploy-Bicep {
    Write-Header "Deploying Bicep Template"

    $deploymentName = "mycoolapp-deploy-$(Get-Date -Format 'yyyyMMddHHmmss')"

    try {
        Write-Host "Deployment Name: $deploymentName"
        Write-Host "Starting deployment..."

        $deployment = az deployment group create `
          --resource-group $ResourceGroupName `
          --template-file $TemplateFile `
          --parameters $ParameterFile `
          --name $deploymentName `
          --output json | ConvertFrom-Json

        if ($deployment.properties.provisioningState -eq 'Succeeded') {
            Write-Host "✓ Deployment succeeded" -ForegroundColor Green
            return $deployment
        }
        else {
            Write-Host "✗ Deployment failed: $($deployment.properties.provisioningState)" -ForegroundColor Red
            exit 1
        }
    }
    catch {
        Write-Host "✗ Deployment error: $_" -ForegroundColor Red
        exit 1
    }
}

function Show-Outputs {
    param([object]$Deployment)
    
    Write-Header "Deployment Outputs"

    $outputs = $Deployment.properties.outputs

    if ($outputs) {
        foreach ($key in $outputs.PSObject.Properties.Name) {
            $value = $outputs.$key.value
            Write-Host "$key : $value"
        }
    }
}

# ============================================================================
# Main Execution
# ============================================================================

try {
    Write-Host "mycoolapp Deployment Script" -ForegroundColor Yellow
    Write-Host "Environment: $Environment" -ForegroundColor Yellow
    Write-Host "Start: $(Get-Date)" -ForegroundColor Yellow

    # Set subscription if provided
    if ($SubscriptionId) {
        Write-Host "Setting subscription: $SubscriptionId" -ForegroundColor Cyan
        az account set --subscription $SubscriptionId
    }

    # Verify prerequisites
    Test-Prerequisites

    # Validate template
    Validate-Bicep

    # Create resource group
    Create-ResourceGroup

    # Deploy template
    $deployment = Deploy-Bicep

    # Show outputs
    Show-Outputs $deployment

    Write-Header "Deployment Complete"
    Write-Host "End: $(Get-Date)" -ForegroundColor Yellow
    Write-Host "✓ Deployment successful" -ForegroundColor Green

    exit 0
}
catch {
    Write-Host "✗ Deployment failed: $_" -ForegroundColor Red
    exit 1
}
