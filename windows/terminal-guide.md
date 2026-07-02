# 你的终端操作手册

> 这台机器上的 Windows Terminal + PowerShell 5.1，是专门为你这套工作流调过的。
> 文档里的命令都可以直接复制粘贴。
> 最后更新：2026/07/01

---

## 0. 先搞清楚你在用什么

| 组件 | 状态 |
|---|---|
| Windows Terminal | 已装，默认 PowerShell，macOS Dark 主题，Sarasa Mono SC 10pt |
| PowerShell | 5.1（系统自带，没有 admin 装不了 pwsh 7） |
| 字体 | Sarasa Mono SC（等距更纱黑体），VS Code / Obsidian 都是同款，视觉一致 |
| 透明度 | 85% 亚克力模糊，滚动条隐藏，光标是竖线 |
| Admin | **没有**——装东西只能走 winget / 用户目录 / MSIX |
| 网络 | `github.com` 直连会超时，下载要走 `gh-proxy.com` 镜像 |

---

## 1. 启动 & 切换

- **打开终端**：`Win + R` → 输入 `wt` → 回车。比开始菜单快。
- **以管理员身份**：你没 admin，这招用不上，跳过。
- **在当前文件夹打开终端**：在资源管理器地址栏输入 `wt` 回车，终端会直接定位到当前目录。
- **从 VS Code 里打开**：`` Ctrl + ` ``，底部直接出集成终端，已经是 PowerShell + 更纱。
- **切换标签页**：`Ctrl + Tab`（下一个）/ `Ctrl + Shift + Tab`（上一个）。
- **跳到指定标签**：`Ctrl + Alt + 1/2/3...`

---

## 2. 窗口 & 分屏（你已经配好了，直接记快捷键）

| 操作 | 快捷键 |
|---|---|
| 左右分屏 | `Alt + Shift + -` |
| 上下分屏 | `Alt + Shift + +` |
| 关闭当前窗格 | `Ctrl + Shift + W` |
| 当前窗格放大/还原 | 没绑——建议绑 `Alt + Enter`（下面教你加） |
| 在新标签打开 | 你配了，默认 `Ctrl + Shift + T` |
| 新建窗口 | `Ctrl + Shift + N` |

**想加"放大窗格"的快捷键？** 在设置 JSON 的 `keybindings` 数组里加一条：

```json
{ "id": "User.toggleZoom", "keys": "alt+enter" }
```

---

## 3. 产品经理最常用的几条命令

### 3.1 一秒打开你常用的应用

直接敲名字就行（前提是 Start 菜单里有快捷方式）：

```powershell
code            # VS Code
code .          # VS Code 打开当前文件夹
obsidian        # Obsidian
wt              # 再开一个终端窗口
notepad         # 记事本
```

> 如果某个命令不识别，把它的 .lnk 路径加到 PATH。下面有一节专门讲。

### 3.2 快速在 Obsidian / VS Code / 资源管理器 间跳转

```powershell
# 打开 Obsidian 笔记库根目录（你的库在 Downloads）
Invoke-Item "$env:USERPROFILE\Downloads"

# 用 VS Code 打开某个 md 文件
code "$env:USERPROFILE\Downloads\xxx.md"

# 用资源管理器打开当前目录
ii .
```

`ii` 是 `Invoke-Item` 的别名——Windows 下"用默认程序打开"的万能命令。
`ii xxx.drawio` 会直接唤起 drawio 桌面版。

### 3.3 文件搜索（比资源管理器快）

```powershell
# 在当前目录找所有 .md 文件（递归）
gci -Recurse -Filter *.md

# 在当前目录找包含"权限"二字的 md 文件内容
gci -Recurse -Filter *.md | sls "权限"

