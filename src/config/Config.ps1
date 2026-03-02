# Config.ps1 - Config directory resolution, config.json/presets.json, Get/Set-BlueShellConfig (Spec §3)
# Dot-sourced from Load-Config.ps1. Uses script-level vars set by Load-Config.

function Get-BlueShellConfigDir {
    <#
    .SYNOPSIS
        Returns the BlueShell config directory (~/.blueshell or override).
    .DESCRIPTION
        If $env:BLUESHELL_CONFIG_DIR is set before module load, that path is used (for tests).
        Otherwise: Windows uses $env:USERPROFILE\.blueshell, macOS/Linux use $HOME/.blueshell.
    #>
    [CmdletBinding()]
    param()
    if ($script:BlueShellConfigDir) { return $script:BlueShellConfigDir }
    if ($env:BLUESHELL_CONFIG_DIR) { return $env:BLUESHELL_CONFIG_DIR }
    $homeDir = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
    if (-not $homeDir) { throw "Cannot resolve home directory for config (USERPROFILE/HOME not set)." }
    return Join-Path $homeDir '.blueshell'
}

function Get-BlueShellConfig {
    <#
    .SYNOPSIS
        Get a config value by key (Spec §3.4).
    .PARAMETER Key
        Config key: moduleRoots, activePreset.
    .PARAMETER Name
        Alias for Key.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Key,
        [string]$Name
    )
    if ($Name) { $Key = $Name }
    $k = $Key
    if (-not $script:BlueShellConfig) { Initialize-BlueShellConfigStore }
    if (-not $script:BlueShellConfig.ContainsKey($k)) {
        if ($k -eq 'moduleRoots') { return @{} }
        return $null
    }
    return $script:BlueShellConfig[$k]
}

function Set-BlueShellConfig {
    <#
    .SYNOPSIS
        Set a config value and persist to config.json (Spec §3.4).
    .PARAMETER Key
        Config key: moduleRoots, activePreset.
    .PARAMETER Name
        Alias for Key.
    .PARAMETER Value
        Value; type is validated for known keys.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Key,
        [string]$Name,
        [Parameter(Mandatory)]
        [object]$Value
    )
    if ($Name) { $Key = $Name }
    $k = $Key
    $knownKeys = @{
        moduleRoots   = @('Hashtable', 'PSCustomObject')
        activePreset  = @('String', 'null')
    }
    if ($knownKeys.ContainsKey($k)) {
        $validTypes = $knownKeys[$k]
        $t = if ($null -eq $Value) { 'null' } else { $Value.GetType().Name }
        if ($Value -is [hashtable]) { $t = 'Hashtable' }
        if ($Value -is [PSCustomObject]) { $t = 'PSCustomObject' }
        if ($t -notin $validTypes) {
            throw "Invalid type for config key '$k'. Expected: $($validTypes -join ', ')."
        }
    }
    if (-not $script:BlueShellConfig) { Initialize-BlueShellConfigStore }
    $script:BlueShellConfig[$k] = $Value
    Save-BlueShellConfig
}

function Initialize-BlueShellConfigStore {
    $dir = Get-BlueShellConfigDir
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $configPath = Join-Path $dir 'config.json'
    $script:BlueShellConfig = @{}   # always start with empty; load from file if present
    if (Test-Path $configPath) {
        try {
            $json = Get-Content -Raw -Path $configPath -ErrorAction Stop
            $obj = $json | ConvertFrom-Json
            if ($obj.PSObject.Properties['moduleRoots']) {
                $mr = $obj.moduleRoots
                $ht = @{}
                if ($mr -is [hashtable]) { $script:BlueShellConfig['moduleRoots'] = $mr }
                else {
                    $mr.PSObject.Properties | ForEach-Object { $ht[$_.Name] = $_.Value }
                    $script:BlueShellConfig['moduleRoots'] = $ht
                }
            }
            if ($obj.PSObject.Properties['activePreset']) {
                $script:BlueShellConfig['activePreset'] = [string]$obj.activePreset
            }
        } catch {
            # Corrupt or empty; keep empty hashtable
        }
    }
    if (-not $script:BlueShellConfig.ContainsKey('moduleRoots')) {
        $script:BlueShellConfig['moduleRoots'] = @{}
    }
    if (-not $script:BlueShellConfig.ContainsKey('activePreset')) {
        $script:BlueShellConfig['activePreset'] = $null
    }
}

function Save-BlueShellConfig {
    $dir = Get-BlueShellConfigDir
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $configPath = Join-Path $dir 'config.json'
    $mr = $script:BlueShellConfig['moduleRoots']
    $ap = $script:BlueShellConfig['activePreset']
    $out = @{
        moduleRoots  = if ($mr -is [hashtable]) { $mr } else { @{} }
        activePreset = if ($null -ne $ap) { $ap } else { '' }
    }
    $out | ConvertTo-Json -Depth 10 | Set-Content -Path $configPath -Encoding utf8
}

function Get-BlueShellPresets {
    $dir = Get-BlueShellConfigDir
    $path = Join-Path $dir 'presets.json'
    if (-not (Test-Path $path)) { return @{} }
    try {
        $json = Get-Content -Raw -Path $path -ErrorAction Stop
        $obj = $json | ConvertFrom-Json
        $result = @{}
        $obj.PSObject.Properties | ForEach-Object { $result[$_.Name] = $_.Value }
        return $result
    } catch { return @{} }
}
