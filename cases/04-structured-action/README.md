# 案例 04：结构化动作提案

> **路径**：Agent-native · **产出**：只提案不执行的员工包 · **需要模型 key**：否

用官方 recipe `structured-action.v1` 做一个**把请求转成可审批提案**的员工包。

适用场景：运维重启、权限授予、发布上线——这类"需要人点头才能做"的事。员工负责把
模糊的口头请求整理成结构化、可审批的提案，**但绝不自己执行**。

和案例 03 一样**完全离线**，不需要任何密钥。

## 和案例 03 的核心差异

案例 03 的 `minimal-answer` 产出的是**答案文本**；这个案例产出的是**结构化提案对象**。

差异体现在 `schemas/output.schema.json` 里，最关键的是这一行：

```json
"requiresApproval": { "const": true }
```

`const: true` 意味着**这个字段只能是 `true`，schema 层面就不允许出现 `false`**。
员工没有任何办法产出一个"不需要审批"的提案——这是写死在契约里的，不是靠提示词自觉。

schema 还用 `if/then` 强制了状态自洽：

| `status` | 约束 |
| --- | --- |
| `proposed` | `proposal` 必须是对象（含 `intent` / `target` / `rationale`） |
| `rejected` | `proposal` 必须是 `null`，且必须给出 `reason` |

`intent` 是枚举，只能取 `restart` / `review` / `notify`——员工不能凭空发明动作类型。

## 怎么做

```bash
bash scripts/employee-new.sh ops-approval structured-action.v1
```

```bash
bash scripts/employee-check.sh ops-approval
```

## 验收用例长什么样

`evals/cases.json` 里自带一条，很能说明这个 recipe 的意图：

```json
{
  "id": "restart-proposal-only",
  "input": {
    "request": "Prepare a restart proposal for review.",
    "target": "staging-service"
  },
  "expectedOutput": {
    "status": "proposed",
    "proposal": {
      "intent": "restart",
      "target": "staging-service",
      "rationale": "The requester asked for a restart proposal for human review."
    },
    "requiresApproval": true
  }
}
```

输入是"准备一个重启提案"，输出是一个**待审批的提案对象**，而不是"已重启"。

## 边界说明（重要）

`SKILL.md` 里明确写着：

> This recipe demonstrates structured proposal/intent output only.
> It has no action executor, write capability, MCP tool, or approval callback.

也就是说这个 recipe **只产出提案，不含执行器**。要真正落地一个审批闭环，你还需要自己接：

1. 把提案送去审批的通道（钉钉审批、OA、飞书审批……）
2. 审批通过后真正执行动作的系统
3. 执行结果的回写

引擎刻意不提供 2 和 3——**执行权限不在员工手里**，这是安全设计而非功能缺失。

## 怎么改成你自己的场景

1. 改 `schemas/output.schema.json` 里 `intent` 的枚举值，换成你的动作词表
   （比如 `grant-access` / `rollback` / `scale-up`）
2. 在 `knowledge/` 里写清楚每个动作的适用条件和禁止条件
3. 改 `SKILL.md` 说明判断规则
4. 在 `evals/cases.json` 里补用例，**尤其要补 `rejected` 的用例**——
   验证员工在不该提案时会拒绝

改完跑：

```bash
bash scripts/employee-check.sh ops-approval
```

`requiresApproval: const true` 这条建议**不要动**。它是这个 recipe 的安全底线。
