# 案例库

每个案例对应一个真实场景，说清楚**它走哪条路径、需要什么前置条件、能得到什么**。

先看下面这张图选对路径，再进具体案例——**选错路径是这个项目最容易踩的坑**。

---

## 引擎有两条路径，它们不能混用

Digital Employee 引擎内部是两套独立架构，各自能做的事完全不同：

|  | **standalone-v1**（兼容路径） | **Agent-native**（包路径） |
| --- | --- | --- |
| 配置单元 | `configs/*.json` + `profiles/answer-agent` | `employee.json` + `SKILL.md` + `schemas/` |
| 谁来跑模型 | 引擎内置的检索 + 模型循环 | 外部 Agent Host（Claude Code / Qoder / …） |
| **常驻服务** | ✅ 钉钉、HTTP、Console | ❌ 没有 |
| **一次性调用** | ✅ `legacy ask` | ✅ `run` |
| 要什么密钥 | 一个 OpenAI 兼容的 key | Agent Host 自己的 key |
| 命令 | `legacy ask/start/serve/sync` | `init/validate/eval/run/doctor` |

**最关键的一条**：`run` 命令**没有 `--channel` 参数**。Agent-native 路径不提供任何常驻渠道，所以**"用 recipe 做一个钉钉机器人"在当前引擎上做不到**——钉钉只能走 standalone-v1。

反过来，standalone-v1 也不用 `employee.json` 那套包规范，它用的是 `profiles/answer-agent`。

> 这不是缺陷，是分层：Agent-native 把"模型和工具循环"交给外部 Agent Host，
> 框架只管包规范、策略、校验和执行边界。渠道属于 standalone-v1 的职责。

## 案例清单

### standalone-v1 路径 —— 要的是"活的机器人"

| 案例 | 场景 | 前置条件 |
| --- | --- | --- |
| [01 钉钉问答](01-dingtalk-qa/) | 同事在钉钉里 @ 机器人提问 | 钉钉管理员账号 + 模型 key |
| [02 HTTP 接口](02-http-api/) | 接进工单系统、内网页面、其他 IM | 模型 key |

### Agent-native 路径 —— 要的是"可移植、可验收的员工包"

| 案例 | 场景 | 前置条件 |
| --- | --- | --- |
| [03 最小问答包](03-minimal-answer/) | 做一个能交付给别人的标准员工包 | **无**（全离线） |
| [04 结构化提案](04-structured-action/) | 让员工产出可审批的动作提案，只提案不执行 | **无**（全离线） |
| [05 多宿主运行](05-multi-host/) | 同一个包在不同 Agent Host 上跑 | 指定版本的 Agent Host + 其 key |

**案例 03 和 04 不需要任何模型密钥、不需要装 Agent Host**——`validate` 和 `eval` 是完全离线的静态校验，这也是它们适合放进 CI 的原因。只有案例 05 真正调模型。

## 该从哪个开始

- **想让同事今天就能用上** → [01 钉钉问答](01-dingtalk-qa/)
- **想接进自己的系统** → [02 HTTP 接口](02-http-api/)
- **想理解引擎的包规范** → [03 最小问答包](03-minimal-answer/)
- **想做审批类场景** → [04 结构化提案](04-structured-action/)
- **想换 Agent Host 或做兼容性验证** → [05 多宿主运行](05-multi-host/)