# 找最近 7 天改过的文件
gci -Recurse | ? LastWriteTime -gt (Get-Date).AddDays(-7)
```

> `gci` = `Get-ChildItem`（ls）；`?` = `Where-Object`（过滤）；`sls` = `Select-String`（grep）。

### 3.4 剪贴板——终端和 IM 之间的桥梁

```powershell
# 把一段文字直接塞进剪贴板，去钉钉/飞书里 Ctrl+V
"这个版本主要改了权限中心的审批链路" | clip

# 把某个文件内容塞进剪贴板
clip < .\CHANGELOG.md

# 把命令输出塞进剪贴板
gci -Recurse -Filter *.md | clip
```

### 3.5 批量重命名文件（产品截图 / PRD 版本）

```powershell
# 把 screenshots/ 下所有 png 加上日期前缀
gci screenshots\*.png | % { Rename-Item $_.FullName "20260701-$($_.Name)" }
```

---

## 4. 给 Obsidian 用户的定制技巧

你的 vault 在 `C:\Users\min.dai\Downloads`，从终端快速新建一条日记：

```powershell
# 在 Obsidian vault 里新建今天的日记骨架
$d = Get-Date -Format "yyyy-MM-dd"
$p = "$env:USERPROFILE\Downloads\$d.md"
"---`ntags: [daily]`n---`n`n# $d`n`n## 今日要事`n- `n`n## 笔记`n" | Out-File -Encoding utf8 $p
code $p
```

（要天天用，把这段塞进 PowerShell 配置文件，做成 `new-daily` 命令，见第 7 节。）

---

## 5. 给画图 / 画流程的人

你桌面上有 drawio，Start 菜单有 Mermaid Live Editor。终端能直接：

```powershell
# 打开 drawio 编辑某个文件
ii "$env:USERPROFILE\Desktop\权限中心.drawio"

# 在 Mermaid Live 网页上画图（用默认浏览器打开）
Start-Process "https://mermaid.live"
```

**小技巧**：Mermaid 的流程图语法可以直接写在 Obsidian 笔记里（装 Mermaid Plugins 插件即可渲染），不用再去 Live Editor。

---

## 6. 这台机器独有的坑 & 捷径

### 6.1 下载 GitHub 东西

直连 `github.com` 会超时。正确姿势：

```powershell
# 给任意 github URL 套一层镜像
$mirror = "https://gh-proxy.com/"
$url = $mirror + "https://github.com/user/repo/releases/download/v1.0/file.zip"
Invoke-WebRequest $url -OutFile file.zip
```

### 6.2 PowerShell 5.1 的编码陷阱

PS 5.1 读 `.ps1` 默认用 GBK。**UTF-8 的 .ps1 里有中文会乱码甚至报错**。两条出路：
- .ps1 里别写中文，全英文；
- 或者保存时加 UTF-8 BOM：`Out-File -Encoding utf8`（PS 5.1 的 utf8 自带 BOM）。

### 6.3 没 admin 也能装东西的三扇门

| 方法 | 命令 |
|---|---|
| winget（推荐） | `winget install 软件名` |
| 用户目录手动装 | 解压到 `$env:USERPROFILE\工具名`，加到 PATH |
| MSIX 包 | `Add-AppxPackage .\xxx.msix` |

你 Node 24 就是这么装到 `C:\Users\min.dai\node24` 的。

### 6.4 PATH 怎么加（用户级，不需要 admin）

```powershell
# 看当前用户 PATH
$env:PATH -split ';'

# 永久加一条（比如 C:\Users\min.dai\tools\bin）
[Environment]::SetEnvironmentVariable(
    "PATH",
    "C:\Users\min.dai\tools\bin;" + [Environment]::GetEnvironmentVariable("PATH", "User"),
    "User"
)
# 关掉重开终端才生效
```

### 6.5 "固定到任务栏"被公司策略禁了

你的 Monkeytype 快捷方式已经踩过这个坑。解决办法：**手动右键 .lnk → "固定到任务栏"**，脚本搞不定。

---

## 7. 打造你自己的命令（PowerShell Profile）

你目前**没有** PowerShell 配置文件——意味着每次开终端，你的"私人定制命令"都是空的。创建一个：

```powershell
# 创建配置文件（如果不存在）
if (-not (Test-Path $PROFILE)) { New-Item $PROFILE -Force }
# 用 VS Code 编辑
code $PROFILE
```

把这段贴进去保存，下次开终端就有这些快捷命令了：

```powershell
# ==== 我的快捷命令 ====

