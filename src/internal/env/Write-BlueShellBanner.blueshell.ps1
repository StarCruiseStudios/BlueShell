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

$script:SmallBannerTemplate = @"
`e[97m------
`e[94mBlueShell
`e[96mv{0} [{1}]
`e[92mPowerShell v{2}
`e[97m------`e[0m

"@

# ANSI Color codes: Yellow=93, Blue=94, White=97, DarkCyan=96, DarkGreen=92, Black=90, Reset=0
$script:LargeBannerTemplate = @"
{0}`e[93m===============================================================================
{0}`e[94m                                                                                
{0}`e[94m                                    `e[97m                  __                _       
{0}`e[94m                                    `e[97m                 /. }}             _/ |      
{0}`e[94m                                    `e[97m              ,-'/ \ \         _./   /\     
{0}`e[94m      ____  __   __  ________       `e[97m            .'  /   \/       ./     / |     
{0}`e[94m     / __ \/ /  / / / / ____/       `e[97m  ._       /`e[94m__-''''-.`e[97m\`e[94m_`e[97m    ./      ' /\     
{0}`e[94m    / __  / /  / / / / __/          `e[97m   \ ''--.`e[94m'   '\_______.\`e[97m./         ' |     
{0}`e[94m   / /_/ / /__/ /_/ / /___          `e[97m ___\     |`e[94m    / `e[97m.''''`e[94m.\`e[97m/           _/|     
{0}`e[94m  /_____/_____\____/_____/          `e[97m \  `e[94m/`e[97m\__,-'`e[94m   /  `e[97m|  ' ||           _./      
{0}`e[97m       _____ __  __________    __   `e[97m .\`e[94m/`e[97m-----..`e[94m-''\`e[97m   '--' |          '/        
{0}`e[93m      / ___// / / / ____/ /   / /   `e[97m|          ''--`e[94m\`e[97m,       \_____..-'          
{0}`e[93m      \__ \/ /_/ / __/ / /   / /    `e[97m|   ,..__        ''---.`e[94m/`e[97m...`e[94m\`e[97m-   |           
{0}`e[93m     ___/ / __  / /___/ /___/ /___  `e[97m '-`e[93m| `e[90m|   |`e[97m'--._                .'           
{0}`e[93m    /____/_/ /_/_____/_____/_____/  `e[93m    \ `e[90m\_/`e[93m ,' `e[90m|`e[97m  ''`e[90m,`e[97m--.______.-'             
{0}`e[93m                                    `e[93m     '---'    `e[90m'`e[93m;`e[90m''`e[93m    /   /./               
{0}`e[93m                                    `e[93m       '-.___.'     ,* ,.''                 
{0}`e[93m                                    `e[93m           ''------'-''                     
{0}`e[94m                                                                                
{0}`e[93m===============================================================================
{0}`e[96m         v{1} [{2}]
{0}`e[92m         PowerShell v{3}
{0}`e[93m===============================================================================`e[0m

"@

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
    if ($env:BlueShellQuietMode -eq "True") {
        return
    }
    
    Set-Variable BannerWidth -Option Constant -Value 80
    Set-Variable PowerShellVersion -Option Constant -Value $PSVersionTable.PSVersion.ToString()
        
    # Safely get buffer width with fallback
    $BufferWidth = 80  # Default fallback
    try {
        if ($Host.UI -and $Host.UI.RawUI -and $Host.UI.RawUI.BufferSize) {
            $BufferWidth = $Host.UI.RawUI.BufferSize.Width
        }
    } catch {
        Write-Verbose "Could not determine buffer width, using default: $($_.Exception.Message)"
    }
    
    Set-Variable BufferWidth -Option Constant -Value $BufferWidth
        
    if ($BufferWidth -lt $BannerWidth) {
        $banner = $script:SmallBannerTemplate -f $BlueShellVersion, $BlueShellBranch, $PowerShellVersion
        Write-Host $banner -NoNewline
    } else {
        $bannerIndentSize = [Math]::Max(0, [Math]::Floor(($BufferWidth - $BannerWidth) / 2))
        $bannerIndent = [System.String]::new(' ', $bannerIndentSize)
        
        $banner = $script:LargeBannerTemplate -f $bannerIndent, $BlueShellVersion, $BlueShellBranch, $PowerShellVersion
        Write-Host $banner -NoNewline
    }
}
