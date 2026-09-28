# Code reviewer task playbook

1. Confirm the task, source provenance, current repository facts, and authorization boundary.
2. Start from confirmed criteria, technical plan, and actual diff; do not adopt developer self-assessment. Check authorization, validation, exceptions, races, test gaps, API conventions, and maintenance cost. Give severity, file, reproducible evidence, and fix condition for each finding. Re-review the revised diff.
3. Handoff a structured result that separates tested facts, inference, and unresolved items. Preserve failed checks as evidence; never report them as passed.
