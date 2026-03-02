# BlueShell

## Overview

BlueShell is a dev-environment base that provides scaffolding, configuration, four-phase auto-load, a provider/topic registry, reload and environment switching, and setup. Extension modules (e.g. DanBlueShell, ScsBlueShell) register via config and participate through topics; there are no module-to-module dependencies—all interaction goes through the base. See the [specification](docs/specification.md) for behavior and [tasks](docs/tasks.md) for implementation status.

---

## BlueShell set up

### Prerequisites

- **PowerShell 7** (pwsh) on all platforms. Check with:
  ```powershell
  pwsh --version
  ```
  If missing, install per platform:
  - **Windows**: [PowerShell GitHub releases](https://github.com/PowerShell/PowerShell/releases) (MSI), or `winget install Microsoft.PowerShell`.
  - **macOS**: `brew install powershell/tap/powershell` (Homebrew), or see [PowerShell install docs](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-macos).
  - **Linux**: Use your distro’s package manager or the [Microsoft repository](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux); see official install docs for your distribution.
- **Optional**: Git (for cloning the repo).

### Download and install

1. **Download**: Clone the repo and go to its root:
   ```bash
   git clone <repo-url>
   cd BlueShell
   ```

2. **Install** (from the repo root):
   - **Windows**: In PowerShell or cmd run:
     ```powershell
     .\Install-BlueShell.ps1
     ```
     If execution policy blocks the script:
     ```powershell
     pwsh -ExecutionPolicy Bypass -File .\Install-BlueShell.ps1
     ```
   - **macOS / Linux**: In a terminal run:
     ```bash
     chmod +x Install-BlueShell.sh
     ./Install-BlueShell.sh
     ```
   The install script ensures PowerShell 7 is installed if missing, then configures your profile and `~/.blueshell`. If `Install-BlueShell.ps1` / `Install-BlueShell.sh` are not yet present at repo root, ensure pwsh 7 is installed, then load the module and run the setup function:
   ```powershell
   Import-Module .\src\BlueShell.psm1 -Force
   Install-BlueShell
   ```

3. Restart your terminal or start `pwsh` to use BlueShell.

### How to configure an extension

- **Config location**: `~/.blueshell/config.json` (Windows: `%USERPROFILE%\.blueshell`, macOS/Linux: `$HOME/.blueshell`).
- **Adding a module**: Add the extension’s root path to `config.json` under `moduleRoots`, for example:
  ```json
  "moduleRoots": {
    "DanBlueShell": "C:\\path\\to\\DanBlueShell",
    "ScsBlueShell": "/path/to/ScsBlueShell"
  }
  ```
  Then either:
  - Run the extension’s setup script once from that root: `Setup-<ModuleName>.ps1` or `Install-<ModuleName>.ps1`, or
  - Run **Install-DevEnvironment** (from a session with BlueShell loaded): it discovers modules from `moduleRoots` and optionally `$env:BLUESHELL_MODULES`, and runs each module’s `Setup-<Name>.ps1` or `Install-<Name>.ps1`.
- **Presets**: Optionally create `~/.blueshell/presets.json` mapping preset names to component paths. Use **Switch-BlueShellEnvironment -PresetName \<name\>** to apply a preset and reload.

---

## Functionality and functions (base module)

The following are the exported functions and main concepts of the base BlueShell module.

### Root and config

- **Get-BlueShellRoot** — Returns the base module root (directory containing BlueShell.psm1).
- **Get-BlueShellConfig** — Get a config value by key (`moduleRoots`, `activePreset`). Use this instead of reading config.json directly.
- **Set-BlueShellConfig** — Set a config value and persist to config.json.

### Secrets (four-phase “secret” step)

Used by `*.secret.auto.ps1` scripts; secrets are git-ignored.

- **Set-BlueShellSecret** — Set a secret value.
- **Get-BlueShellSecret** — Get a secret; throws **BlueShell.SecretNotInitialized** if the key was never set.
- **Test-BlueShellSecret** — Test whether a secret key is set.

### Provider / topic mechanism

Topics are named extension points with optional JSON Schema; modules register providers and optionally subscribe to events.

- **Register-BlueShellTopic** — Register a topic and its JSON Schema path.
- **Register-BlueShellTopicProvider** — Register a provider (script block or function) for a topic.
- **Get-BlueShellTopicData** — Invoke all providers for a topic; returns an array of responses.
- **Register-BlueShellTopicSubscription** — Subscribe to topic events (push).
- **Publish-BlueShellTopicEvent** — Publish an event for a topic to all subscribers.

### Interactive mode

Sessions are quiet by default (no banner or loading messages). Interactive mode is opt-in.

- **Enable-BlueShellInteractive** — Enable interactive mode (banner, messages); typically called from your profile.
- **Test-BlueShellInteractive** — Returns whether interactive mode is enabled.

### Reload and environment switching

- **Update-BlueShell** (alias **Reload-BlueShell**) — Idempotent reload: remove the module, reset PATH to baseline, re-import the module.
- **Set-BlueShellComponentRoot** — Set the path for a component (e.g. a module) in config and reload.
- **Switch-BlueShellEnvironment** — Apply a preset from presets.json and reload.

### Agent rules and skills (Cursor)

Base defines **AgentRules** and **AgentSkills** topics; extensions register providers. Rules and skills can be listed and enabled/disabled for Cursor.

- **Get-BlueShellCursorSkillsPath** — Returns the Cursor skills directory (`%USERPROFILE%\.cursor\skills` on Windows, `~/.cursor/skills` on macOS/Linux).
- **Get-BlueShellAgentRules** — List all rules from AgentRules topic providers.
- **Get-BlueShellAgentSkills** — List all skills from AgentSkills topic providers.
- **Enable-BlueShellAgentRules** / **Disable-BlueShellAgentRules** — Copy rules to or remove them from `.cursor/rules/` (optional `-WorkspaceRoot`).
- **Enable-BlueShellAgentSkills** / **Disable-BlueShellAgentSkills** — Copy skills to or remove them from the Cursor skills path.

### Setup

- **Install-BlueShell** — Ensure profile exists, profile loads BlueShell, and `~/.blueshell` and config.json exist; idempotent.
- **Install-DevEnvironment** — Run base setup, then each discovered module’s setup script; idempotent.

### Concepts

- **Four-phase auto-load**: Order is **env** → **secret** → **bootstrap** → **init**. The base runs all four steps, then all extensions run the same steps (per step). Scripts are discovered by pattern: `*.env.auto.ps1`, `*.secret.auto.ps1`, `*.bootstrap.auto.ps1`, `*.init.auto.ps1` (recursive under each root). **Env**: set environment variables only. **Secret**: git-ignored values; accessing an unset secret throws. **Bootstrap**: define functions only. **Init**: run logic, register providers.
- **Quiet by default**: No banner or loading messages unless **BLUESHELL_INTERACTIVE** is set (e.g. `true`) or **Enable-BlueShellInteractive** is used. **BLUESHELL_QUIET** forces quiet mode (e.g. for scripts).
- **Environment variable mirror**: Config is mirrored to environment variables (e.g. **BLUESHELL_CONFIG_DIR**, **BLUESHELL_ROOT**, **BLUESHELL_MODULE_\<Name\>**). See the [specification §3.5](docs/specification.md) for the full list.

---

## Testing

- **Prerequisite**: Pester 5. If needed:
  ```powershell
  Install-Module -Name Pester -MinimumVersion 5.0.0 -Scope CurrentUser
  ```
- **Run tests** (from repo root; cross-platform under PowerShell 7):
  ```powershell
  pwsh -File src/tests/Invoke-Tests.ps1
  ```
  Or from a pwsh session:
  ```powershell
  Invoke-Pester -Path src/tests
  ```
- **Options**: Use `-Output` for detailed output and `-Tag` to filter tests (see [src/tests/Invoke-Tests.ps1](src/tests/Invoke-Tests.ps1)).
- Tests are isolated and do not modify your real `~/.blueshell` or user profile.

---

## Docs

- [Specification](docs/specification.md) — behavior and contracts
- [Tasks](docs/tasks.md) — implementation plan
- [AGENTS.md](AGENTS.md) — agent and contributor guidance
- [Recommended agent skills](docs/recommended-agent-skills.md) — optional
