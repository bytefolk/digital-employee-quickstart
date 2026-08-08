# 数字员工官方案例库

[English](README.md)

[Digital Employee](https://github.com/fullstack-ai-infra/digital-employee) 框架的官方案例库。
每个案例是一个**完整可运行的员工包**——`cd` 进去直接部署。

---

## 快速开始

```bash
git clone https://github.com/fullstack-ai-infra/digital-employee-quickstart.git
cd digital-employee-quickstart/cases/team-qa
npx @fullstack-ai-infra/digital-employee deploy
```

deploy 命令全程交互式引导，处理语言、渠道、授权、引擎检测和部署。

## 案例列表

| 案例 | 场景 | 说明 |
|------|------|------|
| [`team-qa`](cases/team-qa/) | IT 团队问答 | 从团队手册、值班制度、权限文档中回答 |
| [`hr-onboarding`](cases/hr-onboarding/) | HR 入职引导 | 引导新人了解流程、福利、办公指南 |
| [`ops-approval`](cases/ops-approval/) | 运维审批提案 | 把请求转成结构化提案——只提案不执行 |
| [`product-faq`](cases/product-faq/) | 产品 FAQ | 面向客户的产品问答，从公开文档回答 |

每个案例都符合 `employee-package.v1alpha1` 规范，可以直接：

```bash
npx @fullstack-ai-infra/digital-employee validate cases/team-qa   # 静态校验
npx @fullstack-ai-infra/digital-employee eval cases/team-qa       # 离线验收
npx @fullstack-ai-infra/digital-employee deploy                    # 完整部署
```

## 案例结构

每个案例遵循员工包规范：

```
<案例>/
├── employee.json              # 包清单
├── SKILL.md                   # AI 引擎的行为说明书
├── knowledge/                 # 知识库（markdown）
├── schemas/
│   ├── input.schema.json      # 输入契约
│   └── output.schema.json     # 输出契约
└── evals/
    └── cases.json             # 离线验收用例
```

## 创建你自己的案例

三方案例仓库欢迎贡献。只要目录下有符合 `employee-package.v1alpha1` 规范的
`employee.json`，框架 CLI 就能识别和运行：

```bash
# 从 recipe 初始化新案例
npx @fullstack-ai-infra/digital-employee init my-case --recipe minimal-answer.v1

# 校验和测试
npx @fullstack-ai-infra/digital-employee validate my-case
npx @fullstack-ai-infra/digital-employee eval my-case

# 部署到渠道
cd my-case && npx @fullstack-ai-infra/digital-employee deploy
```

## 前置条件

- Node.js 20+
- AI 引擎：Qoder CLI / Claude Code / Qwen Code / CodeBuddy——或 OpenAI 兼容 key

## 参考

- [框架 CLI 文档](https://github.com/fullstack-ai-infra/digital-employee)
- [员工包规范](https://github.com/fullstack-ai-infra/digital-employee/blob/main/docs/employee-package.md)
- [手动操作教程](docs/)（中文）

## 许可

Apache-2.0。详见 [NOTICE](NOTICE)。
