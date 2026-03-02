# ------------------------------------------------------------------------------
# <copyright file="Add-MachineConfigVariable.blueshell.ps1" company="Star Cruise Studios LLC">
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
Adds a new variable to the BlueShell machine configuration file.

.DESCRIPTION
The Add-MachineConfigVariable function adds a new variable to the BlueShell
machine configuration file.

.PARAMETER Name
The name of the variable to add.

.PARAMETER Value
The value of the variable to add.

.EXAMPLE
Add-MachineConfigVariable -Name "MyVariable" -Value "MyValue"

This example adds a new variable named "MyVariable" with a value of "MyValue" to
the BlueShell machine configuration file.
#>
Function Add-MachineConfigVariable([String] $Name, [String] $Value) {
    Write-Message "Adding $Name : $Value"
    Add-Content -Path $BlueShellMachineConfig -Value "Set-ReadOnly $Name ""$Value"""
    Set-ReadOnly $Name "$Value"
}

Export-ModuleMember -Function 'Add-MachineConfigVariable'
