# Wiring connectors into `sales-employee`

This guide is the **extension point** for the
[`cases/sales-employee`](../../cases/sales-employee/) employee package. It is
written against the framework contracts in
[`docs/employee-package.md`](https://github.com/bytefolk/digital-employee/blob/main/docs/employee-package.md),
[`docs/connectors/README.md`](https://github.com/bytefolk/digital-employee/blob/main/docs/connectors/README.md)
and the `employee-mcp.v1alpha1` declaration
([`configs/employee-mcp.schema.json`](https://github.com/bytefolk/digital-employee/blob/main/configs/employee-mcp.schema.json)).

Unlike `sales-qualifier` (which receives caller-populated data and never
declares a connector), this package declares MCP tool requests and is the first
case in this repo that requests a write.

## The boundary (read this first)

The package declares:

```json
"policy": {
  "mode": "approval_required",
  "network": "host_policy",
  "filesystem": { "read": ["./knowledge/**"], "write": [] },
  "mcpTools": [
    { "name": "crm.account.read", "requestedMode": "read" },
    { "name": "crm.account.upsert", "requestedMode": "write" },
    { "name": "web.search", "requestedMode": "read" }
  ]
}
```

and an `entrypoints.mcp` manifest (`employee-mcp.v1alpha1`) naming the two
servers behind those tools. Following the framework rule that an MCP
declaration is **a request, never a grant**, the package therefore:

- may only reach the declared tool surface — there is no hard-coded CRM client
  and no direct HTTP integration in the package;
- never carries credentials: the manifest lists **environment variable names**
  only (`CRM_CONNECTOR_ENDPOINT`, `CRM_CONNECTOR_TOKEN`,
  `WEB_SEARCH_CONNECTOR_ENDPOINT`, `WEB_SEARCH_CONNECTOR_TOKEN`);
- requests `write` for exactly one tool (`crm.account.upsert`). A
  `requestedMode` is a request, never a self-granted safety label: preflight
  must compare it against trusted operator/registry metadata before the tool is
  exposed, and the operator decides whether to grant it. `policy.mode:
  "approval_required"` records the boundary; nothing in this package executes
  the write by itself.

> **Current-host note.** Today's built-in runnable Adapters reject employee MCP
> bindings and approval callbacks outright, so no shipped built-in path spawns
> these servers. This package is a declaration for a Host that does provide
> them — the same posture as the framework's own
> [`recipes/real-local-context`](https://github.com/bytefolk/digital-employee/tree/main/recipes/real-local-context)
> and
> [`recipes/synthetic-mcp-context`](https://github.com/bytefolk/digital-employee/tree/main/recipes/synthetic-mcp-context).
> `policy.network: "host_policy"` is likewise a requested boundary that a Host
> has to prove it can enforce.

## Declared connectors

| Server | Tools requested | Mode | Required? | Behaviour when absent |
|---|---|---|---|---|
| `crm` | `crm.account.read`, `crm.account.upsert` | read + write | optional | `crmSync.status: "degraded"`, `reason: "crm_connector_absent"`, `recordRef: null`; `degraded[]` carries `crm_write`. Write-back is skipped, never simulated. |
| `web-search` | `web.search` | read | optional | No enrichment; qualification runs on supplied text only; `degraded[]` carries `enrichment`; band ceiling stays `medium`. |
| none | — | — | — | Qualification still runs on supplied text only. |

The manifest names host-supplied stdio entrypoints
(`digital-employee-connector-crm`, `digital-employee-connector-web-search`).
The host provides those servers; this repository does not ship them, and the
package makes no claim about which CRM vendor is behind `crm`.

## What each server must expose

| Server | Tool | Contract |
|---|---|---|
| `crm` | `crm.account.read` | Read a record by `externalId`. Returns the record or a not-found error. |
| `crm` | `crm.account.upsert` | Create/update a `lead` / `contact` / `opportunity` / `activity` and return its identifier. The returned identifier is the **only** legal value for `crmSync.recordRef`. A rejection must surface as an error, not as a successful sync. |
| `web-search` | `web.search` | A search/read call returning public text about a company. Enrichment only lifts the band ceiling above `medium` when the connector actually answered; it is never cited as if it were supplied context. |

## Provider permissions

Each server is the operator's integration, granted outside this package:

- `crm` needs read on the target record type **and**, for `crm.account.upsert`,
  create/update on that record type. The operator grants those scopes in the
  CRM; this package cannot widen them and the declared scope is read-only by
  default (`policy.filesystem.write` is empty).
- `web-search` needs only a public-search scope. No authenticated tenant data
  is read through it.
- A grant is operator-owned and lives outside the package. A package that
  grants to itself is rejected — the same `mcp_self_grant_rejected` posture the
  framework records for its MCP recipes.

## Data sent across the boundary

| Direction | Payload | Notes |
|---|---|---|
| package → `crm` | the identifiers in `crmTarget` (`recordType`, `operation`, `externalId`) and the extracted fields to upsert | Only what the run produced. `crmTarget` carries *which* record, never record content, and never stands in for a connector response. |
| `crm` → package | the record read, or the identifier of the written record | The identifier is the only value accepted for `crmSync.recordRef`. |
| package → `web-search` | the company name and domain under qualification | Nothing about the inquiry, transcript or CRM record is sent for enrichment. |
| `web-search` → package | public text about the company | Cited as `evidence[].source: "connector"`; never merged into `qualification.reasoning` as if it were supplied context. |

No credentials, tenant identifiers or raw internal URLs travel in either
direction: the package carries environment-variable **names** only.

## Retention

Per the framework's retention boundary (`docs/knowledge/knowledge-source-quality-bar.md`
§ alignment with the retention RFC), **this package declares no retention
behavior** and implies none. Retention and deletion of anything written to the
CRM, or read from the search provider, are set by the operator or platform that
hosts that data — not by the employee package. Declaring a connector is not a
claim of retention, export or deletion rights over it.

## Time and size limits

| Limit | Value | Enforced by |
|---|---|---|
| `account.company` | 200 chars | input Schema |
| `account.domain` | 253 chars | input Schema |
| `account.suppliedContext` | 20 000 chars | input Schema |
| `inquiry.rawMessage` | 20 000 chars | input Schema |
| `transcript.text` | 50 000 chars | input Schema |
| `outreachDraft.body` | 5 000 chars | output Schema |
| `crmSync.recordRef` | 128 chars | output Schema |
| extracted items | 20 per category | output Schema |
| `evidence[]` | 20 entries | output Schema |
| per-task budget | 20 000 tokens / 8 iterations | deployment budget (see `teams/` precedent) |
| connector calls | one `crm.account.read`, at most one `crm.account.upsert`, at most one `web.search` per run | Skill contract |

There is no wall-clock timer inside the package; a Host that carries a run
deadline reports it as its own failure, which the package surfaces as an error
rather than a degraded sync.

## Rejected input tests

The following inputs must fail closed, each with a stable reason rather than a
plausible-looking record:

| Input | Expected outcome |
|---|---|
| `crmTarget` present but the `crm` server is not bound | `crmSync.status: "degraded"`, `reason: "crm_connector_absent"`, `recordRef: null` — **no** invented record id |
| `crm.account.upsert` returns an error or rejection | `crmSync.status: "degraded"`, `reason: "crm_write_rejected"`; the write is not retried silently and no id is fabricated |
| `crm.account.upsert` is requested while the host has not approved the write | `crmSync.status: "degraded"`, `reason: "crm_write_pending_approval"`; the run stops at the proposal |
| no `account` and no `inquiry` supplied, nothing reachable | `qualification.band: "insufficient_input"`, `outreachDraft: null` — nothing is invented |
| transcript contains no literal commitment/objection/next action | the corresponding array is empty; text is never paraphrased into an item |
| any `enum` field outside its declared set | input or output Schema rejection (fail closed), never coercion |

`requiresApproval` is a `const: true` in the output Schema: every run is a
proposal for a human, and no output shape can claim that a write completed on
its own.

## Credentials

Never put secrets in the package or in `mcp.json`. The manifest references
environment variable names; the host injects their values. A package that
demands a literal token violates the framework rule that MCP declarations carry
no credentials.

## Offline path (what `eval` proves)

The offline contract run has no connectors, so its fixtures exercise exactly
the degradation table:

- `full-cycle-crm-absent` — qualification + outreach + meeting extraction all
  run, and the CRM write-back reports `crm_connector_absent` with
  `recordRef: null`.
- `qualification-only-no-enrichment` — supplied context is enough to qualify;
  enrichment is declared degraded.
- `insufficient-input-no-invention` — nothing supplied and nothing reachable
  → `insufficient_input`, `outreachDraft: null`.

`crmTarget` in the input says *which* record the run concerns. It never carries
record content, and it never stands in for a connector response.
