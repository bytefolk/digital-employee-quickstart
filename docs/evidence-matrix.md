# Evidence Matrix

This document records the offline evidence for each case package. Evidence is captured from the deterministic eval suite (`evals/cases.json`) pinned to CLI `0.6.0`; no live model invocation, no live connector call, and no CRM write is performed or proved.

Run the evals locally:

```bash
cd cases/<case-name>
npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
  digital-employee eval . --json
```

## sales-employee

| Evidence | Eval case | Key observation |
|---|---|---|
| Full qualification → outreach → follow-up cycle | `full-cycle-crm-absent` | Qualification produces `band=medium`, `score=68`, with cited reasoning across budget/authority/need/timeline. Outreach draft references the transcript commitments (depot count breakdown by Friday, two-week pilot outline). Meeting extraction captures 2 commitments, 1 price objection, 2 next actions. |
| Connector-degraded run (CRM absent) | `full-cycle-crm-absent` | `crmSync.status=degraded`, `reason=crm_connector_absent`, `recordRef=null`. No CRM record or record id is fabricated. |
| Web-search absent degradation | `full-cycle-crm-absent`, `qualification-only-no-enrichment` | `degraded[]` entries with `capability=enrichment`, `reason=web_search_connector_absent`. Qualification band stays at medium ceiling. |
| Insufficient input, no invention | `insufficient-input-no-invention` | `band=insufficient_input`, all signals `unknown`/`unclear`. No outreach draft, no meeting extraction, no CRM sync requested. |
| CLI version pin | — | `@fullstack-ai-infra/digital-employee@0.6.0` |
| What it does not prove | — | No live CRM writes in the recorded run. No live web-search enrichment. No model invocation. The eval proves the **contract shape** and the **degradation contract**, not that a live run would produce the same scores or copy. |

## support-employee

| Evidence | Eval case | Key observation |
|---|---|---|
| Answered case with citations | `answered-with-citations` | `intent=how_to`, `decision=answer`, `confidence=high`. Answer text cites two knowledge-base entries (`kb/export-data`, `kb/scheduled-exports`) with excerpts. |
| Low-confidence escalation (partial KB coverage) | `low-confidence-escalate-partial-coverage` | `intent=billing`, `decision=escalate`, `confidence=low`. Retrieval considered `kb/billing-cycle` but it covers standard plans only; no entry supports computing a refund amount on a custom annual contract. Escalation reason: `low_confidence`. |
| No-KB run: 100% escalation | `no-kb-escalates-everything` | `intent=how_to`, `decision=escalate`, `confidence=low`. No knowledge-base connector and no supplied entries. Escalation reason: `no_kb`. No answer is produced from model priors. |
| Out-of-scope escalation despite KB | `out-of-scope-escalates-despite-kb` | `intent=out_of_scope`, `decision=escalate`, `confidence=low`. Legal advice request; `kb/data-residency` is relevant background but must not be used to respond to a third-party claim. Escalation reason: `out_of_scope`. |
| CLI version pin | — | `@fullstack-ai-infra/digital-employee@0.6.0` |
| What it does not prove | — | No live knowledge-base connector call. No live ticketing system call. No model invocation. The eval proves the **intent classification contract**, the **citation contract**, and the **escalation contract** (including the no-KB path), not that a live run would retrieve the same entries or produce the same copy. |

## sales-qualifier

| Evidence | Eval case | Key observation |
|---|---|---|
| Full-context qualification | `qualified-full-context` | Qualification produces a structured proposal with cited reasoning and a next best action. Enterprise context is consumed via the caller-supplied `enterpriseContext` field, not via a connector. |
| CLI version pin | — | `@fullstack-ai-infra/digital-employee@0.6.0` |
| What it does not prove | — | No live enterprise-data connector call. No model invocation. The eval proves the **contract shape** and the **degradation contract** when enterprise data is missing or stale. |
