# Digital Employee Quickstart

[简体中文](README.zh-CN.md)

Official case library for [Digital Employee](https://github.com/fullstack-ai-infra/digital-employee).
Each case is a portable `employee-package.v1alpha1` example with knowledge,
Schemas, and offline acceptance fixtures.

## Public release boundary

This quickstart is pinned to the public package
`@fullstack-ai-infra/digital-employee@0.3.0`.

| Path | Status | What it means here |
|------|--------|--------------------|
| `init`, `validate`, `eval` | Verified public path | Credential-free package creation and offline contract checks |
| `run` | Environment-qualified | Optional one-shot execution with an already configured supported Agent Host |
| `legacy ...` | Historical demo/compatibility | `standalone-v1` compatibility, not this quickstart's primary experience |
| v0.4 adoption candidate | Candidate, not released | Development and acceptance work must not be presented as public capability |
| `deploy` | Planned | Not present in public `0.3.0`; no channel wizard, IM provisioning, or long-running channel service |

The planned deployment path is tracked in
[digital-employee#91](https://github.com/fullstack-ai-infra/digital-employee/issues/91)
and [digital-employee-quickstart#2][run-report].

## Try a case safely

The following path is credential-free and was verified against the exact public
release:

```bash
git clone https://github.com/fullstack-ai-infra/digital-employee-quickstart.git
cd digital-employee-quickstart/cases/team-qa

npx --yes --package @fullstack-ai-infra/digital-employee@0.3.0 -- \
  digital-employee validate . --json
npx --yes --package @fullstack-ai-infra/digital-employee@0.3.0 -- \
  digital-employee eval . --json
```

Expected results for `team-qa` are `status: "valid"` and then
`status: "passed"` with `3` of `3` fixtures passing.

`validate` checks the package structure. `eval` only checks the contract of the
repository's offline fixtures. It does not invoke a model, Agent Host, MCP
server, or online service, and it does **not** prove that a digital employee
answered these questions correctly.

## Report this run

After a success or failure, use the single public feedback entry:
[comment on digital-employee-quickstart#2][run-report]. Paste this small,
redacted Run Report:

```text
CLI: @fullstack-ai-infra/digital-employee@0.3.0
Case: team-qa
Node / OS:
validate: valid | failed
eval: passed (3/3) | failed
Failure code/output (if any, redacted):
```

Do not include credentials, account identifiers, private repository names, or
local absolute paths.

## Cases

| Case | Scenario | Description |
|------|----------|-------------|
| [`team-qa`](cases/team-qa/) | IT team Q&A | Answers from team handbook, on-call rules, permission docs |
| [`hr-onboarding`](cases/hr-onboarding/) | HR onboarding | Guides new hires through processes, benefits, office logistics |
| [`ops-approval`](cases/ops-approval/) | Ops approval proposals | Turns requests into structured proposals — never executes |
| [`product-faq`](cases/product-faq/) | Product FAQ | Customer-facing product questions from public docs |

Run the same credential-free checks against any case:

```bash
npx --yes --package @fullstack-ai-infra/digital-employee@0.3.0 -- \
  digital-employee validate cases/hr-onboarding --json
npx --yes --package @fullstack-ai-infra/digital-employee@0.3.0 -- \
  digital-employee eval cases/hr-onboarding --json
```

## Case structure

Every case follows the employee package spec:

```text
<case>/
├── employee.json              # package manifest
├── SKILL.md                   # behavior instructions for the AI engine
├── knowledge/                 # knowledge base (Markdown)
├── schemas/
│   ├── input.schema.json      # input contract
│   └── output.schema.json     # output contract
└── evals/
    └── cases.json             # offline acceptance fixtures
```

## Creating your own cases

Third-party case repositories are welcome. Initialize a package, then validate
and evaluate it before attempting a one-shot run with a supported Agent Host:

```bash
npx --yes --package @fullstack-ai-infra/digital-employee@0.3.0 -- \
  digital-employee init my-case --recipe minimal-answer.v1
npx --yes --package @fullstack-ai-infra/digital-employee@0.3.0 -- \
  digital-employee validate my-case --json
npx --yes --package @fullstack-ai-infra/digital-employee@0.3.0 -- \
  digital-employee eval my-case --json
```

One-shot execution requires a supported, configured Agent Host. See the
[v0.3.0 framework documentation](https://github.com/fullstack-ai-infra/digital-employee/blob/v0.3.0/README.md#runner-on-a-publisher-owned-machine)
for the current engine matrix and `run` syntax.

## Requirements

- Node.js 20 or newer for validation and offline evaluation.
- A supported Agent Host only when performing a one-shot `run`.

## Reference

- [Framework CLI documentation](https://github.com/fullstack-ai-infra/digital-employee)
- [Employee package specification](https://github.com/fullstack-ai-infra/digital-employee/blob/v0.3.0/docs/employee-package.md)
- [`docs/`](docs/) contains historical deployment drafts. They are not an
  executable guide for CLI `0.3.0`.

## License

Apache-2.0. See [NOTICE](NOTICE) for attribution.

[run-report]: https://github.com/fullstack-ai-infra/digital-employee-quickstart/issues/2
