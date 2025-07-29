# ------------------------------------------------------------------------------
# <copyright file="New-BlueShellExtension.blueshell.ps1" company="Star Cruise Studios LLC">
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
Creates a BlueShell extension from the given directory.

.DESCRIPTION
Creates a BlueShell extension from the directory at the provided path. The 
*.blueshell.ps1 scripts in the directory will automatically get imported when
starting BlueShell.

.PARAMETER ExtensionName
The name of the extension.

.PARAMETER ExtensionPath
The path of the extension root. Defaults to the current directory.

.INPUTS
None. Piped values are not used.

.OUTPUTS
The newly created extension import file.
#>
Function New-BlueShellExtension(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String] $ExtensionName,
    
    [ValidateNotNullOrEmpty()]
    [String] $ExtensionPath = "."
) {
    try {
        if (-not (Test-Path $ExtensionPath)) {
            throw "Extension path '$ExtensionPath' does not exist"
        }
        
        $fileName = "Import-${ExtensionName}BlueShell.blueshell.ps1"
        $filePath = Join-Path $BlueShellExtensionRoot $fileName

        $extensionRoot = (Resolve-Path $ExtensionPath).Path

        $contents = @"
#
# Import BlueShell Extension $ExtensionName
#   Imported using New-BlueShellExtension
#   BlueShell V$BlueShellVersion
#

`$global:BlueShellExtensions.Add("${extensionRoot}")

"@

        New-Item $filePath -ItemType File -Value $contents -Force
        return Get-Item $filePath
    }
    catch {
        Write-Error "Failed to create BlueShell extension '$ExtensionName': $($_.Exception.Message)"
        throw
    }
}

Export-ModuleMember -Function 'New-BlueShellExtension'
