# Terminal Config / 终端配置

A consistent terminal look across Windows and macOS — same font (**Sarasa Mono SC / 更纱黑体**), same color scheme (**macOS Dark**).

在 Windows 和 macOS 上保持一致的终端外观：同一字体（**更纱黑体**），同一配色（**macOS Dark**）。

---

## Repository layout / 目录结构

```
.
├── macos/
│   ├── macOS-Dark.itermcolors   # iTerm2 颜色预设 / iTerm2 color preset
│   ├── terminal-app-setup.md    # 系统自带 Terminal.app 配置说明
│   └── README.md                # macOS 完整安装步骤
├── windows/
│   ├── settings.json            # Windows Terminal 配置（原样备份）
│   ├── terminal-guide.md        # 中文操作手册（含新手练习 6 步）
│   ├── powershell/              # 模块化 PowerShell profile（PSReadLine/Terminal-Icons/zoxide）
│   └── README.md                # Windows 完整安装步骤
├── claude-code/
│   ├── settings.json            # Claude Code 用户配置（CC-Switch 代理版）
│   ├── settings-bailian-direct.json  # 直连百炼版（不需要 CC-Switch / 公司内网）
│   ├── zshrc.append             # 追加到 ~/.zshrc 的 shell 配置片段
│   ├── CLAUDE.md                # 项目级指令模板（放到任意项目根目录）
│   ├── zhengxi-views-install.md # 郑希观点库 skill 的 Windows 安装指南
│   └── README.md                # Mac 上 Claude Code 安装说明
├── tools/
│   └── video-to-text-best-practices.md  # 视频转文字/翻译工具对比与安装指南
└── README.md                    # 本文件 / this file
```

## Quick start / 快速开始

### macOS

1. 安装 Sarasa Mono SC 字体：`brew install --cask font-sarasa-mono-sc`
2. 安装 iTerm2（如未安装）：`brew install --cask iterm2`
3. 双击 `macos/macOS-Dark.itermcolors` 导入配色
4. 在 iTerm2 Profile → Colors → Color Presets 选 `macOS Dark`，字体设为 `Sarasa Mono SC` 13pt

详细步骤见 [`macos/README.md`](macos/README.md)。

### Windows

1. 安装 Sarasa Mono SC 字体（per-user，无需管理员）
2. 安装 Windows Terminal：`winget install Microsoft.WindowsTerminal`
3. 把 `windows/settings.json` 复制到 `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`

详细步骤见 [`windows/README.md`](windows/README.md)。

### Claude Code (Mac)

1. 装 Node.js：`brew install node`
2. 装 Claude Code：`npm install -g @anthropic-ai/claude-code`
3. 装 CC-Switch Mac 版：https://github.com/farion1231/cc-switch/releases （dmg，已经 Apple 公证）
4. 在 CC-Switch 里配置百炼 API Key + 模型映射
5. 复制配置：`cp claude-code/settings.json ~/.claude/settings.json`
6. 启动：`claude`（或先 `cat claude-code/zshrc.append >> ~/.zshrc` 加个别名）

详细步骤见 [`claude-code/README.md`](claude-code/README.md)。

## Color scheme: macOS Dark

| Role           | Hex       |
|----------------|-----------|
| Background     | `#1E1E1E` |
| Foreground     | `#DDDDDD` |
| Cursor         | `#FFFFFF` |
| Selection      | `#264F78` |
| Black / Bright | `#1E1E1E` / `#7F7F7F` |
| Red / Bright   | `#E5222B` / `#FF6E62` |
| Green / Bright | `#19C718` / `#5FF96B` |
| Yellow / Bright| `#E5A922` / `#FFC95E` |
| Blue / Bright  | `#2B66FF` / `#6C9EFF` |
| Purple / Bright| `#C027B4` / `#E667D9` |
| Cyan / Bright  | `#19A9C7` / `#5CE3F0` |
| White / Bright | `#DDDDDD` / `#FFFFFF` |

## License

配置本身无版权限制，随意使用。字体 Sarasa Mono SC 遵循 SIL Open Font License 1.1。
