# Functions - PM-flavored shortcuts

# obs - open Obsidian vault
function obs { Invoke-Item "$env:USERPROFILE\Downloads" }

# today - open or create today's daily note in Obsidian vault
function today {
    $d = Get-Date -Format "yyyy-MM-dd"
    $p = Join-Path $env:USERPROFILE "Downloads\$d.md"
    if (Test-Path $p) { code $p; return }
    $body = @"
---
tags: [daily]
---

# $d

## 今日要事
-

## 笔记
"@
    # Out-File with utf8 in PS 5.1 writes UTF-8 WITH BOM (what we want)
    $body | Out-File -FilePath $p -Encoding utf8
    code $p
}

# clipf - dump file contents into clipboard
function clipf($path) { Get-Content -LiteralPath $path | clip }

# gh-dl - download a GitHub release asset via gh-proxy mirror
#   gh-dl <github-url> <local-file>
#   e.g. gh-dl "https://github.com/user/repo/releases/download/v1/f.zip" f.zip
function gh-dl {
    param([string]$Url, [string]$Out)
    $mirrored = "https://gh-proxy.com/" + $Url
    "downloading via mirror: $mirrored"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $mirrored -OutFile $Out -UseBasicParsing
    "done -> $Out"
}

# peek - quick-open any file with default app
function peek($path) { Invoke-Item $path }

# which - like Linux 'which': show where a command lives
function which($name) {
    Get-Command $name -ErrorAction SilentlyContinue |
        Select-Object Name, CommandType, Source |
        Format-Table -AutoSize
}

# tree-lite - poor man's tree (no admin needed, no binary needed)
function tree-lite {
    param([string]$Path = ".", [int]$Depth = 2)
    Get-ChildItem -LiteralPath $Path -Recurse -Directory -ErrorAction SilentlyContinue |
        Where-Object {
            ($_.FullName.Split('\').Count - $Path.Split('\').Count) -le $Depth
        } |
        ForEach-Object {
            $indent = '  ' * ($_.FullName.Split('\').Count - $Path.Split('\').Count)
            "$indent$($_.Name)"
        }
}
