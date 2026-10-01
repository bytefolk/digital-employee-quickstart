# 研发数字员工案例库（研发团队示范工作区）

[English](README.md)

本目录是《研发数字员工案例库建设方案》的首轮可运行内容：七个岗位员工包、结构化交接契约、数据准入规则、公开演示案例和确定性检索。首条任务聚焦“成员列表筛选、分页及加载/空/错误状态”。这里的案例明确标为**合成教学材料**，不代表已有真实 PR、人工评审或端到端研发效果。

## 边界

- 公开兼容基线为 `@fullstack-ai-infra/digital-employee@0.6.0`。`validate` 验员工包结构，`eval` 验公开 fixture 契约，均不调用模型。
- 七个岗位均申请包内读取、仅向各自 `./work/**` 写入，并要求操作前审批。员工策略、技能文件、schema、验收样例、knowledge 和 playbook 保持只读。组织白名单包含读、写以及常见浏览器/搜索工具名；`Bash` 明确列入拒绝名单。这些只是权限申请：最终可用工具和联网能力仍取决于配置的 Agent Host；当前发布的 v0.6 适配器尚未提供隔离写代码、运行构建和审批后应用 Patch 的研发闭环。
- `organization.v1alpha1.json` 的汇报关系不表示执行顺序。`workflow.json` 只描述计划流程和人工门禁，当前框架不自动执行它。
- `cases/` 仅存公开演示材料。真实案例需要授权、脱敏、固定基线与人工审核；保留任务和隐藏测试必须放在独立评测环境。
- `work/`、凭据、Agent Host 绑定和仓库副本都不随模板分发。

## 权限执行与独立复核

工具/MCP 数据面联网默认采用 `deny`。未来若申请 `host_policy`，必须采用 **fail-closed**：宿主机不支持、支持情况未知或不能强制执行时，一律 deny。启用需要单独评审，提供所选宿主机确实执行网络边界的证据及明确的任务授权。浏览器/搜索工具可见不代表联网获准；宿主机认证和模型控制面流量不在此数据面策略内。

组织层的工具名规则无法限制 Bash 子命令，因此在单独评审过的受控执行路径存在前，默认拒绝命令行。每个岗位的 SKILL 和 playbook 都禁止删除文件（`rm`）、重置历史、推送或合并（`git push`）、部署、安装程序、下载并执行脚本（`curl`/`wget` 管道）、绕过被拒绝的工具，以及改写自己的验收基线或策略。需要这些动作时，提出方案交由人工单独执行和复核。宿主机必须执行文件范围、工具授权、联网限制和审批，否则不运行这些包。文字约束与离线检查本身不构成沙箱。

`.github/CODEOWNERS` 将研发示范目录、对应 CI 和 CODEOWNERS 自身交给独立评审人 `@PeterGuy326`。仓库管理员还须在 `main` 启用必需的 code-owner review；文件本身不能强制门禁。权限修改（含检查脚本修改）应由非作者核对策略差异、包 digest 和宿主机执行证据后批准。作者刷新 digest 只能校验内容完整性，不能代替独立批准。

## 无凭据检查

在 `digital-employee-quickstart` 目录运行（Node.js 20+）：

```bash
node showcases/rd-team/tools/check.mjs
node showcases/rd-team/tools/search.mjs --role frontend-engineer --task-type frontend-feature --stack react --query '成员列表筛选 分页 空状态' --repository example/member-console --commit demo-baseline-v1

npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
  digital-employee org tree showcases/rd-team --json

for manifest in showcases/rd-team/positions/tech-lead/employee.json showcases/rd-team/positions/tech-lead/*/employee.json; do
  package_dir="$(dirname "$manifest")"
  npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- digital-employee validate "$package_dir" --json
  npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- digital-employee eval "$package_dir" --json
done
```

只有 `validate.status=valid` 和 `eval.status=passed` 且 `summary.failed=0` 才算岗位包契约通过。`org apply` 会写入工作区并更新 digest；先复制本目录到其他位置再运行，勿直接修改仓库中的模板。

## 首轮接入真实项目时需补齐

1. 由项目负责人确认真实需求、授权仓库和固定 Commit；填写 `context/project.md` 中的待确认项。
2. 按 `cases/README.md` 的准入表收集至少 3 个真实示范案例和 3 个独立保留任务；保留任务不得进入本目录。
3. 明确实际构建、测试、视觉和业务验收命令，在隔离执行环境中获取运行证据。
4. 按 `workflow.json` 人工执行并签署门禁，直至框架的跨岗位流程、受控写入和审批执行能力通过端到端验收。不要把声明的权限申请当作所选宿主机已提供或强制执行这些工具的证据。

检索工具只对 `cases/catalog.json` 中批准且公开的条目做元数据过滤和文本排序，并输出命中原因和基线冲突标志。它不是模型运行器，也不读取私有仓库。
