# Setup.ps1 - Install-BlueShell, Install-DevEnvironment (Spec §8)

function Install-BlueShell {
    <#
    .SYNOPSIS
        Ensure profile exists, profile loads BlueShell, config dir and config.json exist. Idempotent (Spec §8).
    .PARAMETER ProfilePath
        Optional. Override profile path (e.g. for tests).
    #>
    [CmdletBinding()]
    param([string]$ProfilePath)
    $root = Get-BlueShellRoot
    $psm1Path = Join-Path $root 'BlueShell.psm1'
    $configDir = Get-BlueShellConfigDir
    if (-not (Test-Path $configDir)) { New-Item -ItemType Directory -Path $configDir -Force | Out-Null }
    $configPath = Join-Path $configDir 'config.json'
    if (-not (Test-Path $configPath)) {
        @{ moduleRoots = @{}; activePreset = '' } | ConvertTo-Json | Set-Content -Path $configPath -Encoding utf8
    }
    $profilePath = if ($ProfilePath) { $ProfilePath } else { $PROFILE.CurrentUserAllHosts }
    $profileDir = Split-Path $profilePath
    if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }
    $loadLine = "Import-Module '$psm1Path' -Force"
    $content = $null
    if (Test-Path $profilePath) { $content = Get-Content -Raw -Path $profilePath -ErrorAction SilentlyContinue }
    if ($content -and $content -match [regex]::Escape($loadLine)) { return }
    $block = @"

# BlueShell (added by Install-BlueShell)
$loadLine
"@
    Add-Content -Path $profilePath -Value $block
}

function Install-DevEnvironment {
    <#
    .SYNOPSIS
        Run base setup, then run each discovered module's setup script. Idempotent (Spec §8).
    #>
    [CmdletBinding()]
    param()
    Install-BlueShell
    $moduleRoots = Get-BlueShellConfig -Key 'moduleRoots'
    if (-not $moduleRoots) { $moduleRoots = @{} }
    $modulesEnv = $env:BLUESHELL_MODULES
    if ($modulesEnv) {
        $names = $modulesEnv -split '[;,]'
        foreach ($n in $names) {
            $n = $n.Trim()
            if (-not $n) { continue }
            if ($moduleRoots.ContainsKey($n) -and (Test-Path $moduleRoots[$n])) {
                $setupPath = Join-Path $moduleRoots[$n] "Setup-$n.ps1"
                if (-not (Test-Path $setupPath)) { $setupPath = Join-Path $moduleRoots[$n] "Install-$n.ps1" }
                if (Test-Path $setupPath) { & $setupPath }
            }
        }
    }
    foreach ($name in $moduleRoots.Keys) {
        $path = $moduleRoots[$name]
        if (-not $path -or -not (Test-Path $path)) { continue }
        $setupPath = Join-Path $path "Setup-$name.ps1"
        if (-not (Test-Path $setupPath)) { $setupPath = Join-Path $path "Install-$name.ps1" }
        if (Test-Path $setupPath) { & $setupPath }
    }
}
