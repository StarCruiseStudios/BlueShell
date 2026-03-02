# Topic.ps1 - Provider/topic registry, pull, push (Spec §2)
# Dot-sourced from a loader or init so it runs after config.

$script:BlueShellTopics = @{}      # Topic -> { SchemaPath, SchemaVersion, Schema }
$script:BlueShellProviders = @{}  # Topic -> @( scriptblock or function name )
$script:BlueShellSubscriptions = @{}  # Topic -> @( scriptblock )

function Register-BlueShellTopic {
    <#
    .SYNOPSIS
        Register a topic and its JSON Schema (Spec §2.3). First registration defines the topic.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Topic,
        [Parameter(Mandatory)][string]$SchemaPath
    )
    if (-not (Test-Path $SchemaPath)) { throw "Schema path not found: $SchemaPath" }
    $json = Get-Content -Raw -Path $SchemaPath -ErrorAction Stop
    $schema = $json | ConvertFrom-Json
    $version = if ($schema.PSObject.Properties['version']) { $schema.version } else { '0.0.0' }
    if ($script:BlueShellTopics.ContainsKey($Topic)) {
        $existing = $script:BlueShellTopics[$Topic]
        if ($existing.SchemaVersion -eq $version) {
            $existingJson = $existing.Schema | ConvertTo-Json -Depth 20 -Compress
            $newJson = $schema | ConvertTo-Json -Depth 20 -Compress
            if ($existingJson -ne $newJson) {
                throw "Topic '$Topic' already registered with same version '$version' but different schema."
            }
        }
        # Different version or consumer subset: allow (backwards compatible)
    } else {
        $script:BlueShellTopics[$Topic] = @{
            SchemaPath   = $SchemaPath
            SchemaVersion = $version
            Schema       = $schema
        }
    }
    if (-not $script:BlueShellProviders.ContainsKey($Topic)) {
        $script:BlueShellProviders[$Topic] = [System.Collections.ArrayList]::new()
    }
    if (-not $script:BlueShellSubscriptions.ContainsKey($Topic)) {
        $script:BlueShellSubscriptions[$Topic] = [System.Collections.ArrayList]::new()
    }
}

function Register-BlueShellTopicProvider {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Topic,
        [Parameter(Mandatory)][object]$Provider  # ScriptBlock or function name
    )
    if (-not $script:BlueShellProviders.ContainsKey($Topic)) {
        $script:BlueShellProviders[$Topic] = [System.Collections.ArrayList]::new()
    }
    $null = $script:BlueShellProviders[$Topic].Add($Provider)
}

function Get-BlueShellTopicData {
    <#
    .SYNOPSIS
        Invoke all providers for the topic and return array of responses (Spec §2.3).
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Topic)
    if (-not $script:BlueShellProviders.ContainsKey($Topic)) {
        return @()
    }
    $results = [System.Collections.ArrayList]::new()
    foreach ($p in $script:BlueShellProviders[$Topic]) {
        try {
            $out = if ($p -is [scriptblock]) { & $p } else { & $p }
            $null = $results.Add($out)
        } catch {
            $null = $results.Add($null)
        }
    }
    # Ensure array is returned (no single-element unwrap)
    $arr = [object[]]::new($results.Count)
    $results.CopyTo($arr, 0)
    return $arr
}

function Register-BlueShellTopicSubscription {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Topic,
        [Parameter(Mandatory)][scriptblock]$Callback
    )
    if (-not $script:BlueShellSubscriptions.ContainsKey($Topic)) {
        $script:BlueShellSubscriptions[$Topic] = [System.Collections.ArrayList]::new()
    }
    $null = $script:BlueShellSubscriptions[$Topic].Add($Callback)
}

function Publish-BlueShellTopicEvent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Topic,
        [Parameter(Mandatory)][object]$Payload
    )
    if (-not $script:BlueShellSubscriptions.ContainsKey($Topic)) { return }
    foreach ($cb in $script:BlueShellSubscriptions[$Topic]) {
        try { & $cb $Payload } catch { }
    }
}
