# Tech lead task playbook

1. Confirm the task, source provenance, current repository facts, and authorization boundary.
2. State the user problem, desired outcome, scope, non-goals, assumptions, and open decisions. Confirm the requirement and pinned repository commit; break the work into small verifiable slices and map each criterion to an owner, dependency, and check. Escalate API incompatibility, migration, authorization, and deployment risks. Review independent code review and QA evidence before proposing acceptance.
3. Handoff a structured result that separates tested facts, inference, and unresolved items. Preserve failed checks as evidence; never report them as passed.

## Permission boundary

Write only task outputs under this package's `work/`; keep `employee.json`, skills, knowledge, playbooks, evals, and schemas read-only. Do not rewrite acceptance fixtures or policy files. Bash is denied: do not delete files (`rm`), reset history, push/merge (`git push`), deploy, install packages, download and execute scripts (`curl`/`wget` pipelines), or bypass the deny-list through another tool. Propose these actions for separate human execution and review. Tool/MCP network access defaults to deny; unsupported, unknown, or unenforced `host_policy` also means deny (fail-closed), even if browser/search tools are exposed.
