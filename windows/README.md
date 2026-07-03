# Windows Terminal 配置说明

本目录包含 Windows 上复现统一终端外观所需的全部文件。

## 前置条件

### 1. 安装 Sarasa Mono SC 字体（更纱黑体）

**无需管理员权限**，使用 per-user 安装：

```powershell
# 下载字体 (v1.0.39) - 使用 gh-proxy 镜像加速
$url = "https://gh-proxy.com/https://github.com/be5invis/Sarasa-Gothic/releases/download/v1.0.39/SarasaMonoSC-1.0.39.zip"
$zip = "$env:TEMP\sarasa.zip"
$extract = "$env:TEMP\sarasa"
Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
Expand-Archive -Path $zip -DestinationPath $extract -Force
```

```powershell
# Per-user 安装到用户字体目录
$fontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
if (-not (Test-Path $fontDir)) { New-Item -ItemType Directory -Path $fontDir | Out-Null }

Get-ChildItem $extract -Filter "*.ttf" | ForEach-Object {
    Copy-Item $_.FullName $fontDir -Force
    # 注册到当前用户
    $regPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
    $fontName = $_.BaseName + " (TrueType)"
    Set-ItemProperty -Path $regPath -Name $fontName -Value "$fontDir\$($_.Name)"
}
```

```powershell
# 注销并重新登录一次，让 Font Cache 服务加载新字体
# （没有管理员权限无法重启 Font Cache 服务）
shutdown /l
```

重登后，字体即生效。

### 2. 安装 Windows Terminal

```powershell
winget install Microsoft.WindowsTerminal
```

或从 Microsoft Store 安装。

## 应用配置

### 方法 A：直接替换配置文件（推荐）

```powershell
$target = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# 先备份原配置
Copy-Item $target "$target.bak" -ErrorAction SilentlyContinue

# 复制本仓库的配置
Copy-Item "$PSScriptRoot\settings.json" $target -Force
```

重启 Windows Terminal 即可生效。

### 方法 B：在 GUI 中导入配色

1. 打开 Windows Terminal → Settings（`Ctrl+,`）
2. 左侧 **Color schemes** → **Add new** → **Import**
3. 把 `settings.json` 的 `schemes` 数组里 `macOS Dark` 那一段复制到一个单独 JSON 文件导入
4. 设置默认 scheme 为 `macOS Dark`
5. 设置默认字体为 `Sarasa Mono SC`，字号 10-13

## 配置亮点

这份 `settings.json` 包含以下设定：

### 外观
- **配色**: macOS Dark（自定义 16 色方案，与 macOS 版一致）
- **字体**: Sarasa Mono SC（更纱黑体），10pt，正常字重
- **光标**: 竖线（bar）
- **背景**: 85% 不透明度 + Acrylic 模糊
- **滚动条**: 隐藏
- **内边距**: 左右 12px，上下 16px

### 默认 Profile
- Windows PowerShell（无 Logo）
- 启动目录: `%USERPROFILE%`
- 也保留 Command Prompt profile

### 快捷键
- `Alt+Shift+-` : 水平分屏
- `Alt+Shift++` : 垂直分屏
- `Ctrl+Shift+W` : 关闭当前面板

## PowerShell Profile（模块化）

`powershell/` 目录是一份**模块化**的 PowerShell 5.1 profile，装在 `$env:USERPROFILE\Documents\WindowsPowerShell\` 下。重开终端自动加载。

### 文件布局

```
WindowsPowerShell\
├── Microsoft.PowerShell_profile.ps1    # 入口：点 source profile.d\ 下所有 .ps1
└── profile.d\
    ├── 01-psreadline.ps1               # PSReadLine 2.3.6 配置（预测性输入）
    ├── 02-integrations.ps1             # 加载 Terminal-Icons + zoxide
    ├── 03-workspaces.ps1               # ws / ws-add / ws-del 目录书签
    ├── 04-aliases.ps1                  # 短命令别名（.. / ll / grep / ep / reload）
    └── 05-functions.ps1                # 自定义函数（obs / today / clipf / gh-dl / which / tree-lite）
```

### 安装

```powershell
$src = "<repo>\windows\powershell"
$dst = "$env:USERPROFILE\Documents\WindowsPowerShell"
Copy-Item "$src\Microsoft.PowerShell_profile.ps1" $dst -Force
Copy-Item "$src\profile.d" $dst -Recurse -Force
```

### 依赖（用户级安装，不需要管理员）

| 模块 | 装法 |
|---|---|
| PSReadLine 2.3.6 | 从 PSGallery 下 `.nupkg` 解压到 `Modules\PSReadLine\` |
| Terminal-Icons 0.11.0 | 同上，到 `Modules\Terminal-Icons\` |
| zoxide 0.9.9 | GitHub Release 便携 zip 解压到 `$env:USERPROFILE\zoxide\`，加到用户 PATH |

完整安装脚本和踩坑说明见 [`terminal-guide.md`](terminal-guide.md) §10。

## 操作手册

[`terminal-guide.md`](terminal-guide.md) 是一份**中文操作手册**，覆盖：

- §1-9 终端基础：启动、分屏、快捷键速查、产品人常用命令、Obsidian/drawio 联动
- §10-11 增强套件：PSReadLine / Terminal-Icons / zoxide 的使用
- §12 故障排查（PS 5.1 GBK 编码、方块字图标、PSReadLine 不工作等）
- §13 一页速查表（贴工位）
- §14 **新手练习**（6 个循序渐进的练习任务 + 12 条自检清单）

## Claude Code 项目工作流

[`claude-workflow/`](claude-workflow/) 是一套**用终端 + Obsidian + Claude Code 管理多项目**的工作流模板：

- `claude.ps1` — PowerShell 快捷命令（`pj` / `cc` / `cr` / `pl`），路径通过环境变量配置
- `setup.ps1` — 一键部署脚本
- `templates/` — `CLAUDE.md` / `TODO.md` / 任务中心 / 操作指南模板

详见 [`claude-workflow/README.md`](claude-workflow/README.md)。

## 卸载 / 回滚

```powershell
# 恢复备份
$target = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
Copy-Item "$target.bak" $target -Force

# 删除字体
Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\Fonts\Sarasa*" -Force
# 并从 HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts 中删除对应条目
```

注销重登一次即可完全还原。
