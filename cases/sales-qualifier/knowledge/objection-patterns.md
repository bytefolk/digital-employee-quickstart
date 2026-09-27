# Objection patterns (drafting aid only)

This file helps a human rep draft `draftTalkingPoints`. It is **never** an
auto-reply. Nothing here authorizes this employee to send a message, quote a
price, or commit a date. Talking points are proposals for a human to edit and
send.

## Pattern catalog

| Pattern | Signal in the inquiry | Suggested talking-point shape (draft, human-owned) |
|---|---|---|
| `price_first` | "How much?", "Send me pricing" | **Do not draft talking points.** Per the degradation table, a pricing demand forces `status: escalate` with `proposal: null`; route to a human instead. |
| `just_researching` | "Gathering options", "No timeline yet" | Thank them, offer a concise capability overview, propose a low-pressure follow-up window. |
| `competitor_compare` | "How are you better than X?" | Avoid naming or disparaging competitors; map the expressed need to a capability; propose a technical deep-dive. |
| `need_clarification` | Vague or one-line request | Ask at most three targeted discovery questions drawn from `missingFields`. |
| `urgency` | "ASAP", "Live blocker", a hard deadline this cycle | Acknowledge urgency, propose the fastest human-owned path (call), flag `timeline: immediate`. **Do not promise a delivery date.** |
| `authority_gap` | Sender cannot decide | Offer material the sender can forward; propose involving the decision maker. |
| `complaint` | Frustration, a service failure, profanity | Do not argue. Set `status: escalate` with `proposal: null`; put the compliance concern in `reason`, not in `risks`. A human owns the response. |
| `out_of_scope` | Request unrelated to the catalog | Set `status: disqualified` with a clear `reason`; do not stretch the catalog. |

## Drafting rules

1. A talking point is one sentence of plain language, at most 500 characters.
2. Never embed a price, discount, percentage, currency symbol, or delivery
   date in a talking point.
3. Never claim the company has already done something ("we have scheduled",
   "we have sent"). Use proposal phrasing ("propose to", "suggest", "next step
   would be").
4. At most eight talking points per proposal; prefer three.
5. If the objection is `complaint` or `out_of_scope`, do not draft talking
   points at all — escalate or disqualify instead.
