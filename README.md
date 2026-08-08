# Digital Employee Quickstart

[简体中文](README.zh-CN.md)

Official case library for [Digital Employee](https://github.com/fullstack-ai-infra/digital-employee).
Each case is a **complete, runnable employee package** — `cd` into it and deploy.

---

## Quick start

```bash
git clone https://github.com/fullstack-ai-infra/digital-employee-quickstart.git
cd digital-employee-quickstart/cases/team-qa
npx @fullstack-ai-infra/digital-employee deploy
```

That's it. The deploy command is fully interactive — handles language, channel,
auth, engine detection, and deployment for you.

## Cases

| Case | Scenario | Description |
|------|----------|-------------|
| [`team-qa`](cases/team-qa/) | IT team Q&A | Answers from team handbook, on-call rules, permission docs |
| [`hr-onboarding`](cases/hr-onboarding/) | HR onboarding | Guides new hires through processes, benefits, office logistics |
| [`ops-approval`](cases/ops-approval/) | Ops approval proposals | Turns requests into structured proposals — never executes |
| [`product-faq`](cases/product-faq/) | Product FAQ | Customer-facing product questions from public docs |

Each case is a complete `employee-package.v1alpha1` directory. You can:

```bash
npx @fullstack-ai-infra/digital-employee validate cases/team-qa   # static check
npx @fullstack-ai-infra/digital-employee eval cases/team-qa       # offline eval
npx @fullstack-ai-infra/digital-employee deploy                    # full deploy
```

## Case structure

Every case follows the employee package spec:

```
<case>/
├── employee.json              # package manifest
├── SKILL.md                   # behavior instructions for the AI engine
├── knowledge/                 # knowledge base (markdown)
├── schemas/
│   ├── input.schema.json      # input contract
│   └── output.schema.json     # output contract
└── evals/
    └── cases.json             # offline acceptance tests
```

## Creating your own cases

Third-party case repositories are welcome. As long as the directory contains a
valid `employee.json` conforming to `employee-package.v1alpha1`, the framework
CLI will recognize and run it:

```bash
# Initialize a new case from a recipe
npx @fullstack-ai-infra/digital-employee init my-case --recipe minimal-answer.v1

# Validate and test
npx @fullstack-ai-infr/digital-employee validate my-case
npx @fullstack-ai-infra/digital-employee eval my-case

# Deploy to a channel
cd my-case && npx @fullstack-ai-infra/digital-employee deploy
```

## Requirements

- Node.js 20+
- An AI engine: Qoder CLI / Claude Code / Qwen Code / CodeBuddy — or an OpenAI-compatible key

## Reference

- [Framework CLI docs](https://github.com/fullstack-ai-infra/digital-employee)
- [Employee package spec](https://github.com/fullstack-ai-infra/digital-employee/blob/main/docs/employee-package.md)
- [Manual setup guides](docs/) (Chinese)

## License

Apache-2.0. See [NOTICE](NOTICE) for attribution.
