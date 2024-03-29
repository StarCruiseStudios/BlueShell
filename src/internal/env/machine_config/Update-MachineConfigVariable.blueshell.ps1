# ------------------------------------------------------------------------------
# <copyright file="Update-MachineConfigVariable.blueshell.ps1" company="Star Cruise Studios LLC">
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
Updates a machine configuration variable.

.DESCRIPTION
This function updates a machine configuration variable by modifying the 
BlueShell machine configuration file.

.PARAMETER Name
The name of the machine configuration variable to update.

.PARAMETER NewValue
The new value to set for the machine configuration variable.

.EXAMPLE
Update-MachineConfigVariable -Name "MyVariable" -NewValue "NewValue"

This example updates the value of the "MyVariable" machine configuration 
variable to "NewValue".
#>
Function Update-MachineConfigVariable([String] $Name, [String] $NewValue) {
    Write-Message "Updating $Name : $NewValue"
    $content = Get-Content -Path $BlueShellMachineConfig
    $regex = "^Set-ReadOnly $Name .*$"
    $content | ForEach-Object {
        if ($_ -match $regex) {
            $_ -replace $regex, "Set-ReadOnly $Name ""$NewValue"""
        } else {
            $_
        }
    } | Set-Content -Path $BlueShellMachineConfig
    Set-ReadOnly $Name "$NewValue"
}

Export-ModuleMember -Function 'Update-MachineConfigVariable'
