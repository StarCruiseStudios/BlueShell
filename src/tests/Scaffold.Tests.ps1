# Scaffold.Tests.ps1 - T010.03: basic scaffold and entry point (Spec §12)
# Uses isolated env; does not touch real config.
# Requires Pester v5.

Describe 'T010 scaffold and entry point' {
    BeforeAll {
        $projectRoot = (Get-Item $PSScriptRoot).Parent.Parent.FullName
        $moduleRoot = Join-Path $projectRoot 'src'
        $psm1Path = Join-Path $moduleRoot 'BlueShell.psm1'
    }

    It 'BlueShell.psm1 exists' {
        Test-Path $psm1Path | Should -BeTrue
    }

    It 'Script folders exist' {
        @('bootstrap', 'config', 'env', 'core') | ForEach-Object {
            Join-Path $moduleRoot $_ | Should -Exist
        }
    }

    It 'Tests structure exists' {
        $testsRoot = Join-Path $projectRoot 'src' 'tests'
        @('bootstrap', 'config', 'env', 'core') | ForEach-Object {
            Join-Path $testsRoot $_ | Should -Exist
        }
        Join-Path $testsRoot 'Invoke-Tests.ps1' | Should -Exist
    }

    It 'Module loads and exposes Get-BlueShellRoot' {
        $origPSModulePath = $env:PSModulePath
        try {
            $env:PSModulePath = $moduleRoot + [System.IO.Path]::PathSeparator + $env:PSModulePath
            Remove-Module BlueShell -Force -ErrorAction SilentlyContinue
            Import-Module $psm1Path -Force -Global
            Get-Command Get-BlueShellRoot -ErrorAction Stop | Should -Not -BeNullOrEmpty
            $root = Get-BlueShellRoot
            $root | Should -Be $moduleRoot
        } finally {
            Remove-Module BlueShell -Force -ErrorAction SilentlyContinue
            $env:PSModulePath = $origPSModulePath
        }
    }
}
