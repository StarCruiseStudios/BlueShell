# Recommended Agent Skills for the BlueShell Ecosystem

This document recommends **agent skills** that should be created so that AI agents can work effectively with the BlueShell ecosystem and with defining new modules or functions. Each skill is a recommendation for a separate SKILL.md (or equivalent) that guides the agent. This file does not implement the skills; it describes what each skill should cover.

---

## 1. Create a new BlueShell module

**Short name**: Create BlueShell module  

**Purpose**: Guide the agent to scaffold a new extension module that follows BlueShell conventions and depends only on the base.

**When to use**: User asks to create a new module (e.g. "Create a module for project X" or "Add a new BlueShell extension").

**What the skill should guide the agent to do**:

- **Inputs**: Module name (e.g. MyProjectBlueShell), optional description and list of features (PATH, workflows, topics).
- **Outputs**: A new directory/repo with:
  - Convention-based layout (no required folder names; recommend scripts by concern and optional folders like `rules/`, `skills/`, `tests/`).
  - At least one **\*.env.auto.ps1** (env/config only), **\*.bootstrap.auto.ps1** (function definitions), **\*.init.auto.ps1** (initialization logic); **\*.secret.auto.ps1** only if the module needs secrets, with placeholders and .gitignore.
  - A **Setup-&lt;Module&gt;** (or **Install-&lt;Module&gt;**).ps1 script that registers the module root in BlueShell config (moduleRoots) and is idempotent.
  - **AGENTS.md** describing the module and how agents should navigate it.
  - **tests/** with at least one test for module-specific behavior.
- **Conventions**: No direct dependency on other modules; use provider/topic APIs for cross-module behavior. Reference [specification.md](specification.md) §1, §5, §8.

---

## 2. Add a function to a BlueShell module

**Short name**: Add function to BlueShell module  

**Purpose**: Guide the agent to add a new PowerShell function to an existing module in the correct phase and with the right exports.

**When to use**: User asks to add a function or command to a module (e.g. "Add a function to list X" or "Add Get-Foo to DanBlueShell").

**What the skill should guide the agent to do**:

- **Inputs**: Function name (verb-noun), brief description, which module (path or name), and whether it only defines the function (bootstrap) or also runs logic (init).
- **Outputs**:
  - **Bootstrap**: Add or create a **\*.bootstrap.auto.ps1** file that defines the function (and uses `Export-ModuleMember -Function` if the module uses that pattern). No execution of business logic in bootstrap.
  - **Init**: If the function must run initialization or register providers, add or extend **\*.init.auto.ps1** to call that logic after functions are defined.
- **Conventions**: One main concern per file; consistent naming. Use base APIs (Get-BlueShellConfig, Get-BlueShellTopicData, etc.) rather than reading config or other modules directly. Reference [specification.md](specification.md) §5.2.

---

## 3. Register a topic provider

**Short name**: Register BlueShell topic provider  

**Purpose**: Guide the agent to register a provider for an existing topic (or define a new topic and schema) so that the module participates in the provider/topic system without depending on other modules.

**When to use**: User asks to "add a provider for X", "list X from this module too", or "register this module's data for topic Y".

**What the skill should guide the agent to do**:

- **Inputs**: Topic name (e.g. AwsSsoProfiles, AgentRules), whether the topic already exists, and what data or events this module will provide.
- **Outputs**:
  - If the topic is new: a **JSON Schema** file (with version) for the topic and registration of the topic + schema via base API (e.g. Register-BlueShellTopic).
  - A **provider** (script block or function) that returns data conforming to the schema (for pull) and optionally publishes events (for push). Registered in **init** phase via e.g. Register-BlueShellTopicProvider.
  - Schema compatibility: consumer schema may omit fields; same version must match. Reference [specification.md](specification.md) §2.
- **Conventions**: Provider runs in init phase. Consumer receives an **array of responses** (one per provider). No direct calls to other modules.

---

## 4. Add an auto-load script for a phase

**Short name**: Add BlueShell auto-load script  

**Purpose**: Guide the agent to add or extend a script that runs in a specific load phase (env, secret, bootstrap, init) so that behavior fits the phase contract.

**When to use**: User asks to "set env var X in the module", "add a secret", "define a function that runs at load", or "run this logic when the module loads".

**What the skill should guide the agent to do**:

- **Inputs**: Which phase (env | secret | bootstrap | init), what the script should do, and which module.
- **Outputs**:
  - **env**: New or extended **\*.env.auto.ps1** — only set env vars and config values; no function definitions or business logic.
  - **secret**: New or extended **\*.secret.auto.ps1** (git-ignored); document placeholder in env; access via base secret handling; fail with BlueShell.SecretNotInitialized if unset.
  - **bootstrap**: New or extended **\*.bootstrap.auto.ps1** — define functions only; no execution of initialization logic.
  - **init**: New or extended **\*.init.auto.ps1** — run initialization (e.g. register providers, call functions).
- **Conventions**: File pattern **\*.{stepName}.auto.ps1**; discovery is recursive under module root. Reference [specification.md](specification.md) §5.

---

## 5. Enable or disable agent rules/skills

**Short name**: Manage BlueShell agent rules and skills  

**Purpose**: Guide the agent to enable/disable rules or skills for the agent (Cursor) using the base's provider-based discovery, or to add a module's rules/skills as providers.

**When to use**: User asks to "enable rule X", "add our rules to the agent", "disable skill Y", or "make this module's rules available to the agent".

**What the skill should guide the agent to do**:

- **Inputs**: Action (enable | disable | list), target (rules | skills), optional name or filter; or "add this module as a provider".
- **Outputs**:
  - **List**: Use base list (which uses Get-BlueShellTopicData for AgentRules/AgentSkills).
  - **Enable/disable**: Use base enable/disable (copy to or remove from .cursor/rules/ and Cursor skills path). No env override for these paths.
  - **Add as provider**: In the module's init, register a provider for AgentRules and/or AgentSkills that returns the module's rules/skills (e.g. list of { name, path }). Reference [specification.md](specification.md) §6.
- **Conventions**: Modules do not implement their own store; they register providers. Base handles copy/remove.

---

## 6. Work with BlueShell config and env

**Short name**: BlueShell config and env vars  

**Purpose**: Guide the agent to read or write BlueShell config in a type-safe way and to document or use env var mirror for non-BlueShell scripts.

**When to use**: User asks to "read config X", "set module root", "use BlueShell version in a script", or "expose this to env for external scripts".

**What the skill should guide the agent to do**:

- **Inputs**: Config key (e.g. moduleRoots, activePreset) or env var name; read vs write.
- **Outputs**:
  - **Inside BlueShell**: Use **Get-BlueShellConfig -Key** and **Set-BlueShellConfig -Key -Value**. Prefer typed API over raw JSON or env.
  - **Outside BlueShell**: Use env vars (BLUESHELL_CONFIG_DIR, BLUESHELL_VERSION, BLUESHELL_ROOT, BLUESHELL_ACTIVE_PRESET, BLUESHELL_MODULE_&lt;Name&gt;, BLUESHELL_INTERACTIVE, BLUESHELL_QUIET). Reference [specification.md](specification.md) §3.5.
- **Conventions**: Config file is config.json in ~/.blueshell; presets in presets.json same directory. Do not hardcode paths; use config or env.

---

## 7. Reload or switch BlueShell environment

**Short name**: Reload or switch BlueShell  

**Purpose**: Guide the agent to reload the BlueShell session or switch preset/component roots so that changes take effect in the current session.

**When to use**: User asks to "reload BlueShell", "switch to dev environment", or "change module path and reload".

**What the skill should guide the agent to do**:

- **Inputs**: Action (reload | set component root | switch preset), optional preset name or component name + path.
- **Outputs**:
  - **Reload**: Run **Reload-BlueShell** (idempotent; resets PATH and re-imports module).
  - **Set root**: Run **Set-BlueShellComponentRoot** with component name and new path; base updates config and reloads.
  - **Switch preset**: Run **Switch-BlueShellEnvironment** with preset name; base loads presets.json and reloads.
- **Conventions**: No git operations; only config/preset file updates and reload. Reference [specification.md](specification.md) §7.

---

## 8. Run BlueShell setup (install / initialize environment)

**Short name**: BlueShell setup and install  

**Purpose**: Guide the agent to run base or full environment setup so that profile, config, and modules are installed and idempotent.

**When to use**: User asks to "install BlueShell", "set up dev environment", "configure a new machine", or "run setup".

**What the skill should guide the agent to do**:

- **Inputs**: Scope (base only | full environment), platform (Windows | macOS | Linux) if relevant.
- **Outputs**:
  - **Base only**: Run **Install-BlueShell** (or **Setup-BlueShell**): ensure profile, Start-BlueShell, config dir and config.json; idempotent.
  - **Full**: Run **Install-DevEnvironment** (or **Initialize-DevEnvironment**): base setup then each discovered module's setup script; idempotent.
  - **First-time (no pwsh 7)**: Direct user to run **Install-BlueShell.ps1** (Windows) or **Install-BlueShell.sh** (macOS/Linux) to install PowerShell 7 and then setup.
- **Conventions**: All setup is idempotent. Reference [specification.md](specification.md) §8, §9.

---

## 9. Write cross-platform BlueShell scripts and tests

**Short name**: Cross-platform BlueShell  

**Purpose**: Guide the agent to write PowerShell 7 scripts and tests that work on Windows, macOS, and Linux, and to document platform-specific behavior.

**When to use**: User asks to "add a script that works on Mac too", "fix path for Linux", or "add tests for all platforms".

**What the skill should guide the agent to do**:

- **Inputs**: Script or test to write or modify; target platforms (Windows, macOS, Linux).
- **Outputs**:
  - Use PowerShell 7 compatible syntax; avoid Windows-only or Unix-only assumptions unless abstracted (e.g. path join, line endings, native commands).
  - Tests: run on all three platforms where feasible; document platform-specific tests; CI/cross-platform verification in agent rules.
  - AGENTS.md / .cursor/rules: state that code must be cross-platform; document unavoidable platform differences.
- **Conventions**: Reference [specification.md](specification.md) §10.
