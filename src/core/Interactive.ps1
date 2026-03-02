# Interactive.ps1 - Quiet by default, interactive opt-in (Spec §4)

function Test-BlueShellInteractive {
    <#
    .SYNOPSIS
        Returns true when interactive mode is enabled (banner and loading messages).
    #>
    [CmdletBinding()]
    param()
    if ($env:BLUESHELL_QUIET -match '^(1|true|yes)$') { return $false }
    return ($env:BLUESHELL_INTERACTIVE -match '^(1|true|yes)$')
}

function Enable-BlueShellInteractive {
    <#
    .SYNOPSIS
        Enable interactive mode for the current session (banner, loading messages). Typically called from profile.
    #>
    [CmdletBinding()]
    param()
    $env:BLUESHELL_INTERACTIVE = 'true'
}

function Show-BlueShellBanner {
    [CmdletBinding()]
    param()
    if (-not (Test-BlueShellInteractive)) { return }
    $v = $env:BLUESHELL_VERSION
    Write-Host "BlueShell $v loaded. (quiet by default; use Enable-BlueShellInteractive in profile for interactive.)" -ForegroundColor Cyan
}
