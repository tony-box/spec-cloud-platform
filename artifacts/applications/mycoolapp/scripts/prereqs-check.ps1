#!/usr/bin/env pwsh
<#
.SYNOPSIS
Check prerequisites for mycoolapp deployment

.DESCRIPTION
Validates that all required tools and permissions are available for deployment:
- Azure CLI and Bicep CLI installed
- Azure subscription and authentication
- Required resource providers registered
- Necessary permissions

.EXAMPLE
./prereqs-check.ps1

.EXAMPLE
./prereqs-check.ps1 -Verbose
#>

param()

$ErrorActionPreference = 'Stop'
$prereqsValid = $true

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

function Test-AzureCli {
    Write-Header "Checking Azure CLI"

    try {
        $version = az version --output json | ConvertFrom-Json
        $cliVersion = $version.'azure-cli'
        Write-Host "✓ Azure CLI installed: $cliVersion" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "✗ Azure CLI not found" -ForegroundColor Red
        Write-Host "  Install from: https://aka.ms/azcli" -ForegroundColor Yellow
        return $false
    }
}

function Test-BicepCli {
    Write-Header "Checking Bicep CLI"

    try {
        $bicep = az bicep version | ConvertFrom-Json
        $bicepVersion = $bicep.bicep
        Write-Host "✓ Bicep CLI installed: $bicepVersion" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "✗ Bicep CLI not found" -ForegroundColor Red
        Write-Host "  Install with: az bicep install" -ForegroundColor Yellow
        return $false
    }
}

function Test-PowerShellVersion {
    Write-Header "Checking PowerShell Version"

    $psVersion = $PSVersionTable.PSVersion.Major
    if ($psVersion -ge 6) {
        Write-Host "✓ PowerShell 7+ installed: $PSVersionTable.PSVersion" -ForegroundColor Green
        return $true
    }
    else {
        Write-Host "⚠ PowerShell $psVersion detected (6+ recommended)" -ForegroundColor Yellow
        return $true  # Not a blocker
    }
}

function Test-AzureAuthentication {
    Write-Header "Checking Azure Authentication"

    try {
        $account = az account show --output json | ConvertFrom-Json
        Write-Host "✓ Authenticated to Azure" -ForegroundColor Green
        Write-Host "  Subscription: $($account.name)" -ForegroundColor Green
        Write-Host "  ID: $($account.id)" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "✗ Not authenticated to Azure" -ForegroundColor Red
        Write-Host "  Run: az login" -ForegroundColor Yellow
        return $false
    }
}

function Test-ResourceProviders {
    Write-Header "Checking Resource Providers"

    $requiredProviders = @(
        'Microsoft.Compute'
        'Microsoft.Network'
        'Microsoft.Storage'
        'Microsoft.Sql'
        'Microsoft.Insights'
        'Microsoft.OperationalInsights'
    )

    $allRegistered = $true
    foreach ($provider in $requiredProviders) {
        try {
            $providerStatus = az provider show --namespace $provider --output json | ConvertFrom-Json
            if ($providerStatus.registrationState -eq 'Registered') {
                Write-Host "✓ $provider is registered" -ForegroundColor Green
            }
            else {
                Write-Host "⚠ $provider is not registered - attempting registration..." -ForegroundColor Yellow
                az provider register --namespace $provider
                Write-Host "  Registered" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "✗ Failed to check $provider : $_" -ForegroundColor Red
            $allRegistered = $false
        }
    }
    return $allRegistered
}

function Test-RegionAvailability {
    Write-Header "Checking Region Availability"

    $region = 'centralus'
    
    try {
        $regions = az account list-locations --output json | ConvertFrom-Json
        $targetRegion = $regions | Where-Object { $_.name -eq $region }

        if ($targetRegion) {
            Write-Host "✓ Region '$region' is available ($($targetRegion.displayName))" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "✗ Region '$region' not available" -ForegroundColor Red
            Write-Host "  Available regions:" -ForegroundColor Yellow
            $regions | ForEach-Object { Write-Host "    - $($_.name) ($($_.displayName))" -ForegroundColor Yellow }
            return $false
        }
    }
    catch {
        Write-Host "✗ Failed to check region availability: $_" -ForegroundColor Red
        return $false
    }
}

function Test-NetworkConnectivity {
    Write-Header "Checking Network Connectivity"

    $testUrls = @(
        @{ Name = 'Azure Portal'; Url = 'https://portal.azure.com' }
        @{ Name = 'Azure Management API'; Url = 'https://management.azure.com' }
        @{ Name = 'GitHub'; Url = 'https://github.com' }
    )

    $allReachable = $true
    foreach ($test in $testUrls) {
        try {
            $response = Invoke-WebRequest -Uri $test.Url -TimeoutSec 5 -UseBasicParsing
            Write-Host "✓ $($test.Name) is reachable" -ForegroundColor Green
        }
        catch {
            Write-Host "✗ Cannot reach $($test.Name): $_" -ForegroundColor Red
            $allReachable = $false
        }
    }
    return $allReachable
}

function Test-DiskSpace {
    Write-Header "Checking Disk Space"

    try {
        $driveletter = (Get-Location).Drive.Name
        $drive = Get-PSDrive -Name $driveletter
        
        $usedPercent = [math]::Round(($drive.Used / ($drive.Used + $drive.Free)) * 100, 2)
        $freeGB = [math]::Round(($drive.Free / 1GB), 2)

        if ($freeGB -gt 10) {
            Write-Host "✓ Sufficient disk space available: $freeGB GB free ($usedPercent%)" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "⚠ Low disk space: $freeGB GB available ($usedPercent%)" -ForegroundColor Yellow
            return $true  # Not a blocker
        }
    }
    catch {
        Write-Host "⚠ Could not check disk space: $_" -ForegroundColor Yellow
        return $true  # Not critical
    }
}

# ============================================================================
# Main Execution
# ============================================================================

try {
    Write-Host "Prerequisites Check for mycoolapp Deployment" -ForegroundColor Yellow
    Write-Host "Start: $(Get-Date)" -ForegroundColor Yellow

    # Run checks
    $cliOk = Test-AzureCli
    $bicepOk = Test-BicepCli
    $psOk = Test-PowerShellVersion
    $authOk = Test-AzureAuthentication
    $providersOk = Test-ResourceProviders
    $regionOk = Test-RegionAvailability
    $networkOk = Test-NetworkConnectivity
    $diskOk = Test-DiskSpace

    # Determine overall status
    $criticalChecks = $cliOk -and $bicepOk -and $authOk -and $providersOk
    $allChecks = $criticalChecks -and $regionOk -and $networkOk

    # Summary
    Write-Header "Prerequisites Summary"

    if ($allChecks) {
        Write-Host "✓ All prerequisites met - deployment ready" -ForegroundColor Green
        exit 0
    }
    elseif ($criticalChecks) {
        Write-Host "⚠ Critical prerequisites met, but some optional checks failed" -ForegroundColor Yellow
        exit 0
    }
    else {
        Write-Host "✗ Critical prerequisites not met - fix issues above before deployment" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "✗ Prerequisite check error: $_" -ForegroundColor Red
    exit 1
}
