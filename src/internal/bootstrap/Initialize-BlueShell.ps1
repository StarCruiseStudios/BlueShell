# -----------------------------------------------------------------------------
# <copyright file="Initialize-BlueShell.ps1" company="Star Cruise Studios LLC">
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

Write-Host "Bootstrapping..."

. $BlueShellRoot/internal/bootstrap/Import-AutoScripts.ps1
. Import-AutoScripts $BlueShellRoot/internal/blueshell

$global:BlueShellExtensions = [System.Collections.ArrayList]::new()
. Import-AutoScripts $BlueShellExtensionRoot

$extensionsToImport = [System.Collections.ArrayList]::new($global:BlueShellExtensions)
foreach ($extension in $extensionsToImport) {
    . Import-AutoScripts $extension
}

Write-Host "...Finished Bootstrapping."
