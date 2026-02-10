param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('critical','non-critical','dev-test')]
    [string]$Criticality
)

Write-Host "Workload criticality '$Criticality' is valid."
exit 0
