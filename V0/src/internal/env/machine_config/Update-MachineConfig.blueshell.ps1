# ------------------------------------------------------------------------------
# <copyright file="Update-MachineConfig.blueshell.ps1" company="Star Cruise Studios LLC">
#     Copyright 2023 Star Cruise Studios LLC.
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
Updates the machine configuration file for BlueShell.

.DESCRIPTION
This function updates the machine configuration variables for BlueShell.

.EXAMPLE
Update-MachineConfig

This example updates the machine configuration variables for BlueShell.
#>
Function Update-MachineConfig() {
    $updated = $false
    if (-not (Test-GlobalVariableExists 'BlueShellMachineName')) {
        Add-MachineConfigVariable "BlueShellMachineName" "BlueShell"
        $updated = $true
    }

    if (-not (Test-GlobalVariableExists 'BlueShellUser')) {
        Add-MachineConfigVariable "BlueShellUser" "BlueShell"
        $updated = $true
    }

    if (-not (Test-GlobalVariableExists 'BlueShellMachineConfigVersion')) {
        Add-MachineConfigVariable "BlueShellMachineConfigVersion" $BlueShellVersion
        $updated = $true
    } else {
        if ($BlueShellMachineConfigVersion -lt $BlueShellVersion) {
            Update-MachineConfigVariable "BlueShellMachineConfigVersion" $BlueShellVersion
            $updated = $true
        }
    }

    return $updated
}

Export-ModuleMember -Function 'Update-MachineConfig'
