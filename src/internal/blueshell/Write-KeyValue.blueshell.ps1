# ------------------------------------------------------------------------------
# <copyright file="Write-KeyValue.blueshell.ps1" company="Star Cruise Studios LLC">
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
Displays a key value pair.

.DESCRIPTION
Displays a key value pair with a defined styling. The color of the key and value
is customizable as well as the separator character.

.PARAMETER Key
The key to display.

.PARAMETER Value
The value to display

.PARAMETER KeyColor
The color to use when displaying the key and separator strings. Defaults to Red.

.PARAMETER ValueColor
The color to use when displaying the value string. Defaults to Yellow.

.PARAMETER Separator
The separator string to display between the key and value. No spaces will be
included between the key value or separator. Any whitespace should be included
in the separator. Defaults to ": ".

.EXAMPLE
# Basic usage with default colors
Write-KeyValue "Status" "Running"
# Output: Status: Running (with Cyan key and Yellow value)

.EXAMPLE
# Custom colors and separator
Write-KeyValue "Error" "404" -KeyColor Red -ValueColor White -Separator " -> "
# Output: Error -> 404 (with Red key and White value)

.INPUTS
None. Piped values are not used.

.OUTPUTS
No value is output. The message is sent directly to the host.
#>
Function Write-KeyValue(
    [String] $Key, 
    [String] $Value, 
    [ConsoleColor] $KeyColor = [ConsoleColor]::Cyan, 
    [System.ConsoleColor] $ValueColor = [ConsoleColor]::Yellow,
    [String] $Separator = ": "
) {
    Write-Message "$Key$Separator" -ForegroundColor $KeyColor -NoNewline
    Write-Message $Value -ForegroundColor $ValueColor
}

Export-ModuleMember -Function 'Write-KeyValue'