# obs —— 打开 Obsidian vault
function obs { Invoke-Item "$env:USERPROFILE\Downloads" }

# today —— 新建今日 Obsidian 日记
function today {
    $d = Get-Date -Format "yyyy-MM-dd"
    $p = "$env:USERPROFILE\Downloads\$d.md"
    if (Test-Path $p) { code $p; return }
    "---`ntags: [daily]`n---`n`n# $d`n`n## 今日要事`n- `n`n## 笔记`n" |
        Out-File -Encoding utf8 $p
    code $p
}

# ll —— 详细列表（Mac 习惯）
function ll { gci $args | Format-Table Mode, LastWriteTime, Length, Name }

# .. —— 上一层目录（比 cd .. 顺）
function .. { Set-Location .. }
function ... { Set-Location ..\.. }

# grep —— 让 PowerShell 也用 grep 这个名字
function grep($pattern, $path = ".") { gci -Recurse $path | sls $pattern }

# clipf —— 把文件内容塞进剪贴板
function clipf($path) { Get-Content $path | clip }

# gh-dl —— GitHub 镜像下载
function gh-dl($url, $out) {
    Invoke-WebRequest ("https://gh-proxy.com/" + $url) -OutFile $out
}
```

保存后，在当前终端执行 `. $PROFILE` 立即生效（或重开终端）。

---

## 8. 终端调教小贴士

- **字号不够大**：`Ctrl + +` 放大，`Ctrl + -` 缩小。
- **背景太花**：设置 → 外观 → 把不透明度从 85 调到 92 左右会更清爽。
- **复制不带格式**：已经关了 `copyFormatting`，直接 `Ctrl + Shift + C` 复制出来的就是纯文本，粘到 IM 不会有黑底。
- **搜索终端里的历史输出**：`Ctrl + Shift + F`。
- **命令历史**：`F7` 列出所有敲过的命令（图形化弹窗），`↑/↓` 单步翻。
- **快速清屏**：`Ctrl + L` 或敲 `cls`。
- **中断卡住的命令**：`Ctrl + C`；还不行就 `Ctrl + Break`（笔记本上通常是 `Ctrl + Fn + B` 或 `Pause`）。

---

## 9. 一页速查表（贴工位）

```
启动: Win+R  wt
新标签: Ctrl+Shift+T
分屏(左右): Alt+Shift+-
分屏(上下): Alt+Shift++
关窗格: Ctrl+Shift+W
下一标签: Ctrl+Tab
找历史: F7
清屏: Ctrl+L
复制: Ctrl+Shift+C
粘贴: Ctrl+Shift+V (或右键)
放大字: Ctrl+ +
搜终端输出: Ctrl+Shift+F
中断命令: Ctrl+C
打开当前目录资源管理器: ii .
塞进剪贴板: xxx | clip
VS Code 打开当前目录: code .
```

---

**想加什么进来？** 比如你常用的钉钉/飞书命令、Git 别名、或者某个重复性的操作，跟我说一声就能加进这份文档和 profile 里。

---

## 10. 已经帮你装好的"增强套件"

这三个插件已经装好，重开终端就生效。不需要你做任何配置。

### 10.1 PSReadLine 2.3.6 — 像搜索引擎一样的命令建议

**这是什么**：输入命令时，会**灰色**显示你**以前敲过**的类似命令作为建议，按 `→`（右方向键）接受，按 `Tab` 接受一个词。

**效果**：
- 输入 `cd Down`，如果以前敲过 `cd Downloads`，会灰色显示完整路径
- 输入 `gci -Rec`，会补全成 `gci -Recurse`
- 按 `↑/↓` 不再是一条条翻历史，而是按**你输入的前缀**过滤

**还有**：
- `F7` 弹出历史命令菜单，可上下选
- 历史记录**自动去重**、**跨会话保存**（下次开终端还在）
- 最多保存 4000 条，超出自动删旧的

**关掉/调回去？** 编辑 `Documents\WindowsPowerShell\profile.d\01-psreadline.ps1`，把 `Set-PSReadLineOption` 那几行注释掉（行首加 `#`）。

