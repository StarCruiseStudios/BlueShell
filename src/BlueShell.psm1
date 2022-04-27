# ------------------------------------------------------------------------------
# <copyright file="BlueShell.psm1" company="Star Cruise Studios LLC">
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

Set-Variable BlueShellRoot -Value $PSScriptRoot -Force -Option ReadOnly -Scope:Global
Set-Variable BlueShellVersion -Value "0.0.3-220426" -Force -Option ReadOnly -Scope:Global
Set-Variable BlueShellBranch -Value "main" -Force -Option ReadOnly -Scope:Global
Set-Variable BlueShellExtensionRoot -Value $BlueShellRoot/extensions

. $BlueShellRoot/internal/bootstrap/Initialize-BlueShell.ps1

Write-BlueShellBanner

Write-KeyValue BlueShellRoot $BlueShellRoot
Write-KeyValue BlueShellVersion $BlueShellVersion
Write-KeyValue BlueShellBranch $BlueShellBranch

Export-ModuleMember -Variable 'BlueShellRoot'
Export-ModuleMember -Variable 'BlueShellVersion'
Export-ModuleMember -Variable 'BlueShellBranch'
