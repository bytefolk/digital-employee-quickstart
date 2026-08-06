# Digital Employee Quickstart

[简体中文](README.zh-CN.md)

Put a question-answering digital employee into your company's DingTalk —
without writing any code.

Once it is running, colleagues ask the bot a question in DingTalk and it answers
**only from material you have approved**, with the source attached. When the
answer is not in your material, it says so and hands off to a human instead of
making something up.

---

## What this repo is

The engine doing the actual work is
[Digital Employee](https://github.com/fullstack-ai-infra/digital-employee),
an open-source read-only answer runtime. Getting it running means registering a
DingTalk app, collecting credentials, wiring up a model, writing a config file,
and keeping a service alive — a real barrier if you are not a developer.

This repo turns that whole flow into **a runbook an AI coding agent can execute
for you, plus the scripts it drives**. Install an AI coding agent, tell it to set
up your digital employee, and follow along.

## What you need

| Requirement | Notes |
| --- | --- |
| A computer or server | macOS / Windows / Linux all work |
| A DingTalk **admin** account | Regular members usually cannot create apps — ask your IT admin |
| An LLM API key | OpenAI, or any OpenAI-compatible endpoint |
| An AI coding agent | [Claude Code](https://claude.com/claude-code), Codex, Cursor, … |
| Node.js 20+ | Not installed? The agent will walk you through it |

## Usage (recommended: hand it to an AI agent)

### 1. Get the project

```bash
git clone https://github.com/fullstack-ai-infra/digital-employee-quickstart.git
cd digital-employee-quickstart
```

### 2. Open your AI coding agent in that directory

For example, with Claude Code:

```bash
claude
```

### 3. Say one thing

```
Set up my digital employee, follow AGENTS.md
```

From there you just cooperate. The agent asks when it needs something from you
and reports progress the rest of the time.

**It will need you three times** — worth knowing up front:

1. **Authorize DingTalk** — it gives you a link and a code; open it with your
   admin account.
2. **Pick an approver** — publishing the app requires approval, so it lists the
   candidates and asks you to choose.
3. **Provide model details** — your endpoint URL, model name, and API key.

### 4. Wait for approval

After the app version is submitted, an approver has to accept it inside
DingTalk. **Until that happens the bot is not searchable in DingTalk** — that is
expected, not a broken setup. Chasing the approver is on you.

Once approved, search DingTalk for the name you gave the bot and start chatting.

## Prefer to do it yourself, step by step

Walk through `docs/` in order:

1. [01 — Prerequisites](docs/01-准备工作.md)
2. [02 — Create the DingTalk bot](docs/02-创建钉钉机器人.md)
3. [03 — Start the digital employee](docs/03-启动数字员工.md)
4. [04 — Build up the knowledge base](docs/04-沉淀知识库.md)
5. [05 — Troubleshooting](docs/05-常见问题.md)

> These step-by-step guides are currently written in Simplified Chinese.
> English translations are welcome — see [CONTRIBUTING](#contributing).

## Day-to-day operation

The digital employee only answers from **material you give it**. So the main
ongoing job is feeding it:

```
knowledge/            ← company policies, handbooks, FAQs (markdown)
```

**Every time you edit anything in `knowledge/`, restart the service** or the
change will not take effect:

```bash
bash scripts/start.sh
```

Common commands:

```bash
bash scripts/doctor.sh             # health check: where you are, what is next
```

```bash
bash scripts/ask.sh "your question"  # test from the terminal, skipping DingTalk
```

```bash
bash scripts/logs.sh               # service logs
```

```bash
bash scripts/stop.sh               # stop the service
```

**When you are not sure what state things are in, run `doctor.sh`** — it tells
you the next step:

```
【1/6】基础软件      齐了
【2/6】钉钉登录      已登录
【3/6】钉钉应用      已创建（数字员工-答疑助手）
【4/6】发布审批      等审批中（机器人此时搜不到，去催审批人）
【5/6】引擎与配置    就绪（知识库 3 个文件）
【6/6】服务运行      运行中，钉钉已连接
```

## Layout

```
.
├── README.md              ← this file
├── README.zh-CN.md        ← Simplified Chinese
├── AGENTS.md              ← the runbook your AI coding agent follows
├── CLAUDE.md              ← points at AGENTS.md
├── .env.example           ← secrets template (copy to .env and fill in)
├── docs/                  ← manual step-by-step guides
├── scripts/               ← the one-command scripts
├── templates/             ← config file template
├── knowledge/             ← your knowledge base (the bot's textbook)
└── runtime/               ← the engine itself; scripts fetch it, git ignores it
```

## Writing knowledge that actually gets found

Retrieval is keyword-based, so **phrase your headings the way people actually
ask**. This is measurable, not folklore — same document, same question:

| Heading | Asking "值班时间是几点到几点" |
| --- | --- |
| `## 值班时间` | ❌ falls back to "not enough evidence" |
| `## 值班时间是几点到几点 / 值班时间 / 什么时候有人` | ✅ answers correctly, with a source |

Cover the common phrasings in the heading, separated by `/`. Details in
[04 — Build up the knowledge base](docs/04-沉淀知识库.md).

## Security

- Secrets live only in your local `.env`, which `.gitignore` excludes — they
  never reach GitHub.
- The digital employee is **read-only** by default: it does not approve things,
  modify data, or take any action on your behalf.
- It reads only the material you explicitly approve; it does not go browsing
  your company's other documents.
- The engine skips `.env` and files named like `secret` / `token` / `password`,
  so credentials do not get indexed as knowledge by accident.
- The generated config contains **no secrets** — only the names of environment
  variables, which are resolved at runtime.

For the full boundary description, see the engine's
[SECURITY.md](https://github.com/fullstack-ai-infra/digital-employee/blob/main/SECURITY.md).

## Contributing

Issues and pull requests are welcome — especially English translations of the
`docs/` guides, and fixes for DingTalk or CLI behavior that has changed since
this was written.

## License

This scaffold is licensed under Apache-2.0. The engine,
[Digital Employee](https://github.com/fullstack-ai-infra/digital-employee), is
also Apache-2.0 and remains the copyright of its authors. See
[NOTICE](NOTICE) for attribution details.
