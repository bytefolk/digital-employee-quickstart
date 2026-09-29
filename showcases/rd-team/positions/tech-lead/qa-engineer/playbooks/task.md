# QA engineer task playbook

1. Confirm the task, source provenance, current repository facts, and authorization boundary.
2. Map each PRD criterion ID to risk-based normal, boundary, empty, loading, error, and unauthorized cases. Prefer user-visible accessible locators, isolated setup, and state-based waits. Preserve command, exit code, tool/browser version, environment, reproduction steps, and available trace or screenshot. Mark unavailable checks `not_run`; keep the QA audit separate from code review.
3. Handoff a structured result that separates tested facts, inference, and unresolved items. Preserve failed checks as evidence; never report them as passed.
