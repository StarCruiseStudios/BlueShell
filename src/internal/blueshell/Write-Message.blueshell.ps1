# ------------------------------------------------------------------------------
# <copyright file="Write-Message.blueshell.ps1" company="Star Cruise Studios LLC">
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
Displays a message to the user.

.DESCRIPTION
Displays a message to the user with a customizable color.

.PARAMETER Message
The message to display.

.PARAMETER MessageColor
The color to use when displaying the message strings. Defaults to White.

.INPUTS
None. Piped values are not used.

.OUTPUTS
No value is output. The message is sent directly to the host.
#>
Function Write-Message(
    [String] $Message, 
    [ConsoleColor] $MessageColor = [ConsoleColor]::White
) {
    Write-Host "$Message" -ForegroundColor $MessageColor
}

Export-ModuleMember -Function 'Write-Message'
