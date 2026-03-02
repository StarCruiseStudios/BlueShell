# BlueShell

BlueShell is a dev environment base: scaffolding, config, four-phase auto-load, provider/topic registry, reload and environment switching, and setup. See the [specification](docs/specification.md) for behavior and [tasks](docs/tasks.md) for implementation status.

## Requirements

- **PowerShell 7** (pwsh). All scripts and the module assume pwsh 7 is available.

## Quick install

1. Clone this repo and `cd` into it.

2. **Windows**: In PowerShell or cmd run:
   ```powershell
   .\Install-BlueShell.ps1
   ```
   If execution policy blocks the script, run:
   ```powershell
   pwsh -ExecutionPolicy Bypass -File .\Install-BlueShell.ps1
   ```

3. **macOS / Linux**: In a terminal run:
   ```bash
   chmod +x Install-BlueShell.sh
   ./Install-BlueShell.sh
   ```

The install script ensures PowerShell 7 is installed (if missing), then configures your profile and `~/.blueshell` config. Restart your terminal or start `pwsh` to use BlueShell.

## Tests

Tests run on Windows, macOS, and Linux under PowerShell 7:

```powershell
pwsh -File src/tests/Invoke-Tests.ps1
```

Or from a pwsh session: `Invoke-Pester -Path src/tests`. Platform-specific tests (if any) are noted in the test files or in the spec (§12).

## Docs

- [Specification](docs/specification.md) — behavior and contracts
- [Tasks](docs/tasks.md) — implementation plan
- [AGENTS.md](AGENTS.md) — agent and contributor guidance
- [Recommended agent skills](docs/recommended-agent-skills.md) — optional
