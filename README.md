# Digital Employee Quickstart

[简体中文](README.zh-CN.md)

Put a question-answering digital employee into your company's DingTalk —
without writing any code, without editing any config file.

Once it is running, colleagues ask the bot a question in DingTalk and it answers
**only from material you have approved**, with the source attached. When the
answer is not in your material, it says so and hands off to a human instead of
making something up.

---

## What you need

| Requirement | Notes |
| --- | --- |
| A computer or server | macOS / Windows / Linux all work |
| Node.js 20+ | Not installed? The agent will walk you through it |
| An AI coding agent (optional) | [Claude Code](https://claude.com/claude-code), Codex, Cursor, … |

That's it. Credentials, DingTalk setup, and engine configuration are handled
interactively by the deploy command.

## Usage

### Option A: Hand it to an AI coding agent (recommended)

```bash
git clone https://github.com/fullstack-ai-infra/digital-employee-quickstart.git
cd digital-employee-quickstart
claude   # or your preferred AI coding agent
```

Then say:

```
帮我搭建数字员工，按 AGENTS.md 来
```

### Option B: Run the deploy command yourself

```bash
npx @fullstack-ai-infra/digital-employee deploy
```

The command is fully interactive — it walks you through:

1. **Language** — English or Simplified Chinese (auto-detected from system locale)
2. **Channel** — DingTalk / Console / HTTP API
3. **Authorization** — DingTalk device-flow QR code in terminal (if DingTalk)
4. **Bot name** — what to call your digital employee
5. **AI engine** — auto-detects installed Agent Hosts; falls back to OpenAI key
6. **Deployment** — creates app, configures bot, starts service
7. **Done** — tells you what to do next

### After deployment

Feed the digital employee your company's knowledge:

```
knowledge/            ← company policies, handbooks, FAQs (markdown)
```

Every time you update `knowledge/`, restart the service for changes to take effect.

## Other scenarios

| Case | Scenario | Needs a model key? |
| --- | --- | --- |
| [01 DingTalk Q&A](cases/01-dingtalk-qa/) | A live bot colleagues chat with | Yes |
| [02 HTTP API](cases/02-http-api/) | Wire it into your own system | Yes |
| [03 Minimal answer package](cases/03-minimal-answer/) | A portable, shippable employee package | **No** |
| [04 Structured action](cases/04-structured-action/) | Proposals for approval, never executed | **No** |
| [05 Multi-host](cases/05-multi-host/) | One package across different Agent Hosts | Yes |

See [cases/README.md](cases/README.md) for details on each scenario.

## Manual step-by-step guides

If you prefer doing everything manually, the `docs/` directory has step-by-step
guides (currently in Simplified Chinese):

1. [01 — Prerequisites](docs/01-准备工作.md)
2. [02 — Create the DingTalk bot](docs/02-创建钉钉机器人.md)
3. [03 — Start the digital employee](docs/03-启动数字员工.md)
4. [04 — Build up the knowledge base](docs/04-沉淀知识库.md)
5. [05 — Troubleshooting](docs/05-常见问题.md)

## Layout

```
.
├── README.md              ← this file
├── README.zh-CN.md        ← Simplified Chinese
├── AGENTS.md              ← the runbook your AI coding agent follows
├── CLAUDE.md              ← points at AGENTS.md
├── cases/                 ← scenario library
├── docs/                  ← manual step-by-step guides (Chinese)
└── knowledge/             ← your knowledge base (the bot's textbook)
```

## Security

- The deploy command stores configuration in `~/.digital-employee/config.json`.
  Secrets (like OpenAI keys) are stored locally and never transmitted to GitHub.
- The digital employee is **read-only** by default: it does not approve things,
  modify data, or take any action on your behalf.
- It reads only the material you explicitly approve.

For the full boundary description, see the engine's
[SECURITY.md](https://github.com/fullstack-ai-infra/digital-employee/blob/main/SECURITY.md).

## License

This scaffold is licensed under Apache-2.0. The engine,
[Digital Employee](https://github.com/fullstack-ai-infra/digital-employee), is
also Apache-2.0 and remains the copyright of its authors. See
[NOTICE](NOTICE) for attribution details.
