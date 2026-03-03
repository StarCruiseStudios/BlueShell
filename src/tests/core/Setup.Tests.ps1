# Setup.Tests.ps1 - T017.03: setup idempotency (Spec §8, §12)

Describe 'T017 Base setup and orchestrator' {
    BeforeAll {
        $projectRoot = (Get-Item $PSScriptRoot).Parent.Parent.Parent.FullName
        $moduleRoot = Join-Path $projectRoot 'src'
        $psm1Path = Join-Path $moduleRoot 'BlueShell.psm1'
        $testConfigDir = Join-Path ([System.IO.Path]::GetTempPath()) "BlueShellSetupTests_$(Get-Random)"
        New-Item -ItemType Directory -Path $testConfigDir -Force | Out-Null
        $testAllHostsProfilePath = Join-Path $testConfigDir 'profileAllHosts.ps1'
        $testCurrentHostProfilePath = Join-Path $testConfigDir 'profileCurrentHost.ps1'
    }

    AfterAll {
        if (Test-Path $testConfigDir) { Remove-Item -Recurse -Force $testConfigDir -ErrorAction SilentlyContinue }
        Remove-Module BlueShell -Force -ErrorAction SilentlyContinue
    }

    BeforeEach {
        Remove-Module BlueShell -Force -ErrorAction SilentlyContinue
        $env:BLUESHELL_CONFIG_DIR = $testConfigDir
        if (Test-Path $testAllHostsProfilePath) { Remove-Item $testAllHostsProfilePath -Force }
        if (Test-Path $testCurrentHostProfilePath) { Remove-Item $testCurrentHostProfilePath -Force }
    }

    It 'Install-BlueShell creates config dir and config.json when missing' {
        Import-Module $psm1Path -Force -Global
        Get-ChildItem $testConfigDir -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Install-BlueShell -AllHostsProfilePath $testAllHostsProfilePath -CurrentHostProfilePath $testCurrentHostProfilePath
        Test-Path (Join-Path $testConfigDir 'config.json') | Should -BeTrue
    }

    It 'Install-BlueShell writes Import-Module only to AllHosts profile (no interactive line there)' {
        Import-Module $psm1Path -Force -Global
        Install-BlueShell -AllHostsProfilePath $testAllHostsProfilePath -CurrentHostProfilePath $testCurrentHostProfilePath
        $allHostsContent = Get-Content -Raw -Path $testAllHostsProfilePath -ErrorAction SilentlyContinue
        $allHostsContent | Should -Match 'Import-Module'
        $allHostsContent | Should -Not -Match 'Enable-BlueShellInteractive'
    }

    It 'Install-BlueShell writes interactive line only to CurrentHost profile (no Import-Module there)' {
        Import-Module $psm1Path -Force -Global
        Install-BlueShell -AllHostsProfilePath $testAllHostsProfilePath -CurrentHostProfilePath $testCurrentHostProfilePath
        $currentHostContent = Get-Content -Raw -Path $testCurrentHostProfilePath -ErrorAction SilentlyContinue
        $currentHostContent | Should -Match 'Enable-BlueShellInteractive'
        $currentHostContent | Should -Not -Match 'Import-Module'
    }

    It 'Install-BlueShell is idempotent (second run does not duplicate profile lines)' {
        Import-Module $psm1Path -Force -Global
        Install-BlueShell -AllHostsProfilePath $testAllHostsProfilePath -CurrentHostProfilePath $testCurrentHostProfilePath
        $allHosts1 = Get-Content -Raw -Path $testAllHostsProfilePath -ErrorAction SilentlyContinue
        $currentHost1 = Get-Content -Raw -Path $testCurrentHostProfilePath -ErrorAction SilentlyContinue
        Install-BlueShell -AllHostsProfilePath $testAllHostsProfilePath -CurrentHostProfilePath $testCurrentHostProfilePath
        $allHosts2 = Get-Content -Raw -Path $testAllHostsProfilePath -ErrorAction SilentlyContinue
        $currentHost2 = Get-Content -Raw -Path $testCurrentHostProfilePath -ErrorAction SilentlyContinue
        ([regex]::Matches($allHosts1, 'Import-Module')).Count | Should -Be ([regex]::Matches($allHosts2, 'Import-Module')).Count
        ([regex]::Matches($currentHost1, 'Enable-BlueShellInteractive')).Count | Should -Be ([regex]::Matches($currentHost2, 'Enable-BlueShellInteractive')).Count
        ([regex]::Matches($currentHost2, 'Enable-BlueShellInteractive')).Count | Should -Be 1
    }

    It 'Install-BlueShell -ProfilePath (legacy) still configures AllHosts profile' {
        Import-Module $psm1Path -Force -Global
        Install-BlueShell -ProfilePath $testAllHostsProfilePath
        $content = Get-Content -Raw -Path $testAllHostsProfilePath -ErrorAction SilentlyContinue
        $content | Should -Match 'Import-Module'
    }
}
