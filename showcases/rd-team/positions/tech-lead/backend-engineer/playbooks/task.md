# Backend engineer task playbook

1. Confirm the task, source provenance, current repository facts, and authorization boundary.
2. Verify actual routes, data model, tenant boundary, and authorization middleware. Define bounded pagination, allowlisted filters, stable ordering, server-side object authorization, and error behavior. For database changes, review constraints, query-shaped indexes, transactions, concurrency, and migration/backfill/rollback. Escalate data-loss risk or incompatible APIs. Record unit, integration, and contract results.
3. Handoff a structured result that separates tested facts, inference, and unresolved items. Preserve failed checks as evidence; never report them as passed.
