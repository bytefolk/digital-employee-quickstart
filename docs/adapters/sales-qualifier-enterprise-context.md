# Wiring enterprise data into `sales-qualifier`

This guide is the **extension point** for the
[`cases/sales-qualifier`](../../cases/sales-qualifier/) employee package. It
explains how an adopting company feeds its own CRM/ERP data into the package
**without changing the package and without giving the package network access**.

## The boundary (read this first)

The `sales-qualifier` package declares:

```json
"policy": { "mode": "read_only", "network": "deny", "mcpTools": [] }
```

That means the package itself:

- cannot call your CRM,
- cannot read credentials,
- cannot send anything,
- runs fully offline and is verified by `digital-employee validate` / `eval`
  with no credential of any kind.

Enterprise data therefore enters through **one door only**: the optional
`enterpriseContext` field of the task input. Your integration code — running on
*your* side, in *your* environment — reads your CRM, maps it to
`enterpriseContext`, and passes it in. The package never reaches back out.

```
┌─────────────────────────┐      ┌──────────────────────────────┐
│  Your environment        │      │  sales-qualifier package      │
│                          │      │  (read_only, network: deny)   │
│  CRM / ERP / CSV         │      │                               │
│     │                    │      │                               │
│     ▼                    │      │                               │
│  adapter (your code) ────┼─────▶│  input.enterpriseContext      │
│  maps + stamps asOf      │ input│  SKILL.md degradation rules   │
│                          │      │     │                         │
│  credentials stay here   │      │     ▼                         │
│  (never in the package)  │      │  structured proposal ◀────────┼── output
└─────────────────────────┘      └──────────────────────────────┘
```

If you supply no `enterpriseContext` at all, the package still runs: it degrades
to `confidence: low` and flags `missing_data`. That is the zero-integration
path proven by the `needs-info-no-context` fixture.

## The contract you must fill

`enterpriseContext` is versioned by `schemaVersion: "sales-context.v1alpha1"`.
Every block carries its own `asOf` (an ISO-8601 timestamp). The package uses
`asOf` to apply staleness ceilings, so **always stamp the real snapshot time**,
not "now".

| Block | Required fields | Optional fields | Drives |
|---|---|---|---|
| `customerProfile` | `asOf` | `industry`, `companySize`, `region`, `tier`, `interactionCount` | `authority` default, tier assumptions |
| `productCatalog` | `asOf`, `items[]` (`sku`, `name`) | per item: `category`, `priceBand`, `inStock` | whether `send_product_info` / `prepare_quote_request` are legal |
| `interactionHistory` | `asOf`, `entries[]` (`at`, `kind`) | per entry: `summary` | confidence ceiling, "previous conversation" evidence |

`priceBand` is an enum (`low`/`mid`/`high`/`premium`/`unknown`) — **never a
number**. The package is forbidden from emitting a price, so do not try to
smuggle one in through a band.

## Mapping examples

### Salesforce → `enterpriseContext`

| Salesforce object/field | Target |
|---|---|
| `Account.Industry` | `customerProfile.industry` |
| `Account.NumberOfEmployees` → bucketed | `customerProfile.companySize` (`smb`/`mid`/`enterprise`) |
| `Account.BillingCountry` | `customerProfile.region` |
| `Account.Type` (`Prospect`/`Customer`) | `customerProfile.tier` |
| `Account.LastActivityDate` | `customerProfile.asOf` |
| Count of related `Activity` records | `customerProfile.interactionCount` |
| `Product2.ProductCode` | `productCatalog.items[].sku` |
| `Product2.Name` | `productCatalog.items[].name` |
| `Product2.Family` | `productCatalog.items[].category` |
| Custom price-tier picklist → band | `productCatalog.items[].priceBand` |
| `Task` / `Event` history | `interactionHistory.entries[]` |

Sketch (your side, pseudocode — runs where your credentials live):

