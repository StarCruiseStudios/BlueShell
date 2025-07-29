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

.PARAMETER silent
If specified, suppresses the automatic display of the variable name and value
after setting it.

.EXAMPLE
# Basic usage
Set-ReadOnly "MaxRetries" "3"
# Output: MaxRetries: 3

.EXAMPLE
# Silent mode
Set-ReadOnly "ApiKey" "secret123" -silent
# No output

.EXAMPLE
# Attempting to modify a readonly variable
Set-ReadOnly "Version" "1.0.0"
$Version = "2.0.0"  # This will fail with an error
# Error: Cannot overwrite variable Version because it is read-only or constant.

.INPUTS
None. Piped values are not used.

.OUTPUTS
No value is output. If -silent is not specified, the variable name and value
are displayed to the host.

.NOTES
Variables set with this function can still be modified by calling Set-ReadOnly
again with a new value. This allows for updating configuration while preventing
accidental modifications.
#>
Function Set-ReadOnly(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String] $Name, 
    
    [Parameter(Mandatory = $true)]
    [AllowEmptyString()]
    [String] $Value,
    
    [Switch] $silent
) {
    try {
        Set-Variable $Name -Value $Value -Force -Option ReadOnly -Scope:Global
        
        if (!$silent) {
            $var = Get-Variable $Name
            Write-KeyValue $var.Name $var.Value
        }
    }
    catch {
        Write-Error "Failed to set read-only variable '$Name': $($_.Exception.Message)"
        throw
    }
}

Export-ModuleMember -Function 'Set-ReadOnly'
