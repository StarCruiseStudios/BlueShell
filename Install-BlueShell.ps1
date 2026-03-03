# ==============================================================================
# Usage: .\Install-BlueShell.ps1
# If execution policy blocks: pwsh -ExecutionPolicy Bypass -File .\Install-BlueShell.ps1
# ==============================================================================
$ErrorActionPreference = 'Stop'
$setupVersion = 1

# ==============================================================================
# Ensure PowerShell 7 is installed.

$pwsh7Installed = $false
try {
    $pwshMajorVersion = & pwsh -NoProfile -Command '$PSVersionTable.PSVersion.Major' 2>$null
    $pwsh7Installed = ($pwshMajorVersion -ge 7)
} catch { }

if (-not $pwsh7Installed) {
    Write-Host "PowerShell 7 not found. Attempting to install via winget..."
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $winget) {
        Write-Host "winget is not available. Please install PowerShell 7 manually and then run this script again." -ForegroundColor Yellow
        Write-Host "Install: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows"
        Write-Host "After installing pwsh run this script again."
        exit 1
    }
    & winget install --id Microsoft.PowerShell --source winget --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        Write-Host "PowerShell 7 installation failed. Install it manually and then run this script again." -ForegroundColor Yellow
        Write-Host "Install: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows"
        Write-Host "Or: https://github.com/PowerShell/PowerShell/releases"
        Write-Host "You may need to run this script as Administrator for winget to succeed."
        exit 1
    }
    Write-Host "PowerShell 7 installed. Please open a new terminal and run: .\Install-BlueShell.ps1"
}

# ==============================================================================
# Configure $PROFILE.CurrentUserAllHosts to Start BlueShell.

$content = Get-Content -Path $PROFILE.CurrentUserAllHosts -Raw
if ($content -match '# Run BlueShell \(Setup V(\d+)\)') {
    $versionNumber = [int]$Matches[1]
}

if ($versionNumber -ge $setupVersion) {
    Write-Host "BlueShell set up with version $versionNumber."
    exit 0
}

$thisScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$blueShellRoot = Join-Path $thisScriptPath (Join-Path 'src' 'BlueShell.psm1')
if (-not (Test-Path $blueShellRoot)) {
    Write-Error "BlueShell.psm1 not found at $blueShellRoot. Run this script from the BlueShell repo root."
    exit 1
}
$blueShellRootQuoted = $blueShellRoot -replace "'", "''"
$startBlueShellCmd = "Import-Module '$blueShellRootQuoted' -Force"

$setupBlock = @"
# Run BlueShell (Setup V$setupVersion)
$startBlueShellCmd
# End Run BlueShell
"@

if ($versionNumber -ne $null) {
    $pattern = '(?s)# Run BlueShell.*?# End Run BlueShell[^\r\n]*'
    $newContent = $content -replace $pattern, $setupBlock
    Set-Content -Path $PROFILE.CurrentUserAllHosts -Value $newContent -NoNewline
} else {
    Add-Content -Path $PROFILE.CurrentUserAllHosts -Value $setupBlock
}

# ==============================================================================
# Start BlueShell

Invoke-Expression $startBlueShellCmd

# ==============================================================================
# Setup Complete

Write-Host "BlueShell install complete." -ForegroundColor Green
