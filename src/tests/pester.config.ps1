# Pester configuration for BlueShell tests
@{
    Run          = @{
        Path     = "."
        PassThru = $true
        Exit     = $true
    }
    Output       = @{
        Verbosity = "Detailed"
        CIFormat  = "Auto"
    }
    TestResult   = @{
        Enabled      = $true
        OutputPath   = "TestResults.xml"
        OutputFormat = "NUnitXml"
    }
    CodeCoverage = @{
        Enabled      = $true
        OutputPath   = "coverage.xml"
        OutputFormat = "JaCoCo"
        Path         = @(
            "../internal/blueshell/*.ps1"
            "../BlueShell.psm1"
        )
    }
} 