# ByteFolk 开源组织案例

[English](README.md)

这是 ByteFolk 实际开源组织经过公开化处理后的数字员工工作区案例，不是虚构业务数据快照。它展示如何把一个同时维护多个开源项目的组织，映射为可寻址、可检查、可离线验证的数字员工组织。

## 组织结构

```text
ByteFolk Owner（CEO）
├── RoleWeave 项目组（1 位负责人 + 6 个职能岗位）
├── Digital Employee 项目组（1 + 3）
├── Digital Employee Platform 项目组（1 + 2）
├── Digital Employee Quickstart 项目组（1 + 2）
├── Mem 项目组（1 + 2）
├── Doc 项目组（1 + 2）
└── Design System 项目组（1 + 3）
```

合计 28 个岗位：1 位组织负责人、7 位项目负责人和 20 个职能岗位。负责人岗位为 `read_only`；职能岗位同样按 `read_only` 运行；当前固定 CLI v0.6.0 会拒绝 `Write` / `Edit`，因此本案例不宣称审批后可写。

## 公开边界

本目录只包含可公开、可移植的组织配置、岗位包、职责知识和离线契约：

- 不包含任何凭据、个人账号或本机绝对路径；
- 不包含 `.workbench/agent-binding.v1.json` 等本机 Agent Host 绑定；
- 不包含 `.digital-employee/` 运行审计、会话历史和 `work/` 工作产物；
- 不包含各项目的 Git 仓库副本；
- 离线 `eval` 只验证固定输入输出契约，不代表模型真实回答质量。

## 无凭据验证

需要 Node.js 20 或更高版本。以下命令固定使用公开版本 `@fullstack-ai-infra/digital-employee@0.6.0`，不会调用模型：

```bash
npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
  digital-employee org tree showcases/bytefolk --json

find showcases/bytefolk/positions -name employee.json -print0 | while IFS= read -r -d '' manifest; do
  package_dir="$(dirname "$manifest")"
  npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
    digital-employee validate "$package_dir" --json
  npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
    digital-employee eval "$package_dir" --json
done
```

`org tree` 应报告 28 个岗位、深度 3；每个岗位应得到 `validate: valid` 和 `eval: passed`。

`org apply` 会重写 package digest，因此只应在复制出的工作区中运行：

```bash
mkdir -p "$HOME/roleweave-workspaces"
cp -R showcases/bytefolk "$HOME/roleweave-workspaces/bytefolk"
npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
  digital-employee org apply "$HOME/roleweave-workspaces/bytefolk" --json
```

## 在 RoleWeave 中打开

请先按上面的命令复制到仓库之外，再在 RoleWeave 中选择 `$HOME/roleweave-workspaces/bytefolk`。桌面端会把工作区视为可变状态：招聘、移动、裁撤岗位或运行会话都可能修改目录，不应直接操作 Git 跟踪的原始案例。

真实对话还需要用户自行配置受支持的 Agent Host；本案例不包含凭据，也不自动部署任何渠道。
