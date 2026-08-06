# 案例 03：最小问答员工包

> **路径**：Agent-native · **产出**：可交付的标准员工包 · **需要模型 key**：否

用官方 recipe `minimal-answer.v1` 做一个符合 `employee-package.v1alpha1` 规范的员工包。

**整个案例完全离线**——不调模型、不连 Agent Host、不访问网络，所以没有任何密钥也能跑完。

## 这和案例 01 有什么不同

案例 01 产出的是"跑在你机器上的钉钉机器人"，配置绑在你的 `configs/local.json` 里。

这个案例产出的是**一个可以打包交付给别人的目录**：里面自带身份、行为说明书、
输入输出格式约束、知识和验收用例。别人拿到之后可以在**他自己的** Agent Host 上跑，
不需要你的配置文件。

## 怎么做

```bash
bash scripts/setup-runtime.sh
```

```bash
bash scripts/employee-new.sh team-qa minimal-answer.v1
```

```bash
bash scripts/employee-check.sh team-qa
```

预期输出：

```
▶ 1/2 静态包校验……
Static package valid: team-qa@0.1.0
Checked 5 declared file(s).

▶ 2/2 离线验收用例……
Contract eval (offline fixture conformance): passed. 1/1 case(s) passed.
- approved-support-channel: passed (EVAL_CASE_PASSED)

✓ 全部通过。
```

## 包里有什么

```
employees/team-qa/
├── employee.json              身份 + 宿主协议 + 权限策略
├── SKILL.md                   给 Agent Host 的行为说明书 ← 你主要改这个
├── schemas/input.schema.json  输入格式约束
├── schemas/output.schema.json 输出格式约束
├── knowledge/                 这个员工能读的资料
└── evals/cases.json           离线验收用例
```

`employee.json` 里最值得看的是 `policy` 段：

```json
"policy": {
  "mode": "read_only",
  "network": "deny",
  "filesystem": { "read": ["./knowledge/**"], "write": [] },
  "mcpTools": []
}
```

这是**声明式的权限边界**——只读、禁网、只能读自己的 `knowledge/`、不给任何 MCP 工具。
Agent Host 适配层负责把它翻译成宿主的实际约束。

## 改完怎么验

改 `SKILL.md` 或 `schemas/` 之后，重跑校验：

```bash
bash scripts/employee-check.sh team-qa
```

两步的分工：

- **`validate`** 查包结构：声明的文件在不在、schema 合不合法、字段齐不齐。
- **`eval`** 查行为契约：把 `evals/cases.json` 里的 `expectedOutput` 拿去撞
  `output.schema.json`，确保你声明的期望输出本身是合规的。

`eval` 不调模型，所以它验的是**契约自洽性**，不是模型答得对不对。这个区分很重要：
它能在你还没花一分钱调模型之前，就把格式类错误全挡掉。

## 放进 CI

因为全离线、无密钥，可以直接进流水线：

```bash
bash scripts/employee-check.sh team-qa
```

通过退出 `0`，任何包/契约/夹具错误退出 `1`。

## 下一步

- 想让它产出**可审批的动作提案**而不只是答案 → [案例 04](../04-structured-action/)
- 想**真的调模型**跑起来 → [案例 05](../05-multi-host/)
