# ------------------------------------------------------------------------------
# <copyright file="Write-AutoScriptImport.ps1" company="Star Cruise Studios LLC">
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
Displays a message indicating an autoscript file was imported.

.DESCRIPTION
Displays a message indicating that an autoscript file was imported via a 
BlueShell script. This is an internal script used to provide a consistent 
appearance to the BlueShell auto script imports.

.INPUTS
None. Piped values are not used.

.OUTPUTS
No value is output. The message is sent directly to the host.
#>
Function Write-AutoScriptImport([String] $FileName) {
    Write-Message "Loading - " -ForegroundColor Blue -NoNewline
    Write-Message $FileName -ForegroundColor Green
}
