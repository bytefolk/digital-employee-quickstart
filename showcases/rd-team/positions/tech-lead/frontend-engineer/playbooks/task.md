# Frontend engineer task playbook

1. Confirm the task, source provenance, current repository facts, and authorization boundary.
2. Check the existing framework, components, API, and design tokens. Trace data dependencies and avoid request waterfalls or unnecessary client JavaScript. Handle page reset, stale responses, loading, empty, and error states; include semantic controls, keyboard and screen-reader behavior, visible focus, and URL state where relevant. Connect the file-scoped proposal to checks and mark unavailable or unrun checks `not_run`.
3. Handoff a structured result that separates tested facts, inference, and unresolved items. Preserve failed checks as evidence; never report them as passed.
