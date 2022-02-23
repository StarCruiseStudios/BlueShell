# ------------------------------------------------------------------------------
# <copyright file="Set-ReadOnly.blueshell.ps1" company="Star Cruise Studios LLC">
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
Sets a read only variable.

.DESCRIPTION
Sets a read only variable in the global scope. A read only variable cannot be 
accidentally overwritten using the $Variable notation, but can be re-written
by invoking the Set-ReadOnly function a second time.

.PARAMETER Name
The name of the variable.

.PARAMETER Value
The value to display

.INPUTS
None. Piped values are not used.

.OUTPUTS
No value is output.
#>
Function Set-ReadOnly(
    [String] $Name, 
    [String] $Value
) {
    Set-Variable $Name -Value $Value -Force -Option ReadOnly -Scope:Global
    $var = Get-Variable $Name
    Write-KeyValue $var.Name $var.Value
}

Export-ModuleMember -Function 'Set-ReadOnly'
