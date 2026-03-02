# BlueShell Ecosystem — Specification

This document is the target specification for the BlueShell dev environment ecosystem. It describes behavior and contracts only; implementation tasks are in [tasks.md](tasks.md).

---

## 1. Architecture

### 1.1 Module dependency rule

- **Rule**: Modules may depend only on the base (BlueShell). No module may depend on another module directly.
- **Implication**: Any cross-module behavior (e.g. "list all AWS SSO profiles from everywhere") is achieved via a base-defined extension mechanism (the provider/topic system), not by one module calling another.

### 1.2 Components

- **Base**: BlueShell — scaffolding, bootstrap, config, four-phase auto-load, provider/topic registry, reload/switch, setup, rules/skills plumbing, typed config. Entry point: **src/BlueShell.psm1**.
- **Modules**: Extension modules (e.g. DanBlueShell, ScsBlueShell). Each is a directory root; loaded when registered in config. Each has its own setup script and can register topic providers. No hardcoded module paths in base.
- **Per-component roots**: Each component has a configurable directory root (base path and each module path). Roots are stored in config; switching roots (e.g. "branch") is done by updating config and reloading.

---

## 2. Provider / topic mechanism

Extension points are **topics** with a **registered schema**. Modules register **providers** for a topic and **subscribe** for pull (data) or push (events).

### 2.1 Schema

- **Format**: JSON Schema. One schema file per topic. Modules that define or participate in a topic contain their own schema definition **with a version** (e.g. in a `schemas/` folder or alongside provider registration).
- **Validation**: The base validates provider output against the topic's JSON Schema. When registering, publishing, or consuming, the base verifies that the provided schema matches what is already registered for that topic (if any).
- **Compatibility**:
  - A consumer schema may omit fields that exist on the provider schema (backwards compatible).
  - Schemas with the **same version** must be identical; if two schemas claim the same version but differ, the base reports an error and rejects the operation.

### 2.2 Concepts

- **Topic**: Named extension point (e.g. `AwsSsoProfiles`, `AgentRules`). Defined by registering a topic name and its JSON Schema.
- **Provider**: A module registers a provider for a topic; it supplies data conforming to the schema (pull) and may publish events (push).
- **Subscribe (pull)**: A consumer calls the base API to get all data for topic X. The base invokes all registered providers for X and returns an **array of responses** (one element per provider). The consumer always receives an array, even when zero or one provider is registered.
- **Subscribe (push)**: A consumer registers a callback for a topic; when a provider or the base raises an event for that topic, the base delivers the event payload to all subscribers.

### 2.3 Base APIs

- **Register topic (and schema)**: e.g. `Register-BlueShellTopic -Topic <name> -SchemaPath <path>` or equivalent. First registration defines the topic; subsequent registrations must match (per compatibility rules above).
- **Register provider**: e.g. `Register-BlueShellTopicProvider -Topic <name> -Provider <scriptblock or function>`.
- **Pull**: `Get-BlueShellTopicData -Topic <name>` — returns `[response1, response2, ...]` (array of provider outputs).
- **Push (subscribe)**: `Register-BlueShellTopicSubscription -Topic <name> -Callback <scriptblock>`.
- **Push (publish)**: `Publish-BlueShellTopicEvent -Topic <name> -Payload <object>` — for providers or base to raise events; base delivers to all subscribers.

No module-to-module calls; all interaction goes through these base APIs.

---

## 3. Configuration

### 3.1 Location and files

