BeforeAll {
    # Get the module path and root
    $script:moduleRoot = Join-Path $PSScriptRoot ".." -Resolve
    
    # Remove module if it exists
    if (Get-Module BlueShell) {
        Remove-Module BlueShell -Force
    }
    
    # Import the module
    Import-Module (Join-Path $moduleRoot "BlueShell.psm1") -Force
}

Describe "Set-ReadOnly" {
    BeforeEach {
        Remove-Variable -Name TestVar -ErrorAction SilentlyContinue -Scope Global
        Remove-Variable -Name TestVar2 -ErrorAction SilentlyContinue -Scope Global
    }

    It "Should create a read-only variable" {
        Set-ReadOnly "TestVar" "TestValue" -silent
        $TestVar | Should -Be "TestValue"
        
        # Test that the variable is actually read-only
        $var = Get-Variable -Name TestVar
        $var.Options | Should -Be ([System.Management.Automation.ScopedItemOptions]::ReadOnly)
        
        # This should throw because the variable is read-only
        { $global:TestVar = "NewValue" } | Should -Throw -ErrorId "VariableNotWritable"
    }

    It "Should allow overwriting with Set-ReadOnly" {
        Set-ReadOnly "TestVar2" "Value1" -silent
        Set-ReadOnly "TestVar2" "Value2" -silent
        $TestVar2 | Should -Be "Value2"
    }

    Describe "Test-CommandExists" {
        It "Should return true for existing PowerShell commands" {
            $result = Test-CommandExists "Get-Process"
            $result | Should -Be $true
        }

        It "Should return false for non-existent commands" {
            $result = Test-CommandExists "NonExistentCommand123"
            $result | Should -Be $false
        }
    }

    Describe "Invoke-BlueShellCommand" {
        It "Should execute commands and return output" {
            $result = Invoke-BlueShellCommand "Write-Output 'test'" | Select-Object -Last 1
            $result | Should -Be "test"
        }

        It "Should handle working directory changes" {
            $tempPath = [System.IO.Path]::GetTempPath().TrimEnd('\')
            $result = Invoke-BlueShellCommand "Get-Location" $tempPath | Select-Object -Last 1
            $result.Path.TrimEnd('\') | Should -Be $tempPath
        }
    } 