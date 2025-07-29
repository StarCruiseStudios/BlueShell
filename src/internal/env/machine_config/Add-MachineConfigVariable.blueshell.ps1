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
Function Add-MachineConfigVariable(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String] $Name, 
    
    [Parameter(Mandatory = $true)]
    [AllowEmptyString()]
    [String] $Value
) {
    try {
        # Create the config file and directory if they don't exist
        $configDir = Split-Path $BlueShellMachineConfig -Parent
        if (-not (Test-Path $configDir)) {
            New-Item -Path $configDir -ItemType Directory -Force | Out-Null
        }
        
        if (-not (Test-Path $BlueShellMachineConfig)) {
            New-Item -Path $BlueShellMachineConfig -ItemType File -Force | Out-Null
        }
        
        Write-Message "Adding $Name : $Value"
        Add-Content -Path $BlueShellMachineConfig -Value "Set-ReadOnly $Name ""$Value"""
        Set-ReadOnly $Name "$Value"
    }
    catch {
        Write-Error "Failed to add machine config variable '$Name': $($_.Exception.Message)"
        throw
    }
}

Export-ModuleMember -Function 'Add-MachineConfigVariable'
