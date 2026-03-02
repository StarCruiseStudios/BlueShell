# Load-Config.ps1 - Bootstrap: set config dir, load config, apply env mirror (Spec §3)
# Dot-sourced from BlueShell.psm1. If $env:BLUESHELL_CONFIG_DIR is set before load, it is used (for tests).

. (Join-Path $PSScriptRoot 'Config.ps1')

# Allow tests to override config dir by setting env before module load
if ($env:BLUESHELL_CONFIG_DIR) {
    $script:BlueShellConfigDir = $env:BLUESHELL_CONFIG_DIR
}

Initialize-BlueShellConfigStore

function Update-BlueShellEnvMirror {
    <#
    .SYNOPSIS
        Set environment variables to mirror config (Spec §3.5). Called during bootstrap and after config/preset change.
    #>
    [CmdletBinding()]
    param()
    $dir = Get-BlueShellConfigDir
    $env:BLUESHELL_CONFIG_DIR = $dir
    $env:BLUESHELL_VERSION = $script:BlueShellVersion
    if (-not $env:BLUESHELL_ROOT) { $env:BLUESHELL_ROOT = (Get-BlueShellRoot) }
    $preset = Get-BlueShellConfig -Key 'activePreset'
    $env:BLUESHELL_ACTIVE_PRESET = if ($preset) { $preset } else { '' }
    $moduleRoots = Get-BlueShellConfig -Key 'moduleRoots'
    if (-not $moduleRoots) { $moduleRoots = @{} }
    $sep = if ($env:OS -eq 'Windows_NT') { ';' } else { ':' }
    $env:BLUESHELL_MODULE_ROOTS = ($moduleRoots.Values | Where-Object { $_ }) -join $sep
    foreach ($key in $moduleRoots.Keys) {
        $safeName = $key -replace '[^a-zA-Z0-9]', '_'
        Set-Item -Path "env:BLUESHELL_MODULE_$safeName" -Value $moduleRoots[$key]
    }
    # Interactive/Quiet: only set if not already set so external scripts can pre-configure
    if (-not (Test-Path 'env:BLUESHELL_INTERACTIVE')) { $env:BLUESHELL_INTERACTIVE = '' }
    if (-not (Test-Path 'env:BLUESHELL_QUIET')) { $env:BLUESHELL_QUIET = '' }
    # Baseline PATH and psm1 path for Reload-BlueShell (Spec §7)
    if (-not $env:BLUESHELL_PATH_BASELINE) { $env:BLUESHELL_PATH_BASELINE = $env:PATH }
    $env:BLUESHELL_PSM1_PATH = Join-Path (Get-BlueShellRoot) 'BlueShell.psm1'
}

# Version when no manifest (T017/Phase 2 may add manifest)
$script:BlueShellVersion = '0.1.0'
Update-BlueShellEnvMirror
