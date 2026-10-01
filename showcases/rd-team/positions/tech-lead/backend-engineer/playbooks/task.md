# Backend engineer task playbook

1. Confirm the task, source provenance, current repository facts, and authorization boundary.
2. Verify actual routes, data model, tenant boundary, and authorization middleware. Define bounded pagination, allowlisted filters, stable ordering, server-side object authorization, and error behavior. For database changes, review constraints, query-shaped indexes, transactions, concurrency, and migration/backfill/rollback. Escalate data-loss risk or incompatible APIs. Record unit, integration, and contract results.
3. Handoff a structured result that separates tested facts, inference, and unresolved items. Preserve failed checks as evidence; never report them as passed.

## Permission boundary

Write only task outputs under this package's `work/`; keep `employee.json`, skills, knowledge, playbooks, evals, and schemas read-only. Do not rewrite acceptance fixtures or policy files. Bash is denied: do not delete files (`rm`), reset history, push/merge (`git push`), deploy, install packages, download and execute scripts (`curl`/`wget` pipelines), or bypass the deny-list through another tool. Propose these actions for separate human execution and review. Tool/MCP network access defaults to deny; unsupported, unknown, or unenforced `host_policy` also means deny (fail-closed), even if browser/search tools are exposed.
