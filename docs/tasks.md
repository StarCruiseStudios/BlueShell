# BlueShell Ecosystem — Implementation Tasks

Step-by-step implementation plan. Each task and subtask has a unique ID and a reference to the specification. Check off items as they are completed.

---

## Phase 0 — Migration (all three repos)

- [x] **T001** — Migrate BlueShell repo to V0 and prepare blank slate  
  Spec: §1 Architecture, §11 Base repository layout  

  - [x] **T001.01** Copy existing repo root contents (excluding `.git`, optionally `.cursor`) into **V0/** in BlueShell repo.
  - [x] **T001.02** Add **.cursorignore** so **V0/** is ignored by agents (editing and codebase answers).
  - [x] **T001.03** Add **.cursor/rules/** and/or **AGENTS.md** at repo root stating root is the active codebase, V0 is legacy reference only, and design is from-scratch; point agents at new layout and tests.

- [x] **T002** — Migrate DanBlueShell repo to V0 and prepare blank slate  
  Spec: §1 Architecture  

  - [x] **T002.01** Copy existing repo root contents (excluding `.git`, optionally `.cursor`) into **V0/** in DanBlueShell repo.
  - [x] **T002.02** Add **.cursorignore** so **V0/** is ignored by agents.
  - [x] **T002.03** Add **.cursor/rules/** and/or **AGENTS.md** stating root is active codebase, V0 is reference only.

- [x] **T003** — Migrate ScsBlueShell repo to V0 and prepare blank slate  
  Spec: §1 Architecture  

  - [x] **T003.01** Copy existing repo root contents (excluding `.git`, optionally `.cursor`) into **V0/** in ScsBlueShell repo.
  - [x] **T003.02** Add **.cursorignore** so **V0/** is ignored by agents.
  - [x] **T003.03** Add **.cursor/rules/** and/or **AGENTS.md** stating root is active codebase, V0 is reference only.

---

## Phase 1 — Base BlueShell (scaffold, config, load, provider, reload, setup, tests)

- [x] **T010** — Create base repo scaffold and entry point  
  Spec: §11 Base repository layout  

  - [x] **T010.01** Create **src/BlueShell.psm1** as module entry; set globals (e.g. BlueShellRoot from $PSScriptRoot) and trigger bootstrap.
  - [x] **T010.02** Create folders **src/bootstrap/**, **src/config/**, **src/env/**, **src/core/**.
  - [x] **T010.03** Create **src/tests/** with structure (e.g. tests/bootstrap/, tests/config/, tests/env/, tests/core/) and a test runner (e.g. Invoke-Pester config).

- [x] **T011** — Implement config read/write and env mirror  
  Spec: §3 Configuration  

  - [x] **T011.01** Implement resolution of config directory **~/.blueshell/** per platform (Windows/macOS/Linux).
  - [x] **T011.02** Implement read/write of **config.json** (moduleRoots, activePreset) and **presets.json** (convention: same directory).
  - [x] **T011.03** Implement **Get-BlueShellConfig** and **Set-BlueShellConfig** with **-Key** and **-Value**; validate known keys and types.
  - [x] **T011.04** Implement env var mirror: set **BLUESHELL_CONFIG_DIR**, **BLUESHELL_VERSION**, **BLUESHELL_ROOT**, **BLUESHELL_ACTIVE_PRESET**, **BLUESHELL_MODULE_&lt;Name&gt;** (per moduleRoots), **BLUESHELL_INTERACTIVE**, **BLUESHELL_QUIET** during bootstrap and keep in sync on config change.
  - [x] **T011.05** Add tests for config load, default/missing config, and env mirror (Spec §12).

- [x] **T012** — Implement four-phase auto-load  
  Spec: §5 Four-phase auto-load  

  - [x] **T012.01** Implement discovery of **\*.env.auto.ps1**, **\*.secret.auto.ps1**, **\*.bootstrap.auto.ps1**, **\*.init.auto.ps1** recursively under **src/** and under each module root from config.
  - [x] **T012.02** Implement execution order: base env → base secret → base bootstrap → base init, then all extensions env → all extensions secret → all extensions bootstrap → all extensions init.
  - [x] **T012.03** Make step list and order configurable (e.g. ordered list of step names).
  - [x] **T012.04** Implement secret handling: when a secret value is read but never set, write error to output and throw **BlueShell.SecretNotInitialized** (Spec §5.2, §13).
  - [x] **T012.05** Add tests for phase order, discovery, and secret failure (Spec §12).

- [x] **T013** — Implement provider/topic mechanism  
  Spec: §2 Provider / topic mechanism  

  - [x] **T013.01** Implement topic registry: register topic + JSON Schema path; validate schema compatibility (consumer may omit fields; same version must match).
  - [x] **T013.02** Implement provider registry: register provider (script block or function) for a topic.
  - [x] **T013.03** Implement **Get-BlueShellTopicData -Topic** returning array of provider responses (one per provider).
  - [x] **T013.04** Implement **Register-BlueShellTopicSubscription -Topic -Callback** and **Publish-BlueShellTopicEvent -Topic -Payload** for push.
  - [x] **T013.05** Add tests for register, pull (array), and push (Spec §12).

- [x] **T014** — Implement reload and branch/root switching  
  Spec: §7 Reload and branch/root switching  

  - [x] **T014.01** Implement **Update-BlueShell** (alias Reload-BlueShell): remove/clear module, reset PATH to baseline, re-import src/BlueShell.psm1; idempotent, non-interactive.
  - [x] **T014.02** Implement **Set-BlueShellComponentRoot** (component name, path): update config then Update-BlueShell.
  - [x] **T014.03** Implement **Switch-BlueShellEnvironment** (preset name): load preset from presets.json, apply paths, then Update-BlueShell.
  - [x] **T014.04** Add tests for reload idempotency and switch (Spec §12).

- [x] **T015** — Implement default quiet and interactive opt-in  
  Spec: §4 Default quiet / interactive opt-in  

  - [x] **T015.01** Default: no banner, no loading messages (respect **BLUESHELL_QUIET** or unset **BLUESHELL_INTERACTIVE**).
  - [x] **T015.02** When **BLUESHELL_INTERACTIVE** is truthy, show banner and loading messages.
  - [x] **T015.03** Implement **Enable-BlueShellInteractive** (set env or state so session becomes interactive).
  - [x] **T015.04** Add tests for quiet vs interactive output (Spec §12).

- [x] **T016** — Implement rules/skills as providers  
  Spec: §6 Rules and skills as provider pattern  

  - [x] **T016.01** Define topics **AgentRules** and **AgentSkills** with JSON Schema (e.g. id, name, path).
  - [x] **T016.02** Implement list/enable/disable for rules and skills using **Get-BlueShellTopicData** for these topics; copy to **.cursor/rules/** and Cursor skills path (Spec §6), remove on disable.
  - [x] **T016.03** Document Cursor skills path in spec and code (e.g. %USERPROFILE%\\.cursor\\skills and ~/.cursor/skills).
  - [x] **T016.04** Add tests for enable/disable and provider discovery (Spec §12).

- [x] **T017** — Implement base setup and orchestrator  
  Spec: §8 Setup and orchestrator  

  - [x] **T017.01** Implement **Install-BlueShell** (or **Setup-BlueShell**): ensure profile exists, add Start-BlueShell (load src/BlueShell.psm1), ensure ~/.blueshell and config.json exist; idempotent.
  - [x] **T017.02** Implement **Install-DevEnvironment** (or **Initialize-DevEnvironment**): run base setup, discover modules (from config or BLUESHELL_MODULES), run each module's setup script by path; idempotent.
  - [x] **T017.03** Add tests for setup idempotency (Spec §12).

- [x] **T018** — Base docs and agent instructions  
  Spec: §10 Cross-platform, §11 Base repository layout  

  - [x] **T018.01** Add **AGENTS.md** (and optionally .cursor/rules) in base repo: how to navigate, cross-platform requirements, where scripts and tests live, reload/switch, quiet vs interactive.
  - [x] **T018.02** Ensure specification.md, tasks.md, recommended-agent-skills.md are present in **docs/** (already created; link from README or AGENTS.md if needed).

---

## Phase 2 — Cross-platform and PowerShell 7 install

- [x] **T020** — Install scripts and PowerShell 7  
  Spec: §9 PowerShell 7 and install scripts  

  - [x] **T020.01** Implement **Install-BlueShell.ps1** (Windows): check for PowerShell 7, install if missing; then run profile/config setup (or call base setup in pwsh).
  - [x] **T020.02** Implement **Install-BlueShell.sh** (macOS and Linux): install pwsh 7 if needed (e.g. package manager), invoke pwsh to run profile/config setup.
  - [x] **T020.03** Document in specification.md and README that BlueShell requires pwsh 7 and how to run install scripts.

- [x] **T021** — Cross-platform testing and agent rules  
  Spec: §10 Cross-platform  

  - [x] **T021.01** Add or extend tests to run on Windows, macOS, Linux where feasible; document any platform-specific tests.
  - [x] **T021.02** In AGENTS.md and .cursor/rules, state that code must be cross-platform and document any unavoidable platform differences.

---

## Phase 3 — Modules (DanBlueShell, ScsBlueShell)

- [x] **T030** — DanBlueShell from-scratch layout and setup  
  Spec: §1 Architecture, §5 discovery, §8 per-module setup  

  - [x] **T030.01** Create module layout by convention (e.g. scripts by concern); add **\*.env.auto.ps1**, **\*.secret.auto.ps1** (or omit secret if none), **\*.bootstrap.auto.ps1**, **\*.init.auto.ps1** as needed.
  - [x] **T030.02** Implement **Setup-DanBlueShell** (or **Install-DanBlueShell**): register DanBlueShell root in config (moduleRoots); idempotent.
  - [x] **T030.03** Add **tests/** for DanBlueShell-specific behavior (e.g. PATH, helpers); add AGENTS.md.
  - [x] **T030.04** Optionally register providers for topics (e.g. AgentRules, or a custom topic); ensure no direct dependency on ScsBlueShell.

- [x] **T031** — ScsBlueShell from-scratch layout and setup  
  Spec: §1 Architecture, §5 discovery, §8 per-module setup  

  - [x] **T031.01** Create module layout by convention; add four-phase auto-load scripts as needed.
  - [x] **T031.02** Implement **Setup-ScsBlueShell** (or **Install-ScsBlueShell**): register ScsBlueShell root in config; idempotent.
  - [x] **T031.03** Add **tests/** for ScsBlueShell-specific behavior; add AGENTS.md.
  - [x] **T031.04** Register providers for AgentRules/AgentSkills and any custom topics; ensure no direct dependency on DanBlueShell.

- [x] **T032** — Base integration tests for modules  
  Spec: §12 Testability  

  - [x] **T032.01** Add integration tests in base **src/tests/** that load a test module from a temp path (e.g. minimal module with one provider) and assert it is loaded and exports/participates correctly.
