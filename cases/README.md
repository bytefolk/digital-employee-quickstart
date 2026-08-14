# 案例库

每个子目录都是一个符合 `employee-package.v1alpha1` 的数字员工案例。

## 当前可执行路径

公开 CLI `0.3.0` 可以校验员工包并执行离线样例契约验收，但没有 `deploy` 命令或长期
渠道服务。离线验收不调用模型，也不能证明数字员工真实回答过问题。请固定版本运行：

```bash
cd cases/<案例名>
npx --yes --package @fullstack-ai-infra/digital-employee@0.3.0 -- \
  digital-employee validate . --json
npx --yes --package @fullstack-ai-infra/digital-employee@0.3.0 -- \
  digital-employee eval . --json
```

不要执行 `digital-employee deploy` 或 `deploy --channel dingtalk`；统一部署体验尚未公开交付。
完成或失败后，只在
[digital-employee-quickstart#2](https://github.com/fullstack-ai-infra/digital-employee-quickstart/issues/2)
提交脱敏 Run Report。

## 案例列表

| 目录 | 场景 | 一次性运行需要 Agent Host |
|------|------|--------------------------|
| `team-qa/` | IT 答疑（团队手册问答） | 是 |
| `hr-onboarding/` | HR 入职引导（多文档知识源） | 是 |
| `ops-approval/` | 运维审批提案（结构化输出） | 是 |
| `product-faq/` | 产品 FAQ（对外客服场景） | 是 |

## 案例规范

每个案例目录必须包含：

```text
<案例名>/
├── employee.json          # 员工包清单
├── SKILL.md               # 行为说明书
├── knowledge/             # 知识库（Markdown）
├── schemas/
│   ├── input.schema.json  # 输入格式约束
│   └── output.schema.json # 输出格式约束
└── evals/
    └── cases.json         # employee-evals.v1alpha1 离线样例
```

## 创建你自己的案例

只要目录符合上述规范，CLI 就能识别。先完成无凭据验证；需要一次性执行时，再按框架文档
配置受支持的 Agent Host：

```bash
npx --yes --package @fullstack-ai-infra/digital-employee@0.3.0 -- \
  digital-employee validate . --json
npx --yes --package @fullstack-ai-infra/digital-employee@0.3.0 -- \
  digital-employee eval . --json
```