### 10.2 Terminal-Icons — 文件列表带颜色和图标

**这是什么**：`gci`（或 `ls`）输出的文件名，会按**文件类型上色**：
- `.md` 蓝色
- `.pdf` 红色
- `.drawio` 紫色
- 文件夹 青色
- 快捷方式 绿色

**效果**：一眼能分出文件类型，不用再读后缀名。

**图标问题**：Terminal-Icons 默认想用 NerdFont 图标（📄、📁 那种），但你装的 Sarasa Mono SC **不是 NerdFont**。两种可能：
- 图标显示为空白（**最常见的结果**）——颜色还在，不影响使用
- 图标显示为方块 `□`——可以禁用图标，只保留颜色（见故障排查 §12）

### 10.3 zoxide — 智能目录跳转

**这是什么**：一个 smarter 的 `cd`。它会**记住你去过的每个目录**，下次你只需要输入**目录名的一部分**。

**用法**：
```powershell
# 假设你以前 cd 到过 Downloads
z Down          # 跳到 Downloads，不用打全路径
z monkey        # 跳到 monkeytype
z profile       # 跳到 WindowsPowerShell/profile.d
z docs          # 跳到 Documents

# 模糊匹配多个词
z min Downloads   # 跳到包含 "min" 和 "Downloads" 的目录

# 不确定跳哪个？交互选择
zi Down            # 弹出候选列表让你选

# 看 zoxide 记住了哪些目录
zoxide query --list
```

**`cd` 还能用吗？** 能。`cd` 命令现在也**同时**告诉 zoxide，所以正常用 `cd` 就行，zoxide 会自动学习。

---

## 11. 已经帮你写好的"Profile"——你的自定义命令集

`Documents\WindowsPowerShell\` 下有这套结构：

```
WindowsPowerShell\
├── Microsoft.PowerShell_profile.ps1     ← 入口
└── profile.d\
    ├── 01-psreadline.ps1               ← PSReadLine 配置
    ├── 02-integrations.ps1             ← 加载 Terminal-Icons + zoxide
    ├── 03-workspaces.ps1               ← ws 工作目录书签
    ├── 04-aliases.ps1                  ← 短命令别名
    └── 05-functions.ps1                ← 自定义函数
```

**为什么这么拆**：以后想加功能，新建个 `06-xxx.ps1` 就行，不用改入口。

### 11.1 你现在可以敲的这些命令

| 命令 | 干啥 |
|---|---|
| `ws` | 列出所有工作目录书签 |
| `ws obsidian` | 跳到 Obsidian 库 |
| `ws monkey` | 跳到 monkeytype 目录 |
| `ws-add work C:\projects\权限中心` | 添加一个书签 |
| `obs` | 打开 Obsidian vault（资源管理器） |
| `today` | 创建/打开今天的 Obsidian 日记（`Downloads/yyyy-MM-dd.md`） |
| `ll` | 详细列表（带图标颜色） |
| `la` | 详细列表含隐藏文件 |
| `..` | 上一层目录（Mac 风） |
| `...` | 上两层 |
| `grep 权限` | 在当前目录递归搜内容 |
| `clipf 文件名.md` | 文件内容塞剪贴板 |
| `gh-dl <github-url> <文件>` | 通过 gh-proxy 镜像下载 |
| `which code` | 看 code 命令从哪来 |
| `tree-lite` | 看当前目录 2 层深的结构 |
| `peek xxx.drawio` | 用默认程序打开文件 |
| `ep` | 用 VS Code 打开 profile 目录（方便改） |
| `reload` | 改了 profile 后，重加载（不用重启终端） |

**改完 profile 想立刻生效？** 在终端里敲 `reload`，或关掉重开。

### 11.2 添加你自己的书签

```powershell
ws-add qxz "D:\projects\权限中心"   # 给权限中心项目起个别名
ws-add notes "C:\notes"              # 某个笔记目录
ws-add release                       # 不指定路径 = 用当前目录
```

之后 `ws qxz` 就跳过去了。

---

## 12. 故障排查

### 12.1 Terminal-Icons 显示方块字 `□`

说明 Sarasa Mono SC 里没对应 glyph。两个选择：

**选项 A：完全禁用 Terminal-Icons**（改回普通 ls）
编辑 `profile.d\02-integrations.ps1`，把 `Import-Module Terminal-Icons` 那行前面加 `#`。

