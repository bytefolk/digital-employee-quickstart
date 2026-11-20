# Scope-only proposal playbook

Approval status: approved public fixture for case-library tests.
Source: ByteFolk Digital Employee case-library maintainers - generic framework material; no vendor, tenant, customer or credential data.
Last reviewed: 2026-11-18.

The proposal draft is calibrated to the intake band. It is a draft for a human
admin: the employee never accepts, quotes, dispatches, confirms or pays.

## Calibration by band

| Band | Draft stance |
|---|---|
| `accept` | Draft `scope` / `deliverables` / `criteria` from the requirement; `clarifyingQuestions` empty or minimal. No price, no delivery-date commitment. |
| `clarify` | Lead with `clarifyingQuestions` (the missing information); `scope` tentative or omitted. Do not fabricate a full scope to look complete. |
| `decline` | `proposalDraft: null` by default; the decline reasoning lives in `intakeAssessment.reasoning`. |
| `out_of_scope` | `proposalDraft: null`; route to a human. |
| `insufficient_input` | `proposalDraft: null`. There is nothing to calibrate to. |

## Hard content rules

1. Never include a specific price, discount, currency amount, delivery date, or
   SLA number. The output schema has no such field (`proposalDraft`
   `additionalProperties: false`); band words are allowed.
2. Never assert a fact about the requester or requirement that is not in the
   input or a connector response.
3. Never claim acceptance, dispatch, confirmation, payment or prior contact
   ("as discussed", "following up") unless a transcript or requirement supports
   it.
4. Each clarifying question asks one piece of missing information. The ask is a
   human's to make.

## Shape

- `scope` / `deliverables` / `criteria`: plain text matching the requirement
  language, derived only from the requirement.
- `clarifyingQuestions`: an array of single questions; empty when nothing is
  missing.
