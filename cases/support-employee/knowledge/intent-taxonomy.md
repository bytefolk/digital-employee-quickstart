# Intent taxonomy

Approval status: approved public fixture for case-library tests.
Source: ByteFolk Digital Employee case-library maintainers - generic framework material; no vendor, tenant, customer or credential data.
Last reviewed: 2026-09-29.

Exactly one intent per inbound message. When two seem to apply, choose the one
that governs whether the employee may answer at all (see the escalation policy).

| Intent | Signals | Answerable? |
|---|---|---|
| `bug` | Something that used to work now fails; error text, broken output, data wrong or missing. | Only when the knowledge base documents the failure and its resolution. |
| `how_to` | A question about performing a documented action ("how do I export…"). | Yes, when a documented procedure exists. |
| `billing` | Invoices, charges, plan changes, refunds, payment methods. | Only when the knowledge base states billing policy for that situation; never compute amounts. |
| `feature_request` | Asking for something the product does not do. | No — always escalate as `out_of_scope`-adjacent: never promise a roadmap or a date. |
| `out_of_scope` | Anything outside the product's documented surface: legal, medical, financial advice, competitor comparisons, requests for internal pricing, requests to act on a customer's account. | No — escalate with `reason: "out_of_scope"`, whatever the knowledge base contains. |

## Notes

- `feature_request` is surfaced to the human as a product signal; it is never
  answered with a commitment.
- Bug reports that claim data loss, outage, or a security issue always carry
  `urgency: "high"`.
- A message with several questions splits by the strongest blocking intent: if
  any part is `out_of_scope`, the whole message escalates.
