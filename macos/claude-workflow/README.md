# Claude Code 项目工作流 (macOS 版)

这是为 macOS 适配的终端 + Obsidian + Claude Code 工作流。它提供了一组 Zsh 函数，让你能在终端中快速创建、切换项目，并结合 Obsidian 模板管理复杂的任务。

## 安装步骤

### 1. 配置 Zsh 环境

将 `claude.zsh` 复制到你的配置目录（例如 `~/.zsh/`）或直接复制内容追加到 `~/.zshrc`：

```bash
# 方法 A: 直接追加到 .zshrc
cat claude.zsh >> ~/.zshrc

# 方法 B: 作为一个单独的文件引入
mkdir -p ~/.zsh/
cp claude.zsh ~/.zsh/
echo "source ~/.zsh/claude.zsh" >> ~/.zshrc
```

使配置生效：
```bash
source ~/.zshrc
```

### 2. 配置项目根目录 (可选)

默认情况下，工作流会将项目创建在 `~/Projects`。如果你想改用其他目录，在 `~/.zshrc` 中添加：

```bash
export CLAUDE_PROJECT_ROOT="/Users/你的用户名/Documents/Projects"
```

### 3. 配置 Obsidian 模板

1. 在 Obsidian 中打开你的主干 Vault。
2. 将 `templates/` 目录下的所有 `.md` 文件复制到你的 Obsidian Vault 的模板目录下。
3. 参考 `templates/USER-GUIDE.md` 了解如何使用 TASK-HUB 等看板模板。

## 使用方法

在终端中使用以下命令：

- **`pj`** (Project Jump):
  - 不带参数时：列出所有按时间排序的项目，输入序号快速进入。
  - 带参数时 (`pj my-project`)：如果存在直接进入；如果不存在，询问是否创建。进入后会自动启动 Claude Code。
- **`cr`** (Claude Restore): 恢复上一次在任何项目中运行的最后一次对话。
- **`cc`** (Claude Continue): 继续当前项目中最近的一次对话。
- **`pl`** (Project List): 单纯列出所有项目。

