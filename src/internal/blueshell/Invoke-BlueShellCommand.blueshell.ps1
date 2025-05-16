# ------------------------------------------------------------------------------
# <copyright file="Invoke-BlueShellCommand.blueshell.ps1" company="Star Cruise Studios LLC">
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
Executes a command while displaying it to the console.

.DESCRIPTION
Executes a PowerShell command while displaying it to the console with formatting.
This is particularly useful for do-nothing scripts where you want to show the
operator what command is being executed. The command is displayed with visual
separators and optional working directory information.

.PARAMETER Command
The PowerShell command to execute. This parameter is mandatory.

.PARAMETER WorkingDirectory
Optional. The directory to execute the command in. If specified, the function will:
1. Change to this directory before executing the command
2. Display the working directory in the output
3. Return to the original directory after execution

.EXAMPLE
# Execute a simple command
Invoke-BlueShellCommand 'Write-Host "Hello World"'
# Output:
# ----------
# Write-Host "Hello World"
# ----------
# Hello World

.EXAMPLE
# Execute a command in a specific directory
Invoke-BlueShellCommand 'Get-ChildItem' 'C:\temp'
# Output:
# ----------
# Get-ChildItem
#   > C:\temp
# ----------
# [directory contents...]

.INPUTS
None. This function does not accept pipeline input.

.OUTPUTS
Returns the output of the executed command.

.NOTES
The command is executed using Invoke-Expression, so proper care should be taken
with the command input to avoid security risks.
#>

Function Invoke-BlueShellCommand(
    [Parameter(Mandatory = $true)][string] $Command,
    [string] $WorkingDirectory = ""
) {
    $workingDirectorySpecified = $WorkingDirectory.Length -gt 0

    Write-Host -ForegroundColor Blue "----------"
    Write-Host -ForegroundColor DarkCyan $Command
    if ($workingDirectorySpecified) { 
        $originalLocation = $PWD.Path
        Set-Location -Path $WorkingDirectory
        Write-Host -ForegroundColor DarkBlue ("  > " + $WorkingDirectory)
    }
    Write-Host -ForegroundColor Blue "----------"

    Invoke-Expression $Command
    
    if ($workingDirectorySpecified) { 
        Set-Location -Path $originalLocation
    }
}

Export-ModuleMember -Function "Invoke-BlueShellCommand"
