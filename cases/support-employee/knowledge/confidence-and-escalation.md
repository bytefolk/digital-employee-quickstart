# Confidence gate and escalation policy

Approval status: approved public fixture for case-library tests.
Source: ByteFolk Digital Employee case-library maintainers - generic framework material; no vendor, tenant, customer or credential data.
Last reviewed: 2026-09-29.

The escalation path is a first-class deliverable. The gate below is the only
thing that decides whether a reply may be emitted at all.

## Declared threshold

| Condition | Decision | Confidence |
|---|---|---|
| A retrieved entry directly and fully answers the question | `answer` | `high` |
| A retrieved entry answers the question but requires a small, stated generalisation (e.g. applying a documented rule to the customer's plan) | `answer` | `medium` |
| Retrieval returns nothing that addresses the question | `escalate` (`low_confidence`) | `low` |
| Retrieval returns only partial coverage, or conflicting entries | `escalate` (`low_confidence`) | `low` |
| Retrieval returns nothing at all because there is no knowledge base | `escalate` (`no_kb`) | `low` |
| The intent is `out_of_scope` | `escalate` (`out_of_scope`) | `low` |

Rule of thumb: **retrieval coverage is the only licence to answer.** Retrieval
score thresholds are advisory; the deciding question is always "does an entry I
can cite actually answer this?".

## Escalation record

An escalation must be usable by the human who picks it up:

- `reason` — `no_kb`, `low_confidence`, `out_of_scope`, or `other`.
- `retrievalAttempt.queries` — the queries issued.
- `retrievalAttempt.entriesConsidered` — entry names retrieved and evaluated,
  so the human does not repeat the same search.
- `handoff.note` — what the customer asked, what retrieval produced, why a
  human is needed.
- `handoff.urgency` — `high` for outage, data-loss, or security claims;
  `medium` for blocked work; `low` otherwise.
- `handoff.ticket` — `filed: true` with a connector-returned `ticketRef` when
  the ticketing connector is present; otherwise `filed: false`,
  `ticketRef: null` and the escalation lives only in this record.

## No-knowledge-base rule

With no knowledge base available, **every** request escalates with
`reason: "no_kb"`. Answering from model priors is never permitted, however
routine the question looks. A confident-sounding reply with no citable entry
is treated as a policy violation, not a helpfulness win.
