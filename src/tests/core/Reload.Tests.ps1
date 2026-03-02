# Reload.Tests.ps1 - T014.04: reload idempotency, switch preset (Spec §7, §12)

Describe 'T014 Reload and switch' {
    BeforeAll {
        $projectRoot = (Get-Item $PSScriptRoot).Parent.Parent.Parent.FullName
        $moduleRoot = Join-Path $projectRoot 'src'
        $psm1Path = Join-Path $moduleRoot 'BlueShell.psm1'
        $testConfigDir = Join-Path ([System.IO.Path]::GetTempPath()) "BlueShellReloadTests_$(Get-Random)"
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

    It 'Reload-BlueShell is idempotent' {
        Import-Module $psm1Path -Force -Global
        Reload-BlueShell
        Reload-BlueShell
        Get-Command Get-BlueShellRoot -ErrorAction Stop | Should -Not -BeNullOrEmpty
    }

    It 'Set-BlueShellComponentRoot updates config and reloads' {
        $emptyDir = Join-Path $testConfigDir 'comp'
        New-Item -ItemType Directory -Path $emptyDir -Force | Out-Null
        Import-Module $psm1Path -Force -Global
        Set-BlueShellComponentRoot -ComponentName 'TestMod' -Path $emptyDir
        (Get-BlueShellConfig -Key 'moduleRoots').TestMod | Should -Be $emptyDir
    }

    It 'Switch-BlueShellEnvironment applies preset and reloads' {
        $dir1 = Join-Path $testConfigDir 'p1'
        $dir2 = Join-Path $testConfigDir 'p2'
        New-Item -ItemType Directory -Path $dir1, $dir2 -Force | Out-Null
        $presetsPath = Join-Path $testConfigDir 'presets.json'
        @{
            dev = @{ BlueShell = $moduleRoot; M1 = $dir1 }
            main = @{ BlueShell = $moduleRoot; M1 = $dir2 }
        } | ConvertTo-Json -Depth 5 | Set-Content -Path $presetsPath -Encoding utf8
        Import-Module $psm1Path -Force -Global
        Switch-BlueShellEnvironment -PresetName 'main'
        (Get-BlueShellConfig -Key 'moduleRoots').M1 | Should -Be $dir2
    }
}
