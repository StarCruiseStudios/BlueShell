# ------------------------------------------------------------------------------
# <copyright file="Test-MachineUser.blueshell.ps1" company="Star Cruise Studios LLC">
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
    Tests if the specified user matches the BlueShell user.

.PARAMETER User
    The user to test.

.EXAMPLE
    Test-MachineUser -User 'JohnDoe'
#>
Function Test-MachineUser(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String] $User
) {
    if (-not (Get-Variable -Name 'BlueShellUser' -Scope Global -ErrorAction SilentlyContinue)) {
        Write-Warning "BlueShellUser global variable is not defined"
        return $false
    }
    
    return $BlueShellUser -eq $User
}

Export-ModuleMember -Function 'Test-MachineUser'
