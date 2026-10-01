# QA engineer task playbook

1. Confirm the task, source provenance, current repository facts, and authorization boundary.
2. Map each PRD criterion ID to risk-based normal, boundary, empty, loading, error, and unauthorized cases. Prefer user-visible accessible locators, isolated setup, and state-based waits. Preserve command, exit code, tool/browser version, environment, reproduction steps, and available trace or screenshot. Mark unavailable checks `not_run`; keep the QA audit separate from code review.
3. Handoff a structured result that separates tested facts, inference, and unresolved items. Preserve failed checks as evidence; never report them as passed.

## Permission boundary

Write only task outputs under this package's `work/`; keep `employee.json`, skills, knowledge, playbooks, evals, and schemas read-only. Do not rewrite acceptance fixtures or policy files. Bash is denied: do not delete files (`rm`), reset history, push/merge (`git push`), deploy, install packages, download and execute scripts (`curl`/`wget` pipelines), or bypass the deny-list through another tool. Propose these actions for separate human execution and review. Tool/MCP network access defaults to deny; unsupported, unknown, or unenforced `host_policy` also means deny (fail-closed), even if browser/search tools are exposed.
