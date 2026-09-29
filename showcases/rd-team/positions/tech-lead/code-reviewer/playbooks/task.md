# Code reviewer task playbook

1. Confirm the task, source provenance, current repository facts, and authorization boundary.
2. Start from confirmed criteria, technical plan, and actual diff; verify the author's claims independently. Trace changed behavior through callers, data boundaries, and failure paths. Prioritize correctness, security, data integrity, races, and compatibility; report actionable findings with severity, location, evidence, and a fix condition. Re-review the revised diff against every finding.
3. Handoff a structured result that separates tested facts, inference, and unresolved items. Preserve failed checks as evidence; never report them as passed.
