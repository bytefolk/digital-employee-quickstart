# 案例 05：同一个包，多个 Agent Host

> **路径**：Agent-native · **产出**：真实模型调用 · **需要模型 key**：是（Agent Host 自己的）

同一个员工包不改一行，换个 `--engine` 就能跑在不同的 Agent Host 上。

这是**唯一真正调模型**的 Agent-native 案例。案例 03、04 都是离线校验。

## 先看本机能用哪个

```bash
bash scripts/hosts.sh
```

典型输出：

```
Agent hosts:
- Claude Code: not_ready (2.1.72 (Claude Code)) [runnable]
- Qoder CLI: not_found [runnable]
- Codex CLI: probe_failed [probe-only]
- Qwen Code: not_found [runnable]
- CodeBuddy Code: not_found [runnable]
```

| 状态 | 含义 |
| --- | --- |
| `ready` | 可以用 |
| `not_ready` | 装了，但版本不在引擎认证区间内 |
| `not_found` | 没装 |
| `probe-only` | 引擎只探测、不支持运行 |

## 版本要求很严格，这是有原因的

引擎对每个 Agent Host 都锁定了**精确的版本区间**：

| Engine | 认证版本 | 需要的密钥 |
| --- | --- | --- |
| `claude-code` | `>=2.1.214 <2.2.0` | `ANTHROPIC_API_KEY` |
| `qoder` | Qoder CLI 1.1.x | `QODER_PERSONAL_ACCESS_TOKEN` |
| `qwen-code` | Qwen Code `0.17.1` | `OPENAI_API_KEY` + `OPENAI_MODEL` |
| `codebuddy` | CodeBuddy Code `2.106.4` | `CODEBUDDY_API_KEY` + `CODEBUDDY_MODEL` |

版本对不上会被直接拒绝运行，报 `*_version_not_conformance_verified`。

**为什么这么严**：员工包声明了 `"mode": "read_only"`、`"network": "deny"` 这类策略，
适配层要把它翻译成宿主的实际约束。宿主版本一变，可用的工具集和禁用方式可能就变了，
默认拒绝的边界就守不住。所以引擎宁可拒绝运行，也不在没验证过的版本上假装安全。

**Codex 为什么被排除**：Codex CLI 0.146.0 无法可靠移除全部模型可见的内建工具
（尤其是 `apply_patch`），满足不了 default-deny 的工具契约，因此只做探测不支持运行。

## 怎么跑

先确认某个 host 是 `ready`，然后：

```bash
bash scripts/employee-run.sh team-qa claude-code "What is the approved support channel?"
```

换一个 host，其他都不用改：

```bash
bash scripts/employee-run.sh team-qa qoder "What is the approved support channel?"
```

## 跑之前先做兼容性预检

不用真的调模型就能知道某个 host 行不行：

```bash
bash scripts/employee-check.sh team-qa claude-code
```

这会在静态校验之外多做一次宿主兼容性判断。注意区分两类失败：

- **包本身有问题** → 得改 `SKILL.md` / `schemas/` / `evals/`
- **包没问题，宿主不满足** → 包是好的，只是这台机器跑不了

脚本会把这两类分开报，不会让你误以为是包写错了。

## 没有可用 host 时会怎样

会干净地失败，并告诉你具体卡在哪：

```
digital-employee: agent_host_incompatible
- blocked: claude_version_not_conformance_verified
- blocked: host_not_ready
```

**这不影响案例 03、04**——那两个是纯离线的，没有任何 host 也能跑完整流程。

## 这个案例的实际意义

- **换模型不用改员工**：包是可移植的，宿主是可替换的。
- **交付前验兼容性**：把包交给别人之前，先确认他的宿主环境能跑。
- **CI 里跑离线部分**：`validate` + `eval` 不需要 host，可以无条件进流水线；
  真实运行留给有 host 的环境。
