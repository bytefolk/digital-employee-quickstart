# oss-maintainer showcase（开源维护者案例包）

一个「开源维护者」业务 = 1 个负责人（repo-owner）+ 3 个专家岗位
（issue-researcher / release-engineer / community-operator）。它演示数字组织工作区的
目标形态：一个目录 = 一项业务，一个岗位 = 一个可寻址数字员工，一次对话 = 带岗位
Context 与权限边界的工作。

> 本 showcase 的**组织契约**（`business.json` / `organization.json`）是旧版设计稿，
> 不符合公开 `0.6.0` 的标准工作区结构。`0.6.0` 已提供 `workspace init`、`org tree` 和
> `org apply`，但只消费其标准 `workspace.json` / `organization.v1alpha1.json` / `positions/`
> 布局；本目录尚未迁移，不能直接作为这些命令的输入。当前在本目录可执行且已真实验证的
> 部分，只有四个岗位员工包的 `validate` / `eval`；`chat @岗位` 仍未发布。

## 组织树

```text
open-source-maintenance/                 # 业务工作区（本 showcase 目录）
├── business.json                        # business-workspace.v1alpha1（proposed 设计稿）
├── organization.json                    # organization.v1alpha1, revision 1（proposed 设计稿）
├── context/                             # mission.md / roadmap.md（workspace scope）
└── employees/
    ├── repo-owner/          (root Owner，可委派给直接下属)
    ├── issue-researcher/    (只读专家：issue/PR 调研)
    ├── release-engineer/    (只读专家：发布计划与检查清单)
    └── community-operator/  (只读专家：社区内容草稿)
```

```text
repo-owner
├── issue-researcher
├── release-engineer
└── community-operator
```

## 岗位与权限表

首版统一安全默认值：**全部 read_only、network deny、无 MCP、无 write**。岗位差异体现在
「可读 context bundle 与委派权」（委派权属组织设计稿，未实现）。

| 岗位 | 职责 | 对话场景示例 | 权限边界（设计稿） |
|------|------|--------------|--------------------|
| repo-owner | 理解业务全局；收到任务后决定 complete / delegate / escalate；汇总下属产出，对结果负责 | 「我们下个版本该做什么？调研一下近一个月的 issue 和社区反馈再给建议。」 | `contextBundleIds: [business-brief]`（mission.md + roadmap.md）；`delegation: direct_reports`（深度 1、fan-out ≤ 3）；maxTurns 最高；无 write |
| issue-researcher | 基于 issue 快照与用户反馈做事实调研；只出结论与建议，不做产品决策 | 「把这 30 个 open issue 按主题聚类，标出重复和无人认领的。」 | `contextBundleIds: [issue-backlog]`；无委派权；maxTurns 低、成本最低；无 write |
| release-engineer | 按 roadmap 与发布流程草拟发布计划/检查清单/迁移说明；不实际发布 | 「按当前 changelog 草拟 v2.4.0 发布检查清单。」 | `contextBundleIds: [release-checklist]`；无委派权；无 write |
| community-operator | 把社区反馈与活动记录写成对外内容草稿（FAQ/公告/回复模板）；只产出文本，不发布 | 「把本周社区的高频问题整理成一份 FAQ 更新草稿。」 | `contextBundleIds: [community-feed]`；无委派权；无 write |

## 发布边界（诚实声明）

- 本 showcase 的固定验证版本：`@fullstack-ai-infra/digital-employee@0.6.0`（npm 已发布，
  含 `init` / `doctor` / `validate` / `eval`）。quickstart 现有 `cases/` 的公共基线
  同步固定为 0.6.0。
- `business.json` / `organization.json` 标注 `status: "proposed"`：它们是组织/工作区
  契约的设计稿，**已发布 CLI 不读取、不校验**；不要把它们当成可用命令的输入。
