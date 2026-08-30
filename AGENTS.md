# 给 AI 编程助手的执行说明

这个仓库是 Digital Employee 的案例库。使用者可能没有开发经验，请代替他执行命令，
用中文和非技术语言汇报，并严格遵守下面的发布边界。

## 当前发布边界

本 quickstart 的公开稳定基线固定为
`@fullstack-ai-infra/digital-employee@0.6.0`。当前对外主路径只覆盖：

- 员工包结构校验；
- 离线样例契约验收；
- 从公开 recipe 创建最小员工包；
- 在用户已经配置受支持 Agent Host 后执行一次性 `run`。

一次性 `run` 只有在用户已经配置受支持 Agent Host 时才可选。`legacy` 命名空间是历史
`standalone-v1` demo/兼容路径，不是本 quickstart 的主体验。`0.4.0` 新增的 `setup`
命令（既有目录内配置员工包）已发布，但尚无本仓库的干净机走查记录，不在对外主路径内。
`0.6.0` 继续提供包绑定的 `deploy` 命令：先校验并绑定精确员工包才产生部署效果；渠道上
`http` 仅在认证回读后 ready，`console`、`dingtalk` 为 preview 且永不 ready，`lark`、
`wecom` 不可用；没有交互式渠道向导、扫码授权、IM 应用创建或长期渠道服务。

不要执行或建议 `digital-employee deploy`，不要把源码 main、PR 或任何预览能力
当成已发布的走查路径。在干净环境验收完成前，`deploy` 只按上述边界表述，不提供操作指引。

## 铁律

1. 绝不打印、读取或索要密钥来完成本 quickstart。
2. 不依据 `docs/` 中的历史草稿创建钉钉、飞书或企业微信应用。
3. 不声称机器人 ONLINE、HTTP 服务已启动或渠道已部署，除非未来公开版本提供该能力且已真实验证。
4. 任何需要在线服务、Agent Host 或写入外部系统的动作，都先向用户说明边界并取得确认。

## 安全实践流程

### 1. 检查 Node.js

```bash
node --version
```

需要 Node.js 20 或更高版本。

### 2. 选择案例

```bash
cd cases/team-qa         # IT 团队问答
cd cases/hr-onboarding   # HR 入职引导
cd cases/ops-approval    # 运维审批提案
cd cases/product-faq     # 产品 FAQ
```

### 3. 固定公开版本并做无凭据验证

```bash
npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
  digital-employee validate . --json
npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
  digital-employee eval . --json
```

必须分别检查退出码与 JSON：`validate` 应为 `status: "valid"`；`eval` 应为
`status: "passed"` 且 `summary.failed: 0`。`eval` 只核对仓库自带离线样例的契约，不调用
模型，也不能证明数字员工真实回答过这些问题或回答正确。

### 4. 提交唯一运行反馈

完成或失败后，邀请用户把脱敏 Run Report 提交到
[digital-employee-quickstart#2][quickstart-adoption]。必须先得到用户同意才能代发，不要再创建
第二个 Issue 或 Discussion 入口。至少包含：CLI 固定版本、案例名、Node/操作系统、
`validate` 和 `eval` 状态，以及脱敏后的失败码。

### 5. 可选的一次性运行

只有用户明确要求、且已经安装并登录受支持 Agent Host 时，才按
[v0.6.0 框架文档][v060-runner]选择精确 `run --engine`
命令。不要自动探测凭据，不要退化为 OpenAI key，也不要把一次性 `run` 描述成部署。

## 已知路线图

统一部署体验由以下公开事项跟踪：

- [digital-employee#91](https://github.com/fullstack-ai-infra/digital-employee/issues/91)
- [digital-employee-quickstart#2][quickstart-adoption]

在新的公开版本和干净环境验收完成前，不得恢复 `deploy` 指引。

## 参考资料

- [README.md](README.md)
- [cases/README.md](cases/README.md)
- [框架 CLI 文档](https://github.com/fullstack-ai-infra/digital-employee)

`docs/` 下内容是历史部署草稿，不是 CLI `0.6.0` 的执行手册。

[v060-runner]: https://github.com/fullstack-ai-infra/digital-employee/blob/v0.6.0/README.zh-CN.md#发布者自有机器上的-runner-路径
[quickstart-adoption]: https://github.com/fullstack-ai-infra/digital-employee-quickstart/issues/2
