# ------------------------------------------------------------------------------
# <copyright file="Test-GlobalVariableExists.blueshell.ps1" company="Star Cruise Studios LLC">
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
    Tests if a variable with the given name is defined in the global scope.

.PARAMETER Name
    The name of the variable to test.

.EXAMPLE
    Test-GlobalVariableExists -Name "MyVariable"
    Returns True if a variable named "MyVariable" is defined in the global 
    scope.
#>
Function Test-GlobalVariableExists(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String] $Name
) {
    try {
        return (Get-Variable -Name $Name -Scope Global -ErrorAction SilentlyContinue) -ne $null
    }
    catch {
        return $false
    }
}

Export-ModuleMember -Function 'Test-GlobalVariableExists'
