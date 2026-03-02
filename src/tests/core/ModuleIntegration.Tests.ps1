# ModuleIntegration.Tests.ps1 - T032.01: load temp module and assert participation (Spec §12)

Describe 'T032 Module integration' {
    BeforeAll {
        $projectRoot = (Get-Item $PSScriptRoot).Parent.Parent.Parent.FullName
        $moduleRoot = Join-Path $projectRoot 'src'
        $psm1Path = Join-Path $moduleRoot 'BlueShell.psm1'
        $testConfigDir = Join-Path ([System.IO.Path]::GetTempPath()) "BlueShellModuleIntegration_$(Get-Random)"
        New-Item -ItemType Directory -Path $testConfigDir -Force | Out-Null
        $minimalExtRoot = Join-Path $testConfigDir 'MinimalExt'
        New-Item -ItemType Directory -Path $minimalExtRoot -Force | Out-Null
        # Env script: set marker so we know extension was loaded
        Set-Content -Path (Join-Path $minimalExtRoot 'minimal.env.auto.ps1') -Value @"
`$env:BLUESHELL_MODULE_INTEGRATION_TEST = 'loaded'
"@
        # Init script: register provider for AgentRules (topic already defined by base)
        Set-Content -Path (Join-Path $minimalExtRoot 'minimal.init.auto.ps1') -Value @"
Register-BlueShellTopicProvider -Topic 'AgentRules' -Provider {
    [PSCustomObject]@{ id = 'minimal'; name = 'minimal.md'; path = 'C:\fake\minimal.md' }
}
"@
    }

    AfterAll {
        if (Test-Path $testConfigDir) { Remove-Item -Recurse -Force $testConfigDir -ErrorAction SilentlyContinue }
        Remove-Module BlueShell -Force -ErrorAction SilentlyContinue
        Remove-Item Env:BLUESHELL_MODULE_INTEGRATION_TEST -ErrorAction SilentlyContinue
    }

    BeforeEach {
        Remove-Module BlueShell -Force -ErrorAction SilentlyContinue
        Remove-Item Env:BLUESHELL_MODULE_INTEGRATION_TEST -ErrorAction SilentlyContinue
        $env:BLUESHELL_CONFIG_DIR = $testConfigDir
        $configPath = Join-Path $testConfigDir 'config.json'
        @{ moduleRoots = @{ MinimalExt = $minimalExtRoot }; activePreset = '' } | ConvertTo-Json -Depth 5 | Set-Content -Path $configPath -Encoding utf8
    }

    It 'Loads extension and runs env script (env var set)' {
        Import-Module $psm1Path -Force -Global
        $env:BLUESHELL_MODULE_INTEGRATION_TEST | Should -Be 'loaded'
    }

    It 'Extension provider is invoked and Get-BlueShellTopicData returns its output' {
        Import-Module $psm1Path -Force -Global
        $data = Get-BlueShellTopicData -Topic 'AgentRules'
        $data | Should -Not -BeNullOrEmpty
        $flat = @()
        foreach ($r in $data) {
            if ($r -is [array]) { $flat += $r } else { $flat += $r }
        }
        $minimal = $flat | Where-Object { $_.id -eq 'minimal' }
        $minimal | Should -Not -BeNullOrEmpty
        $minimal.name | Should -Be 'minimal.md'
    }
}
