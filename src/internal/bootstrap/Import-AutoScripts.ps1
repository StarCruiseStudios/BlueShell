# ------------------------------------------------------------------------------
# <copyright file="Import-AutoScripts.ps1" company="Star Cruise Studios LLC">
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

. $BlueShellRoot/internal/bootstrap/Write-AutoScriptImport.ps1
Write-AutoScriptImport "Import-AutoScripts"

<#
.SYNOPSIS
Automatically imports scripts in a given directory.

.DESCRIPTION
Automatically imports scripts in a given directory. This will recursively search
through the given directory for scripts with a given extension and dot sources
them.

.PARAMETER RootDir
The root directory to recursively search through.

.PARAMETER Extension
The file extension of the files to import. Defaults to ".blueshell.ps1".

.INPUTS
The value from the pipeline is used as the $RootDir parameter.

.OUTPUTS
No value is output.
#>
Function Import-AutoScripts {
    param(
        [Parameter(ValueFromPipeline=$true)]
        [String] $RootDir, 
        [Parameter()]
        [String] $Extension = ".blueshell.ps1"
    )

    $childScripts = get-childitem $RootDir\*$Extension -recurse -force
    foreach ($child in $childScripts) {
        Write-AutoScriptImport $child
        . $child
    }
}
