# BlueShell.psm1 - Base module entry point (Spec §1, §11)
# Requires PowerShell 7. Load via: Import-Module .\src\BlueShell.psm1 -Force

$script:BlueShellRoot = $PSScriptRoot

function Get-BlueShellRoot {
    <#
    .SYNOPSIS
        Returns the base BlueShell module root (directory containing BlueShell.psm1).
    #>
    [CmdletBinding()]
    param()
    return $script:BlueShellRoot
}

# Bootstrap: load config and env, then run four-phase auto-load (filled in T011, T012)
$configPath = Join-Path $script:BlueShellRoot 'config'
$corePath   = Join-Path $script:BlueShellRoot 'core'
if (Test-Path (Join-Path $configPath 'Load-Config.ps1')) {
    . (Join-Path $configPath 'Load-Config.ps1')
}
if (Test-Path (Join-Path $corePath 'Topic.ps1')) {
    . (Join-Path $corePath 'Topic.ps1')
}
if (Test-Path (Join-Path $corePath 'RulesSkills.ps1')) {
    . (Join-Path $corePath 'RulesSkills.ps1')
}
if (Test-Path (Join-Path $corePath 'Setup.ps1')) {
    . (Join-Path $corePath 'Setup.ps1')
}
if (Test-Path (Join-Path $corePath 'Reload.ps1')) {
    . (Join-Path $corePath 'Reload.ps1')
}
if (Test-Path (Join-Path $corePath 'Interactive.ps1')) {
    . (Join-Path $corePath 'Interactive.ps1')
}
if (Test-Path (Join-Path $corePath 'Invoke-FourPhase.ps1')) {
    . (Join-Path $corePath 'Invoke-FourPhase.ps1')
    Invoke-FourPhaseLoad
}
Show-BlueShellBanner

Export-ModuleMember -Function 'Get-BlueShellRoot', 'Get-BlueShellConfig', 'Set-BlueShellConfig', 'Set-BlueShellSecret', 'Get-BlueShellSecret', 'Test-BlueShellSecret', 'Register-BlueShellTopic', 'Register-BlueShellTopicProvider', 'Get-BlueShellTopicData', 'Register-BlueShellTopicSubscription', 'Publish-BlueShellTopicEvent', 'Enable-BlueShellInteractive', 'Test-BlueShellInteractive', 'Reload-BlueShell', 'Set-BlueShellComponentRoot', 'Switch-BlueShellEnvironment', 'Get-BlueShellAgentRules', 'Get-BlueShellAgentSkills', 'Enable-BlueShellAgentRules', 'Disable-BlueShellAgentRules', 'Enable-BlueShellAgentSkills', 'Disable-BlueShellAgentSkills', 'Get-BlueShellCursorSkillsPath', 'Install-BlueShell', 'Install-DevEnvironment'
