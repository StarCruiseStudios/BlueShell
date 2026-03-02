# RulesSkills.Tests.ps1 - T016.04: list/enable/disable, provider discovery (Spec §6, §12)
# Uses temp dirs for workspace and skills (override USERPROFILE for skills path).

Describe 'T016 Rules and skills as providers' {
    BeforeAll {
        $projectRoot = (Get-Item $PSScriptRoot).Parent.Parent.Parent.FullName
        $moduleRoot = Join-Path $projectRoot 'src'
        $psm1Path = Join-Path $moduleRoot 'BlueShell.psm1'
        $testConfigDir = Join-Path ([System.IO.Path]::GetTempPath()) "BlueShellRulesSkillsTests_$(Get-Random)"
        New-Item -ItemType Directory -Path $testConfigDir -Force | Out-Null
        $testWorkspace = Join-Path $testConfigDir 'workspace'
        New-Item -ItemType Directory -Path $testWorkspace -Force | Out-Null
    }

    AfterAll {
        if (Test-Path $testConfigDir) { Remove-Item -Recurse -Force $testConfigDir -ErrorAction SilentlyContinue }
        Remove-Module BlueShell -Force -ErrorAction SilentlyContinue
    }

    BeforeEach {
        Remove-Module BlueShell -Force -ErrorAction SilentlyContinue
        $env:BLUESHELL_CONFIG_DIR = $testConfigDir
        $env:USERPROFILE = $testConfigDir
        Get-ChildItem $testWorkspace -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    }

    It 'Get-BlueShellAgentRules returns empty when no providers' {
        Import-Module $psm1Path -Force -Global
        $r = Get-BlueShellAgentRules
        $r.Count | Should -Be 0
    }

    It 'Get-BlueShellCursorSkillsPath returns path under USERPROFILE' {
        Import-Module $psm1Path -Force -Global
        $p = Get-BlueShellCursorSkillsPath
        $p | Should -Match '\.cursor\\skills'
    }

    It 'Enable-BlueShellAgentRules copies file to .cursor/rules' {
        Import-Module $psm1Path -Force -Global
        $ruleFile = Join-Path $testConfigDir 'myrule.md'
        Set-Content -Path $ruleFile -Value '# test'
        @{ name = 'myrule.md'; path = $ruleFile } | Enable-BlueShellAgentRules -WorkspaceRoot $testWorkspace
        $dest = Join-Path $testWorkspace '.cursor' 'rules' 'myrule.md'
        Test-Path $dest | Should -BeTrue
    }

    It 'Disable-BlueShellAgentRules removes file from .cursor/rules' {
        Import-Module $psm1Path -Force -Global
        $rulesDir = Join-Path $testWorkspace '.cursor' 'rules'
        New-Item -ItemType Directory -Path $rulesDir -Force | Out-Null
        $dest = Join-Path $rulesDir 'myrule.md'
        Set-Content -Path $dest -Value '# test'
        @{ name = 'myrule.md' } | Disable-BlueShellAgentRules -WorkspaceRoot $testWorkspace
        Test-Path $dest | Should -BeFalse
    }
}
