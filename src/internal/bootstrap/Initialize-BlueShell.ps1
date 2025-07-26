# ------------------------------------------------------------------------------
# <copyright file="Initialize-BlueShell.ps1" company="Star Cruise Studios LLC">
#     Copyright 2022 Star Cruise Studios LLC.
#
#     Licensed under the Apache License, Version 2.0 (the "License");
#     you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at
#
#     http: //www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.
# </copyright>
# ------------------------------------------------------------------------------

Function Write-Message(
    [String] $Message, 
    [ConsoleColor] $ForegroundColor = [ConsoleColor]::White,
    [switch] $NoNewLine
) {
    if ($env:BlueShellQuietMode -ne "True") {
        Write-Host "$Message" -ForegroundColor $ForegroundColor -NoNewLine:$NoNewLine
    }
}

Export-ModuleMember -Function 'Write-Message'

Write-Host "BlueShellQuietMode:" -ForegroundColor Blue -NoNewLine
Write-Host "$($env:BlueShellQuietMode -eq $true)" -ForegroundColor Cyan
Write-Message "Bootstrapping..."

# Load Bootstrapping scripts.
. $BlueShellRoot/internal/bootstrap/Write-AutoScriptImport.ps1
. $BlueShellRoot/internal/bootstrap/Import-AutoScripts.ps1

# Import Blueshell scripts.
. Import-AutoScripts $BlueShellRoot/internal/env
. Import-AutoScripts $BlueShellRoot/internal/blueshell

# Create/Load Machine Config.
Set-ReadOnly BlueShellMachineConfig "$BlueShellRoot\machine_config.ps1"
if (-not (Test-Path $BlueShellMachineConfig)) {
    Write-Message "No Machine Config found at $BlueShellMachineConfig. Creating..."
    New-Item -Path $BlueShellMachineConfig -ItemType File -Force -Value ""
}

Write-AutoScriptImport $BlueShellMachineConfig
. $BlueShellMachineConfig
Update-MachineConfig

# Import extensions.
if (Test-Path $BlueShellExtensionRoot) {
    $global:BlueShellExtensions = [System.Collections.ArrayList]::new()
    . Import-AutoScripts $BlueShellExtensionRoot

    foreach ($extension in $global:BlueShellExtensions) {
        . Import-AutoScripts $extension
    }
} else {
    Write-Message "No Extensions Found."
}

Write-Message "...Finished Bootstrapping."