**选项 B：只禁用图标，保留颜色**（推荐）
在 `profile.d\02-integrations.ps1` 末尾加一行：
```powershell
$global:TerminalIconsIcons = @{}
```
颜色保留、图标消失。

### 12.2 PSReadLine 建议没出现

确认两件事：
1. 你**重开了终端**（不是 reload）—— PSReadLine 必须重启才能升级生效
2. 你**之前敲过**这条命令——它从历史记录里学，第一次不会有建议

### 12.3 `z` 命令找不到

- 重开终端，看 profile 加载有没有警告
- 手动：`& "$env:USERPROFILE\zoxide\zoxide.exe" --version` 确认能跑
- 检查 PATH：`$env:PATH -split ';' | Select-String zoxide`

### 12.4 profile 加载报错

启动时看到 `WARNING: profile load failed: 01-xxx.ps1: ...` ——打开 `ep`（VS Code 编辑 profile 目录），找错在哪一行。

**通用调试**：
```powershell
. $PROFILE   # 强制 reload，看完整报错
```

### 12.5 PowerShell 5.1 中文编码

.ps1 文件里写中文，必须用 **UTF-8 with BOM** 保存。VS Code 里：`Ctrl+Shift+P` → `Change File Encoding` → `Save with Encoding` → `UTF-8 with BOM`。
否则 PS 5.1 用 GBK 解析，中文会乱。

**最简单的做法**：.ps1 里别写中文，全英文注释 + 英文函数名。中文只在 `ws-add` 之类的参数里出现，那是运行时字符串，不影响解析。

---

## 13. 一页总表（更新版，贴工位）

```
启动:            Win+R  wt
新标签:          Ctrl+Shift+T
分屏(左右):      Alt+Shift+-
分屏(上下):      Alt+Shift++
关窗格:          Ctrl+Shift+W
下一标签:        Ctrl+Tab
找历史:          F7
清屏:            Ctrl+L
复制:            Ctrl+Shift+C
粘贴:            Ctrl+Shift+V
放大字:          Ctrl+ +
搜终端输出:      Ctrl+Shift+F
中断命令:        Ctrl+C
资源管理器当前:  ii .
VS Code 当前:    code .
塞剪贴板:        xxx | clip
工作目录书签:    ws / ws <name>
智能跳转:        z <部分名>
今日日记:        today
搜内容:          grep <关键字>
打开 Obsidian:   obs
改 profile:      ep
重载 profile:    reload
```

---

## 14. 新手练习（5 分钟上手）

> 如果你是第一次用终端，**按顺序跟着做完 6 个练习**。每条命令都要**真的敲**，看懂不等于会用。
> 做完这套，你就"会用终端"了。剩下的都是"用到再查"。

### 14.1 开始前的心态

