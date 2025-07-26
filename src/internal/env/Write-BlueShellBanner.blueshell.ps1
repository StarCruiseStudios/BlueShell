# ------------------------------------------------------------------------------
# <copyright file="Write-BlueShellBanner.blueshell.ps1" company="Star Cruise Studios LLC">
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
Displays the BlueShell banner.

.DESCRIPTION
Displays the BlueShell banner. If the display buffer is wide enough, the banner
will include the logo as well as the BlueShell version and branch and PowerShell
version. If the display buffer is too narrow, a simple text banner will be 
shown.

.INPUTS
None. Piped values are not used.

.OUTPUTS
No value is output. The message is sent directly to the host.
#>
Function Write-BlueShellBanner {
    Set-Variable BannerWidth -Option Constant -Value 80
    Set-Variable PowerShellVersion -Option Constant -Value $PSVersionTable.PSVersion.ToString()
    Set-Variable BufferWidth -Option Constant -Value $Host.UI.RawUI.BufferSize.Width

    # Print the small banner if the display buffer is too narrow.
    if ($BufferWidth -lt $BannerWidth) {
        Write-Message "------"                                -ForegroundColor White
        Write-Message "BlueShell"                             -ForegroundColor Blue
        Write-Message "v$BlueShellVersion [$BlueShellBranch]" -ForegroundColor DarkCyan
        Write-Message "PowerShell v$PowerShellVersion"       -ForegroundColor DarkGreen
        Write-Message "------"                                -ForegroundColor White
        Write-Message ""
    } else {
        $bannerIndentSize = ($BufferWidth - $BannerWidth) / 2 -as [int]        
        $bannerIndent = [System.String]::new(' ', $bannerIndentSize)

        Write-Message "$bannerIndent================================================================================" -ForegroundColor White
        Write-Message "$bannerIndent                                                                                " -ForegroundColor Blue
        Write-Message "$bannerIndent                                                      __                _       " -ForegroundColor Blue
        Write-Message "$bannerIndent                                                     /. }             _/ |      " -ForegroundColor Blue
        Write-Message "$bannerIndent                                                  ,-'/ \ \         _./   /\     " -ForegroundColor Blue
        Write-Message "$bannerIndent      ____  __   __  ________                   .'  /   \/       ./     / |     " -ForegroundColor Blue
        Write-Message "$bannerIndent     / __ \/ /  / / / / ____/         ._       /__-''''-.\_    ./      ' /\     " -ForegroundColor Blue
        Write-Message "$bannerIndent    / __  / /  / / / / __/             \ ''--:'   '\_______.\./         ' |     " -ForegroundColor Blue
        Write-Message "$bannerIndent   / /_/ / /__/ /_/ / /___           ___\     |    / .''''.\/           _/|     " -ForegroundColor Blue
        Write-Message "$bannerIndent  /_____/_____\____/_____/           \  /\__,-'   /  |  ' ||           _./      " -ForegroundColor Blue
        Write-Message "$bannerIndent       _____ __  __________    __    .\/-----..-''\   '--' |          '/        " -ForegroundColor Blue
        Write-Message "$bannerIndent      / ___// / / / ____/ /   / /   |          ''--\,       \_____..-'          " -ForegroundColor Blue
        Write-Message "$bannerIndent      \__ \/ /_/ / __/ / /   / /    |   ,.._         ''---./...\-   |           " -ForegroundColor Blue
        Write-Message "$bannerIndent     ___/ / __  / /___/ /___/ /___   '-| |   |'--._                .'           " -ForegroundColor Blue
        Write-Message "$bannerIndent    /____/_/ /_/_____/_____/_____/      \ \_/ ,' |  '';--.______.-'             " -ForegroundColor Blue
        Write-Message "$bannerIndent                                         '---'    ';''    /   /./               " -ForegroundColor Blue
        Write-Message "$bannerIndent                                           '-.___.'     ,* ,.''                 " -ForegroundColor Blue
        Write-Message "$bannerIndent                                               ''------'-''                     " -ForegroundColor Blue
        Write-Message "$bannerIndent                                                                                " -ForegroundColor Blue
        Write-Message "$bannerIndent================================================================================" -ForegroundColor White
        Write-Message "$bannerIndent         v$BlueShellVersion [$BlueShellBranch]"                                   -ForegroundColor DarkCyan
        Write-Message "$bannerIndent         PowerShell v$PowerShellVersion"                                          -ForegroundColor DarkGreen
        Write-Message "$bannerIndent================================================================================" -ForegroundColor White
        Write-Message ""
    }
}
