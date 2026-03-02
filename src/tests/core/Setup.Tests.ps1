# Setup.Tests.ps1 - T017.03: setup idempotency (Spec §8, §12)

Describe 'T017 Base setup and orchestrator' {
    BeforeAll {
        $projectRoot = (Get-Item $PSScriptRoot).Parent.Parent.Parent.FullName
        $moduleRoot = Join-Path $projectRoot 'src'
        $psm1Path = Join-Path $moduleRoot 'BlueShell.psm1'
        $testConfigDir = Join-Path ([System.IO.Path]::GetTempPath()) "BlueShellSetupTests_$(Get-Random)"
        New-Item -ItemType Directory -Path $testConfigDir -Force | Out-Null
        $testProfilePath = Join-Path $testConfigDir 'profile.ps1'
    }

    AfterAll {
        if (Test-Path $testConfigDir) { Remove-Item -Recurse -Force $testConfigDir -ErrorAction SilentlyContinue }
        Remove-Module BlueShell -Force -ErrorAction SilentlyContinue
    }

    BeforeEach {
        Remove-Module BlueShell -Force -ErrorAction SilentlyContinue
        $env:BLUESHELL_CONFIG_DIR = $testConfigDir
        if (Test-Path $testProfilePath) { Remove-Item $testProfilePath -Force }
    }

    It 'Install-BlueShell creates config dir and config.json when missing' {
        Import-Module $psm1Path -Force -Global
        Get-ChildItem $testConfigDir -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Install-BlueShell -ProfilePath $testProfilePath
        Test-Path (Join-Path $testConfigDir 'config.json') | Should -BeTrue
    }

    It 'Install-BlueShell is idempotent (second run does not duplicate profile line)' {
        Import-Module $psm1Path -Force -Global
        Install-BlueShell -ProfilePath $testProfilePath
        $content1 = Get-Content -Raw -Path $testProfilePath -ErrorAction SilentlyContinue
        Install-BlueShell -ProfilePath $testProfilePath
        $content2 = Get-Content -Raw -Path $testProfilePath -ErrorAction SilentlyContinue
        $count1 = ([regex]::Matches($content1, 'Import-Module')).Count
        $count2 = ([regex]::Matches($content2, 'Import-Module')).Count
        $count1 | Should -Be $count2
    }
}