- **别背命令**。忘了就翻回 §13 那页总表看。
- **别追求一次学会**。第一档 7 条练一周，第二档下周再加。
- **`Tab` 是王道**。任何时候都先敲几个字母按 Tab 让终端补全，**别手打完整名字**。
- **敲错了没事**。终端不会把你电脑弄坏（`rm` 要小心，其他都安全）。

### 14.2 先打开终端

按 `Win + R`，敲 `wt`，回车。

看到黑色窗口、白色文字、光标在闪——就对了。

### 14.3 练习 1：空间感（4 条命令）

这个练习让你知道"我在哪 / 这有什么 / 怎么移动"。

**任务 1.1：看我在哪**
```
pwd
```
回车。你会看到类似 `C:\Users\min.dai` —— 这就是你当前所在的目录。
> 类比：资源管理器顶部的地址栏。

**任务 1.2：看这里有什么**
```
ls
```
回车。会列出一堆名字：`Desktop`、`Documents`、`Downloads`、`monkeytype`……
> 如果带颜色/图标 —— 那是 Terminal-Icons 在干活，文件夹应该是青色的。

**任务 1.3：进一个目录**
```
cd Desktop
```
回车。然后敲 `pwd` 回车 —— 应该变成 `C:\Users\min.dai\Desktop`。
再敲 `ls` —— 应该看到 `Monkeytype.lnk` / `Obsidian.lnk` / `权限中心.drawio` 等。

**任务 1.4：回上一层**
```
cd ..
pwd
```
回车 —— 回到 `C:\Users\min.dai`。
> 两个点 `..` 代表"父目录"。记这个就行，别的先别管。

**✅ 检验**：能不看这文档，说出 `pwd` / `ls` / `cd` / `cd ..` 各自干啥，这个练习就过了。

### 14.4 练习 2：`Tab` 自动补全（最重要的习惯）

这个**单独成一个练习**，因为它值得成为你的本能反应。

**任务 2.1：让 Tab 帮你补全目录名**
```
cd De<Tab>
```
只敲 `De` 然后按 `Tab` 键 —— 应该自动补全成 `Desktop`。回车，进去了。
> 如果按 Tab 没反应 / 哔一声 —— 说明补全不唯一（多个以 De 开头的），再敲个 `s` 变成 `Des` 再按 Tab。

**任务 2.2：用 Tab 补全文件名**
```
ii 权限<Tab>
```
敲"权限"两个中文字然后按 Tab —— 应该会补全成 `权限中心.drawio`。
> 这个超好用：你不用记完整文件名，记得前两个字就够。

**✅ 检验**：任何时候要敲文件名/目录名，**第一反应是按 Tab**，不是继续手打。养成这个习惯，速度翻倍。

### 14.5 练习 3：打开文件

**任务 3.1：用 ii 打开一个文件**
```
ii 权限中心.drawio
```
回车 —— drawio 应该弹出来了。关掉它回来。
> `ii` 是 `Invoke-Item` 的别名，意思是"用默认程序打开"。
> `.md` 会用记事本打开，`.pdf` 会用浏览器/阅读器打开，`.lnk` 会启动快捷方式指向的程序。

**任务 3.2：打开当前目录的资源管理器**
```
ii .
```
> `.` 代表"当前目录"。这会让资源管理器弹出，位置正是你终端现在待的地方。
> 超有用：在终端里切到某个深目录，想看一眼文件 —— `ii .` 直接跳过去。

**✅ 检验**：看到一个文件名，能下意识敲 `ii ` + Tab 打开它。

### 14.6 练习 4：命令复用 + 清屏

**任务 4.1：用 ↑ 拿回上一条命令**
```
ls
```
回车。然后按 **↑**（键盘上箭头）—— `ls` 又回来了，回车再跑一次。
按多次 ↑ 可以翻更早的命令。
> 进阶：装了 PSReadLine 之后，↑ 会按你输入的前缀过滤历史。比如敲 `cd` 再按 ↑，只会在 `cd` 开头的历史里翻。

