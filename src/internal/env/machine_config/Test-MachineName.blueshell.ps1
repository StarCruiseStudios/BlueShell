# ------------------------------------------------------------------------------
# <copyright file="Test-MachineName.blueshell.ps1" company="Star Cruise Studios LLC">
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
    Tests if the specified machine name matches the current Blue Shell machine
    name.
.DESCRIPTION
    The Test-MachineName function tests if the specified machine name matches
    the current machine name.
.PARAMETER Name
    The name of the machine to test.
.EXAMPLE
    PS C:\> Test-MachineName -Name "MyComputer"
    True
#>
Function Test-MachineName(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String] $Name
) {
    if (-not (Get-Variable -Name 'BlueShellMachineName' -Scope Global -ErrorAction SilentlyContinue)) {
        Write-Warning "BlueShellMachineName global variable is not defined"
        return $false
    }

    return $BlueShellMachineName -eq $Name
}

Export-ModuleMember -Function 'Test-MachineName'