- **Config directory**: **~/.blueshell/** (path resolved per platform: Windows uses `$env:USERPROFILE`, macOS/Linux use `$HOME`).
- **Main config file**: **config.json** in that directory. Format: **JSON**.
- **Presets file**: **presets.json** in the **same directory** as config.json (convention: ~/.blueshell/presets.json). No key in config.json points to it; the base always looks for presets.json alongside config.json.

### 3.2 config.json structure

- **moduleRoots**: Object mapping module name (string) to absolute path (string). Example: `"moduleRoots": { "DanBlueShell": "/path/to/DanBlueShell", "ScsBlueShell": "/path/to/ScsBlueShell" }`. The base (BlueShell) root is the directory containing the loaded BlueShell.psm1; it may be overridden by an environment variable (see env mirror).
- **activePreset**: Optional string. When set, the base resolves component roots from presets.json under this key instead of (or merged with) moduleRoots; exact behavior (replace vs merge) is defined in base logic (e.g. preset overwrites moduleRoots for the session).

### 3.3 presets.json structure

- Object mapping preset name (string) to an object that maps component names to paths. Example: `{ "dev": { "BlueShell": "/env/dev/BlueShell", "DanBlueShell": "/env/dev/DanBlueShell" }, "main": { ... } }`.

### 3.4 Typed config API

- **Get-BlueShellConfig** — get a config value by key. Parameters: **-Key** (or **-Name**), string. Returns the value in a type-safe form (e.g. string, hashtable) according to the known key. BlueShell modules and extensions **must** use this API (or the env mirror) in preference to reading config.json directly.
- **Set-BlueShellConfig** — set a config value. Parameters: **-Key** (or **-Name**), **-Value**. Persists to config.json. Known keys are validated for type.

### 3.5 Environment variable mirror

Every BlueShell config value that non-BlueShell scripts might need is also exposed as an environment variable. Scripts that do not load BlueShell can rely on these. The base sets them during bootstrap and keeps them in sync when config or preset changes (e.g. on reload).

**Canonical list** (exact env names):

- **BLUESHELL_CONFIG_DIR** — path to ~/.blueshell (resolved).
- **BLUESHELL_VERSION** — BlueShell version string (e.g. from module manifest).
- **BLUESHELL_ROOT** — absolute path to the base BlueShell module root (directory containing BlueShell.psm1). Overrides default when set before load.
- **BLUESHELL_ACTIVE_PRESET** — current preset name, if any (mirrors activePreset).
- **BLUESHELL_MODULE_ROOTS** — semicolon-separated (Windows) or colon-separated (Unix) list of module roots in config order, or a single env per module: **BLUESHELL_MODULE_&lt;ModuleName&gt;** (e.g. BLUESHELL_MODULE_DanBlueShell) for each module in moduleRoots.
- **BLUESHELL_INTERACTIVE** — when set to a truthy value (e.g. `true`, `1`), enables interactive mode (banner, messages). Default is unset/quiet.
- **BLUESHELL_QUIET** — when set to a truthy value, forces quiet mode (overrides interactive for non-interactive scripts). Used for scripting.

Specification of per-module env vars: the base MAY set `BLUESHELL_MODULE_<ModuleName>` for each key in moduleRoots, with value the path, so that scripts can reference e.g. `$env:BLUESHELL_MODULE_DanBlueShell`.

---

## 4. Default quiet / interactive opt-in

- **Default**: Sessions are **quiet and non-interactive** by default. No banner, no "Loading…" messages, no prompts. Scripts that start a shell which loads BlueShell do not get interactive behavior unless they or the user opt in.
- **Opt-in**: Interactive experience is enabled in two ways, both supported:
  1. **Environment variable**: **BLUESHELL_INTERACTIVE** set to a truthy value (e.g. `true` or `1`).
  2. **Function**: **Enable-BlueShellInteractive** (provided by base) — sets the env var or equivalent state so that the current session becomes interactive.
- **Documentation**: The spec and user docs must state that users typically call `Enable-BlueShellInteractive` or set `BLUESHELL_INTERACTIVE` in their profile for interactive terminals only, so that non-interactive scripts (e.g. CI) do not see banners or prompts.

---

## 5. Four-phase auto-load

### 5.1 Step names and file pattern

- **Step names** (in order): **env**, **secret**, **bootstrap**, **init**.
- **File pattern**: **\*.{stepName}.auto.ps1** — e.g. **\*.env.auto.ps1**, **\*.secret.auto.ps1**, **\*.bootstrap.auto.ps1**, **\*.init.auto.ps1**.
- **Discovery**: **Recursive** under each module root and under base **src/** (so files in any subfolder are included). All matching files for a step are executed (order may be deterministic, e.g. by path sort).
- **Configurable steps**: The list of steps and their order are configurable in the base (e.g. an ordered list of step names). New steps can be added or reordered; the file pattern remains `*.{stepName}.auto.ps1` for each step name.

### 5.2 Step semantics

1. **Environment (env)**: Only set env vars and known config values. No function definitions, no execution of business logic. Use for PATH, config keys that are mirrored to env, etc.
2. **Secret (secret)**: Git-ignored files; contain secrets. Env or config define empty or placeholder values; secret files overwrite them. If a value is read that was never initialized by a secret file (e.g. new clone, no secret file present), the base **writes the error to output** (e.g. Write-Error) and **throws** a custom error type **BlueShell.SecretNotInitialized**. The error message must include the key name and how to fix (e.g. "Add the key to your secret file or set env VAR_NAME"). No silent empty values.
3. **Bootstrap (bootstrap)**: Define functions only; do not execute initialization logic. Use for dot-sourcing function definitions.
4. **Init (init)**: Run initialization logic. All functions are already defined; this phase may call functions, register providers, etc.

### 5.3 Execution order

- **Base first, fully**: Run all four steps for the base module (env → secret → bootstrap → init). Base is fully loaded before any extension step runs.
- **Then per-step, all extensions**: For each step in order, run that step for **all** extension modules. Order: all extensions env → all extensions secret → all extensions bootstrap → all extensions init.

Total order: Base env → Base secret → Base bootstrap → Base init → Ext1 env, Ext2 env, … → Ext1 secret, Ext2 secret, … → Ext1 bootstrap, Ext2 bootstrap, … → Ext1 init, Ext2 init, …

---

## 6. Rules and skills as provider pattern

- **Base**: Defines topics **AgentRules** and **AgentSkills** (or equivalent names) with a JSON Schema (e.g. rule/skill id, name, path or content). Base provides core functions to **list**, **enable**, **disable** (copy to or remove from agent-visible locations). Discovery is implemented by calling `Get-BlueShellTopicData` for these topics; the result is the union of all provider responses.
- **Modules**: Do **not** implement their own store logic. They **register providers** for `AgentRules` and/or `AgentSkills` that return their rules/skills (e.g. list of { name, path } or { id, path }). Base's enable/disable logic uses this data to copy or remove files.
- **Agent-visible locations**: Rules are copied to **.cursor/rules/** (relative to the project or a documented workspace root). Skills are copied to the **Cursor skills path** — the exact path is the Cursor application/user skills directory (e.g. under user profile or .cursor; the spec documents the default path used by the base, e.g. `~/.cursor/skills/` or the Cursor-documented location). There is **no environment variable override** for these two locations; they are fixed in the base and documented here.

**Cursor skills path (documented default)**: For Cursor IDE, skills are typically stored in the user's Cursor settings directory. The base will use: **%USERPROFILE%\\.cursor\\skills** (Windows) and **~/.cursor/skills** (macOS/Linux) unless Cursor documents a different path, in which case the implementation and this spec will be updated to that path.

---

## 7. Reload and branch/root switching

- **Reload-BlueShell**: Idempotent. Cleans or removes the current module state (e.g. Remove-Module BlueShell), resets `$env:PATH` to a baseline (saved at startup or from config), then re-imports **src/BlueShell.psm1** (so bootstrap runs again: config, four phases for base then extensions). Result: current session has up-to-date functions and env. No interactive prompts; quiet mode applies.
- **Set-BlueShellComponentRoot**: Updates the config (e.g. for a given component name, set its path) and then calls Reload-BlueShell so the current session sees the change immediately.
- **Switch-BlueShellEnvironment** (or equivalent): Accepts a preset name; loads that preset from presets.json and applies the paths (e.g. to moduleRoots or session state), then calls Reload-BlueShell. No git operations; only config/preset file and path updates plus reload.

---

## 8. Setup and orchestrator

- **Base setup** (e.g. **Install-BlueShell** or **Setup-BlueShell**): Ensures PowerShell profile exists; ensures profile loads BlueShell from the current base root (or from **BLUESHELL_ROOT** if set); ensures config directory and config.json exist (create empty or with defaults if missing); idempotent (skip if already configured).
- **Per-module setup**: Each module has a setup script (e.g. **Setup-&lt;Module&gt;** or **Install-&lt;Module&gt;**). It ensures the module's root is registered in config (moduleRoots) and optionally registers rules/skills providers; idempotent.
- **Single entry point**: One command (e.g. **Install-DevEnvironment** or **Initialize-DevEnvironment**) that: (1) ensures base is installed (run base setup), (2) discovers available modules (e.g. from config, or a list, or env **BLUESHELL_MODULES**), (3) for each available module runs that module's setup script. The orchestrator lives in the base and invokes each module's setup by path (from config or discovery).

---

## 9. PowerShell 7 and install scripts

- **Runtime**: BlueShell requires **PowerShell 7** (pwsh). All scripts and documentation assume pwsh 7 is available.
- **Install scripts**: 
  - **Install-BlueShell.ps1** (Windows): Run with PowerShell (any version) or pwsh. Performs all installation steps including checking for and installing PowerShell 7 if missing. Then configures profile and BlueShell as above.
  - **Install-BlueShell.sh** (macOS and Linux): Run with bash/sh. Installs PowerShell 7 if needed (e.g. via package manager), then invokes pwsh to run the rest of the setup (profile, config, etc.).
- Running the install is a one-time (or as-needed) prerequisite, independent of the BlueShell module load sequence. The base assumes pwsh 7 is available when the module is loaded.

---

## 10. Cross-platform

- **Target**: All behavior and scripts run on **PowerShell 7** on Windows, macOS, and Linux. Paths, line endings, and platform-specific commands must be abstracted or conditional.
- **Testing**: Where feasible, tests run on all three platforms; any platform-specific tests are documented. CI or agent instructions call out cross-platform verification.
- **Agent instructions**: AGENTS.md and .cursor/rules state that code must be cross-platform; avoid Windows-only or Unix-only assumptions unless abstracted; document any unavoidable platform differences.

---

## 11. Base repository layout

- **Entry point**: **src/BlueShell.psm1** — the file that is `Import-Module`'d.
- **Script folders**: **src/bootstrap/**, **src/config/**, **src/env/**, **src/core/**.
- **Tests**: **src/tests/** — structure mirrors src/ where relevant (e.g. tests/config/, tests/bootstrap/, tests/env/, tests/core/).
- **Docs**: **docs/** — specification.md, tasks.md, recommended-agent-skills.md.

Modules have **no required** top-level folder names; layout is by convention. Auto-load discovers scripts recursively by the pattern **\*.{stepName}.auto.ps1** under each module root.

---

## 12. Testability

- **Test framework**: Pester v5 (or equivalent) for PowerShell. Tests live in **src/tests/**.
- **Scope**: Config load and override; bootstrap and four-phase order; reload idempotency and PATH reinit; switch (config update and reload); setup idempotency; quiet mode (no output when BLUESHELL_QUIET or default); provider/topic registration and pull/push.
- **Isolation**: Tests must not depend on real user profile or global machine config. Use temp directories, mock or override config path, and optionally a test-specific profile path so production config is untouched.
- **CI**: Tests must be runnable non-interactively (e.g. `Invoke-Pester` or `./src/tests/Invoke-Tests.ps1`). Design so tests do not require loading the full interactive environment unless testing that explicitly.

---

## 13. Error type

- **BlueShell.SecretNotInitialized**: Thrown when a secret value is accessed but was never set (missing secret file or key). Base writes the error to output (e.g. Write-Error) and then throws this type. Message includes key name and remediation (e.g. add to secret file or set env).
