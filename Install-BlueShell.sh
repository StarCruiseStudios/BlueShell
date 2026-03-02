#!/usr/bin/env bash
# Install-BlueShell.sh - macOS and Linux installer (Spec §9)
# Run from BlueShell repo root. Installs PowerShell 7 if needed, then runs profile/config setup.
# Usage: chmod +x Install-BlueShell.sh && ./Install-BlueShell.sh

set -e
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
PSM1_PATH="$REPO_ROOT/src/BlueShell.psm1"

if [ ! -f "$PSM1_PATH" ]; then
    echo "BlueShell.psm1 not found at $PSM1_PATH. Run this script from the BlueShell repo root." >&2
    exit 1
fi

# Check for pwsh 7+
pwsh_ok=false
if command -v pwsh >/dev/null 2>&1; then
    major=$(pwsh -NoProfile -Command '$PSVersionTable.PSVersion.Major' 2>/dev/null || true)
    if [ "$major" -ge 7 ] 2>/dev/null; then
        pwsh_ok=true
    fi
fi

if [ "$pwsh_ok" = false ]; then
    echo "PowerShell 7 (pwsh) not found. Attempting to install..."
    if [ "$(uname -s)" = "Darwin" ]; then
        if command -v brew >/dev/null 2>&1; then
            brew install powershell/tap/powershell
        else
            echo "Homebrew not found. Install PowerShell 7 manually: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-macos"
            exit 1
        fi
    else
        # Linux: try common package managers
        if command -v apt-get >/dev/null 2>&1; then
            # Debian/Ubuntu - use Microsoft repo or instruct
            echo "On Debian/Ubuntu, install with: https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu"
            echo "Or: sudo apt-get update && sudo apt-get install -y powershell"
            if ! command -v pwsh >/dev/null 2>&1; then exit 1; fi
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y powershell 2>/dev/null || {
                echo "Install PowerShell 7 manually: https://learn.microsoft.com/en-us/powershell/scripting/install/install-rhel"
                exit 1
            }
        elif command -v yum >/dev/null 2>&1; then
            echo "On RHEL/CentOS, see: https://learn.microsoft.com/en-us/powershell/scripting/install/install-rhel"
            exit 1
        else
            echo "Unsupported package manager. Install PowerShell 7 from: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux"
            exit 1
        fi
    fi
fi

# Run base setup via pwsh
export BLUESHELL_ROOT="$REPO_ROOT"
pwsh -NoProfile -Command "Import-Module '$PSM1_PATH' -Force; Install-BlueShell"
echo "BlueShell setup complete. Restart your terminal or run: pwsh"
