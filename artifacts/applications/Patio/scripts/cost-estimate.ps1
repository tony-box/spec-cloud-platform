param(
    [Parameter(Mandatory = $true)]
    [string]$ParamFile
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -Path $ParamFile)) {
    throw "Parameter file not found: $ParamFile"
}

$paramContent = Get-Content -Path $ParamFile -Raw
$criticalityMatch = [regex]::Match($paramContent, "workloadCriticality\s*=\s*'([^']+)'")
if (-not $criticalityMatch.Success) {
    throw "workloadCriticality not found in parameter file."
}

$criticality = $criticalityMatch.Groups[1].Value
$estimate = switch ($criticality) {
    'critical' { 200 }
    'non-critical' { 75 }
    'dev-test' { 35 }
    default { throw "Unsupported workloadCriticality: $criticality" }
}

Write-Output $estimate