- `workspace init` / `org tree` / `org apply` 已在 `0.6.0` 发布，并已针对 CLI 新建的临时
  标准工作区完成无凭据验证；本 showcase 目录仍会被 `org tree` 以
  `workspace_org_workspace_not_initialized` 拒绝，不能声称已经迁移。
- `chat @岗位` / `task show` / `context inspect` 仍不是已发布命令面；`0.6.0` 提供的是底层
  `task delegate`，不等同于 `task show` 或交互式聊天。runbook 中这些步骤继续标 ⏳ 或 🧩。
- `validate` 只校验员工包结构；`eval` 只核对仓库自带离线样例的契约，不调用模型、
  Agent Host、MCP 或在线服务，**不能证明数字员工真实回答过这些问题或回答正确**。
- 本 showcase 不含任何凭证、内部路径或个人标识。

## Clean-machine runbook

目标：新用户从零安装到第一次 `chat @岗位`。每条标注依赖状态：

- ✅ 现在就能验证（基于已发布能力，本仓库已真实执行）
- ⏳ 依赖本 showcase 迁移到 `0.6.0` 标准工作区契约，或依赖尚未发布的上层命令
- 🧩 底层能力已发布或可验证，但本 showcase 的迁移/岗位绑定尚未完成

### 阶段 A：环境与工具（✅ 现在就能验证）

1. 安装 Node.js 20+（`node --version` 确认）。
2. 固定版本安装 CLI：
   ```bash
   npm install --global @fullstack-ai-infra/digital-employee@0.6.0
   ```
3. 确认安装（无模型调用、零成本、无需凭据）：
   ```bash
   digital-employee doctor --json
   ```
   `doctor` 只做本机就绪度检查与本地 `<host> --version` 探测，不认证、不调模型。
   `runnable: false` 是正常的——它只表示当前没有已配置的合格 Agent Host。

### 阶段 B：确认「底座可信」（✅ 现在就能验证）

4. 获取案例（本目录仍是旧版草稿布局，不要对它执行 `org tree` / `org apply`）：
   ```bash
   git clone https://github.com/fullstack-ai-infra/digital-employee-quickstart.git
   cd digital-employee-quickstart/showcases/oss-maintainer
   ```
5. 校验与离线验收（对四个岗位包分别执行，全部应通过）：
   ```bash
   npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
     digital-employee validate employees/repo-owner --json
   npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
     digital-employee eval employees/repo-owner --json
   # 其余岗位：issue-researcher / release-engineer / community-operator 同法
   ```
   期望：`validate` 为 `status: "valid"`；`eval` 为 `status: "passed"` 且
   `summary.failed: 0`。此步无凭据、不调模型，是最低门槛的「跑通」证据。

### 阶段 C：第一次对话（⏳ 依赖实现；🧩 部分项）

6. 查看组织（🧩 命令已发布，showcase 迁移未完成）：`digital-employee org tree` 已在
   `0.6.0` 提供，但只支持 `workspace init` 创建的标准工作区；当前目录会被判定为
   `workspace_org_workspace_not_initialized`，现阶段只静态查看 `organization.json` 与
   本 README 的组织树图。
7. 省心模式（⏳ 目标 `digital-employee chat @repo-owner`，未实现）：目标体验是向负责人
   提问后看到委派链与汇总 Artifact；当前可验证的证据只有 `eval` 离线契约
   （`employees/repo-owner/evals/cases.json` 的委派/汇总样例）。
8. 精确模式（⏳ 目标 `digital-employee chat @issue-researcher`，未实现）：目标体验是确认
   无委派、Context 更窄、权限更小；当前可验证的证据只有该岗位更窄的 knowledge 与
   3 条离线契约。
9. 岗位记忆（🧩 mem 本体可自托管，`durable-context.v1` recall 契约已冻结；岗位绑定与
   `context inspect` 命令未实现）：目标体验是关闭终端重进后岗位记忆仍可恢复。
