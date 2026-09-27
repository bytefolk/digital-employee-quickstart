# Qualification framework

This file defines how to score an inquiry. It is public-safe: no customer
names, no vendor field names, no pricing. The output of scoring is always the
schema enum, never a number and never free text.

## BANT scoring

Score each dimension from the inquiry text and, when present, from
`enterpriseContext`. Use the most conservative value the evidence supports.

### Budget

| Value | Use when |
|---|---|
| `known` | The inquiry or customer profile states a budget range or an approved spend. |
| `unknown` | No budget signal either way. |
| `insufficient` | A stated budget clearly cannot cover the expressed need. |
| `not_applicable` | The inquiry is not a purchase intent (support, partnership, media). |

Never convert a budget into a price quote. Budget is a qualification signal
only.

### Authority

| Value | Use when |
|---|---|
| `confirmed` | The sender self-identifies as a decision maker, or the customer profile marks them so. |
| `likely` | The sender's role implies influence but final authority is unverified. |
| `unknown` | No authority signal, **or** `customerProfile` is absent (degradation rule). |
| `none` | The sender explicitly states they cannot decide. |

### Need

| Value | Use when |
|---|---|
| `explicit` | The inquiry states a concrete problem or requirement. |
| `implicit` | A problem is implied but not stated; discovery questions are warranted. |
| `unclear` | The message is too vague to classify. |
| `none` | No need is expressed, or the request is out of scope. |

### Timeline

| Value | Use when |
|---|---|
| `immediate` | The inquiry signals urgency (a live blocker, a deadline this cycle). |
| `quarter` | Evaluation or purchase is expected within roughly one quarter. |
| `half_year` | Longer horizon, exploratory. |
| `unknown` | No timeline signal. |
| `none` | The inquiry explicitly has no purchase timeline. |

Never translate a timeline into a delivery-date commitment. Timeline describes
the *buyer's* horizon, not a promise from the seller.

## Status decision tree

```
Is a hard prohibition triggered (price / date / direct-send / compliance)?
├─ yes → escalate
└─ no
   └─ Is need == none, or the inquiry out of scope / competitor fishing?
      ├─ yes → disqualified (set reason)
      └─ no
         └─ Are B, A, and T all at least partially known AND need is explicit/implicit?
            ├─ yes → qualified
            └─ no  → needs_info (list the gaps in missingFields)
```

## Confidence

| Value | Use when |
|---|---|
| `high` | All four BANT dimensions have affirmative evidence and no degradation ceiling applies. |
| `medium` | At least one dimension is `unknown`/`unclear`, **or** a 30-day staleness ceiling applies, **or** `interactionHistory` is absent. |
| `low` | `enterpriseContext` is entirely absent, **or** a 180-day staleness rule applies, **or** `authority` is `none`, **or** the inquiry alone is thin. |

`authority: none` forces `low` on its own: a sender who has stated they cannot
decide leaves no owner for a follow-up, so even a well-specified need cannot be
carried forward on this inquiry alone.

Confidence is a ceiling-aware value: degradation rules can only lower it. Apply
every rule that matches and take the **lowest** result.

## Evidence discipline

Every claim in the proposal must map to an `evidence[]` entry whose `source`
is one of:

- `inquiry` — the raw message itself.
- `knowledge` — a rule from this framework or the action catalog.
- `enterpriseContext` — a caller-supplied block; the entry must carry that
  block's `asOf`.

If a claim has no source, drop the claim. Do not guess.
