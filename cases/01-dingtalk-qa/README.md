# 案例 01：钉钉答疑机器人

> **路径**：standalone-v1 · **产出**：钉钉里能对话的常驻机器人 · **需要模型 key**：是

同事在钉钉里搜到机器人、直接提问，它只根据你批准过的资料回答并附上出处；
资料里没有的，它会转人工而不是编造。

这是本项目的**主案例**，也是唯一能产出"活机器人"的路径。

## 为什么是 standalone-v1 而不是 recipe

钉钉 Stream 长连接属于 standalone-v1 的渠道层。Agent-native 的 `run` 命令是一次性调用，
没有 `--channel` 参数，**做不出常驻机器人**。详见[案例库首页的路径对比](../README.md)。

`legacy start` 是 standalone-v1 的**权威用法**——被引擎标记为 deprecated 的是顶层别名
（`npm start` / `npm run ask`），不是 `legacy` 命名空间本身。

## 前置条件

| 需要 | 说明 |
| --- | --- |
| 钉钉**管理员**账号 | 普通成员通常没有创建应用的权限 |
| 一个 OpenAI 兼容的模型 key | 官方 OpenAI 或任何兼容服务都行 |
| Node.js 20+、git、dws CLI | `bash scripts/check-env.sh` 会逐项检查 |

**不需要**装 Claude Code 等 Agent Host。

## 怎么做

完整分步教程见 [docs/02-创建钉钉机器人.md](../../docs/02-创建钉钉机器人.md) 和
[docs/03-启动数字员工.md](../../docs/03-启动数字员工.md)。命令速览：

```bash
bash scripts/check-env.sh
```

```bash
dws auth login --device
```

```bash
bash scripts/setup-dingtalk.sh "数字员工-答疑助手"
```

```bash
bash scripts/publish-app.sh
```

```bash
bash scripts/setup-runtime.sh && bash scripts/make-config.sh
```

```bash
bash scripts/start.sh
```

## 验证

先脱开钉钉，直接在命令行测问答链路：

```bash
bash scripts/ask.sh "值班时间是几点到几点"
```

答对且末尾有 `Sources:` 就说明知识库和模型都通了。再去钉钉里搜机器人名字对话。

## 这个案例特有的坑

**机器人搜不到，八成是版本审批没过。** 应用创建后必须发布，而发布要走审批流程；
审批通过前机器人在钉钉里完全不可见，但后台长连接是正常的（日志有 `connect success`）。
这不是配错了。

```bash
bash scripts/app-status.sh
```

**改完资料必须重启。** 知识库和配置都是进程启动时一次性读入内存的：

```bash
bash scripts/start.sh
```

其余问题见 [docs/05-常见问题.md](../../docs/05-常见问题.md)。
