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

Function Invoke-BlueShellCommand(
    [Parameter(Mandatory=$true)][string] $Command,
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
