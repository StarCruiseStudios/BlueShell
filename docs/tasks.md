# BlueShell Ecosystem — Implementation Tasks

Step-by-step implementation plan. Each task and subtask has a unique ID and a reference to the specification. Check off items as they are completed.

---

## Phase 0 — Migration (all three repos)

- [ ] **T001** — Migrate BlueShell repo to V0 and prepare blank slate  
  Spec: §1 Architecture, §11 Base repository layout  

  - [ ] **T001.01** Copy existing repo root contents (excluding `.git`, optionally `.cursor`) into **V0/** in BlueShell repo.
  - [ ] **T001.02** Add **.cursorignore** so **V0/** is ignored by agents (editing and codebase answers).
  - [ ] **T001.03** Add **.cursor/rules/** and/or **AGENTS.md** at repo root stating root is the active codebase, V0 is legacy reference only, and design is from-scratch; point agents at new layout and tests.

- [ ] **T002** — Migrate DanBlueShell repo to V0 and prepare blank slate  
  Spec: §1 Architecture  

  - [ ] **T002.01** Copy existing repo root contents (excluding `.git`, optionally `.cursor`) into **V0/** in DanBlueShell repo.
  - [ ] **T002.02** Add **.cursorignore** so **V0/** is ignored by agents.
  - [ ] **T002.03** Add **.cursor/rules/** and/or **AGENTS.md** stating root is active codebase, V0 is reference only.

- [ ] **T003** — Migrate ScsBlueShell repo to V0 and prepare blank slate  
  Spec: §1 Architecture  

  - [ ] **T003.01** Copy existing repo root contents (excluding `.git`, optionally `.cursor`) into **V0/** in ScsBlueShell repo.
  - [ ] **T003.02** Add **.cursorignore** so **V0/** is ignored by agents.
  - [ ] **T003.03** Add **.cursor/rules/** and/or **AGENTS.md** stating root is active codebase, V0 is reference only.

---

## Phase 1 — Base BlueShell (scaffold, config, load, provider, reload, setup, tests)

- [ ] **T010** — Create base repo scaffold and entry point  
  Spec: §11 Base repository layout  

  - [ ] **T010.01** Create **src/BlueShell.psm1** as module entry; set globals (e.g. BlueShellRoot from $PSScriptRoot) and trigger bootstrap.
  - [ ] **T010.02** Create folders **src/bootstrap/**, **src/config/**, **src/env/**, **src/core/**.
  - [ ] **T010.03** Create **src/tests/** with structure (e.g. tests/bootstrap/, tests/config/, tests/env/, tests/core/) and a test runner (e.g. Invoke-Pester config).

- [ ] **T011** — Implement config read/write and env mirror  
  Spec: §3 Configuration  

  - [ ] **T011.01** Implement resolution of config directory **~/.blueshell/** per platform (Windows/macOS/Linux).
  - [ ] **T011.02** Implement read/write of **config.json** (moduleRoots, activePreset) and **presets.json** (convention: same directory).
  - [ ] **T011.03** Implement **Get-BlueShellConfig** and **Set-BlueShellConfig** with **-Key** and **-Value**; validate known keys and types.
  - [ ] **T011.04** Implement env var mirror: set **BLUESHELL_CONFIG_DIR**, **BLUESHELL_VERSION**, **BLUESHELL_ROOT**, **BLUESHELL_ACTIVE_PRESET**, **BLUESHELL_MODULE_&lt;Name&gt;** (per moduleRoots), **BLUESHELL_INTERACTIVE**, **BLUESHELL_QUIET** during bootstrap and keep in sync on config change.
  - [ ] **T011.05** Add tests for config load, default/missing config, and env mirror (Spec §12).

- [ ] **T012** — Implement four-phase auto-load  
  Spec: §5 Four-phase auto-load  

  - [ ] **T012.01** Implement discovery of **\*.env.auto.ps1**, **\*.secret.auto.ps1**, **\*.bootstrap.auto.ps1**, **\*.init.auto.ps1** recursively under **src/** and under each module root from config.
  - [ ] **T012.02** Implement execution order: base env → base secret → base bootstrap → base init, then all extensions env → all extensions secret → all extensions bootstrap → all extensions init.
  - [ ] **T012.03** Make step list and order configurable (e.g. ordered list of step names).
  - [ ] **T012.04** Implement secret handling: when a secret value is read but never set, write error to output and throw **BlueShell.SecretNotInitialized** (Spec §5.2, §13).
  - [ ] **T012.05** Add tests for phase order, discovery, and secret failure (Spec §12).

- [ ] **T013** — Implement provider/topic mechanism  
  Spec: §2 Provider / topic mechanism  

  - [ ] **T013.01** Implement topic registry: register topic + JSON Schema path; validate schema compatibility (consumer may omit fields; same version must match).
  - [ ] **T013.02** Implement provider registry: register provider (script block or function) for a topic.
  - [ ] **T013.03** Implement **Get-BlueShellTopicData -Topic** returning array of provider responses (one per provider).
  - [ ] **T013.04** Implement **Register-BlueShellTopicSubscription -Topic -Callback** and **Publish-BlueShellTopicEvent -Topic -Payload** for push.
  - [ ] **T013.05** Add tests for register, pull (array), and push (Spec §12).

- [ ] **T014** — Implement reload and branch/root switching  
  Spec: §7 Reload and branch/root switching  

  - [ ] **T014.01** Implement **Reload-BlueShell**: remove/clear module, reset PATH to baseline, re-import src/BlueShell.psm1; idempotent, non-interactive.
  - [ ] **T014.02** Implement **Set-BlueShellComponentRoot** (component name, path): update config then Reload-BlueShell.
  - [ ] **T014.03** Implement **Switch-BlueShellEnvironment** (preset name): load preset from presets.json, apply paths, then Reload-BlueShell.
  - [ ] **T014.04** Add tests for reload idempotency and switch (Spec §12).

- [ ] **T015** — Implement default quiet and interactive opt-in  
  Spec: §4 Default quiet / interactive opt-in  

  - [ ] **T015.01** Default: no banner, no loading messages (respect **BLUESHELL_QUIET** or unset **BLUESHELL_INTERACTIVE**).
  - [ ] **T015.02** When **BLUESHELL_INTERACTIVE** is truthy, show banner and loading messages.
  - [ ] **T015.03** Implement **Enable-BlueShellInteractive** (set env or state so session becomes interactive).
  - [ ] **T015.04** Add tests for quiet vs interactive output (Spec §12).

- [ ] **T016** — Implement rules/skills as providers  
  Spec: §6 Rules and skills as provider pattern  

  - [ ] **T016.01** Define topics **AgentRules** and **AgentSkills** with JSON Schema (e.g. id, name, path).
  - [ ] **T016.02** Implement list/enable/disable for rules and skills using **Get-BlueShellTopicData** for these topics; copy to **.cursor/rules/** and Cursor skills path (Spec §6), remove on disable.
  - [ ] **T016.03** Document Cursor skills path in spec and code (e.g. %USERPROFILE%\\.cursor\\skills and ~/.cursor/skills).
  - [ ] **T016.04** Add tests for enable/disable and provider discovery (Spec §12).

- [ ] **T017** — Implement base setup and orchestrator  
  Spec: §8 Setup and orchestrator  

  - [ ] **T017.01** Implement **Install-BlueShell** (or **Setup-BlueShell**): ensure profile exists, add Start-BlueShell (load src/BlueShell.psm1), ensure ~/.blueshell and config.json exist; idempotent.
  - [ ] **T017.02** Implement **Install-DevEnvironment** (or **Initialize-DevEnvironment**): run base setup, discover modules (from config or BLUESHELL_MODULES), run each module's setup script by path; idempotent.
  - [ ] **T017.03** Add tests for setup idempotency (Spec §12).

- [ ] **T018** — Base docs and agent instructions  
  Spec: §10 Cross-platform, §11 Base repository layout  

  - [ ] **T018.01** Add **AGENTS.md** (and optionally .cursor/rules) in base repo: how to navigate, cross-platform requirements, where scripts and tests live, reload/switch, quiet vs interactive.
  - [ ] **T018.02** Ensure specification.md, tasks.md, recommended-agent-skills.md are present in **docs/** (already created; link from README or AGENTS.md if needed).

---

## Phase 2 — Cross-platform and PowerShell 7 install

- [ ] **T020** — Install scripts and PowerShell 7  
  Spec: §9 PowerShell 7 and install scripts  

  - [ ] **T020.01** Implement **Install-BlueShell.ps1** (Windows): check for PowerShell 7, install if missing; then run profile/config setup (or call base setup in pwsh).
  - [ ] **T020.02** Implement **Install-BlueShell.sh** (macOS and Linux): install pwsh 7 if needed (e.g. package manager), invoke pwsh to run profile/config setup.
  - [ ] **T020.03** Document in specification.md and README that BlueShell requires pwsh 7 and how to run install scripts.

- [ ] **T021** — Cross-platform testing and agent rules  
  Spec: §10 Cross-platform  

  - [ ] **T021.01** Add or extend tests to run on Windows, macOS, Linux where feasible; document any platform-specific tests.
  - [ ] **T021.02** In AGENTS.md and .cursor/rules, state that code must be cross-platform and document any unavoidable platform differences.

---

## Phase 3 — Modules (DanBlueShell, ScsBlueShell)

- [ ] **T030** — DanBlueShell from-scratch layout and setup  
  Spec: §1 Architecture, §5 discovery, §8 per-module setup  

  - [ ] **T030.01** Create module layout by convention (e.g. scripts by concern); add **\*.env.auto.ps1**, **\*.secret.auto.ps1** (or omit secret if none), **\*.bootstrap.auto.ps1**, **\*.init.auto.ps1** as needed.
  - [ ] **T030.02** Implement **Setup-DanBlueShell** (or **Install-DanBlueShell**): register DanBlueShell root in config (moduleRoots); idempotent.
  - [ ] **T030.03** Add **tests/** for DanBlueShell-specific behavior (e.g. PATH, helpers); add AGENTS.md.
  - [ ] **T030.04** Optionally register providers for topics (e.g. AgentRules, or a custom topic); ensure no direct dependency on ScsBlueShell.

- [ ] **T031** — ScsBlueShell from-scratch layout and setup  
  Spec: §1 Architecture, §5 discovery, §8 per-module setup  

  - [ ] **T031.01** Create module layout by convention; add four-phase auto-load scripts as needed.
  - [ ] **T031.02** Implement **Setup-ScsBlueShell** (or **Install-ScsBlueShell**): register ScsBlueShell root in config; idempotent.
  - [ ] **T031.03** Add **tests/** for ScsBlueShell-specific behavior; add AGENTS.md.
  - [ ] **T031.04** Register providers for AgentRules/AgentSkills and any custom topics; ensure no direct dependency on DanBlueShell.

- [ ] **T032** — Base integration tests for modules  
  Spec: §12 Testability  

  - [ ] **T032.01** Add integration tests in base **src/tests/** that load a test module from a temp path (e.g. minimal module with one provider) and assert it is loaded and exports/participates correctly.