```js
// runs in YOUR integration, not in the package
const enterpriseContext = {
  schemaVersion: "sales-context.v1alpha1",
  customerProfile: {
    asOf: account.LastActivityDate,
    industry: account.Industry,
    companySize: bucketSize(account.NumberOfEmployees),
    region: account.BillingCountry,
    tier: account.Type === "Customer" ? "existing" : "prospect",
    interactionCount: activities.length,
  },
  productCatalog: {
    asOf: catalogSyncedAt,
    items: products.map((p) => ({
      sku: p.ProductCode,
      name: p.Name,
      category: p.Family,
      priceBand: toBand(p.PriceTier__c), // low|mid|high|premium|unknown
      inStock: p.IsActive,
    })),
  },
  interactionHistory: {
    asOf: historySyncedAt,
    entries: activities.slice(0, 50).map((a) => ({
      at: a.ActivityDate,
      kind: mapKind(a.Type), // call|email|meeting|demo|quote_sent|objection|other
      summary: a.Subject?.slice(0, 500),
    })),
  },
};
```

### HubSpot → `enterpriseContext`

| HubSpot property | Target |
|---|---|
| `company.industry` | `customerProfile.industry` |
| `company.numberofemployees` → bucketed | `customerProfile.companySize` |
| `company.country` | `customerProfile.region` |
| `company.lifecyclestage` | `customerProfile.tier` |
| `company.lastmodifieddate` | `customerProfile.asOf` |
| `product.sku` / `product.name` | `productCatalog.items[]` |
| `engagement` calls/emails/notes | `interactionHistory.entries[]` |

### Generic CSV → `enterpriseContext`

For teams with no CRM, three CSVs are enough. Keep them in your environment;
do not commit them to this repository.

`customers.csv`

```csv
customer_id,industry,company_size,region,tier,last_activity,interaction_count
C-1001,logistics,mid,EU,prospect,2026-08-30T00:00:00Z,0
```

`products.csv`

```csv
sku,name,category,price_band,in_stock
AUTO-STD,Task Automation Standard,automation,mid,true
```

`interactions.csv`

```csv
customer_id,at,kind,summary
C-1001,2026-08-28T10:00:00Z,email,Inbound request for a walkthrough.
```

A small script reads the three CSVs, joins on `customer_id`, and emits the
`enterpriseContext` object. `asOf` comes from the `last_activity` /
`last_synced` column so staleness stays honest.

## Staleness rules you are opting into

The package applies these automatically (see `SKILL.md`):

- any block `asOf` more than **30 days** before `inquiry.receivedAt` →
  `confidence` ceiling `medium` + a `stale_data` risk;
- any block `asOf` more than **180 days** before → `confidence` forced `low`.

If your CRM sync is stale, the package gets *more* cautious, never more
confident. Stamp `asOf` truthfully; do not refresh it just to look current.

## Security rules

1. **No credentials in the package.** Tokens, API keys, and connection strings
   live in your adapter's environment, never in `cases/sales-qualifier/`.
2. **No tenant data in the package.** Customer names, record IDs, and internal
   URLs are not package content. Fixtures under `evals/` are synthetic.
3. **Read-only by construction.** The package has no write path; `write_back`
   to your CRM, if you want it, is your adapter's job after a human approves
   the proposal.
4. **Public-safe knowledge.** `knowledge/*.md` ships in the open repository and
   must stay vendor-neutral.

## Verifying your integration

You do not need a model or a credential to check the contract:

```bash
npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
  digital-employee validate cases/sales-qualifier --json
npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
  digital-employee eval cases/sales-qualifier --json
```

`validate` must report `status: "valid"`; `eval` must report `status:
"passed"` with `summary.failed: 0`. To test your own mapping, build a task
input with your `enterpriseContext` and check it against
`cases/sales-qualifier/schemas/input.schema.json` with any JSON Schema
validator before handing it to a configured Agent Host for a one-shot `run`.

> This guide does not cover `digital-employee deploy`. Per the repository
> release boundary, deployment guidance is intentionally withheld until
> clean-machine acceptance lands.
