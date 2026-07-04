# Claude Code Mac 安装配置

把 Windows 上的 Claude Code 使用体验完美搬到 macOS，并使用 LiteLLM 作为底层代理，实现与国内大模型（如百炼）的完美对接（支持全部的高级 Tool Calls 功能）。

---

## 总览 / Overview

整体架构：

```
┌────────────────┐       ┌────────────────┐      ┌──────────────────┐
│  Terminal.app  │  ──▶  │  Claude Code   │ ──▶  │     LiteLLM      │
│  或 iTerm2     │       │  (CLI 前端)     │      │  (本地格式转换代理) │
└────────────────┘       └────────────────┘      └──────────────────┘
                                                          │
                                                          ▼
                                                  ┌──────────────────┐
                                                  │ 百炼 / Bailian   │
                                                  │ Qwen / DeepSeek  │
                                                  │ / Kimi / GLM     │
                                                  └──────────────────┘
```

- **Claude Code** 是 Anthropic 官方的 CLI 前端，只能发送 Anthropic 格式的请求。
- **LiteLLM** 在本地 (`http://127.0.0.1:4000`) 启动代理服务，将 Claude Code 的请求（包含文件读取等复杂的 Tool Calls）无缝翻译成 OpenAI 格式。
- **阿里云百炼** 接收 OpenAI 格式请求并返回结果，LiteLLM 再将其翻译回 Anthropic 格式给 Claude Code。

## 步骤 1：安装 Node.js（v18+）与 Python 3

```bash
# 如果还没装 Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 装 Node 和 Python3
brew install node python3

# 验证
node --version
python3 --version
```

## 步骤 2：安装 Claude Code 与 LiteLLM

```bash
# 安装 Claude Code
npm install -g @anthropic-ai/claude-code

# 安装 LiteLLM 及其代理依赖
pip3 install 'litellm[proxy]'
```

## 步骤 3：启动 LiteLLM 代理服务

你需要把百炼的 API Key 填入环境变量，并用 LiteLLM 启动一个后台代理。
目前由于百炼官方兼容接口不存在 `glm-5.2`，强烈建议使用通义千问最强模型 `qwen-plus` 或 `qwen-max`。

```bash
# 替换为你的百炼 API Key
export OPENAI_API_KEY="sk-你的百炼APIKey"

# 启动代理（默认监听在 4000 端口）
nohup litellm --model openai/qwen-plus --api_base https://dashscope.aliyuncs.com/compatible-mode/v1 > /tmp/litellm.log 2>&1 &
```

> **注意：** 如果你需要更换模型，请先结束旧的代理进程：
> `lsof -ti:4000 | xargs kill -9`
> 然后把启动命令中的 `openai/qwen-plus` 换成你需要测试的其他百炼模型，重新运行即可。

## 步骤 4：应用 Claude 配置文件

把本目录下的 `settings.json` 复制到 `~/.claude/settings.json`：

```bash
mkdir -p ~/.claude
cp settings.json ~/.claude/settings.json
```

这个配置文件将 `ANTHROPIC_BASE_URL` 设置为了 `http://127.0.0.1:4000`，让 Claude Code 自动连上 LiteLLM 代理。

## 步骤 5：配置 shell 别名（可选）

为了方便每次自动设置环境变量并启动，可以将以下内容追加到你的 `~/.zshrc`：

```bash
cat >> ~/.zshrc << 'ALIAS_EOF'

# Claude Code 快捷启动
alias ai="claude"

# 如果你希望每次开机自动启动代理，可以把代理启动脚本写成一个 alias
alias start-ai-proxy='lsof -ti:4000 | xargs kill -9 2>/dev/null; export OPENAI_API_KEY="sk-你的百炼APIKey"; nohup litellm --model openai/qwen-plus --api_base https://dashscope.aliyuncs.com/compatible-mode/v1 > /tmp/litellm.log 2>&1 & echo "LiteLLM 代理已启动"'
ALIAS_EOF

source ~/.zshrc
```

## 步骤 6：启动

```bash
# 确保 LiteLLM 代理已经在跑了，然后直接运行：
claude
# 或者用别名
ai
```

---

## 避坑指南 / Troubleshooting

### 为什么不用直接配 `ANTHROPIC_BASE_URL=百炼地址`？
因为 Claude Code 采用的是 Anthropic 专属协议，且最近加入了严格的连通性探测（`HEAD` 请求验证）。百炼仅兼容 OpenAI 协议。如果直连，不但 Tool Calls（工具调用）完全失效导致无限挂起，连最基础的对话都无法建立。**必须使用 LiteLLM 在本地进行全协议格式转换。**

### 为什么弃用 CC-Switch 和之前的轻量 Python 脚本？
- **CC-Switch**：虽然支持格式转换，但缺少对近期 Claude Code `HEAD` 网络探测的响应支持，刚启动就会抛出连接错误。
- **自定义轻量级代理**：只实现了文本流的转换，但完全丢弃了智能体最重要的 `Tool Calls`（文件操作、运行命令等功能），导致对话无限挂起。
**LiteLLM 是目前最成熟的方案，全协议转换完美支持。**

### 遇到端口被占用 / 代理无响应
如果你遇到 API Error 超时，请检查本地 4000 端口：
```bash
lsof -i :4000
```
杀掉后重新运行代理启动命令。

## 文件清单 / Files

- `settings.json` — LiteLLM 代理版配置（配合端口 4000 使用）
- `CLAUDE.md` — 项目级指令模板（放到任意项目根目录，Claude Code 会自动读取）
- `zhengxi-views-install.md` — **郑希观点库 skill 的 Windows 安装最佳实践**
- `README.md` — 本文档
