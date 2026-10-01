# R&D team case library (public showcase)

This directory implements the first offline slice of the R&D digital employee proposal: seven distinct employee packages, structured handoff contracts, data admission rules, synthetic teaching cases, and deterministic case retrieval. The first sample task concerns member-list filtering, pagination, and loading/empty/error states. **All catalog cases are synthetic teaching material**, not historical PRs, independent reviews, or proof of end-to-end software delivery.

## Capability boundary

- Public compatibility baseline: `@fullstack-ai-infra/digital-employee@0.6.0`. `validate` checks package structure; `eval` checks public fixture contracts. Neither calls a model.
- All seven positions request package reads and writes only to their own `./work/**`, with approval before actions. Employee manifests, skills, schemas, eval fixtures, knowledge, and playbooks remain read-only. The organization allowlist includes read, write, and common browser/search tool names; `Bash` is explicitly denied. These are permission requests: effective tools and network access still depend on the configured Agent Host, and the published v0.6 adapters do not provide the isolated code-writing, test execution, and post-approval patch application needed for an R&D delivery loop.
- The organization file describes reporting lines. `workflow.json` describes a proposed sequence and human gates; the current CLI does not execute it.
- `cases/` contains only public synthetic teaching material. Real cases require authorization, anonymization, a pinned baseline, and human review. Held-out tasks and hidden tests belong in a separate evaluation environment.
- Runtime output, credentials, Agent Host bindings, and repository copies are not part of this template.

## Permission enforcement and independent review

Tool/MCP data-plane network access defaults to `deny`. The fallback for any future `host_policy` request is **fail-closed**: unsupported, unknown, or unenforced host policy means deny. Enabling it requires a separate reviewed change with evidence that the selected host enforces network boundaries and explicit task authorization. Exposing browser/search tools is not a network grant; host authentication/model control-plane traffic is outside this policy.

Tool-name organization rules cannot constrain Bash subcommands, so the shell stays denied until a separately reviewed scoped execution path exists. Every role's SKILL and playbook prohibit deleting files (`rm`), resetting history, pushing or merging (`git push`), deploying, installing packages, downloading/executing scripts (`curl`/`wget` pipelines), bypassing denied tools, and changing its own acceptance baseline or policy. Propose those actions for separate human execution and review. A host must enforce filesystem scope, tool grants, network restrictions, and approval; otherwise do not run these packages. Text instructions and offline checks alone are not a sandbox.

`.github/CODEOWNERS` assigns the R&D showcase, its CI workflow, and CODEOWNERS itself to the independent reviewer `@PeterGuy326`. Repository administrators must enable required code-owner reviews on `main`; this file alone does not enforce a gate. Permission changes (including check-script changes) need an approving non-author reviewer to verify the policy diff, the package digests, and host enforcement evidence. Digests refreshed by the change author remain integrity checks, not independent approval.

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
