# BlueShell — Agent guidance

- **Root** = active codebase. **V0/** = legacy reference only (do not edit; reference only).
- Design is **from-scratch** per the specification.
- **Spec and tasks**: [docs/specification.md](docs/specification.md), [docs/tasks.md](docs/tasks.md).
- **Recommended skills**: [docs/recommended-agent-skills.md](docs/recommended-agent-skills.md).

## Target layout (spec §11)

- **Entry point**: `src/BlueShell.psm1`
- **Script folders**: `src/bootstrap/`, `src/config/`, `src/env/`, `src/core/`
- **Tests**: `src/tests/` (structure mirrors src/: tests/bootstrap/, tests/config/, tests/env/, tests/core/). Run with `pwsh -File src/tests/Invoke-Tests.ps1` or `Invoke-Pester -Path src/tests`.
- **Docs**: `docs/` (specification.md, tasks.md, recommended-agent-skills.md)
- **Schemas**: `src/schemas/` (e.g. AgentRules.schema.json, AgentSkills.schema.json)

## Cross-platform (spec §10)

- Code must run on **PowerShell 7** on Windows, macOS, and Linux. Avoid Windows-only or Unix-only assumptions unless abstracted (e.g. path join, line endings).
- Document any unavoidable platform differences in code comments or docs (e.g. install script behavior per OS).

## Reload and switch (spec §7)

- **Reload-BlueShell**: Idempotent; resets PATH to baseline and re-imports the module. Use after config or script changes.
- **Set-BlueShellComponentRoot** – set a component’s path in config and reload.
- **Switch-BlueShellEnvironment** – apply a preset from presets.json and reload. No git operations.

## Quiet vs interactive (spec §4)

- **Default**: Sessions are quiet (no banner, no loading messages). Non-interactive scripts should not see prompts.
- **Opt-in**: Set `BLUESHELL_INTERACTIVE=true` or call **Enable-BlueShellInteractive** (e.g. from profile) for interactive terminals.
- **BLUESHELL_QUIET**: When set to a truthy value, forces quiet mode.
