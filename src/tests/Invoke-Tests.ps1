# Invoke-Tests.ps1 - Run BlueShell tests (Spec §12)
# Uses Pester v5. Does not touch real ~/.blueshell or user profile.
# Cross-platform: run on Windows, macOS, or Linux under PowerShell 7.
# Run: pwsh -File src/tests/Invoke-Tests.ps1   or   Invoke-Pester -Path src/tests

[CmdletBinding()]
param(
    [switch]$Output,
    [string]$Tag
)

$ErrorActionPreference = 'Stop'
$testsDir = $PSScriptRoot
$projectRoot = (Get-Item $testsDir).Parent.Parent.FullName

# Require Pester 5 (use #Requires -Modules Pester in production)
$pester = Get-Module -ListAvailable -Name Pester | Where-Object { $_.Version.Major -ge 5 } | Sort-Object Version -Descending | Select-Object -First 1
if (-not $pester) {
    Write-Error "Pester 5 is required. Install with: Install-Module -Name Pester -MinimumVersion 5.0.0 -Scope CurrentUser"
    exit 1
}
Import-Module $pester -Force

$config = New-PesterConfiguration
$config.Run.Path = $testsDir
$config.Run.Exit = $true
$config.Output.Verbosity = if ($Output) { 'Detailed' } else { 'Minimal' }
if ($Tag) { $config.Filter.Tag = $Tag }

Invoke-Pester -Configuration $config
