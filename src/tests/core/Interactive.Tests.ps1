# Interactive.Tests.ps1 - T015.04: quiet vs interactive (Spec §4, §12)

Describe 'T015 Quiet and interactive opt-in' {
    BeforeAll {
        $projectRoot = (Get-Item $PSScriptRoot).Parent.Parent.Parent.FullName
        $moduleRoot = Join-Path $projectRoot 'src'
        $psm1Path = Join-Path $moduleRoot 'BlueShell.psm1'
        $testConfigDir = Join-Path ([System.IO.Path]::GetTempPath()) "BlueShellInteractiveTests_$(Get-Random)"
        New-Item -ItemType Directory -Path $testConfigDir -Force | Out-Null
    }

    AfterAll {
        if (Test-Path $testConfigDir) { Remove-Item -Recurse -Force $testConfigDir -ErrorAction SilentlyContinue }
        Remove-Module BlueShell -Force -ErrorAction SilentlyContinue
    }

    BeforeEach {
        Remove-Module BlueShell -Force -ErrorAction SilentlyContinue
        $env:BLUESHELL_CONFIG_DIR = $testConfigDir
        $env:BLUESHELL_INTERACTIVE = ''
        $env:BLUESHELL_QUIET = ''
    }

    It 'Enable-BlueShellInteractive sets BLUESHELL_INTERACTIVE' {
        Import-Module $psm1Path -Force -Global
        Enable-BlueShellInteractive
        $env:BLUESHELL_INTERACTIVE | Should -Be 'true'
    }

    It 'Test-BlueShellInteractive is false when BLUESHELL_INTERACTIVE unset' {
        Import-Module $psm1Path -Force -Global
        $env:BLUESHELL_INTERACTIVE = ''
        Test-BlueShellInteractive | Should -BeFalse
    }

    It 'Test-BlueShellInteractive is true after Enable-BlueShellInteractive' {
        Import-Module $psm1Path -Force -Global
        Enable-BlueShellInteractive
        Test-BlueShellInteractive | Should -BeTrue
    }

    It 'Test-BlueShellInteractive is false when BLUESHELL_QUIET is set' {
        Import-Module $psm1Path -Force -Global
        $env:BLUESHELL_QUIET = '1'
        $env:BLUESHELL_INTERACTIVE = 'true'
        Test-BlueShellInteractive | Should -BeFalse
    }
}
