# ------------------------------------------------------------------------------
# <copyright file="Update-BlueShell.blueshell.ps1" company="Star Cruise Studios LLC">
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

<#
.SYNOPSIS
Reloads the BlueShell environment.

.DESCRIPTION
Reloads the blueshell environment by re-importing the module.

.INPUTS
None. Piped values are not used.

.OUTPUTS
No value is output.
#>
Function Update-BlueShell {
    try {
        $moduleFile = Join-Path $BlueShellRoot "BlueShell.psm1"
        if (-not (Test-Path $moduleFile)) {
            throw "BlueShell module file not found at: $moduleFile"
        }
        
        Import-Module $moduleFile -Force -Global
    }
    catch {
        Write-Error "Failed to update BlueShell: $($_.Exception.Message)"
        throw
    }
}
Set-Alias -Name reload -Value Update-BlueShell

Export-ModuleMember -Function 'Update-BlueShell' -Alias 'reload'