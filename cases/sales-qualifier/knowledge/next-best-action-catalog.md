# Next-best-action catalog (closed enum)

`nextAction.intent` must be exactly one of the values below. This catalog is
closed: do not synthesize a new intent, and do not combine two.

| Intent | Meaning | Precondition |
|---|---|---|
| `send_discovery_questions` | Propose a short list of questions that close the gaps in `missingFields`. | Always allowed. Default when data is thin. |
| `schedule_call` | Propose a discovery or qualification call with a human rep. | Always allowed. |
| `send_product_info` | Propose sending public product material that matches an expressed need. | **Requires `productCatalog`** in `enterpriseContext`. Blocked by degradation when absent. |
| `prepare_quote_request` | Propose that a human prepare a formal quote (internal hand-off). **This never produces a price.** | **Requires `productCatalog`** and `qualification.need` ∈ {`explicit`, `implicit`}. |
| `escalate_to_human` | Propose that a named human own the next step, even though qualification itself can continue. | Use when the qualification is still expressible (`status` ∈ {`qualified`, `needs_info`}) but the next step needs a human owner — e.g. the request straddles a policy boundary without triggering a hard prohibition. |
| `nurture_sequence` | Propose adding the contact to a long-term follow-up cadence. | Use when `timeline` ∈ {`half_year`, `unknown`} but need is real. |
| `disqualify_with_reason` | Propose that a human confirm a soft disqualification. | Use when `status: needs_info` and the inquiry is drifting out of scope but the sender deserves a recorded reason rather than a silence. |

> **Why the last two rows are scoped this way.** `nextAction` lives inside
> `proposal`, and `output.schema.json` forces `proposal: null` whenever `status`
> is `escalate` or `disqualified`. So an intent cannot be "used with
> `status: escalate`" — there would be no `proposal` to carry it. Both intents
> exist for the *remaining* case: qualification is still expressible, but the
> correct next step is a human-owned acknowledgement rather than another
> automated touch.

## Rules

1. When `productCatalog` is absent, the only legal intents are
   `send_discovery_questions`, `schedule_call`, `nurture_sequence`, and
   `escalate_to_human`.
2. `prepare_quote_request` is a *hand-off proposal*, never a quote. The output
   must not contain a number, a currency symbol, or a date.
3. `rationale` must reference at least one `evidence[]` entry.
4. `draftTalkingPoints`, when present, are a draft for a human. They are never
   sent by this employee and must not contain prices, discounts, or delivery
   commitments.
