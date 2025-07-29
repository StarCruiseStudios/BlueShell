# ------------------------------------------------------------------------------
# <copyright file="Test-CommandExists.blueshell.ps1" company="Star Cruise Studios LLC">
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
Tests if a command exists in the current PowerShell session.

.DESCRIPTION
Checks whether a given command (cmdlet, function, alias, or executable) exists
and is accessible in the current PowerShell session. This is useful for
validating prerequisites or checking if specific tools are installed.

.PARAMETER command
The name of the command to check for. This can be:
- A PowerShell cmdlet or function name
- An executable name that exists in the system PATH
- A PowerShell alias

.EXAMPLE
# Check if git is installed
if (Test-CommandExists 'git') {
    Write-Host "Git is installed"
} else {
    Write-Host "Git is not installed"
}

.EXAMPLE
# Check if a PowerShell cmdlet exists
Test-CommandExists 'Get-Process'
# Output: True

.INPUTS
None. This function does not accept pipeline input.

.OUTPUTS
System.Boolean. Returns $True if the command exists, $False otherwise.

.NOTES
The function uses Get-Command internally with error suppression for clean output.
#>

Function Test-CommandExists(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $command
) {
    try {
        $output = Get-Command $command -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

Export-ModuleMember -Function "Test-CommandExists"
