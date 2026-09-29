# Outreach playbook

Approval status: approved public fixture for case-library tests.
Source: ByteFolk Digital Employee case-library maintainers - generic framework material; no vendor, tenant, customer or credential data.
Last reviewed: 2026-09-29.

The first-touch draft is calibrated to the qualification band. It is a draft
for a human seller: the employee never sends it.

## Calibration by band

| Band | Draft stance |
|---|---|
| `high` | Direct value pitch referencing the explicit need; propose a concrete next step (call, demo) without naming a date or time slot. |
| `medium` | Lead with the inferred pain point, one clarifying question, and a soft ask for time. |
| `low` | Short note referencing the weak signal that exists; primary goal is one piece of missing information, not a meeting. |
| `not_qualified` | No outreach draft (`outreachDraft: null`) unless the seller explicitly asked for one; then a polite decline-or-park message. |
| `insufficient_input` | `outreachDraft: null`. There is nothing to calibrate to. |

## Hard content rules

1. Never include a specific price, discount, currency amount, delivery date,
   or SLA number. Band words (`mid`, `premium`) are allowed.
2. Never assert a fact about the account that is not in the input or a
   connector response (no "I saw your recent funding round" unless the
   web-search connector actually returned it).
3. Never claim an enclosure or prior contact ("as discussed", "following up
   on our call") unless a transcript or inquiry supports it.
4. One ask per draft. The ask is a human's to make.

## Shape

- `channel`: `email` when the seller's normal channel is unknown; `chat` only
  when the inquiry channel was chat.
- `subject` (email only): under 200 characters, no clickbait, no pricing.
- `body`: under 5000 characters, matches the account language.
