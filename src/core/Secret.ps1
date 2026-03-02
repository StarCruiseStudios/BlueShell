# Secret.ps1 - Secret store and access; BlueShell.SecretNotInitialized (Spec §5.2, §13)
# Dot-sourced from Invoke-FourPhase.ps1. Used by *.secret.auto.ps1 scripts.

$script:BlueShellSecrets = @{}

function Set-BlueShellSecret {
    <#
    .SYNOPSIS
        Set a secret value (used by *.secret.auto.ps1 scripts).
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Key, [Parameter(Mandatory)][string]$Value)
    $script:BlueShellSecrets[$Key] = $Value
}

function Get-BlueShellSecret {
    <#
    .SYNOPSIS
        Get a secret value. Throws BlueShell.SecretNotInitialized if key was never set (Spec §13).
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Key)
    if (-not $script:BlueShellSecrets.ContainsKey($Key)) {
        $msg = "Secret '$Key' was never initialized. Add the key to your secret file (*.secret.auto.ps1) or set env $Key."
        $ex = [System.Exception]::new($msg)
        $err = [System.Management.Automation.ErrorRecord]::new($ex, 'BlueShell.SecretNotInitialized', 'NotSpecified', $Key)
        throw $err
    }
    return $script:BlueShellSecrets[$Key]
}

function Test-BlueShellSecret {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Key)
    return $script:BlueShellSecrets.ContainsKey($Key)
}
