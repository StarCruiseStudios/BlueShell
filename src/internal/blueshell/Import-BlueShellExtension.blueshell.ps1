# -----------------------------------------------------------------------------
# <copyright file="Import-BlueShellExtension.blueshell.ps1" company="Star Cruise Studios LLC">
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
# -----------------------------------------------------------------------------

<#
.SYNOPSIS
Imports a directory as a BlueShell extension.

.DESCRIPTION
Imports the directory at the provided path as a BlueShell extension that will 
automatically get imported when starting BlueShell.

.PARAMETER ExtensionName
The name of the extension.

.PARAMETER ExtensionPath
The path of the extension root. Defaults to the current directory.

.INPUTS
None. Piped values are not used.

.OUTPUTS
The newly created extension import file.
#>
Function Import-BlueShellExtension(
    [String] $ExtensionName,
    [String] $ExtensionPath = "."
) {
    $fileName = "Import-${ExtensionName}BlueShell.blueshell.ps1"
    $filePath = "${BlueShellExtensionRoot}/${fileName}"

    $extensionRoot = (Resolve-Path $ExtensionPath).path

    $contents = @"
#
# Import BlueShell Extension $ExtensionName
#   Imported using `ImportBlueShellExtension`
#   BlueShell V$BlueShellVersion
#

`$global:BlueShellExtensions.Add("${extensionRoot}")

"@

    New-Item $filePath -ItemType File -Value $contents
}

Export-ModuleMember -Function 'Import-BlueShellExtension'
