# setup.ps1 - Claude Code 项目工作流一键部署
# 用法：.\setup.ps1
# 可选：先设置环境变量
#   $env:CLAUDE_PROJECT_ROOT = "你的项目根目录"
#   $env:OBSIDIAN_VAULT_ROOT = "你的 Obsidian vault 根"（默认同项目根）

param(
    [string]$ProjectRoot = $env:CLAUDE_PROJECT_ROOT,
    [string]$VaultRoot = $env:OBSIDIAN_VAULT_ROOT
)

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

# 默认值
if (-not $ProjectRoot) { $ProjectRoot = "$env:USERPROFILE\Projects" }
if (-not $VaultRoot)   { $VaultRoot = $ProjectRoot }

Write-Host "`n=== Claude Code 项目工作流 部署脚本 ===" -ForegroundColor Cyan
Write-Host "  项目根目录:    $ProjectRoot"
Write-Host "  Obsidian vault: $VaultRoot"
Write-Host ""

# 1. 创建项目根目录
if (-not (Test-Path $ProjectRoot)) {
    New-Item -ItemType Directory -Path $ProjectRoot -Force | Out-Null
    Write-Host "[OK] 创建项目根目录: $ProjectRoot" -ForegroundColor Green
} else {
    Write-Host "[--] 项目根目录已存在" -ForegroundColor Gray
}

# 2. 部署 PowerShell 模块
$profileDir = "$env:USERPROFILE\Documents\WindowsPowerShell\profile.d"
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}
$target = Join-Path $profileDir "06-claude.ps1"
Copy-Item "$here\claude.ps1" $target -Force

# 必须 UTF-8 BOM，否则 PowerShell 5.1 解析中文失败
$content = [System.IO.File]::ReadAllText($target, [System.Text.Encoding]::UTF8)
$utf8bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($target, $content, $utf8bom)
Write-Host "[OK] 部署 PowerShell 模块: $target (UTF-8 BOM)" -ForegroundColor Green

# 3. 部署任务中心
$taskHubSrc = Join-Path $here "templates\TASK-HUB.md"
$taskHubDst = Join-Path $VaultRoot "任务中心.md"
if (Test-Path $taskHubSrc) {
    if (-not (Test-Path $taskHubDst)) {
        Copy-Item $taskHubSrc $taskHubDst -Force
        Write-Host "[OK] 部署任务中心: $taskHubDst" -ForegroundColor Green
    } else {
        Write-Host "[--] 任务中心已存在，跳过" -ForegroundColor Gray
    }
}

# 4. 给每个子文件夹初始化项目文件
$templatesDir = Join-Path $here "templates"
$projectFiles = @{
    "CLAUDE.md" = "PROJECT-CLAUDE.md"
    "TODO.md"   = "TODO.md"
}

$projects = Get-ChildItem -Path $ProjectRoot -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notlike '.*' }

foreach ($p in $projects) {
    foreach ($dst in $projectFiles.Keys) {
        $src = $projectFiles[$dst]
        $dstPath = Join-Path $p.FullName $dst
        $srcPath = Join-Path $templatesDir $src
        if ((Test-Path $srcPath) -and (-not (Test-Path $dstPath))) {
            Copy-Item $srcPath $dstPath -Force
            Write-Host "[OK] 初始化 $($p.Name)\$dst" -ForegroundColor Green
        }
    }
}

Write-Host "`n=== 部署完成 ===" -ForegroundColor Cyan
Write-Host "重启 PowerShell 后，以下命令可用：" -ForegroundColor Yellow
Write-Host "  pj [项目]   进入项目并启动 claude"
Write-Host "  cc          继续上次会话"
Write-Host "  cr          恢复历史会话"
Write-Host "  pl          列出所有项目"
Write-Host ""
Write-Host "Obsidian 打开 vault: $VaultRoot" -ForegroundColor Yellow
