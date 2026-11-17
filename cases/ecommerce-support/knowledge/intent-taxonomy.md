# Intent taxonomy (e-commerce after-sales)

Approval status: approved public fixture for case-library tests.
Source: ByteFolk Digital Employee case-library maintainers - generic framework material; no vendor, shop, order, customer or credential data.
Last reviewed: 2026-11-18.

Exactly one intent per inbound shopper message. When two seem to apply, choose
the one that governs whether the employee may answer at all (see the escalation
policy).

| Intent | Signals | Answerable? |
|---|---|---|
| `order_status` | "我的订单发了吗 / 什么时候发货 / 能不能改地址改规格". | Only when the shop's policy documents the operation and its cut-off. Never promise a date the policy does not guarantee. |
| `logistics` | Tracking stalled, "显示签收但我没收到", 快递丢件/破损, delivery time. | Only when the knowledge base documents the scenario and its resolution. Loss / non-delivery claims carry `urgency: "high"`. |
| `return_refund` | 7 天无理由、退换货、仅退款、退款到账时间、运费险、价保。 | Only when the knowledge base states the policy for that situation; **never compute or commit a refund amount**. |
| `product_qa` | 尺码/材质/规格/保修/是否正品参数等售前咨询。 | Yes, when a documented, citable answer exists; never invent specs or extrapolate a guarantee. |
| `out_of_scope` | Anything outside the shop's documented surface: 鉴定真伪并索赔（假一赔三）、人身伤害/食品安全、法律或工商投诉、要求代为操作订单/账户、伪造发票报销、竞品对比。 | No — escalate with `reason: "out_of_scope"`, whatever the knowledge base contains. |

## Notes

- A message mixing an answerable question with an `out_of_scope` request
  (e.g. "怎么退货 + 帮我直接退款") escalates as a whole under the strongest
  blocking intent; the answerable part goes to the human, not to the employee.
- Claims of lost-in-transit, non-delivery, counterfeit, injury, or a breached
  promised deadline always carry `urgency: "high"`.
- Refund/compensation amounts are adjudicated by a human with order and payment
  access; the employee may restate a documented policy but never compute a number.
