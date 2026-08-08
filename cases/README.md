# 案例库

每个子目录是一个**完整可运行**的数字员工案例。

## 使用方式

```bash
cd cases/<案例名>
npx @fullstack-ai-infra/digital-employee deploy
```

或指定渠道非交互运行：

```bash
npx @fullstack-ai-infra/digital-employee deploy --channel dingtalk --yes
```

## 案例列表

| 目录 | 场景 | 需要 Agent Host |
|------|------|----------------|
| `team-qa/` | IT 答疑机器人（团队手册问答） | 是 |
| `hr-onboarding/` | HR 入职引导（多文档知识源） | 是 |
| `ops-approval/` | 运维审批提案（结构化输出） | 是 |
| `product-faq/` | 产品 FAQ（对外客服场景） | 是 |

## 案例规范

每个案例目录必须包含：

```
<案例名>/
├── employee.json          # 员工包清单（符合 employee-package.v1alpha1）
├── SKILL.md               # 行为说明书
├── knowledge/             # 知识库（markdown）
│   └── *.md
├── schemas/
│   ├── input.schema.json  # 输入格式约束
│   └── output.schema.json # 输出格式约束
└── evals/
    └── cases.json         # 离线验收用例
```

## 创建你自己的案例

三方可以按以上规范做自己的案例仓库。只要目录下有符合 `employee-package.v1alpha1`
规范的 `employee.json`，框架 CLI 就能识别和运行：

```bash
npx @fullstack-ai-infra/digital-employee validate .
npx @fullstack-ai-infra/digital-employee eval .
npx @fullstack-ai-infra/digital-employee deploy
```
