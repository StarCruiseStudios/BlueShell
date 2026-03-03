#!/usr/bin/env bash
# ==============================================================================
# Usage: chmod +x Install-BlueShell.sh && ./Install-BlueShell.sh
# Run from BlueShell repo root.
# ==============================================================================
set -e
SETUP_VERSION=1

# ==============================================================================
# Ensure PowerShell 7 is installed.

pwsh7_installed=false
if command -v pwsh >/dev/null 2>&1; then
    major=$(pwsh -NoProfile -Command '$PSVersionTable.PSVersion.Major' 2>/dev/null || true)
    if [ -n "$major" ] && [ "$major" -ge 7 ] 2>/dev/null; then
        pwsh7_installed=true
    fi
fi

if [ "$pwsh7_installed" = false ]; then
    echo "PowerShell 7 not found. Attempting to install..."
    if [ "$(uname -s)" = "Darwin" ]; then
        if command -v brew >/dev/null 2>&1; then
            brew install powershell/tap/powershell
        else
            echo "Homebrew is not available. Please install PowerShell 7 manually and then run this script again."
            echo "Install: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-macos"
            echo "After installing pwsh run this script again."
            exit 1
        fi
    else
        # Linux
        if command -v apt-get >/dev/null 2>&1; then
            echo "Attempting to install PowerShell via apt-get..."
            sudo apt-get update && sudo apt-get install -y powershell 2>/dev/null || {
                echo "PowerShell 7 installation failed. Install it manually and then run this script again."
                echo "Install: https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu"
                echo "Or: https://github.com/PowerShell/PowerShell/releases"
                exit 1
            }
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y powershell 2>/dev/null || {
                echo "PowerShell 7 installation failed. Install it manually and then run this script again."
                echo "Install: https://learn.microsoft.com/en-us/powershell/scripting/install/install-rhel"
                echo "Or: https://github.com/PowerShell/PowerShell/releases"
                exit 1
            }
        elif command -v yum >/dev/null 2>&1; then
            echo "On RHEL/CentOS, install PowerShell 7 manually and then run this script again."
            echo "Install: https://learn.microsoft.com/en-us/powershell/scripting/install/install-rhel"
            exit 1
        else
            echo "Unsupported package manager. Please install PowerShell 7 manually and then run this script again."
            echo "Install: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux"
            exit 1
        fi
    fi
    echo "PowerShell 7 installed. Please open a new terminal and run: ./Install-BlueShell.sh"
    exit 0
fi

# ==============================================================================
# Configure $PROFILE.CurrentUserAllHosts to Start BlueShell.

THIS_SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)"
PROFILE_PATH=$(pwsh -NoProfile -Command 'echo $PROFILE.CurrentUserAllHosts' 2>/dev/null | tr -d '\r\n')
CONTENT=""
[ -f "$PROFILE_PATH" ] && CONTENT=$(cat "$PROFILE_PATH")

VERSION_NUMBER=""
if [ -n "$CONTENT" ]; then
    VERSION_NUMBER=$(echo "$CONTENT" | sed -n 's/.*# Run BlueShell (Setup V\([0-9]*\)).*/\1/p' | head -1)
fi

if [ -n "$VERSION_NUMBER" ] && [ "$VERSION_NUMBER" -ge "$SETUP_VERSION" ] 2>/dev/null; then
    echo "BlueShell set up with version $VERSION_NUMBER."
    exit 0
fi

BLUE_SHELL_ROOT="$THIS_SCRIPT_PATH/src/BlueShell.psm1"
if [ ! -f "$BLUE_SHELL_ROOT" ]; then
    echo "BlueShell.psm1 not found at $BLUE_SHELL_ROOT. Run this script from the BlueShell repo root." >&2
    exit 1
fi

BLUE_SHELL_ROOT_QUOTED="${BLUE_SHELL_ROOT//\'/\'\'}"
START_BLUE_SHELL_CMD="Import-Module '$BLUE_SHELL_ROOT_QUOTED' -Force"
SETUP_BLOCK="# Run BlueShell (Setup V$SETUP_VERSION)
$START_BLUE_SHELL_CMD
# End Run BlueShell"

mkdir -p "$(dirname "$PROFILE_PATH")"

if [ -n "$VERSION_NUMBER" ]; then
    TMP_REPLACE=$(mktemp)
    printf '%s\n' "$SETUP_BLOCK" > "$TMP_REPLACE"
    export TMP_REPLACE
    perl -i -0pe 'BEGIN { open(F, $ENV{TMP_REPLACE}); $r = join "", <F>; close F } s/# Run BlueShell.*?# End Run BlueShell[^\r\n]*/$r/s' "$PROFILE_PATH"
    rm -f "$TMP_REPLACE"
else
    printf '%s\n' "$SETUP_BLOCK" >> "$PROFILE_PATH"
fi

# ==============================================================================
# Start BlueShell

pwsh -NoProfile -Command "$START_BLUE_SHELL_CMD"

# ==============================================================================
# Setup Complete

echo "BlueShell install complete."
