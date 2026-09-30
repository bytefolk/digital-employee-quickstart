# R&D team case library (public showcase)

This directory implements the first offline slice of the R&D digital employee proposal: seven distinct employee packages, structured handoff contracts, data admission rules, synthetic teaching cases, and deterministic case retrieval. The first sample task concerns member-list filtering, pagination, and loading/empty/error states. **All catalog cases are synthetic teaching material**, not historical PRs, independent reviews, or proof of end-to-end software delivery.

## Capability boundary

- Public compatibility baseline: `@fullstack-ai-infra/digital-employee@0.6.0`. `validate` checks package structure; `eval` checks public fixture contracts. Neither calls a model.
- All seven positions request workspace-wide read/write scope, host-policy network access, and approval before actions. The organization allowlist includes read, write, shell, and common browser/search tool names. These are permission requests: effective tools and network access still depend on the configured Agent Host, and the published v0.6 adapters do not provide the isolated code-writing, test execution, and post-approval patch application needed for an R&D delivery loop.
- The organization file describes reporting lines. `workflow.json` describes a proposed sequence and human gates; the current CLI does not execute it.
- `cases/` contains only public synthetic teaching material. Real cases require authorization, anonymization, a pinned baseline, and human review. Held-out tasks and hidden tests belong in a separate evaluation environment.
- Runtime output, credentials, Agent Host bindings, and repository copies are not part of this template.

## Credential-free verification

From `digital-employee-quickstart` with Node.js 20 or newer:

```bash
node showcases/rd-team/tools/check.mjs
node showcases/rd-team/tools/search.mjs --role frontend-engineer --task-type frontend-feature --stack react --query 'member list pagination' --repository example/member-console --commit demo-baseline-v1

npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
  digital-employee org tree showcases/rd-team --json

for manifest in showcases/rd-team/positions/tech-lead/employee.json showcases/rd-team/positions/tech-lead/*/employee.json; do
  package_dir="$(dirname "$manifest")"
  npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- digital-employee validate "$package_dir" --json
  npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- digital-employee eval "$package_dir" --json
done
```

Require `validate.status=valid`, `eval.status=passed`, and `summary.failed=0`. `org apply` writes workspace state and refreshes digests; copy this directory elsewhere before running it.

## Inputs required for a real pilot

1. A project owner confirms the real requirement, authorized repositories, and pinned commits; replace the unknowns in `context/project.md`.
2. Admit at least three real demonstration cases and keep at least three held-out tasks outside this directory, following `cases/README.md`.
3. Specify actual build, test, visual, and business acceptance commands in an isolated execution environment.
4. Manually execute and sign the gates in `workflow.json` until cross-role orchestration, controlled writes, and approval execution pass end-to-end acceptance. Do not treat declared permission requests as proof that the selected host exposes or enforces those tools.

The search tool filters only approved public entries in `cases/catalog.json`, reports selection reasons and baseline conflicts, and returns no-hit results explicitly. It is neither a model runner nor a private repository reader.

[简体中文](README.zh-CN.md)
