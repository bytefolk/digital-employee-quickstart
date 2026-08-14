# 给 AI 编程助手的执行说明

这个仓库是 Digital Employee 的案例库。使用者可能没有开发经验，请代替他执行命令，
用中文和非技术语言汇报，并严格遵守下面的发布边界。

## 当前发布边界

截至 2026-08-13，本 quickstart 已验证的公开 CLI 版本
`@fullstack-ai-infra/digital-employee@0.3.0` 只支持：

- 员工包结构校验；
- 离线样例契约验收；
- 在用户已经配置受支持 Agent Host 后执行一次性 `run`。

它没有 `deploy` 命令，也没有交付交互式渠道选择、扫码授权、IM 应用创建或长期渠道服务。
不要执行或建议 `digital-employee deploy`，不要把源码 main 上的预览能力当成已发布能力。

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
npx --yes --package @fullstack-ai-infra/digital-employee@0.3.0 -- \
  digital-employee validate . --json
npx --yes --package @fullstack-ai-infra/digital-employee@0.3.0 -- \
  digital-employee eval . --json
```

必须分别检查退出码与 JSON：`validate` 应为 `status: "valid"`；`eval` 应为
`status: "passed"` 且 `summary.failed: 0`。`eval` 是离线样例契约验收，不代表模型回答质量。

### 4. 可选的一次性运行

只有用户明确要求、且已经安装并登录受支持 Agent Host 时，才按
[v0.3.0 框架文档][v030-runner]选择精确 `run --engine`
命令。不要自动探测凭据，不要退化为 OpenAI key，也不要把一次性 `run` 描述成部署。

## 已知路线图

统一部署体验由以下公开事项跟踪：

- [digital-employee#91](https://github.com/fullstack-ai-infra/digital-employee/issues/91)
- [digital-employee-quickstart#2](https://github.com/fullstack-ai-infra/digital-employee-quickstart/issues/2)

在新的公开版本和干净环境验收完成前，不得恢复 `deploy` 指引。

## 参考资料

- [README.md](README.md)
- [cases/README.md](cases/README.md)
- [框架 CLI 文档](https://github.com/fullstack-ai-infra/digital-employee)

`docs/` 下内容是历史部署草稿，不是 CLI `0.3.0` 的执行手册。

[v030-runner]: https://github.com/fullstack-ai-infra/digital-employee/blob/v0.3.0/README.zh-CN.md#发布者自有机器上的-runner-路径
