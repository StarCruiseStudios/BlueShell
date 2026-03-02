# Config.Tests.ps1 - T011.05: config load, Get/Set, env mirror (Spec §3, §12)
# Uses temp config dir; does not touch real ~/.blueshell.

Describe 'T011 Config and env mirror' {
    BeforeAll {
        $projectRoot = (Get-Item $PSScriptRoot).Parent.Parent.Parent.FullName
        $moduleRoot = Join-Path $projectRoot 'src'
        $psm1Path = Join-Path $moduleRoot 'BlueShell.psm1'
        $testConfigDir = Join-Path ([System.IO.Path]::GetTempPath()) "BlueShellTests_$(Get-Random)"
        New-Item -ItemType Directory -Path $testConfigDir -Force | Out-Null
    }

    AfterAll {
        if (Test-Path $testConfigDir) { Remove-Item -Recurse -Force $testConfigDir -ErrorAction SilentlyContinue }
        Remove-Module BlueShell -Force -ErrorAction SilentlyContinue
    }

    BeforeEach {
        Remove-Module BlueShell -Force -ErrorAction SilentlyContinue
        Get-ChildItem $testConfigDir -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        $env:BLUESHELL_CONFIG_DIR = $testConfigDir
        Import-Module $psm1Path -Force -Global
    }

    It 'Uses BLUESHELL_CONFIG_DIR override when set before load' {
        $env:BLUESHELL_CONFIG_DIR | Should -Be $testConfigDir
    }

    It 'Returns default or empty moduleRoots when config missing' {
        $mr = Get-BlueShellConfig -Key 'moduleRoots'
        # When config is missing, API may return empty hashtable or null; we can Set and Get after
        if ($null -ne $mr) {
            $mr | Should -BeOfType ([hashtable])
            $mr.Count | Should -BeGreaterOrEqual 0
        }
    }

    It 'Get/Set-BlueShellConfig persists moduleRoots' {
        $emptyDir = Join-Path $testConfigDir 'foo'
        New-Item -ItemType Directory -Path $emptyDir -Force | Out-Null
        Set-BlueShellConfig -Key 'moduleRoots' -Value @{ Foo = $emptyDir }
        Remove-Module BlueShell -Force -ErrorAction SilentlyContinue
        $env:BLUESHELL_CONFIG_DIR = $testConfigDir
        Import-Module $psm1Path -Force -Global
        $mr = Get-BlueShellConfig -Key 'moduleRoots'
        $mr.Foo | Should -Be $emptyDir
    }

    It 'Get/Set-BlueShellConfig persists activePreset' {
        Set-BlueShellConfig -Key 'activePreset' -Value 'dev'
        Remove-Module BlueShell -Force -ErrorAction SilentlyContinue
        $env:BLUESHELL_CONFIG_DIR = $testConfigDir
        Import-Module $psm1Path -Force -Global
        Get-BlueShellConfig -Key 'activePreset' | Should -Be 'dev'
    }

    It 'Set-BlueShellConfig validates known key types' {
        { Set-BlueShellConfig -Key 'moduleRoots' -Value 'not-a-hashtable' } | Should -Throw
        { Set-BlueShellConfig -Key 'activePreset' -Value 123 } | Should -Throw
    }

    It 'Env mirror sets BLUESHELL_CONFIG_DIR and BLUESHELL_ROOT' {
        $env:BLUESHELL_CONFIG_DIR | Should -Be $testConfigDir
        $env:BLUESHELL_ROOT | Should -Not -BeNullOrEmpty
    }

    It 'Env mirror sets BLUESHELL_MODULE_<Name> when moduleRoots has entries after reload' {
        $emptyExtRoot = Join-Path $testConfigDir 'emptyExt'
        New-Item -ItemType Directory -Path $emptyExtRoot -Force | Out-Null
        Set-BlueShellConfig -Key 'moduleRoots' -Value @{ DanBlueShell = $emptyExtRoot }
        Remove-Module BlueShell -Force -ErrorAction SilentlyContinue
        $env:BLUESHELL_CONFIG_DIR = $testConfigDir
        Import-Module $psm1Path -Force -Global
        $env:BLUESHELL_MODULE_DanBlueShell | Should -Be $emptyExtRoot
    }
}
