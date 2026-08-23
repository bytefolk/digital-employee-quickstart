# Business overview

This is the business context for the open-source maintenance showcase. All facts are
fictional and scoped to this showcase directory.

## Mission

Keep **acme-toolkit** healthy and trusted: ship predictable, well-documented
releases; keep the issue tracker triaged; treat community feedback as a first-class
roadmap input; stay honest (no fabricated facts, no publishing to external channels).

## Organization tree

```text
repo-owner  (root owner, may delegate to direct reports)
├── issue-researcher      (issue/PR research, read-only)
├── release-engineer      (release plans and checklists, read-only)
└── community-operator    (community content drafts, read-only)
```

## Who handles what

- issue-researcher — issue clustering, duplicate and unassigned detection, user
  feedback research.
- release-engineer — release plans, checklists, breaking-change and migration notes.
- community-operator — FAQ drafts, announcement drafts, community feedback summaries.
- repo-owner — global decisions; delegates to the three specialists; synthesizes the
  final answer.
