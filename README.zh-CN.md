# 数字员工官方案例库

[English](README.md)

[Digital Employee](https://github.com/fullstack-ai-infra/digital-employee) 框架的官方案例库。
每个案例都是一个可移植的 `employee-package.v1alpha1` 示例，包含知识、Schema 和离线验收样例。

## 当前发布边界

截至 2026-08-13，本 quickstart 已验证的公开 CLI 版本是
`@fullstack-ai-infra/digital-employee@0.3.0`。它支持员工包校验、
离线样例验收，以及通过已配置 Agent Host 执行一次性 `run`。它**没有**交付 `deploy`
命令、交互式渠道向导、IM 应用创建或长期运行的渠道服务。

当前版本请勿执行 `digital-employee deploy`。部署流程仍是路线图工作，跟踪于
[digital-employee#91][adoption-epic] 和
[digital-employee-quickstart#2][quickstart-adoption]。

## 安全实践一个案例

下面这条路径不需要任何凭据，并且已经针对精确公开版本完成验证：

```bash
git clone https://github.com/fullstack-ai-infra/digital-employee-quickstart.git
cd digital-employee-quickstart/cases/team-qa

npx --yes --package @fullstack-ai-infra/digital-employee@0.3.0 -- \
  digital-employee validate . --json
npx --yes --package @fullstack-ai-infra/digital-employee@0.3.0 -- \
  digital-employee eval . --json
```

`validate` 检查员工包结构；`eval` 只做离线样例契约验收，不会调用模型、Agent Host、
MCP 或任何在线服务。

## 案例列表

| 案例 | 场景 | 说明 |
|------|------|------|
| [`team-qa`](cases/team-qa/) | IT 团队问答 | 从团队手册、值班制度、权限文档中回答 |
| [`hr-onboarding`](cases/hr-onboarding/) | HR 入职引导 | 引导新人了解流程、福利、办公指南 |
| [`ops-approval`](cases/ops-approval/) | 运维审批提案 | 把请求转成结构化提案——只提案不执行 |
| [`product-faq`](cases/product-faq/) | 产品 FAQ | 面向客户的产品问答，从公开文档回答 |

对其他案例执行同样的无凭据检查：

```bash
npx --yes --package @fullstack-ai-infra/digital-employee@0.3.0 -- \
  digital-employee validate cases/hr-onboarding --json
npx --yes --package @fullstack-ai-infra/digital-employee@0.3.0 -- \
  digital-employee eval cases/hr-onboarding --json
```

## 案例结构

每个案例遵循员工包规范：

```text
<案例>/
├── employee.json              # 包清单
├── SKILL.md                   # AI 引擎的行为说明书
├── knowledge/                 # 知识库（Markdown）
├── schemas/
│   ├── input.schema.json      # 输入契约
│   └── output.schema.json     # 输出契约
└── evals/
    └── cases.json             # 离线验收样例
```

## 创建你自己的案例

欢迎三方案例仓库。先初始化员工包，再完成校验与离线验收；需要一次性执行时，再配置受支持的
Agent Host：

```bash
npx --yes --package @fullstack-ai-infra/digital-employee@0.3.0 -- \
  digital-employee init my-case --recipe minimal-answer.v1
npx --yes --package @fullstack-ai-infra/digital-employee@0.3.0 -- \
  digital-employee validate my-case --json
npx --yes --package @fullstack-ai-infra/digital-employee@0.3.0 -- \
  digital-employee eval my-case --json
```

一次性执行需要已安装、已配置的受支持 Agent Host。当前引擎矩阵和 `run` 语法见
[v0.3.0 框架文档](https://github.com/fullstack-ai-infra/digital-employee/blob/v0.3.0/README.zh-CN.md#发布者自有机器上的-runner-路径)。

## 前置条件

- 校验和离线验收需要 Node.js 20 或更高版本。
- 只有执行一次性 `run` 时才需要受支持的 Agent Host。

## 参考

- [框架 CLI 文档](https://github.com/fullstack-ai-infra/digital-employee)
- [员工包规范](https://github.com/fullstack-ai-infra/digital-employee/blob/v0.3.0/docs/employee-package.md)
- [`docs/`](docs/) 是历史部署草稿，不是 CLI `0.3.0` 的可执行教程。

## 许可

Apache-2.0。详见 [NOTICE](NOTICE)。

[adoption-epic]: https://github.com/fullstack-ai-infra/digital-employee/issues/91
[quickstart-adoption]: https://github.com/fullstack-ai-infra/digital-employee-quickstart/issues/2
