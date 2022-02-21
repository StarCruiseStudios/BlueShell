# ------------------------------------------------------------------------------
# <copyright file="Write-Banner.ps1" company="Star Cruise Studios LLC">
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

Set-Variable BannerWidth -Option Constant -Value 80
Set-Variable PowerShellVersion -Option Constant -Value $PSVersionTable.PSVersion.ToString()
Set-Variable BufferWidth -Option Constant -Value $Host.UI.RawUI.BufferSize.Width

# Print the small banner if the display buffer is too narrow.
if ($BufferWidth -lt $BannerWidth) {
    Write-Host "------"                                -ForegroundColor White
    Write-Host "BlueShell"                             -ForegroundColor DarkBlue
    Write-Host "v$BlueShellVersion [$BlueShellBranch]" -ForegroundColor DarkCyan
    Write-Host "PowerShell v$PowerShellVersion"       -ForegroundColor DarkGreen
    Write-Host "------"                                -ForegroundColor White
    Write-Host ""
} else {
    $bannerIndentSize = ($BufferWidth - $BannerWidth) / 2 -as [int]        
    $bannerIndent = [System.String]::new(' ', $bannerIndentSize)

    Write-Host "$bannerIndent================================================================================" -ForegroundColor White
    Write-Host "$bannerIndent                                                                                " -ForegroundColor DarkBlue
    Write-Host "$bannerIndent                                                      __                _       " -ForegroundColor DarkBlue
    Write-Host "$bannerIndent                                                     /. }             _/ |      " -ForegroundColor DarkBlue
    Write-Host "$bannerIndent                                                  ,-'/ \ \         _./   /\     " -ForegroundColor DarkBlue
    Write-Host "$bannerIndent      ____  __   __  ________                   .'  /   \/       ./     / |     " -ForegroundColor DarkBlue
    Write-Host "$bannerIndent     / __ \/ /  / / / / ____/         ._       /__-''''-.\_    ./      ' /\     " -ForegroundColor DarkBlue
    Write-Host "$bannerIndent    / __  / /  / / / / __/             \ ''--:'   '\_______.\./         ' |     " -ForegroundColor DarkBlue
    Write-Host "$bannerIndent   / /_/ / /__/ /_/ / /___           ___\     |    / .''''.\/           _/|     " -ForegroundColor DarkBlue
    Write-Host "$bannerIndent  /_____/_____\____/_____/           \  /\__,-'   /  |  ' ||           _./      " -ForegroundColor DarkBlue
    Write-Host "$bannerIndent       _____ __  __________    __    .\/-----..-''\   '--' |          '/        " -ForegroundColor DarkBlue
    Write-Host "$bannerIndent      / ___// / / / ____/ /   / /   |          ''--\,       \_____..-'          " -ForegroundColor DarkBlue
    Write-Host "$bannerIndent      \__ \/ /_/ / __/ / /   / /    |   ,.._         ''---./...\-   |           " -ForegroundColor DarkBlue
    Write-Host "$bannerIndent     ___/ / __  / /___/ /___/ /___   '-| |   |'--._                .'           " -ForegroundColor DarkBlue
    Write-Host "$bannerIndent    /____/_/ /_/_____/_____/_____/      \ \_/ ,' |  '';--.______.-'             " -ForegroundColor DarkBlue
    Write-Host "$bannerIndent                                         '---'    ';''    /   /./               " -ForegroundColor DarkBlue
    Write-Host "$bannerIndent                                           '-.___.'     ,* ,.''                 " -ForegroundColor DarkBlue
    Write-Host "$bannerIndent                                               ''------'-''                     " -ForegroundColor DarkBlue
    Write-Host "$bannerIndent                                                                                " -ForegroundColor DarkBlue
    Write-Host "$bannerIndent================================================================================" -ForegroundColor White
    Write-Host "$bannerIndent         v$BlueShellVersion [$BlueShellBranch]"                                   -ForegroundColor DarkCyan
    Write-Host "$bannerIndent         PowerShell v$PowerShellVersion"                                          -ForegroundColor DarkGreen
    Write-Host "$bannerIndent================================================================================" -ForegroundColor White
    Write-Host ""
}