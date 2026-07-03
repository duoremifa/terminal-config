# Claude Code 项目管理工作流 / Claude Code Project Workflow

用**终端 + Obsidian + Claude Code** 管理多个项目的日常工作流。按项目隔离会话、集中管理任务、在 Obsidian 里统一看结果。

A terminal-centric workflow that manages daily work across multiple projects. Sessions are isolated per project, tasks are aggregated centrally, and results are viewed in Obsidian.

---

## 设计思路 / Philosophy

```
┌─────────────────────────────────────────────────┐
│  Obsidian (vault = 项目根目录)                    │
│                                                 │
│  ├── 项目A/                                     │
│  │   ├── CLAUDE.md     ← Claude 进入时自动加载   │
│  │   ├── TODO.md       ← 该项目的任务             │
│  │   └── ... 其他文档                            │
│  ├── 项目B/                                     │
│  │   ├── CLAUDE.md                              │
│  │   ├── TODO.md                                │
│  │   └── ...                                    │
│  └── 任务中心.md   ← Tasks 插件聚合所有项目任务    │
└─────────────────────────────────────────────────┘
              ▲ 直接读写 md 文件
              │
┌─────────────────────────────────────────────────┐
│  Claude Code (CLI)                              │
│                                                 │
│  - 每个项目独立会话 + 独立 memory                  │
│  - 用 CLAUDE.md 理解项目上下文                    │
│  - 用 Tasks 格式 (📅 ⏳ 🛫) 管理任务             │
│  - 会话历史自动存在 ~/.claude/projects/           │
└─────────────────────────────────────────────────┘
              ▲
              │ pj / cc / cr / pl 快捷命令
              │
┌─────────────────────────────────────────────────┐
│  PowerShell profile.d/06-claude.ps1             │
│  提供项目管理快捷命令                              │
└─────────────────────────────────────────────────┘
```

**核心理念**：
- **项目 = 文件夹**。每个项目独立，互不干扰
- **会话自动持久化**。退出再进接着聊
- **Obsidian 看结果，终端管会话**。两个工具各做擅长的事
- **任务分散存储，集中查看**。每个项目里写任务，任务中心聚合

---

## 目录结构 / Layout

```
claude-workflow/
├── README.md              ← 本文件
├── claude.ps1             ← PowerShell 快捷命令（装到 profile.d）
├── setup.ps1              ← 一键部署脚本
└── templates/
    ├── PROJECT-CLAUDE.md  ← 每个项目根的说明文件模板
    ├── TODO.md            ← 每个项目的任务列表模板
    ├── TASK-HUB.md        ← 任务聚合中心（放 vault 根）
    └── USER-GUIDE.md      ← 操作指南模板（自用或给同事）
```

---

## 安装 / Install

### 1. 部署 PowerShell 模块

```powershell
# 复制 claude.ps1 到你的 PowerShell profile.d 目录
$src = "<repo>\windows\claude-workflow\claude.ps1"
$dst = "$env:USERPROFILE\Documents\WindowsPowerShell\profile.d\06-claude.ps1"
Copy-Item $src $dst -Force
```

### 2. 配置项目根目录

**方法 A**：编辑 `06-claude-claude.ps1` 里的 `$script:ClaudeProjectRoot`

**方法 B**：设环境变量（推荐，不改脚本）

```powershell
# 在 Microsoft.PowerShell_profile.ps1 里加一行
$env:CLAUDE_PROJECT_ROOT = "$env:USERPROFILE\Projects"
```

### 3. 部署 Obsidian 模板

```powershell
# 复制任务中心到你的 vault 根
$src = "<repo>\windows\claude-workflow\templates\TASK-HUB.md"
$dst = "$env:CLAUDE_PROJECT_ROOT\任务中心.md"
Copy-Item $src $dst -Force
```

### 4. 给每个项目初始化

```powershell
# 对每个项目文件夹执行：
$templateDir = "<repo>\windows\claude-workflow\templates"
$project = "$env:CLAUDE_PROJECT_ROOT\项目A"
Copy-Item "$templateDir\PROJECT-CLAUDE.md" "$project\CLAUDE.md"
Copy-Item "$templateDir\TODO.md" "$project\TODO.md"
```

或者用 **`setup.ps1`** 一键搞定（见下文）。

---

## 快捷命令 / Commands

| 命令 | 作用 |
|---|---|
| `pj [项目]` | 进入项目并启动 claude；不带参数列菜单 |
| `cc` | 继续当前项目上次会话 |
| `cr` | 从历史里挑一个会话恢复 |
| `pl` | 列出所有项目 |
| `/projects` | (在 claude 内) 切换项目 |

---

## 任务管理 / Task Management

### 任务格式（Tasks 插件）

```markdown
- [ ] 任务描述 📅 2026-07-05    # 到期日，显示在日历
- [ ] 任务描述 ⏳ 2026-07-03    # 计划日
- [ ] 任务描述 🛫 2026-07-01    # 开始日
- [ ] 任务描述                  # 无日期，在"待安排"里
```

### 任务聚合（任务中心.md）

用 Tasks 查询语法聚合全 vault 的任务：

````markdown
```tasks
due before tomorrow
not done
```
````

### 推荐 Obsidian 插件

| 插件 | 作用 |
|---|---|
| Tasks | 任务查询和聚合 |
| Full Calendar | 日历视图看任务 |
| Dataview | (可选) 更复杂的查询 |

---

## 一键部署脚本 / setup.ps1

```powershell
# 运行前确认 $ProjectRoot 和 $VaultRoot 指向正确位置
.\setup.ps1
```

脚本会：
1. 创建项目根目录（如不存在）
2. 复制 `claude.ps1` 到 `profile.d/`
3. 在 vault 根创建 `任务中心.md`
4. 给每个子文件夹初始化 `CLAUDE.md` + `TODO.md`（如不存在）

---

## 日常用法 / Daily Use

```powershell
# 早上开工
pj              # 列菜单选项目

# 干活中...
# (Claude 里帮忙写文档、改代码、处理 Excel 等)

# 切换项目
pj 另一个项目    # 或 /projects (在 claude 内)

# 接着昨天进度
cc              # 继续当前项目

# 找历史会话
cr              # 列出所有历史

# 用 Obsidian 看结果
# 打开 vault，所有 md 文件都在
```

---

## 脱敏说明 / Anonymization

本模板是通用版，不含任何个人信息：
- 项目名用 `项目A / 项目B` 占位
- 路径用环境变量 `$env:CLAUDE_PROJECT_ROOT`
- 任务示例是通用的（"写文档"、"整理数据"等）
- 无公司名、无同事名、无业务数据

你可以 fork 后按自己的项目填充。
