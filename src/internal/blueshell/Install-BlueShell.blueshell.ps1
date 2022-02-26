# -----------------------------------------------------------------------------
# <copyright file="Install-BlueShell.blueshell.ps1" company="Star Cruise Studios LLC">
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
# -----------------------------------------------------------------------------
<#
.SYNOPSIS
Installs BlueShell.

.DESCRIPTION
Configures BlueShell to start up with the scripting environment.

.INPUTS
None. Piped values are not used.

.OUTPUTS
None
#>
Function Install-BlueShell {
    if ($IsMacOS) {
        if (!(Test-Path "~/.zprofile")) {
            New-Item -Path "~/.zprofile" -Type File -Force
            Add-Content "~/.zprofile" "pwsh"
        }
    }

    if (!(Test-Path $Profile.CurrentUserAllHosts)) {
        New-Item -Path $Profile.CurrentUserAllHosts -Type File -Force
        Add-Content $Profile.CurrentUserAllHosts "Import-Module $BlueShellRoot/Enter-BlueShell.psm1 -force"
    }
}

Export-ModuleMember -Function 'Install-BlueShell'
