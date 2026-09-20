# bytefolk 工作台目录契约与招聘 SOP

本文位于 `context/`，处于所有 worker 岗位的引擎读闸门范围内（worker 派生 scope = 自己的 positions 子树 + `./context/`），全员必读。

## 目录契约

工作台根目录即所有岗位的运行 cwd。

| 目录 | 用途 | 岗位权限 |
| --- | --- | --- |
| `positions/` | 组织架构：岗位定义包（SKILL.md、budget、schemas），employee.json 有 sha256 封印 | 任何岗位不得写入 |
| `context/` | 全员共享上下文（本文件所在处） | worker 可读 |
| `repos/` | 托管的开源仓库（git） | 仅被明确指派的仓库可改，改动走 git 可追溯 |
| `work/` | 员工工作区树 | 每岗位只写 `work/<自己的岗位id>/` |

## 领地声明（hire 时写入新岗位 SKILL.md 的固定段落）

> 你的专属工作目录是 `work/<你的岗位id>/`，一切产出放这里。`positions/` 为封印岗位包，禁止写入。`repos/` 下仅可修改被明确指派的仓库，且改动必须留在 git 分支上。不要读写其他岗位的 `work/` 目录。

## 招聘 SOP

创建新岗位时，除岗位包本身外必须同时完成：

1. 建 `work/<岗位id>/` 领地目录；
2. 将上方领地声明写入其 SKILL.md；
3. 权限最小化：`toolAllow` 默认 `Read/Grep/Glob`；需要落盘产出再加 `Edit/Write`；**默认不给 `Bash`**——无 shell 才能保证领地约定不可被 shell 命令绕过；
4. `memoryScope` 记账为 `./work/<岗位id>/`（当前引擎版本的路径闸门为固定派生，不读此字段；保留作身份与规划标识）；
5. 预算按任务体量设定 `perTask` / `perDay`，默认从紧。

## 约束边界（诚实声明）

- 引擎在 turn 启动前强制：岗位存在性、上下文读取路径（worker = 自己 positions 子树 + context/）、工具白名单（写默认拒绝）。
- agent host 运行时以 `--permission-mode dont_ask` + 工具白名单启动，无交互审批旁路。
- 引擎没有按岗位的文件系统沙箱；`work/<id>/` 领地 = SKILL.md 约定 + 禁 Bash 的组合约束，不是内核级隔离。
