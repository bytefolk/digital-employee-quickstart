# Wiring connectors into `support-employee`

This guide is the **extension point** for the
[`cases/support-employee`](../../cases/support-employee/) employee package. It
explains what the adopting company must supply so the employee can answer at
all, and what happens when it supplies nothing. It is written against the
framework contracts in
[`docs/employee-package.md`](https://github.com/bytefolk/digital-employee/blob/main/docs/employee-package.md),
[`docs/connectors/README.md`](https://github.com/bytefolk/digital-employee/blob/main/docs/connectors/README.md),
[`docs/knowledge/knowledge-source-quality-bar.md`](https://github.com/bytefolk/digital-employee/blob/main/docs/knowledge/knowledge-source-quality-bar.md)
and the `employee-mcp.v1alpha1` declaration
([`configs/employee-mcp.schema.json`](https://github.com/bytefolk/digital-employee/blob/main/configs/employee-mcp.schema.json)).

The defining capability of this employee is **knowing when to stop**, so the
boundary below is the product, not an implementation detail.

## The boundary (read this first)

The package declares:

```json
"policy": {
  "mode": "approval_required",
  "network": "host_policy",
  "filesystem": { "read": ["./knowledge/**"], "write": [] },
  "mcpTools": [
    { "name": "kb.entry.search", "requestedMode": "read" },
    { "name": "ticket.handoff.create", "requestedMode": "write" }
  ]
}
```

and an `entrypoints.mcp` manifest (`employee-mcp.v1alpha1`) naming the two
servers behind those tools. The package therefore:

- has **no knowledge content of its own** — `knowledge/` holds the intent
  taxonomy and the confidence/escalation policy, not product answers, so the
  package can never become a substitute for a real knowledge base;
- never carries credentials (the manifest lists environment variable names
  only: `KB_CONNECTOR_ENDPOINT`, `KB_CONNECTOR_TOKEN`,
  `TICKETING_CONNECTOR_ENDPOINT`, `TICKETING_CONNECTOR_TOKEN`);
- requests `write` for exactly one tool (`ticket.handoff.create`). A
  `requestedMode` is a request, never a self-granted safety label: preflight
  must compare it against trusted operator/registry metadata before the tool is
  exposed, and the operator decides whether to grant it. `policy.mode:
  "approval_required"` records the boundary; nothing in this package files a
  ticket by itself.

> **Current-host note.** Today's built-in runnable Adapters reject employee MCP
> bindings and approval callbacks outright, so no shipped built-in path spawns
> these servers. This package is a declaration for a Host that does provide
> them — the same posture as the framework's own
> [`recipes/synthetic-mcp-context`](https://github.com/bytefolk/digital-employee/tree/main/recipes/synthetic-mcp-context).
> `policy.network: "host_policy"` is likewise a requested boundary that a Host
> has to prove it can enforce.

## Declared connectors

| Server | Tools requested | Mode | Required? | Behaviour when absent |
|---|---|---|---|---|
| `knowledge-base` | `kb.entry.search` | read | optional | **Every** request escalates with `reason: "no_kb"`. No answer is drafted, and model priors are never used. |
| `ticketing` | `ticket.handoff.create` | write | optional | The escalation is recorded locally with `handoff.ticket.filed: false`, `ticketRef: null`; nothing is filed. |

The manifest names host-supplied stdio entrypoints
(`digital-employee-connector-knowledge-base`,
`digital-employee-connector-ticketing`). The host provides those servers; this
repository does not ship them, and the package makes no claim about which
knowledge base or ticket system is behind them.

## What each server must expose

| Server | Tool | Contract |
|---|---|---|
| `knowledge-base` | `kb.entry.search` | A search/read call returning entries with a stable `entry` identifier, text, and a relevance `score`. `answer.citations[].entry` may only be an identifier the connector returned. An empty result set is a valid answer — it means "escalate". |
| `ticketing` | `ticket.handoff.create` | A create call returning the ticket identifier. That identifier is the only legal value for `handoff.ticket.ticketRef`. A failed filing must surface as an error, not as `filed: true`. |

## Provider permissions

Each server is the operator's integration, granted outside this package:

- `knowledge-base` needs **read-only** access to approved knowledge entries.
  The declared scope is read-only and maximal, never a floor: a run may narrow
  it (operator grant, deployment policy) but never widen it.
- `ticketing` needs create-only access on the hand-off queue. It needs no read,
  update or close permission — this employee never resolves, edits or closes a
  ticket.
- A grant is operator-owned and lives outside the package. A package that
  grants to itself is rejected — the same `mcp_self_grant_rejected` posture the
  framework records for its MCP recipes.

## Data sent across the boundary

| Direction | Payload | Notes |
|---|---|---|
| package → `knowledge-base` | retrieval queries derived from the customer message | The whole transcript is not shipped as a query; queries are bounded and listed in `escalation.retrievalAttempt.queries` when the run escalates. |
| `knowledge-base` → package | candidate entries (`entry`, `text`, `updatedAt`, `score`) | An entry may only be cited if it came back from this call or from `kbSnapshot`. |
| package → `ticketing` | the hand-off note, urgency, and the retrieval attempt | Contains the customer message and the attempted retrieval — it is a hand-off, not a resolution. |
| `ticketing` → package | the ticket identifier | The only value accepted for `handoff.ticket.ticketRef`. |

No credentials, tenant identifiers or raw internal URLs travel in either
direction: the package carries environment-variable **names** only.

## Retention

Per the framework's retention boundary (`docs/knowledge/knowledge-source-quality-bar.md`
§ alignment with the retention RFC), **this package declares no retention
behavior** and implies none. Retention and deletion of knowledge entries, and
of anything written to the ticket system, are set by the operator or platform
that hosts that data — not by the employee package. Declaring a connector is
not a claim of retention, export or deletion rights over it.

## Time and size limits

| Limit | Value | Enforced by |
|---|---|---|
| `customerMessage.text` | 20 000 chars | input Schema |
| `conversationHistory` | 50 entries, 20 000 chars each | input Schema |
| `productContext` | 200 chars | input Schema |
| `kbSnapshot` | 100 entries, 5 000 chars each | input Schema |
| `answer.text` | 10 000 chars | output Schema |
| `answer.citations` | 1–10 entries | output Schema |
| `escalation.retrievalAttempt.queries` | 20 entries, 300 chars each | output Schema |
| `escalation.retrievalAttempt.entriesConsidered` | 50 entries | output Schema |
| `handoff.note` | 2 000 chars | output Schema |
| per-task budget | 20 000 tokens / 8 iterations | deployment budget (see `teams/` precedent) |
| connector calls | one `kb.entry.search`, at most one `ticket.handoff.create` per run | Skill contract |

There is no wall-clock timer inside the package; a Host that carries a run
deadline reports it as its own failure, which the package surfaces as an
escalation with `reason: "other"` rather than as an answer.

## Rejected input tests

The following inputs must fail closed, each with a stable reason rather than a
plausible-looking answer:

| Input | Expected outcome |
|---|---|
| no `knowledge-base` server bound, and no `kbSnapshot` | `decision: "escalate"`, `reason: "no_kb"`, `handoff.ticket.filed: false`, `ticketRef: null` — **no** answer at all |
| `kb.entry.search` returns nothing relevant | `decision: "escalate"`, `reason: "low_confidence"` with the retrieval attempt attached |
| question is out of scope (legal advice, competitor claims) even with an entry available | `decision: "escalate"`, `reason: "out_of_scope"` — an available entry does not license an answer |
| a cited `entry` was never returned by the connector or `kbSnapshot` | output Schema rejection / fail closed — a citation can never be invented |
| `decision: "answer"` submitted with an empty `citations` array | output Schema rejection (`minItems: 1`) — an uncited answer is not a valid answer |
| `ticket.handoff.create` fails or is unapproved | `handoff.ticket.filed: false` with `ticketRef: null`; a failure is never reported as `filed: true` |

`requiresApproval` is a `const: true` in the output Schema: every run is a
proposal a human still has to act on, and no output shape can claim that a
hand-off was completed on its own.

## Caller-supplied `kbSnapshot`

`kbSnapshot` exists so a caller that already fetched entries (or a CI job
capturing a run for review) can hand them in instead of letting the employee
retrieve. Entries are the same shape the connector returns. It is **not** a way
to make the employee answer without a knowledge base: an empty or absent
`kbSnapshot` plus an absent connector still produces `reason: "no_kb"`.

## Credentials

Never put secrets in the package or in `mcp.json`. The manifest references
environment variable names; the host injects their values.

## Offline path (what `eval` proves)

| Fixture | Proves |
|---|---|
| `answered-with-citations` | A grounded answer is only emitted together with its citations. |
| `low-confidence-escalate-partial-coverage` | Partial coverage escalates with `low_confidence` and a usable retrieval record instead of a filled-in guess. |
| `no-kb-escalates-everything` | With no knowledge base, a routine question still escalates — the model-prior shortcut is closed. |
| `out-of-scope-escalates-despite-kb` | `out_of_scope` wins over an available entry (legal advice / competitor claims). |
