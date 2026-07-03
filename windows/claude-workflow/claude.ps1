# claude.ps1 - Claude Code 项目管理快捷命令
# 通用模板版：项目根路径通过环境变量 CLAUDE_PROJECT_ROOT 配置
# 没设环境变量时默认 $env:USERPROFILE\Projects

# 项目根目录
$script:ClaudeProjectRoot = $env:CLAUDE_PROJECT_ROOT
if (-not $script:ClaudeProjectRoot) {
    $script:ClaudeProjectRoot = "$env:USERPROFILE\Projects"
}

# 列出所有项目（排除隐藏目录）
function Get-ClaudeProject {
    Get-ChildItem -Path $script:ClaudeProjectRoot -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notlike '.*' } |
        Sort-Object LastWriteTime -Descending
}

# pj - 进入项目并启动 claude
function pj {
    param([string]$Project)

    if (-not $Project) {
        $projects = @(Get-ClaudeProject)
        if ($projects.Count -eq 0) {
            Write-Host "  项目根目录为空或不存在: $script:ClaudeProjectRoot" -ForegroundColor Red
            Write-Host "  设置 `$env:CLAUDE_PROJECT_ROOT 指向你的项目目录" -ForegroundColor Yellow
            return
        }
        Write-Host "`n  项目列表（按最近更新排序）：" -ForegroundColor Cyan
        for ($i = 0; $i -lt $projects.Count; $i++) {
            $p = $projects[$i]
            $time = $p.LastWriteTime.ToString("MM-dd HH:mm")
            Write-Host ("    [{0}]  {1,-14} {2}" -f ($i+1), $p.Name, $time)
        }
        Write-Host ""
        $choice = Read-Host "  输入序号或项目名（直接回车取消）"
        if ([string]::IsNullOrWhiteSpace($choice)) { return }
        if ($choice -match '^\d+$') {
            $idx = [int]$choice - 1
            if ($idx -lt 0 -or $idx -ge $projects.Count) {
                Write-Host "  序号超出范围" -ForegroundColor Red
                return
            }
            $Project = $projects[$idx].Name
        } else {
            $Project = $choice
        }
    }

    $path = Join-Path $script:ClaudeProjectRoot $Project
    if (-not (Test-Path $path)) {
        $create = Read-Host "  项目不存在: $Project，是否创建？(y/N)"
        if ($create -eq 'y') {
            New-Item -ItemType Directory -Path $path | Out-Null
            Write-Host "  已创建: $path" -ForegroundColor Green
        } else {
            return
        }
    }

    Set-Location $path
    Write-Host "  进入: $Project" -ForegroundColor Green
    claude
}

# cr - 恢复历史会话
function cr { claude -r }

# cc - 继续当前项目上次会话
function cc { claude -c }

# pl - 列出所有项目
function pl {
    $projects = Get-ClaudeProject
    if ($projects -eq $null -or @($projects).Count -eq 0) {
        Write-Host "  项目根目录为空: $script:ClaudeProjectRoot" -ForegroundColor Yellow
        return
    }
    Write-Host "`n  项目列表：" -ForegroundColor Cyan
    $projects | ForEach-Object {
        $time = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm")
        Write-Host ("    {0,-16} {1}" -f $_.Name, $time)
    }
    Write-Host ""
}
