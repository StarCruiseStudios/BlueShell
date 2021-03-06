# ------------------------------------------------------------------------------
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
# ------------------------------------------------------------------------------

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
        # Configure zprofile to start up Powershell.
        if (!(Test-Path "~/.zprofile")) {
            New-Item -Path "~/.zprofile" -Type File -Force
        }

        $installedOnZProfile = (Select-String -Path "~/.zprofile" -Pattern "pwsh" -SimpleMatch -Quiet)
        if (-not $installedOnZProfile) {
            Add-Content "~/.zprofile" "pwsh"
        }
    }

    # Configure the currentUserAllHosts profile to define the `Start-BlueShell`
    # command. This will allow BlueShell to be started at any time, from any 
    # host, but only when explicitly wanted.
    if (-not (Test-Path $Profile.CurrentUserAllHosts)) {
        New-Item -Path $Profile.CurrentUserAllHosts -Type File -Force
    }

    $installedOnAllHosts = (Select-String -Path $Profile.CurrentUserAllHosts -Pattern "Function Start-BlueShell" -SimpleMatch -Quiet)
    if (-not $installedOnAllHosts) {
        Add-Content $Profile.CurrentUserAllHosts @"
Function Start-BlueShell() {
    Import-Module $BlueShellRoot\BlueShell.psm1 -Force -Global
}
"@
    }

    # Configure the currentUserCurrentHost profile to invoke `Start-BlueShell`.
    if (-not (Test-Path $Profile.CurrentUserCurrentHost)) {
        New-Item -Path $Profile.CurrentUserCurrentHost -Type File -Force
    }
    $installedOnCurrentHost = (Select-String -Path $Profile.CurrentUserCurrentHost -Pattern "Start-BlueShell" -SimpleMatch -Quiet)
    if (-not $installedOnCurrentHost) {
        Add-Content $Profile.CurrentUserCurrentHost @"
Start-BlueShell
"@
    }
}

Export-ModuleMember -Function 'Install-BlueShell'
