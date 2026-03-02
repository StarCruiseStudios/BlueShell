# RulesSkills.ps1 - AgentRules/AgentSkills topics, list/enable/disable (Spec §6)
# Cursor skills path: %USERPROFILE%\.cursor\skills (Windows), ~/.cursor/skills (macOS/Linux)

function Get-BlueShellCursorSkillsPath {
    if ($env:USERPROFILE) {
        return Join-Path $env:USERPROFILE '.cursor' 'skills'
    }
    return Join-Path $env:HOME '.cursor' 'skills'
}

function Get-BlueShellAgentRules {
    <#
    .SYNOPSIS
        List all agent rules from providers (Get-BlueShellTopicData for AgentRules).
    #>
    [CmdletBinding()]
    param()
    $all = Get-BlueShellTopicData -Topic 'AgentRules'
    $list = [System.Collections.ArrayList]::new()
    foreach ($r in $all) {
        if ($null -eq $r) { continue }
        if ($r -is [array]) { foreach ($item in $r) { $null = $list.Add($item) } }
        else { $null = $list.Add($r) }
    }
    return @($list)
}

function Get-BlueShellAgentSkills {
    [CmdletBinding()]
    param()
    $all = Get-BlueShellTopicData -Topic 'AgentSkills'
    $list = [System.Collections.ArrayList]::new()
    foreach ($r in $all) {
        if ($null -eq $r) { continue }
        if ($r -is [array]) { foreach ($item in $r) { $null = $list.Add($item) } }
        else { $null = $list.Add($r) }
    }
    return @($list)
}

function Enable-BlueShellAgentRules {
    [CmdletBinding()]
    param([Parameter(ValueFromPipeline)]$Item, [string]$WorkspaceRoot = (Get-Location).Path)
    process {
        $rulesDir = Join-Path $WorkspaceRoot '.cursor' 'rules'
        if (-not (Test-Path $rulesDir)) { New-Item -ItemType Directory -Path $rulesDir -Force | Out-Null }
        $path = if ($Item.path) { $Item.path } else { $Item }
        $name = if ($Item.name) { $Item.name } else { [System.IO.Path]::GetFileName($path) }
        if (Test-Path $path) {
            $dest = Join-Path $rulesDir $name
            Copy-Item -Path $path -Destination $dest -Force
        }
    }
}

function Disable-BlueShellAgentRules {
    [CmdletBinding()]
    param([Parameter(ValueFromPipeline)]$Item, [string]$WorkspaceRoot = (Get-Location).Path)
    process {
        $rulesDir = Join-Path $WorkspaceRoot '.cursor' 'rules'
        $name = if ($Item.name) { $Item.name } else { $Item }
        $dest = Join-Path $rulesDir $name
        if (Test-Path $dest) { Remove-Item -Path $dest -Force }
    }
}

function Enable-BlueShellAgentSkills {
    [CmdletBinding()]
    param([Parameter(ValueFromPipeline)]$Item)
    process {
        $skillsDir = Get-BlueShellCursorSkillsPath
        if (-not (Test-Path $skillsDir)) { New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null }
        $path = if ($Item.path) { $Item.path } else { $Item }
        $name = if ($Item.name) { $Item.name } else { [System.IO.Path]::GetFileName($path) }
        if (Test-Path $path) {
            $dest = Join-Path $skillsDir $name
            Copy-Item -Path $path -Destination $dest -Force
        }
    }
}

function Disable-BlueShellAgentSkills {
    [CmdletBinding()]
    param([Parameter(ValueFromPipeline)]$Item)
    process {
        $skillsDir = Get-BlueShellCursorSkillsPath
        $name = if ($Item.name) { $Item.name } else { $Item }
        $dest = Join-Path $skillsDir $name
        if (Test-Path $dest) { Remove-Item -Path $dest -Force }
    }
}

# Register AgentRules and AgentSkills topics at load (base defines them)
$root = Get-BlueShellRoot
$rulesSchema = Join-Path $root 'schemas' 'AgentRules.schema.json'
$skillsSchema = Join-Path $root 'schemas' 'AgentSkills.schema.json'
if (Test-Path $rulesSchema) { Register-BlueShellTopic -Topic 'AgentRules' -SchemaPath $rulesSchema }
if (Test-Path $skillsSchema) { Register-BlueShellTopic -Topic 'AgentSkills' -SchemaPath $skillsSchema }
