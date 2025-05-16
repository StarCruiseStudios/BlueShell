# Ensure we have Pester v5.x installed
if (-not (Get-Module -ListAvailable -Name Pester | Where-Object { $_.Version.Major -ge 5 })) {
    Install-Module -Name Pester -MinimumVersion 5.0.0 -Force -SkipPublisherCheck -AllowClobber
}

# Remove any existing Pester modules from the session (to avoid version conflicts)
Get-Module Pester | Remove-Module -Force

# Import Pester v5.x
Import-Module Pester -MinimumVersion 5.0.0

# Get the directory containing this script
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# Load the Pester configuration
$config = . (Join-Path $scriptPath "pester.config.ps1")

# Run the tests with the configuration
Invoke-Pester -Configuration $config 