# Invoke-FourPhase.ps1 - Four-phase auto-load (Spec §5)
# Dot-sourced from BlueShell.psm1. Runs env -> secret -> bootstrap -> init for base then extensions.

. (Join-Path $PSScriptRoot 'Secret.ps1')

# Configurable step list and order (Spec §5.1)
$script:BlueShellPhaseSteps = @('env', 'secret', 'bootstrap', 'init')

function Get-BlueShellPhaseSteps { return $script:BlueShellPhaseSteps }
function Set-BlueShellPhaseSteps { param([string[]]$Steps) $script:BlueShellPhaseSteps = $Steps }

function Get-BlueShellPhaseScripts {
    param([string]$Root, [string]$StepName)
    if (-not (Test-Path $Root)) { return @() }
    $filter = "*.$StepName.auto.ps1"
    Get-ChildItem -Path $Root -Recurse -Filter $filter -File -ErrorAction SilentlyContinue | Sort-Object FullName
}

function Invoke-FourPhaseLoad {
    $baseRoot = Get-BlueShellRoot
    $moduleRoots = Get-BlueShellConfig -Key 'moduleRoots'
    if (-not $moduleRoots) { $moduleRoots = @{} }
    $extensionRoots = @($moduleRoots.Values | Where-Object { $_ -and (Test-Path $_) })

    foreach ($step in $script:BlueShellPhaseSteps) {
        # Base: all scripts for this step under base src/
        $baseScripts = Get-BlueShellPhaseScripts -Root $baseRoot -StepName $step
        foreach ($f in $baseScripts) {
            try { . $f.FullName } catch { throw }
        }
    }
    foreach ($step in $script:BlueShellPhaseSteps) {
        # Extensions: all scripts for this step under each module root
        foreach ($extRoot in $extensionRoots) {
            $extScripts = Get-BlueShellPhaseScripts -Root $extRoot -StepName $step
            foreach ($f in $extScripts) {
                try { . $f.FullName } catch { throw }
            }
        }
    }
}
