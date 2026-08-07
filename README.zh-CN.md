# 数字员工一键搭建包

[English](README.md)

把一个会答疑的「数字员工」接进你们公司的钉钉，全程不需要你会写代码，不需要编辑任何配置文件。

搭好之后的效果：同事在钉钉里 @ 这个机器人问问题，它会**只根据你批准过的资料**
回答，并且附上出处；资料里没写的，它会老实说不知道并转人工，不会瞎编。

---

## 你需要准备什么

| 需要的东西 | 说明 |
| --- | --- |
| 一台电脑或服务器 | Mac / Windows / Linux 都行 |
| Node.js 20 或更高 | 没装也没关系，AI 助手会带你装 |
| 一个 AI 编程助手（可选） | [Claude Code](https://claude.com/claude-code)、Codex、Cursor 等任选 |

就这些。密钥、钉钉配置、引擎配置全部由部署命令交互式处理。

## 怎么用

### 方式一：交给 AI 助手（推荐）

```bash
git clone https://github.com/fullstack-ai-infra/digital-employee-quickstart.git
cd digital-employee-quickstart
claude   # 或你喜欢的 AI 编程助手
```

然后说一句话：

```
帮我搭建数字员工，按 AGENTS.md 来
```

### 方式二：自己跑部署命令

```bash
npx @fullstack-ai-infra/digital-employee deploy
```

这条命令全程交互式引导：

1. **选语言** — English / 简体中文（自动检测系统 locale）
2. **选渠道** — 钉钉 / 终端 / HTTP 接口
3. **扫码授权**（仅钉钉） — 终端内显示二维码，扫完自动继续
4. **起名字** — 给数字员工取个名
5. **选 AI 引擎** — 自动检测本机已安装的 Agent Host，已登录的标为可用
6. **自动部署** — 创建应用、配置机器人、启动服务
7. **完成** — 告诉你下一步怎么做

### 部署完成后

给数字员工喂资料：

```
knowledge/            ← 把公司的规章、手册、FAQ 放这里（markdown 格式）
```

每次改完 `knowledge/` 里的文件，需要重启服务才能生效。

## 其他场景

| 案例 | 场景 | 要模型密钥吗 |
| --- | --- | --- |
| [01 钉钉问答](cases/01-dingtalk-qa/) | 同事能在钉钉里聊天的机器人 | 要 |
| [02 HTTP 接口](cases/02-http-api/) | 接进你自己的系统 | 要 |
| [03 最小问答包](cases/03-minimal-answer/) | 可交付、可验收的员工包 | **不要** |
| [04 结构化提案](cases/04-structured-action/) | 只提案不执行的审批场景 | **不要** |
| [05 多宿主运行](cases/05-multi-host/) | 同一个包跑在不同 Agent Host 上 | 要 |

详见 [cases/README.md](cases/README.md)。

## 不想用 AI 助手，想自己一步步做

看 `docs/` 目录，按顺序来：

1. [01-准备工作.md](docs/01-准备工作.md)
2. [02-创建钉钉机器人.md](docs/02-创建钉钉机器人.md)
3. [03-启动数字员工.md](docs/03-启动数字员工.md)
4. [04-沉淀知识库.md](docs/04-沉淀知识库.md)
5. [05-常见问题.md](docs/05-常见问题.md)

## 目录结构

```
.
├── README.md              ← 英文版
├── README.zh-CN.md        ← 你在看的这份
├── AGENTS.md              ← 给 AI 编程助手看的操作手册
├── CLAUDE.md              ← 指向 AGENTS.md
├── cases/                 ← 案例库
├── docs/                  ← 手动操作的分步教程
└── knowledge/             ← 你的知识库（数字员工的"课本"）
```

## 安全说明

- 部署命令将配置存储在 `~/.digital-employee/config.json`。密钥（如 OpenAI key）仅存在本地，不会传到 GitHub。
- 数字员工默认**只读**：它不会帮你审批、不会改数据、不会发起任何操作。
- 它只读你明确批准的资料，不会自己去翻公司的其他文档。

更多边界说明见引擎项目的
[SECURITY.md](https://github.com/fullstack-ai-infra/digital-employee/blob/main/SECURITY.md)。

## 许可

本仓库为搭建脚手架，采用 Apache-2.0 许可。引擎
[Digital Employee](https://github.com/fullstack-ai-infra/digital-employee)
同为 Apache-2.0，版权归其作者所有。