10. 责任轨迹（⏳ 目标 `digital-employee task show <task-id> --tree`，未实现）。

### 阶段 D：反馈回路（✅ 现在就能验证）

11. 走查记录按 quickstart 模板提交到
    [digital-employee-quickstart#2](https://github.com/fullstack-ai-infra/digital-employee-quickstart/issues/2)
    （唯一反馈入口），至少包含：CLI 固定版本、案例名、Node/操作系统、`validate` 和
    `eval` 状态、脱敏后的失败码。无密钥、无个人标识、无私有 URL。

### 依赖矩阵

| 步骤 | 依赖 | 状态 | 阻塞项 |
|------|------|------|--------|
| A1–A3 | 已发布 0.4.0（doctor） | ✅ 可验证 | 无 |
| B4（克隆替代） | quickstart 仓库 | ✅ 可验证 | 无 |
| B4（init 目标） | `0.6.0 workspace init` + showcase 迁移 | 🧩 | CLI 已发布；本目录仍是旧布局 |
| B5 | 已发布 0.4.0（validate/eval） | ✅ 可验证 | 无 |
| C6 | `0.6.0 org tree` + showcase 迁移 | 🧩 | 命令已发布；本目录尚未初始化为标准工作区 |
| C7–C8 | `chat @岗位` / 对话编排 | ⏳ | 上层 chat Runtime + Host 输出契约 |
| C9 | mem durable-context 岗位绑定 | 🧩 | `context inspect` + appointment 绑定 |
| C10 | `task show` | ⏳ | `0.6.0` 仅提供底层 `task delegate`；`task show` 未实现 |
| D11 | quickstart#2 反馈模板 | ✅ 可验证 | 无 |

## 验证记录（本仓库真实执行）

执行环境：Node v22.14.0 / Linux（WSL）；固定版本 `@fullstack-ai-infra/digital-employee@0.6.0`。
全部命令退出码为 0。

| 岗位包 | validate | eval | 退出码 |
|--------|----------|------|--------|
| `employees/repo-owner` | `valid` | `passed`（4/4，failed 0） | 0 / 0 |
| `employees/issue-researcher` | `valid` | `passed`（3/3，failed 0） | 0 / 0 |
| `employees/release-engineer` | `valid` | `passed`（3/3，failed 0） | 0 / 0 |
| `employees/community-operator` | `valid` | `passed`（3/3，failed 0） | 0 / 0 |

`doctor --json`：`status: "installed"`，`runnable: false`（无已配置 Agent Host），退出码 0，
无需任何凭据。

工作区接口兼容性复核（同一环境、同一 `0.6.0` 公共包）：在临时空目录执行
`workspace init --template oss-maintainer`、`org tree`、`org apply` 均退出 0；对本仓库
`showcases/oss-maintainer` 执行只读 `org tree --json` 则退出 1，稳定错误码为
`workspace_org_workspace_not_initialized`。因此这里只记录已发布接口，不把旧 showcase 声称为
已迁移工作区。

## 目录结构

```text
showcases/oss-maintainer/
├── README.md                  # 本走查文档（runbook）
├── business.json              # proposed：business-workspace.v1alpha1 设计稿
├── organization.json          # proposed：organization.v1alpha1 设计稿（岗位 + 权限）
├── context/
│   ├── mission.md             # workspace scope
│   └── roadmap.md             # workspace scope
└── employees/                 # 每个 = 现有 employee-package.v1alpha1 结构
    ├── repo-owner/
    ├── issue-researcher/
    ├── release-engineer/
    └── community-operator/
```

每个员工包：`employee.json` / `SKILL.md` / `schemas/` / `evals/cases.json` /
`knowledge/`。

## 反馈

唯一公开反馈入口：[digital-employee-quickstart#2](https://github.com/fullstack-ai-infra/digital-employee-quickstart/issues/2)。
不要为此 showcase 另开 Issue 或 Discussion。
