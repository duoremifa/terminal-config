# Workspaces - named bookmarks for directories you jump to often
#   ws              list all bookmarks
#   ws <name>       jump to a bookmark
#   ws-add <n> <p>  add/update a bookmark
#   ws-del <name>   remove a bookmark

$script:ws = [ordered]@{
    obsidian   = "$env:USERPROFILE\Downloads"
    downloads  = "$env:USERPROFILE\Downloads"
    desktop    = "$env:USERPROFILE\Desktop"
    docs       = "$env:USERPROFILE\Documents"
    monkey     = "$env:USERPROFILE\monkeytype"
    zoxide     = "$env:USERPROFILE\zoxide"
    modules    = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules"
    profile_d  = "$env:USERPROFILE\Documents\WindowsPowerShell\profile.d"
}

function ws {
    if ($args.Count -eq 0) {
        $script:ws.GetEnumerator() |
            Select-Object Name, Value |
            Format-Table -AutoSize
        return
    }
    $name = $args[0]
    if ($script:ws.Contains($name)) {
        Set-Location $script:ws[$name]
    } else {
        Write-Warning "no such workspace: $name (run 'ws' to list)"
    }
}

function ws-add {
    param([string]$Name, [string]$Path = (Get-Location).Path)
    $script:ws[$Name] = $Path
    "added: $Name -> $Path"
}

function ws-del {
    param([string]$Name)
    if ($script:ws.Contains($Name)) {
        $script:ws.Remove($Name)
        "removed: $Name"
    } else {
        Write-Warning "no such workspace: $Name"
    }
}
