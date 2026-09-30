# Qualification scoring framework

Approval status: approved public fixture for case-library tests.
Source: ByteFolk Digital Employee case-library maintainers - generic framework material; no vendor, tenant, customer or credential data.
Last reviewed: 2026-09-29.

Score every account on four signals. Record each signal **only** as its schema
enum; never as free text or a number.

## Signals

| Signal | Question | Enums |
|---|---|---|
| Budget | Is there money allocated or a budget owner? | `known` / `unknown` / `insufficient` / `not_applicable` |
| Authority | Is the speaker able to decide or influence? | `confirmed` / `likely` / `unknown` / `none` |
| Need | Is the pain explicit, implicit, unclear, or absent? | `explicit` / `implicit` / `unclear` / `none` |
| Timeline | When do they intend to act? | `immediate` / `quarter` / `half_year` / `unknown` / `none` |

## Sources of signal

1. `account.suppliedContext` and `inquiry.rawMessage` — always available.
2. `transcript.text` — only when a transcript was provided.
3. The `web-search` connector — only when it is actually present. Its absence
   is never treated as negative signal, only as missing enrichment (band
   ceiling `medium`).

Anything not in those sources does not exist. Do not infer company size, tier,
or budget from the company name.

## Band mapping

| Condition | Band |
|---|---|
| Need `explicit` **and** authority `confirmed`/`likely` **and** (budget `known` or timeline `immediate`/`quarter`) | `high` |
| Need `explicit`/`implicit` **and** at most one of the other signals `unknown` | `medium` |
| Need `unclear`, or two or more signals `unknown` | `low` |
| Need `none`, or the account is out of scope (competitor fishing, resale-only, banned industry per seller policy) | `not_qualified` |
| No basis at all: no supplied context, no inquiry, no transcript, no enrichment | `insufficient_input` |

With the `web-search` connector absent, the ceiling is `medium` — `high` may
only be assigned on the strength of supplied text alone, which by definition
cannot clear that bar unless the text itself carries all four signals.

## Reasoning lines

One `reasoning` line per signal, each traceable to an `evidence` entry. A
signal that is `unknown` must say what would be needed to resolve it.
