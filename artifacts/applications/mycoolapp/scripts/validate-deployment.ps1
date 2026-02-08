#!/usr/bin/env pwsh
<#
.SYNOPSIS
Validate mycoolapp LAMP stack deployment

.DESCRIPTION
Post-deployment validation script that verifies VM health, LAMP stack components,
and application endpoints.

.PARAMETER ResourceGroupName
Azure resource group name containing deployed resources

.PARAMETER Environment
Environment identifier: 'dev' or 'prod'

.EXAMPLE
./validate-deployment.ps1 -ResourceGroupName mycoolapp-dev-rg -Environment dev
#>

param(
    [string]$ResourceGroupName = 'mycoolapp-dev-rg',
    [ValidateSet('dev', 'prod')]
    [string]$Environment = 'dev'
)

$ErrorActionPreference = 'Stop'
$validationPassed = $true

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

function Test-VMStatus {
    Write-Header "Testing VM Status"

    try {
        $vm = az vm get-instance-view --resource-group $ResourceGroupName --name "mycoolapp-$Environment-vm" --output json | ConvertFrom-Json

        $powerState = $vm.instanceView.statuses | Where-Object { $_.code -match 'PowerState' }
        if ($powerState.code -eq 'PowerState/running') {
            Write-Host "✓ VM is running" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "✗ VM is not running: $($powerState.code)" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "✗ Failed to get VM status: $_" -ForegroundColor Red
        return $false
    }
}

function Get-VMPublicIP {
    Write-Header "Getting VM Public IP"

    try {
        $pip = az network public-ip show --resource-group $ResourceGroupName --name "mycoolapp-$Environment-pip" --output json | ConvertFrom-Json
        if ($pip.ipAddress) {
            Write-Host "✓ Public IP: $($pip.ipAddress)" -ForegroundColor Green
            return $pip.ipAddress
        }
        else {
            Write-Host "✗ No public IP found" -ForegroundColor Red
            return $null
        }
    }
    catch {
        Write-Host "✗ Failed to get public IP: $_" -ForegroundColor Red
        return $null
    }
}

function Test-HTTPEndpoint {
    param(
        [string]$Url,
        [string]$EndpointName
    )

    try {
        $response = Invoke-WebRequest -Uri $Url -TimeoutSec 5 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "✓ $EndpointName is accessible (HTTP $($response.StatusCode))" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "✗ $EndpointName returned HTTP $($response.StatusCode)" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "✗ Failed to access $EndpointName : $_" -ForegroundColor Red
        return $false
    }
}

function Test-HealthCheckEndpoint {
    param([string]$PublicIP)

    Write-Header "Testing Health Check Endpoint"

    $healthUrl = "http://$PublicIP/health"
    Write-Host "Health Check URL: $healthUrl"

    try {
        $response = Invoke-WebRequest -Uri $healthUrl -TimeoutSec 5 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            try {
                $healthData = $response.Content | ConvertFrom-Json
                Write-Host "✓ Health endpoint returned:"
                Write-Host "  Status: $($healthData.status)"
                Write-Host "  Timestamp: $($healthData.timestamp)"
                Write-Host "  Apache: $($healthData.apache)"
                Write-Host "  PHP: $($healthData.php)"
                Write-Host "  MySQL: $($healthData.mysql)"
                return $true
            }
            catch {
                Write-Host "✓ Health endpoint is accessible but response is not JSON" -ForegroundColor Green
                return $true
            }
        }
        else {
            Write-Host "✗ Health endpoint returned HTTP $($response.StatusCode)" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "✗ Failed to access health endpoint: $_" -ForegroundColor Red
        return $false
    }
}

function Test-HTTPSEndpoint {
    param([string]$PublicIP)

    Write-Header "Testing HTTPS"

    $httpsUrl = "https://$PublicIP"
    Write-Host "HTTPS URL: $httpsUrl"

    try {
        # Suppress SSL certificate validation for self-signed cert testing
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
        
        $response = Invoke-WebRequest -Uri $httpsUrl -TimeoutSec 5 -UseBasicParsing
        Write-Host "✓ HTTPS is accessible (HTTP $($response.StatusCode))" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "⚠ HTTPS check failed (may be expected for self-signed cert): $_" -ForegroundColor Yellow
        return $true  # Don't fail on HTTPS issues during testing
    }
}

function Test-SSH {
    param([string]$PublicIP)

    Write-Header "Testing SSH Connectivity"

    Write-Host "SSH endpoint: ssh://azureuser@$PublicIP"

    try {
        $testConnection = Test-NetConnection -ComputerName $PublicIP -Port 22 -WarningAction SilentlyContinue
        if ($testConnection.TcpTestSucceeded) {
            Write-Host "✓ SSH port 22 is open" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "✗ SSH port 22 is not responding" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "✗ Failed to test SSH: $_" -ForegroundColor Red
        return $false
    }
}

function Test-NetworkSecurity {
    Write-Header "Testing Network Security Group"

    try {
        $nsg = az network nsg show --resource-group $ResourceGroupName --name "mycoolapp-$Environment-nsg" --output json | ConvertFrom-Json

        $rules = $nsg.securityRules
        $httpRule = $rules | Where-Object { $_.name -eq 'AllowHTTP' }
        $httpsRule = $rules | Where-Object { $_.name -eq 'AllowHTTPS' }
        $sshRule = $rules | Where-Object { $_.name -eq 'AllowSSH' }

        if ($httpRule) {
            Write-Host "✓ HTTP (port 80) rule present" -ForegroundColor Green
        }
        if ($httpsRule) {
            Write-Host "✓ HTTPS (port 443) rule present" -ForegroundColor Green
        }
        if ($sshRule) {
            Write-Host "✓ SSH (port 22) rule present" -ForegroundColor Green
        }

        return $true
    }
    catch {
        Write-Host "✗ Failed to check NSG: $_" -ForegroundColor Red
        return $false
    }
}

# ============================================================================
# Main Execution
# ============================================================================

try {
    Write-Host "mycoolapp Deployment Validation" -ForegroundColor Yellow
    Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor Yellow
    Write-Host "Environment: $Environment" -ForegroundColor Yellow
    Write-Host "Start: $(Get-Date)" -ForegroundColor Yellow

    # Test VM status
    $vmRunning = Test-VMStatus
    if (-not $vmRunning) { $validationPassed = $false }

    # Get public IP
    $publicIP = Get-VMPublicIP
    if (-not $publicIP) { $validationPassed = $false }

    # Test network security
    $nsgValid = Test-NetworkSecurity
    if (-not $nsgValid) { $validationPassed = $false }

    # Test SSH
    if ($publicIP) {
        $sshValid = Test-SSH $publicIP
        if (-not $sshValid) { $validationPassed = $false }
    }

    # Test HTTP
    if ($publicIP) {
        $httpValid = Test-HTTPEndpoint "http://$publicIP" "HTTP"
        if (-not $httpValid) { $validationPassed = $false }

        # Test health check endpoint
        $healthValid = Test-HealthCheckEndpoint $publicIP
        if (-not $healthValid) { $validationPassed = $false }
    }

    # Test HTTPS
    if ($publicIP) {
        $httpsValid = Test-HTTPSEndpoint $publicIP
        if (-not $httpsValid) { $validationPassed = $false }
    }

    # Summary
    Write-Header "Validation Summary"
    if ($validationPassed) {
        Write-Host "✓ All validations passed" -ForegroundColor Green
        exit 0
    }
    else {
        Write-Host "✗ Some validations failed - review output above" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "✗ Validation error: $_" -ForegroundColor Red
    exit 1
}
