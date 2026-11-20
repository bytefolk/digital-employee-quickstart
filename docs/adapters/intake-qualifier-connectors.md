# Wiring connectors into `intake-qualifier`

This guide is the **extension point** for the
[`cases/intake-qualifier`](../../cases/intake-qualifier/) employee package. It
is written against the framework contracts in
[`docs/employee-package.md`](https://github.com/bytefolk/digital-employee/blob/main/docs/employee-package.md),
[`docs/connectors/README.md`](https://github.com/bytefolk/digital-employee/blob/main/docs/connectors/README.md)
and the `employee-mcp.v1alpha1` declaration
([`configs/employee-mcp.schema.json`](https://github.com/bytefolk/digital-employee/blob/main/configs/employee-mcp.schema.json)).

The package specializes the connector posture of
[`sales-employee`](sales-employee-connectors.md) to **service intake** for a
small delivery team: assess an inbound request, draft a scope-only acceptance
proposal, extract communication notes, and write an *internal proposal* back
through a declared connector. The defining capability is **knowing what it may
not decide**: pricing, dispatch, client confirmation and payment are human
decisions. The boundary below is the product, not an implementation detail.

## The boundary (read this first)

The package declares:

```json
"policy": {
  "mode": "approval_required",
  "network": "host_policy",
  "filesystem": { "read": ["./knowledge/**"], "write": [] },
  "mcpTools": [
    { "name": "intake.request.read", "requestedMode": "read" },
    { "name": "intake.proposal.create", "requestedMode": "write" },
    { "name": "web.search", "requestedMode": "read" }
  ]
}
```

and an `entrypoints.mcp` manifest (`employee-mcp.v1alpha1`) naming the two
servers behind those tools. Following the framework rule that an MCP
declaration is **a request, never a grant**, the package therefore:

- may only reach the declared tool surface — there is no hard-coded intake
  client and no direct HTTP integration in the package;
- never carries credentials: the manifest lists **environment variable names**
  only (`INTAKE_CONNECTOR_ENDPOINT`, `INTAKE_CONNECTOR_TOKEN`,
  `WEB_SEARCH_CONNECTOR_ENDPOINT`, `WEB_SEARCH_CONNECTOR_TOKEN`);
- requests `write` for exactly one tool (`intake.proposal.create`), and that
  tool creates an **internal proposal for human review**, never an accepted
  order. A `requestedMode` is a request, never a self-granted safety label:
  preflight must compare it against trusted operator/registry metadata before
  the tool is exposed, and the operator decides whether to grant it.
  `policy.mode: "approval_required"` records the boundary; nothing in this
  package accepts, dispatches, confirms or pays by itself;
- has **no price surface at all**. `proposalDraft` in the output schema has
  `additionalProperties: false` and only `scope`, `deliverables`, `criteria`,
  `clarifyingQuestions` — there is no amount, currency, discount or
  delivery-date field to fill. A price cannot be carried even by accident.

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
| `intake` | `intake.request.read`, `intake.proposal.create` | read + write | optional | `proposalSync.status: "degraded"`, `reason: "intake_connector_absent"`, `recordRef: null`; `degraded[]` carries `proposal_write`. Write-back is skipped, never simulated. |
| `web-search` | `web.search` | read | optional | No enrichment; assessment runs on supplied text only; `degraded[]` carries `enrichment`. |
| none | — | — | — | Assessment still runs on supplied text only. |

The manifest names host-supplied stdio entrypoints
(`digital-employee-connector-intake`,
`digital-employee-connector-web-search`). The host provides those servers; this
repository does not ship them, and the package makes no claim about which
intake system is behind `intake`. For an adopting team, `intake` is the team's
own request/proposal store (for example a controlled RPC over its delivery
workbench), and the write creates an internal proposal a human admin still has
to price, confirm and dispatch.

## What each server must expose

| Server | Tool | Contract |
|---|---|---|
| `intake` | `intake.request.read` | Read a request by `externalId`. Returns the request or a not-found error. |
| `intake` | `intake.proposal.create` | Create an `intake_proposal` / `activity` **proposal** and return its identifier. The returned identifier is the **only** legal value for `proposalSync.recordRef`. A rejection must surface as an error, not as a successful sync. The tool must not accept an order, set a price, dispatch work, or mark payment. |
| `web-search` | `web.search` | A search/read call returning public text about the requester. Enrichment is cited as `evidence[].source: "connector"`; it is never merged into `intakeAssessment.reasoning` as if it were supplied context, and it never fabricates a signal. |

## Provider permissions

Each server is the operator's integration, granted outside this package:

- `intake` needs read on the request record type **and**, for
  `intake.proposal.create`, create-only on the proposal record type. It needs
  no update/close/pay permission — this employee never accepts, dispatches,
  confirms or pays. The operator grants those scopes in the intake system;
  this package cannot widen them, and `policy.filesystem.write` is empty.
- `web-search` needs only a public-search scope. No authenticated tenant data
  is read through it.
- A grant is operator-owned and lives outside the package. A package that
  grants to itself is rejected — the same `mcp_self_grant_rejected` posture the
  framework records for its MCP recipes.

## Data sent across the boundary

| Direction | Payload | Notes |
|---|---|---|
| package → `intake` | the identifiers in `proposalTarget` (`recordType`, `operation`, `externalId`) and the scope-only proposal fields to create | Only what the run produced. `proposalTarget` carries *which* record, never record content, and never stands in for a connector response. No price or delivery-date field exists to send. |
| `intake` → package | the request read, or the identifier of the created proposal | The identifier is the only value accepted for `proposalSync.recordRef`. |
| package → `web-search` | the requester organization name under assessment | Nothing about the requirement, transcript or proposal is sent for enrichment. |
| `web-search` → package | public text about the requester | Cited as `evidence[].source: "connector"`; never merged into reasoning as if supplied context. |

No credentials, tenant identifiers or raw internal URLs travel in either
direction: the package carries environment-variable **names** only.

## Retention

Per the framework's retention boundary (`docs/knowledge/knowledge-source-quality-bar.md`
§ alignment with the retention RFC), **this package declares no retention
behavior** and implies none. Retention and deletion of anything written to the
intake system, or read from the search provider, are set by the operator or
platform that hosts that data — not by the employee package. Declaring a
connector is not a claim of retention, export or deletion rights over it.

## Time and size limits

| Limit | Value | Enforced by |
|---|---|---|
| `requester.organization` | 200 chars | input Schema |
| `requester.suppliedContext` | 20 000 chars | input Schema |
| `requirement.description` | 20 000 chars | input Schema |
| `requirement.expectedResult` | 5 000 chars | input Schema |
| `requirement.budgetHint` | 500 chars | input Schema |
| `transcript.text` | 50 000 chars | input Schema |
| `proposalDraft.scope` / `deliverables` / `criteria` | 5 000 chars each | output Schema |
| `proposalDraft.clarifyingQuestions` | 20 items, 500 chars each | output Schema |
| `proposalSync.recordRef` | 128 chars | output Schema |
| extracted items | 20 per category | output Schema |
| `evidence[]` | 20 entries | output Schema |
| per-task budget | 20 000 tokens / 8 iterations | deployment budget (see `teams/` precedent) |
| connector calls | one `intake.request.read`, at most one `intake.proposal.create`, at most one `web.search` per run | Skill contract |

There is no wall-clock timer inside the package; a Host that carries a run
deadline reports it as its own failure, which the package surfaces as an error
rather than a degraded sync.

## Rejected input tests

The following inputs must fail closed, each with a stable reason rather than a
plausible-looking record:

| Input | Expected outcome |
|---|---|
| `proposalTarget` present but the `intake` server is not bound | `proposalSync.status: "degraded"`, `reason: "intake_connector_absent"`, `recordRef: null` — **no** invented record id |
| `intake.proposal.create` returns an error or rejection | `proposalSync.status: "degraded"`, `reason: "intake_write_rejected"`; the write is not retried silently and no id is fabricated |
| `intake.proposal.create` is requested while the host has not approved the write | `proposalSync.status: "degraded"`, `reason: "intake_write_pending_approval"`; the run stops at the proposal |
| no `requirement` and no `suppliedContext`, nothing reachable | `intakeAssessment.band: "insufficient_input"`, `proposalDraft: null` — nothing is invented |
| requester's budget hint far below a plausible scope | `band: "decline"` citing the mismatch; `proposalDraft: null`; no price is computed |
| competitor fishing / internal-disclosure request | `band: "out_of_scope"`; routed to a human; `proposalDraft: null` |
| transcript contains no literal commitment/objection/next action | the corresponding array is empty; text is never paraphrased into an item |
| any `enum` field outside its declared set, or any price/date field added to `proposalDraft` | input or output Schema rejection (fail closed), never coercion |

`requiresApproval` is a `const: true` in the output Schema: every run is a
proposal for a human, and no output shape can claim that an acceptance, a
dispatch, a confirmation or a payment completed on its own.

## Credentials

Never put secrets in the package or in `mcp.json`. The manifest references
environment variable names; the host injects their values. A package that
demands a literal token violates the framework rule that MCP declarations carry
no credentials.

## Offline path (what `eval` proves)

The offline contract run has no connectors, so its fixtures exercise exactly
the degradation table:

| Fixture | Proves |
|---|---|
| `clear-request-accept` | A clear request yields `band=accept` and a scope-only proposal; the intake write-back reports `intake_connector_absent` with `recordRef=null`. |
| `needs-info-clarify` | An unclear scope yields `band=clarify` and leads with clarifying questions, not a fabricated full scope. |
| `budget-mismatch-decline` | A budget mismatch yields `band=decline` citing the requester's own hint; no price is invented. |
| `out-of-scope-escalate` | Competitor fishing yields `band=out_of_scope` and routes to a human. |
| `insufficient-input-no-invention` | Nothing supplied and nothing reachable → `insufficient_input`, `proposalDraft=null`. |
| `full-cycle-with-transcript` | Assessment + scope proposal + communication extraction all run; "by Friday" keeps `dueBy` omitted; the write-back degrades explicitly. |

`proposalTarget` in the input says *which* record the run concerns. It never
carries record content, and it never stands in for a connector response.
