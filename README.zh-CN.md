# 数字员工官方案例库

[English](README.md)

[Digital Employee](https://github.com/bytefolk/digital-employee) 框架的官方案例库。
每个案例都是一个可移植的 `employee-package.v1alpha1` 示例，包含知识、Schema 和离线验收样例。

## 公开发布边界

本 quickstart 固定使用公开包 `@fullstack-ai-infra/digital-employee@0.6.0`。

| 路径 | 状态 | 在本 quickstart 中的含义 |
|------|------|--------------------------|
| `init`、`validate`、`eval` | 已验证的公开路径 | 无凭据创建员工包、校验结构和离线契约 |
| `doctor` | 已验证的公开路径 | 无凭据的本机就绪度检查；不认证、不调用模型 |
| `setup` | 已发布，不在本走查内 | `0.4.0` 新增：在既有目录内配置员工包；本仓库尚无对应的干净机走查记录 |
| `run` | 依赖用户环境 | 可选的一次性执行；需要已配置的受支持 Agent Host |
| `legacy ...` | 历史 demo/兼容路径 | `standalone-v1` 兼容能力，不是本 quickstart 的主体验 |
| `deploy` | 已发布，暂不提供指引 | 公开 `0.6.0` 中继续提供的包绑定命令：先校验并绑定精确员工包，才产生任何部署效果。渠道：`http` 仅在认证回读后 ready；`console`、`dingtalk` 为 preview，永不 ready；`lark`、`wecom` 不可用。runtime 仅 `agent-native`；退出码 `0` ready、`2` 等待外部动作、`1` 不支持或失败。在 [digital-employee#91][adoption-epic] 的干净机验收完成前，本 quickstart 不提供任何 deploy 操作指引或走查。 |

规划中的部署路径跟踪于 [digital-employee#91][adoption-epic] 和
[digital-employee-quickstart#2][quickstart-adoption]。

## 安全实践一个案例

下面这条路径不需要任何凭据，并且已经针对精确公开版本完成验证：

```bash
git clone https://github.com/bytefolk/digital-employee-quickstart.git
cd digital-employee-quickstart/cases/team-qa

npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
  digital-employee validate . --json
npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
  digital-employee eval . --json
```

`team-qa` 的预期结果依次是 `status: "valid"`，以及 `status: "passed"`、
3 个离线样例全部通过。

`validate` 检查员工包结构；`eval` 只核对仓库自带离线样例的契约，不会调用模型、
Agent Host、MCP 或任何在线服务，也**不能证明数字员工真实回答过这些问题或回答正确**。

## 提交本次运行反馈

无论成功还是失败，只使用一个公开反馈入口：
[在 digital-employee-quickstart#2 下评论][quickstart-adoption]。请粘贴下面这份脱敏
Run Report：

```text
CLI: @fullstack-ai-infra/digital-employee@0.6.0
案例: team-qa
Node / 操作系统:
validate: valid | failed
eval: passed (3/3) | failed
失败码/输出（如有，需脱敏）:
```

不要提交凭据、账号标识、私有仓库名或本机绝对路径。

## 案例列表

| 案例 | 场景 | 说明 |
|------|------|------|
| [`team-qa`](cases/team-qa/) | IT 团队问答 | 从团队手册、值班制度、权限文档中回答 |
| [`hr-onboarding`](cases/hr-onboarding/) | HR 入职引导 | 引导新人了解流程、福利、办公指南 |
| [`ops-approval`](cases/ops-approval/) | 运维审批提案 | 把请求转成结构化提案——只提案不执行 |
| [`product-faq`](cases/product-faq/) | 产品 FAQ | 面向客户的产品问答，从公开文档回答 |

对其他案例执行同样的无凭据检查：

```bash
npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
  digital-employee validate cases/hr-onboarding --json
npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
  digital-employee eval cases/hr-onboarding --json
```

## 多岗位案例（Showcases）

| Showcase | 形态 | 说明 |
|----------|------|------|
| [`oss-maintainer`](showcases/oss-maintainer/) | 1 负责人 + 3 专家岗位 | 开源维护业务：`repo-owner` 总负责，配 `issue-researcher`、`release-engineer`、`community-operator` 三个只读专家岗位 |

这一类演示数字组织工作区的目标形态：一个目录就是一项业务，一个岗位就是一个可寻址的
数字员工。包内的 `business.json` / `organization.json` 是 `status: "proposed"` 的组织契约
旧版设计稿，已发布 CLI 不读取、不校验这些文件。公开 `0.6.0` 已提供面向其标准工作区结构的
`workspace init`、`org tree` 和 `org apply`，但本 showcase 尚未迁移，CLI 会把它判定为未初始化
工作区；`chat @岗位` 与持久化 Workbench 集成仍未发布。当前仓库内可执行部分只有四个岗位包在
固定版本 `@fullstack-ai-infra/digital-employee@0.6.0` 下的 `validate` / `eval`，精确阶段标记见
包内干净机 runbook。

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
npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
  digital-employee init my-case --recipe minimal-answer.v1
npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
  digital-employee validate my-case --json
npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
  digital-employee eval my-case --json
```

一次性执行需要已安装、已配置的受支持 Agent Host。当前引擎矩阵和 `run` 语法见
[v0.6.0 框架文档](https://github.com/bytefolk/digital-employee/blob/v0.6.0/README.zh-CN.md#发布者自有机器上的-runner-路径)。

## 前置条件

- 校验和离线验收需要 Node.js 20 或更高版本。
- 只有执行一次性 `run` 时才需要受支持的 Agent Host。

## 参考

- [框架 CLI 文档](https://github.com/bytefolk/digital-employee)
- [员工包规范](https://github.com/bytefolk/digital-employee/blob/v0.6.0/docs/employee-package.md)
- [`docs/`](docs/) 是历史部署草稿，不是 CLI `0.6.0` 的可执行教程。

## 许可

Apache-2.0。详见 [NOTICE](NOTICE)。

[adoption-epic]: https://github.com/bytefolk/digital-employee/issues/91
[quickstart-adoption]: https://github.com/bytefolk/digital-employee-quickstart/issues/2
