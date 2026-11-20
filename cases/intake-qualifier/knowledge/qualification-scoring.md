# Intake qualification scoring framework

Approval status: approved public fixture for case-library tests.
Source: ByteFolk Digital Employee case-library maintainers - generic framework material; no vendor, tenant, customer or credential data.
Last reviewed: 2026-11-18.

Score every inbound request on four signals. Record each signal **only** as its
schema enum; never as free text or a number.

## Signals

| Signal | Question | Enums |
|---|---|---|
| Budget | Does the requester's own budget hint plausibly cover the scope? | `known` / `unknown` / `insufficient` / `not_applicable` |
| Authority | Is the requester able to confirm the engagement? | `confirmed` / `likely` / `unknown` / `none` |
| Need | Is the requirement scope clear? | `explicit` / `implicit` / `unclear` / `none` |
| Timeline | Is the expected delivery window stated and feasible? | `immediate` / `quarter` / `half_year` / `unknown` / `none` |

## Sources of signal

1. `requester.suppliedContext` and `requirement.*` — always available.
2. `transcript.text` — only when a transcript was provided.
3. The `web-search` connector — only when it is actually present. Its absence
   is never treated as negative signal, only as missing enrichment.

Anything not in those sources does not exist. Do not infer budget or company
size from the organization name. `budgetHint` is the requester's own words; it
is a signal only — never compute or output a price from it.

## Band mapping

| Condition | Band |
|---|---|
| Need `explicit` **and** authority `confirmed`/`likely` **and** budget `known` **and** timeline not `none` **and** in scope | `accept` |
| Need `unclear`, **or** exactly one signal `unknown` while need `explicit`/`implicit` **and** in scope | `clarify` |
| Need `explicit` **and** (budget `insufficient` **or** timeline infeasible) **and** in scope | `decline` |
| Out of team scope (competitor fishing, resale-only, banned industry per team policy, beyond capability) | `out_of_scope` |
| No requirement, no supplied context, no transcript, no enrichment | `insufficient_input` |

Enrichment never fabricates a signal. With the `web-search` connector absent,
assessment runs on supplied text only; an `accept` band requires all four
signals clearly present in the supplied text.

## Reasoning lines

One `reasoning` line per signal, each traceable to an `evidence` entry. A
signal that is `unknown` must say what would be needed to resolve it. A
`decline` must cite the budget/timeline mismatch; an `out_of_scope` must name
the scope rule and route to a human.
