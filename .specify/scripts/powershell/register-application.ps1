#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Registers a new application in the application tier registry.

.DESCRIPTION
    Deterministic script that adds a new application entry to
    specs/application/_index.yaml. Follows the lifecycle schema defined
    in that file: apps start in 'draft' status.

    This script is idempotent — if the app-id already exists, it reports
    the existing entry and exits successfully without modifying the file.

    Part of the spec-driven development governance framework.

.PARAMETER AppId
    Unique application identifier (kebab-case, e.g. 'payment-service').

.PARAMETER AppName
    Human-readable application name (e.g. 'Payment Service').

.PARAMETER Description
    One-line description of the application.

.PARAMETER AdheresTo
    Comma-separated list of upstream spec-ids this app depends on
    (e.g. 'cost,dp,compute').

.PARAMETER Json
    Output result in JSON format for machine consumption.

.PARAMETER Help
    Show usage information and exit.

.EXAMPLE
    ./register-application.ps1 -AppId "payment-service" -AppName "Payment Service" -Description "Handles payment processing" -AdheresTo "cost,dp,compute"

.EXAMPLE
    ./register-application.ps1 -AppId "payment-service" -AppName "Payment Service" -Description "Handles payment processing" -Json
#>
[CmdletBinding()]
param(
    [string]$AppId,
    [string]$AppName,
    [string]$Description,
    [string]$AdheresTo,
    [switch]$Json,
    [switch]$Help
)
$ErrorActionPreference = 'Stop'

# --- Help ---
if ($Help) {
    Write-Host "Usage: ./register-application.ps1 -AppId <id> -AppName <name> -Description <desc> [-AdheresTo <spec-ids>] [-Json] [-Help]"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  -AppId        Unique kebab-case identifier (e.g. payment-service)"
    Write-Host "  -AppName      Human-readable name (e.g. 'Payment Service')"
    Write-Host "  -Description  One-line description"
    Write-Host "  -AdheresTo    Comma-separated upstream spec-ids (optional)"
    Write-Host "  -Json         Machine-readable JSON output"
    Write-Host "  -Help         Show this help"
    exit 0
}

# --- Prerequisite checks ---
if (-not $AppId -or -not $AppName -or -not $Description) {
    $msg = "Missing required parameters. Use -Help for usage."
    if ($Json) {
        [ordered]@{ status = "error"; message = $msg } | ConvertTo-Json -Compress
    } else {
        Write-Error $msg
    }
    exit 1
}

# Validate AppId format (kebab-case)
if ($AppId -notmatch '^[a-z][a-z0-9]*(-[a-z0-9]+)*$') {
    $msg = "AppId must be kebab-case (lowercase letters, numbers, hyphens). Got: $AppId"
    if ($Json) {
        [ordered]@{ status = "error"; message = $msg } | ConvertTo-Json -Compress
    } else {
        Write-Error $msg
    }
    exit 1
}

# --- Locate repo root and registry file ---
. (Join-Path $PSScriptRoot "common.ps1")
$repoRoot = Get-RepoRoot
$registryPath = Join-Path $repoRoot "specs" "application" "_index.yaml"

if (-not (Test-Path $registryPath)) {
    $msg = "Registry file not found: $registryPath"
    if ($Json) {
        [ordered]@{ status = "error"; message = $msg } | ConvertTo-Json -Compress
    } else {
        Write-Error $msg
    }
    exit 1
}

# --- Read current registry ---
$content = Get-Content -Path $registryPath -Raw

# --- Idempotency: check if app-id already exists ---
if ($content -match "app-id:\s*$([regex]::Escape($AppId))\b") {
    $msg = "Application '$AppId' is already registered. No changes made."
    if ($Json) {
        [ordered]@{ status = "exists"; appId = $AppId; message = $msg } | ConvertTo-Json -Compress
    } else {
        Write-Host "[specify] $msg" -ForegroundColor Yellow
    }
    exit 0
}

# --- Build the new entry ---
$today = (Get-Date).ToString("yyyy-MM-dd")
$specFile = "$AppId/spec.md"

# Build adheres-to block
$adheresToBlock = ""
if ($AdheresTo) {
    $specIds = $AdheresTo -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
    foreach ($specId in $specIds) {
        $adheresToBlock += "      - spec-id: $specId`n"
    }
} else {
    $adheresToBlock = "      []`n"
}

# YAML entry (indented to match the applications array)
$entry = @"

  - app-id: $AppId
    app-name: "$AppName"
    version: "1.0.0-draft"
    status: "draft"
    created: "$today"
    tier: application
    file: $specFile
    description: "$Description"
    adheres-to:
$adheresToBlock
"@

# --- Insert the entry ---
# Replace the empty array marker or append after existing entries.
if ($content -match 'applications:\s*\[\]') {
    # Empty registry — replace [] with the first entry
    $newApplicationsBlock = "applications:`n$entry"
    $updatedContent = $content -replace 'applications:\s*\[\]', $newApplicationsBlock
} else {
    # Non-empty registry — append before the trailing comments/end-of-file
    # Find the last entry in the applications block and append after it
    $updatedContent = $content.TrimEnd() + "`n$entry`n"
}

# Update application-count
$appCount = ($updatedContent | Select-String -Pattern 'app-id:' -AllMatches).Matches.Count
$updatedContent = $updatedContent -replace 'application-count:\s*\d+', "application-count: $appCount"

# Update registry-state if it was empty-initialized
if ($appCount -gt 0) {
    $updatedContent = $updatedContent -replace 'registry-state:\s*empty-initialized', 'registry-state: active'
}

# Write back
Set-Content -Path $registryPath -Value $updatedContent -NoNewline

# --- Output ---
if ($Json) {
    [ordered]@{
        status    = "registered"
        appId     = $AppId
        appName   = $AppName
        lifecycle = "draft"
        file      = $specFile
        registry  = $registryPath
    } | ConvertTo-Json -Compress
} else {
    Write-Host "[specify] Registered application '$AppId' (status: draft)" -ForegroundColor Green
    Write-Host "  Registry: $registryPath" -ForegroundColor Gray
    Write-Host "  Spec file: specs/application/$specFile" -ForegroundColor Gray
}
