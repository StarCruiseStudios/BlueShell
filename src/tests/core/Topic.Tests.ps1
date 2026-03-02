# Topic.Tests.ps1 - T013.05: topic/provider register, pull array, push (Spec §2, §12)

Describe 'T013 Provider/topic mechanism' {
    BeforeAll {
        $projectRoot = (Get-Item $PSScriptRoot).Parent.Parent.Parent.FullName
        $moduleRoot = Join-Path $projectRoot 'src'
        $psm1Path = Join-Path $moduleRoot 'BlueShell.psm1'
        $testConfigDir = Join-Path ([System.IO.Path]::GetTempPath()) "BlueShellTopicTests_$(Get-Random)"
        New-Item -ItemType Directory -Path $testConfigDir -Force | Out-Null
        $schemaDir = Join-Path $testConfigDir 'schemas'
        New-Item -ItemType Directory -Path $schemaDir -Force | Out-Null
        @{ version = '1.0'; type = 'object' } | ConvertTo-Json | Set-Content (Join-Path $schemaDir 'test-schema.json') -Encoding utf8
    }

    AfterAll {
        if (Test-Path $testConfigDir) { Remove-Item -Recurse -Force $testConfigDir -ErrorAction SilentlyContinue }
        Remove-Module BlueShell -Force -ErrorAction SilentlyContinue
    }

    BeforeEach {
        Remove-Module BlueShell -Force -ErrorAction SilentlyContinue
        $env:BLUESHELL_CONFIG_DIR = $testConfigDir
    }

    It 'Get-BlueShellTopicData returns empty array when no providers' {
        Import-Module $psm1Path -Force -Global
        $r = Get-BlueShellTopicData -Topic 'NoSuchTopic'
        ($null -eq $r -or ($r -is [array] -and $r.Count -eq 0)) | Should -BeTrue
    }

    It 'Register-BlueShellTopicProvider and Get-BlueShellTopicData return array of one' {
        Import-Module $psm1Path -Force -Global
        Register-BlueShellTopicProvider -Topic 'TestTopic' -Provider { 'data1' }
        $r = Get-BlueShellTopicData -Topic 'TestTopic'
        $r | Should -Not -BeNullOrEmpty
        $first = if ($r -is [array] -and $r.Count -ge 1) { $r[0] } else { $r }
        $first | Should -Be 'data1'
    }

    It 'Multiple providers return array of responses' {
        Import-Module $psm1Path -Force -Global
        Register-BlueShellTopicProvider -Topic 'Multi' -Provider { 'a' }
        Register-BlueShellTopicProvider -Topic 'Multi' -Provider { 'b' }
        $r = Get-BlueShellTopicData -Topic 'Multi'
        $r.Count | Should -Be 2
        $r[0] | Should -Be 'a'
        $r[1] | Should -Be 'b'
    }

    It 'Register-BlueShellTopic accepts schema path' {
        Import-Module $psm1Path -Force -Global
        $schemaPath = Join-Path $schemaDir 'test-schema.json'
        { Register-BlueShellTopic -Topic 'WithSchema' -SchemaPath $schemaPath } | Should -Not -Throw
    }

    It 'Register-BlueShellTopicSubscription and Publish-BlueShellTopicEvent deliver payload' {
        Import-Module $psm1Path -Force -Global
        $box = @{ received = $null }
        Register-BlueShellTopicSubscription -Topic 'Evt' -Callback { param($p) $box.received = $p }
        Publish-BlueShellTopicEvent -Topic 'Evt' -Payload @{ x = 1 }
        $box.received | Should -Not -BeNullOrEmpty
        $box.received.x | Should -Be 1
    }
}
