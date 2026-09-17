# oss-maintainer 演示工作区

[English](README.md)

oss-maintainer 是一个可运行的开源项目维护数字组织工作区。它由 1 位仓库负责人统领，下设 3 个只读专家岗位：

    repo-owner
    ├── issue-researcher
    ├── release-engineer
    └── community-operator

该 showcase 使用 Digital Employee CLI 和 RoleWeave 消费的标准工作区布局：

    oss-maintainer/
    ├── workspace.json
    ├── organization.v1alpha1.json
    ├── context/
    └── positions/
        └── repo-owner/
            ├── employee.json
            ├── budget.json
            ├── knowledge/
            ├── schemas/
            ├── evals/
            ├── issue-researcher/
            ├── release-engineer/
            └── community-operator/

每个岗位都是一个便携的 `employee-package.v1alpha1` 员工包。文件系统的目录嵌套结构即是汇报结构：三个专家岗位直接向 `repo-owner` 汇报。

## 岗位职责与边界

| 岗位 | 职责 | 运行边界 |
|------|------|----------|
| repo-owner | 负责路线图、评审决策和最终发布建议 | 只读；可建议委托，但不宣称自己代执行 |
| issue-researcher | 整理 Issue、验证复现依据并生成调研摘要 | 只读；不作产品决策 |
| release-engineer | 起草发布方案、检查清单和版本变更说明 | 只读；不直接发布版本 |
| community-operator | 汇总社区反馈，撰写 FAQ 与公告草稿 | 只读；不直接向外发布内容 |

所有岗位均遵循只读基线：`read_only` 模式、`network: deny`、无 MCP 工具、无文件系统写入权限。

## 验证工作区

以下检查无需凭据，不调用大模型：

```bash
npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
  digital-employee org tree showcases/oss-maintainer --json

npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
  digital-employee org apply showcases/oss-maintainer --json
```

校验并评估各个岗位的员工包：

```bash
for package_dir in \
  showcases/oss-maintainer/positions/repo-owner \
  showcases/oss-maintainer/positions/repo-owner/issue-researcher \
  showcases/oss-maintainer/positions/repo-owner/release-engineer \
  showcases/oss-maintainer/positions/repo-owner/community-operator
do
  npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
    digital-employee validate "$package_dir" --json
  npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
    digital-employee eval "$package_dir" --json
done
```

`validate` 校验员工包结构与契约完整性；`eval` 检验离线测试样例。真实的真机运行需要单独配置受支持的 Agent Host。

## 在 RoleWeave 桌面端中打开

### 1. 复制隔离（强烈建议）

RoleWeave 桌面端将打开的工作区视为可变的活体状态。在界面上：
- **招聘**会新建岗位目录；
- **调整汇报线**会物理移动目录；
- **裁撤**会直接删除岗位目录并在 `.digital-employee/backup/` 留痕；
- 会话执行会生成 `.digital-employee/` 运行时审计与历史。

为避免在桌面端操作中误删或篡改 Git 跟踪的示例源码，**请在打开前将 showcase 复制到独立目录**：

```bash
mkdir -p "$HOME/roleweave-workspaces"
cp -R showcases/oss-maintainer "$HOME/roleweave-workspaces/oss-maintainer"
```

### 2. 启动与指向工作区

- **安装包启动**：在 RoleWeave 桌面端顶部选择“打开工作区”，选中 `$HOME/roleweave-workspaces/oss-maintainer` 目录（请选工作区根目录，而不是单个 `employee.json`）。
- **源码运行**：
  ```bash
  ROLEWEAVE_DEFAULT_WORKSPACE=$HOME/roleweave-workspaces/oss-maintainer npm run dev:desktop
  ```

### 3. 界面元素核验

- **左侧组织树**：`oss-maintainer` 根节点下是仓库负责人，其下挂载社区运营、问题研究员、发布工程师。
- **岗位属性与预算面板**：
  - `repo-owner`：单任务 40,000 tokens / 12 iterations，单日 400,000 tokens / 96 iterations。
  - 下属岗位：单任务 20,000 tokens / 8 iterations，单日 200,000 tokens / 64 iterations。
- **权限与上下文**：权限显示 Read / Grep / Glob，知识库连接为只读。

### 4. 发起对话与真机驱动（`@岗位`）

- 对话依赖本地 Agent Host（如 Qoder CLI 1.1.x 或 Claude Code）。
- Qoder Host 需要环境中配置 `QODER_PERSONAL_ACCESS_TOKEN`。
- 本机的引擎与模型选择会保存在各岗位的 `.workbench/agent-binding.v1.json` 中；该文件已被 git 忽略，不跨机器提交。
- 统一网盘存储：如需挂载，可配置 `MEM_URL` 或 `ORG_WORKBENCH_MEM_URL` 指向本地 `memd` 服务。

### 5. 控制面核心规则

1. **文件树即组织架构**：新建目录 = 招聘（需提供 `budget.json`）；移动目录 = 变更汇报线；删除目录 = 裁撤。
2. **Digest 校验与校准**：`organization.v1alpha1.json` 记录了每个岗位的 package digest。修改岗位文件后，若报错校验不一致，执行一次 apply 即可校准：
   ```bash
   npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
     digital-employee org apply <工作区路径> --json
   ```
3. **一键恢复示例**：如果不小心在 Git 仓库的原目录下做了测试操作，可运行恢复脚本还原：
   ```bash
   bash scripts/restore-showcase.sh
   ```

## 更新岗位包

每个岗位包应保持自包含。更新岗位时：

1. 同步更新其 `SKILL.md`、知识库、schema 和离线用例；
2. 补充正常、拒绝、冲突与边界用例；
3. 为变更的岗位执行 `validate` 和 `eval`；
4. 提交前运行完整工作区校验。

请勿在 showcase 中提交凭据、内部私有路径或未经授权的密钥信息。
