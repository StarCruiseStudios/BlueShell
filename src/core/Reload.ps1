# Reload.ps1 - Update-BlueShell (alias Reload-BlueShell), Set-BlueShellComponentRoot, Switch-BlueShellEnvironment (Spec §7)

function Update-BlueShell {
    <#
    .SYNOPSIS
        Reload BlueShell: remove module, reset PATH to baseline, re-import. Idempotent, quiet (Spec §7).
    .NOTES
        Exported as approved verb; use Reload-BlueShell alias for backward compatibility.
    #>
    [CmdletBinding()]
    param()
    $basePath = $env:BLUESHELL_PATH_BASELINE
    $psm1Path = $env:BLUESHELL_PSM1_PATH
    if (-not $psm1Path -or -not (Test-Path $psm1Path)) {
        Write-Error "BLUESHELL_PSM1_PATH not set or file missing; cannot reload."
        return
    }
    Remove-Module BlueShell -Force -ErrorAction SilentlyContinue
    if ($basePath) { $env:PATH = $basePath }
    Import-Module $psm1Path -Force -Global
}

# Backward compatibility: approved verb is Update; Reload is the conventional name (Spec §7).
New-Alias -Name Reload-BlueShell -Value Update-BlueShell -Force

function Set-BlueShellComponentRoot {
    <#
    .SYNOPSIS
        Set the path for a component (e.g. module) and reload BlueShell (Spec §7).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ComponentName,
        [Parameter(Mandatory)][string]$Path
    )
    $mr = Get-BlueShellConfig -Key 'moduleRoots'
    if (-not $mr) { $mr = @{} }
    $mr[$ComponentName] = $Path
    Set-BlueShellConfig -Key 'moduleRoots' -Value $mr
    Update-BlueShell
}

function Switch-BlueShellEnvironment {
    <#
    .SYNOPSIS
        Apply a preset from presets.json and reload BlueShell (Spec §7).
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$PresetName)
    $presets = Get-BlueShellPresets
    if (-not $presets.ContainsKey($PresetName)) {
        Write-Error "Preset '$PresetName' not found in presets.json."
        return
    }
    $preset = $presets[$PresetName]
    $mr = @{}
    if ($preset -is [hashtable]) {
        $mr = $preset
    } else {
        $preset.PSObject.Properties | ForEach-Object { $mr[$_.Name] = $_.Value }
    }
    Set-BlueShellConfig -Key 'moduleRoots' -Value $mr
    Set-BlueShellConfig -Key 'activePreset' -Value $PresetName
    Update-BlueShell
}