**任务 4.2：清屏**
```
Ctrl+L
```
屏幕清空，光标回到顶部。你之前敲的所有命令还在历史里（↑ 能翻出来），只是看不见了。
> 终端用久了屏幕会很乱，`Ctrl+L` 一秒变清爽。

**✅ 检验**：能不看文档用 ↑ 找回之前敲过的命令，会 `Ctrl+L` 清屏。

### 14.7 练习 5：VS Code 联动

**任务 5.1：用 VS Code 打开当前目录**
```
cd Desktop
code .
```
回车 —— VS Code 弹出来了，左边文件树就是你的 Desktop。
> `code` 是 VS Code 的命令名，`.` 是当前目录。

**任务 5.2：用 VS Code 打开某个文件**
```
code _writetest.txt
```
> 直接编辑文本/markdown 文件超方便。

**✅ 检验**：要编辑文件时，第一反应是 `code 文件名`，不是去开始菜单找 VS Code。

### 14.8 练习 6：剪贴板 + 智能跳转（第一档熟练后再做）

**任务 6.1：把 ls 输出塞到剪贴板**
```
ls | clip
```
回车（看起来什么都没发生）。现在切到微信/钉钉/邮件，`Ctrl+V` —— 你桌面的文件列表粘进去了。
> 同理：`pwd | clip` 把当前路径塞进剪贴板，发给同事"我现在在哪个目录"时超好用。

**任务 6.2：用 z 智能跳目录**
```
z Down
```
回车 —— 直接跳到 Downloads。不用敲完整路径。
> zoxide 会记住你去过的目录。第一次用可能没反应（它还没学习过），先正常 `cd Downloads` 几次，之后 `z Down` 就能跳了。
> 想看 zoxide 记住了什么：`zoxide query --list`

**✅ 检验**：要给同事发当前路径时，会 `pwd | clip`；要切到常用目录时，会 `z 名字`。

### 14.9 自我检验清单

做完练习，过几天问自己——能打勾就说明"会了"：

```
[ ] 打开终端: Win+R → wt → 回车
[ ] 看我在哪: pwd
[ ] 看这里有什么: ls
[ ] 进目录: cd Desktop
[ ] 回上一层: cd ..
[ ] 文件名不用手打，按 Tab 补全
[ ] 打开文件: ii 文件名<Tab>
[ ] 打开当前目录资源管理器: ii .
[ ] 复用上一条命令: ↑
[ ] 清屏: Ctrl+L
[ ] 用 VS Code 打开当前目录: code .
[ ] 把命令输出发给同事: xxx | clip
```

> **12 条全打勾 = 终端入门完成**。后面用到的新命令，按第二档慢慢加。
> 如果哪条做不到，翻回对应的练习再做一遍。

### 14.10 常见翻车 & 怎么办

| 现象 | 原因 | 怎么办 |
|---|---|---|
| 按 Tab 没反应 / 哔一声 | 补全不唯一（多个匹配） | 再敲几个字母缩小范围，或按两次 Tab 看所有候选 |
| `cd` 报"找不到路径" | 名字打错了 | `ls` 看一眼，或用 Tab 补全 |
| `ii xxx` 报"找不到" | 文件名不对或不在当前目录 | `pwd` 看位置，`ls` 看文件，Tab 补全 |
| `code` 没反应 | VS Code 没加到 PATH | 打开 VS Code → `Ctrl+Shift+P` → 输 "shell command" → "Install code command in PATH" |
| 中文乱码 | 文件编码问题 | 见 §12.5 |
| 不知道自己在哪 | 忘了 `pwd` | **随时 `pwd`**，敲这个不费事 |
| 卡住了 / 命令一直在跑 | 死循环或下载卡住 | `Ctrl+C` 中断 |

---

**装了什么 / 在哪 / 怎么改**，都在文档里了。

有哪个命令你每天会反复敲的，告诉我，我再给它写个更短的名字，或者帮你绑个快捷键。
