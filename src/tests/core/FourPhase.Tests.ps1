# FourPhase.Tests.ps1 - T012.05: phase order, discovery, secret failure (Spec §5, §12)

Describe 'T012 Four-phase auto-load' {
    BeforeAll {
        $projectRoot = (Get-Item $PSScriptRoot).Parent.Parent.Parent.FullName
        $moduleRoot = Join-Path $projectRoot 'src'
        $psm1Path = Join-Path $moduleRoot 'BlueShell.psm1'
        $testConfigDir = Join-Path ([System.IO.Path]::GetTempPath()) "BlueShellPhaseTests_$(Get-Random)"
        New-Item -ItemType Directory -Path $testConfigDir -Force | Out-Null
    }

    AfterAll {
        if (Test-Path $testConfigDir) { Remove-Item -Recurse -Force $testConfigDir -ErrorAction SilentlyContinue }
        Remove-Module BlueShell -Force -ErrorAction SilentlyContinue
    }

    BeforeEach {
        Remove-Module BlueShell -Force -ErrorAction SilentlyContinue
        $env:BLUESHELL_CONFIG_DIR = $testConfigDir
        Get-ChildItem $testConfigDir -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    }

    It 'Discovers and runs *.env.auto.ps1 under extension root' {
        $extRoot = Join-Path $testConfigDir 'ext'
        New-Item -ItemType Directory -Path $extRoot -Force | Out-Null
        Set-Content -Path (Join-Path $extRoot 'mymod.env.auto.ps1') -Value "`$env:BLUESHELL_PHASE_TEST = 'ran'"
        $configPath = Join-Path $testConfigDir 'config.json'
        @{ moduleRoots = @{ TestExt = $extRoot }; activePreset = '' } | ConvertTo-Json -Depth 5 | Set-Content -Path $configPath -Encoding utf8
        Import-Module $psm1Path -Force -Global
        $env:BLUESHELL_PHASE_TEST | Should -Be 'ran'
        Remove-Item Env:BLUESHELL_PHASE_TEST -ErrorAction SilentlyContinue
    }

    It 'Get-BlueShellSecret throws BlueShell.SecretNotInitialized when key not set' {
        Import-Module $psm1Path -Force -Global
        try {
            $null = Get-BlueShellSecret -Key 'NonexistentKey'
            $true | Should -BeFalse
        } catch {
            # ErrorRecord.FullyQualifiedErrorId is set in our throw (Spec §13)
            $id = if ($_.ErrorRecord) { $_.ErrorRecord.FullyQualifiedErrorId } else { $_.FullyQualifiedErrorId }
            $id | Should -Be 'BlueShell.SecretNotInitialized'
        }
    }

    It 'Set-BlueShellSecret and Get-BlueShellSecret round-trip' {
        Import-Module $psm1Path -Force -Global
        Set-BlueShellSecret -Key 'TestKey' -Value 'TestValue'
        Get-BlueShellSecret -Key 'TestKey' | Should -Be 'TestValue'
    }

    It 'Test-BlueShellSecret returns false when key not set' {
        Import-Module $psm1Path -Force -Global
        Test-BlueShellSecret -Key 'NotSet' | Should -BeFalse
    }

    It 'Test-BlueShellSecret returns true after Set-BlueShellSecret' {
        Import-Module $psm1Path -Force -Global
        Set-BlueShellSecret -Key 'K' -Value 'V'
        Test-BlueShellSecret -Key 'K' | Should -BeTrue
    }
}
