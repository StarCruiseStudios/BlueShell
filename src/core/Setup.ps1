# Setup.ps1 - Install-BlueShell, Install-DevEnvironment (Spec §8)
# Profile strategy: CurrentUserAllHosts = load module once; CurrentUserCurrentHost = enable interactive when host has UI (no second import).

function Install-BlueShell {
    <#
    .SYNOPSIS
        Ensure profile exists, profile loads BlueShell, config dir and config.json exist. Idempotent (Spec §8).
    .PARAMETER ProfilePath
        Optional. Override path for CurrentUserAllHosts profile only (e.g. for tests). CurrentHost uses default unless -CurrentHostProfilePath is set.
    .PARAMETER AllHostsProfilePath
        Optional. Override path for CurrentUserAllHosts profile (e.g. for tests).
    .PARAMETER CurrentHostProfilePath
        Optional. Override path for CurrentUserCurrentHost profile (e.g. for tests).
    #>
    [CmdletBinding()]
    param(
        [string]$ProfilePath,
        [string]$AllHostsProfilePath,
        [string]$CurrentHostProfilePath
    )
    # Backward compatibility: -ProfilePath sets AllHosts path only; when only -ProfilePath is provided, skip CurrentHost (e.g. tests)
    $allHostsPath = if ($AllHostsProfilePath) { $AllHostsProfilePath } elseif ($ProfilePath) { $ProfilePath } else { $PROFILE.CurrentUserAllHosts }
    $currentHostPath = if ($CurrentHostProfilePath) { $CurrentHostProfilePath } else { $PROFILE.CurrentUserCurrentHost }
    $skipCurrentHost = ($ProfilePath -and -not $CurrentHostProfilePath -and -not $AllHostsProfilePath)

    $root = Get-BlueShellRoot
    $psm1Path = Join-Path $root 'BlueShell.psm1'
    $configDir = Get-BlueShellConfigDir
    if (-not (Test-Path $configDir)) { New-Item -ItemType Directory -Path $configDir -Force | Out-Null }
    $configPath = Join-Path $configDir 'config.json'
    if (-not (Test-Path $configPath)) {
        @{ moduleRoots = @{}; activePreset = '' } | ConvertTo-Json | Set-Content -Path $configPath -Encoding utf8
    }

    # CurrentUserAllHosts: Import-Module only (no interactive line here; avoids double load when CurrentHost also runs)
    $loadLine = "Import-Module '$psm1Path' -Force"
    $allHostsDir = Split-Path $allHostsPath
    if (-not (Test-Path $allHostsDir)) { New-Item -ItemType Directory -Path $allHostsDir -Force | Out-Null }
    $allHostsContent = $null
    if (Test-Path $allHostsPath) { $allHostsContent = Get-Content -Raw -Path $allHostsPath -ErrorAction SilentlyContinue }
    if (-not ($allHostsContent -and $allHostsContent -match [regex]::Escape($loadLine))) {
        $block = @"

# BlueShell (added by Install-BlueShell) - load once for all hosts
$loadLine
"@
        Add-Content -Path $allHostsPath -Value $block
    }

    # CurrentUserCurrentHost: interactive opt-in only when host has UI (no Import-Module; module already loaded by AllHosts)
    if (-not $skipCurrentHost) {
        $interactiveMarker = 'Enable-BlueShellInteractive'
        $interactiveLine = 'if (Test-BlueShellInteractiveHost) { Enable-BlueShellInteractive }'
        $currentHostDir = Split-Path $currentHostPath
        if (-not (Test-Path $currentHostDir)) { New-Item -ItemType Directory -Path $currentHostDir -Force | Out-Null }
        $currentHostContent = $null
        if (Test-Path $currentHostPath) { $currentHostContent = Get-Content -Raw -Path $currentHostPath -ErrorAction SilentlyContinue }
        if (-not ($currentHostContent -and $currentHostContent -match [regex]::Escape($interactiveMarker))) {
            $interactiveBlock = @"

# BlueShell (added by Install-BlueShell) - enable interactive mode for this host only
$interactiveLine
"@
            Add-Content -Path $currentHostPath -Value $interactiveBlock
        }
    }
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
