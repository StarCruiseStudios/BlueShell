# Install-BlueShell.ps1 - Windows installer (Spec §9)
# Run from BlueShell repo root. Ensures PowerShell 7 is installed, then runs profile/config setup.
# Usage: .\Install-BlueShell.ps1
# If execution policy blocks: pwsh -ExecutionPolicy Bypass -File .\Install-BlueShell.ps1

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$psm1Path = Join-Path $repoRoot (Join-Path 'src' 'BlueShell.psm1')
if (-not (Test-Path $psm1Path)) {
    Write-Error "BlueShell.psm1 not found at $psm1Path. Run this script from the BlueShell repo root."
    exit 1
}

function Test-PowerShell7Installed {
    try {
        $major = & pwsh -NoProfile -Command '$PSVersionTable.PSVersion.Major' 2>$null
        return ($major -ge 7)
    } catch {
        return $false
    }
}

function Install-PowerShell7Windows {
    Write-Host "PowerShell 7 not found. Attempting to install via winget..."
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $winget) {
        Write-Warning "winget is not available. Please install PowerShell 7 manually: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows"
        Write-Host "After installing pwsh, run this script again: .\Install-BlueShell.ps1"
        exit 1
    }
    & winget install --id Microsoft.PowerShell --source winget --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "winget install failed. You may need to run this script as Administrator."
        Write-Host "Alternatively install PowerShell 7 from: https://github.com/PowerShell/PowerShell/releases"
        exit 1
    }
    Write-Host "PowerShell 7 installed. Please open a new terminal and run: .\Install-BlueShell.ps1"
    exit 0
}

# Ensure pwsh 7 is available
if (-not (Test-PowerShell7Installed)) {
    if ($env:OS -eq 'Windows_NT') {
        Install-PowerShell7Windows
    } else {
        Write-Error "PowerShell 7 (pwsh) is required. Install it for your platform and run this script again."
        exit 1
    }
}

# Run base setup in pwsh so profile/config use pwsh
$psm1PathQuoted = $psm1Path -replace "'", "''"
$cmd = "Import-Module '$psm1PathQuoted' -Force; Install-BlueShell"
& pwsh -NoProfile -Command $cmd
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "BlueShell setup complete. Restart your terminal or run: pwsh" -ForegroundColor Green
