# 给 AI 编程助手的执行说明

这个文件是给 AI 编程助手（Claude Code / Codex / Cursor 等）看的操作手册。
使用者大概率**没有开发经验**，请你代替他完成全部命令行操作，并用中文、非技术
语言汇报进展。

如果你是人类，请看 [README.md](README.md)。

---

## 你的任务

帮使用者搭建一个能在钉钉里对话的「数字员工」问答机器人。完整链路是：

```
钉钉用户提问 → 钉钉 Stream 长连接 → Digital Employee 运行时
            → 检索本地知识库 → 调用大模型生成答案 → 带引用回复钉钉
```

## 铁律（务必遵守）

1. **一次只做一步，做完汇报。** 使用者看不懂报错，你要把结果翻译成人话。
2. **凡是"写"操作，先说清后果再执行。** 创建钉钉应用、发布版本、删除文件都属于
   写操作。创建应用这类动作会在使用者的**真实企业**里留下记录，必须先取得同意。
3. **绝不把密钥打印到对话里。** AppSecret、API Key 一律直接写进 `.env` 文件，
   需要展示时只显示前 4 位 + 后 4 位。
4. **不要替使用者决定审批人。** 版本发布需要选审批人时，把候选名单原样列出来问他。
5. **不要自己扫描企业数据。** 需要读钉钉文档/群聊时，让使用者明确指定要读哪一个。
6. **每次改完配置或知识库，必须重启服务进程**，否则改动不生效（详见步骤 6）。

---

## 先跑这个：判断从哪一步开始

```bash
bash scripts/doctor.sh
```

它会输出 6 项检查和「下一步该做什么」。**如果使用者是接着上次继续做的，直接从
它指出的那一步开始，不要从头重来**（尤其不要重复创建钉钉应用）。

## 步骤 0：环境检查

```bash
bash scripts/check-env.sh
```

它会检查 Node.js（需 ≥ 20）、git、dws CLI。缺什么就按脚本提示装什么：

- Node.js 缺失 → 引导使用者装 Node.js 20 LTS（推荐 nvm 或官网安装包）。
- dws CLI 缺失 → 见 [DingTalk Workspace CLI](https://github.com/DingTalk-Real-AI/dingtalk-workspace-cli) 的安装说明。

## 步骤 1：登录钉钉

```bash
dws profile list
```

如果 `profiles` 是空数组，需要登录。**在服务器 / 容器 / SSH 环境必须用设备码模式**：

```bash
dws auth login --device
```

这条命令会等待授权、最长 15 分钟，**会阻塞很久**，所以要放到后台跑并轮询输出
文件，不要让它占满你的超时。它会打印一个链接和一个授权码，把这两样**原样**发给
使用者，让他用**企业管理员的钉钉账号**打开链接、输入授权码完成授权。

授权成功后再次 `dws profile list` 确认，记下 `corpId:userId`（后面 DWS 数据源要用）。

> 提示：普通成员账号可能没有创建应用的权限。如果后续创建应用报权限错误，
> 让使用者找企业 IT / 管理员操作。

## 步骤 2：创建钉钉应用和机器人

先问使用者要给机器人起什么名字，然后：

```bash
# 2.1 创建企业内部应用（写操作，需先获得同意）
dws dev app create --name "<机器人名字>" --desc "<一句话描述>" --yes

# 记下返回的 appKey 和 unifiedAppId
```

```bash
# 2.2 读取 appSecret —— 注意：重定向到文件，不要打印到终端
dws dev app credentials get --unified-app-id <unifiedAppId> --format json > /tmp/creds.json
```

然后用 Node 从 `/tmp/creds.json` 里读出 `appKey` / `appSecret`，写进项目根目录的
`.env` 文件（格式见 [.env.example](.env.example)），最后删掉 `/tmp/creds.json`。

```bash
# 2.3 把机器人配成 Stream 模式
dws dev app robot config \
  --unified-app-id <unifiedAppId> \
  --name "<机器人名字>" \
  --brief "<一句话简介>" \
  --mode STREAM \
  --add-scope \
  --yes
```

看到 `"robotStatus": "ONLINE"` 就成功了。

> **坑**：不要先跑 `dws dev app robot enable`，机器人还不存在时它会报
> `机器人不存在，请先创建机器人`。必须先 `robot config` 创建，enable 是给已有
> 机器人用的。

## 步骤 3：提交版本发布审批

机器人**不发布是搜不到的**（详见步骤 7 的排查表）。

```bash
# 3.1 创建版本
dws dev app version create --unified-app-id <unifiedAppId> --desc "初始版本" --yes
# 记下 versionId

# 3.2 看需不需要审批、有哪些候选审批人
dws dev app version check-approval --unified-app-id <unifiedAppId> --version-id <versionId>
```

如果返回 `approvalMode: SELECT_APPROVER`，**把 `approvalPromptText` 的完整内容
原样展示给使用者**，让他选一位。不要自己挑，也不要默认取第一个。

```bash
# 3.3 用他选的人提交
dws dev app version publish \
  --unified-app-id <unifiedAppId> \
  --version-id <versionId> \
  --approver-user-id <他选的 userId> \
  --yes
```

`versionStatus` 变成 `AUDIT` 表示已提交，接下来要等审批人在钉钉里点通过。
告诉使用者：**这一步卡在别人手上，你需要去催审批**。

## 步骤 4：装好运行时

```bash
bash scripts/setup-runtime.sh
```

它会把 `digital-employee` 仓库克隆到 `runtime/` 并安装依赖。

> **坑**：一定要跑完整的 `npm install`（含开发依赖）。如果只装了生产依赖，
> 构建时会报 `sh: 1: tsc: not found`。

## 步骤 5：生成配置

问使用者两件事：

1. **用哪个大模型？** 需要 `baseUrl`、模型名、API Key。可以是 OpenAI 官方，也可以
   是任何兼容 OpenAI Chat Completions 协议的服务（自建网关、第三方中转等）。
2. **知识库放哪些内容？** 默认用本项目的 `knowledge/` 目录。

然后：

```bash
bash scripts/make-config.sh
```

它会用 [templates/config.template.json](templates/config.template.json) 生成
`runtime/configs/local.json`，并把 `knowledge/` 目录挂成数据源。

**API Key 只写进 `.env`，配置文件里只出现环境变量名**（`apiKeyEnv` 字段），
永远不要把 key 明文写进 json。

## 步骤 6：启动 / 重启

```bash
bash scripts/start.sh      # 启动（会自动停掉旧进程）
bash scripts/logs.sh       # 看日志
bash scripts/stop.sh       # 停止
```

日志里出现 `connect success` 表示长连接建好了。

**必须重启的场景**（这是最容易踩的坑）：

- 改了 `runtime/configs/local.json`
- 改了 `knowledge/` 里的任何知识文件
- 换了 `.env` 里的 key

配置和知识库都是**进程启动时一次性读进内存**的，不会热更新。改完不重启，机器人
行为完全不变。

> **坑**：重启太快会遇到 `DingTalk Stream connect timed out after 20000ms`，
> 因为上一条连接在钉钉服务端还没清理完。`scripts/start.sh` 已经内置了等待，
> 如果手动操作，`kill` 之后等 5 秒再启动。另外这个进程没做 `SIGTERM` 优雅下线，
> 普通 `kill` 之后观察几秒还在的话，用 `kill -9`。

## 步骤 7：验证

**先用命令行验证问答能力**（不走钉钉，能立刻排除掉一半的问题）：

```bash
bash scripts/ask.sh "你的问题"
```

回答正确、并且末尾有 `Sources:` 引用，说明知识库和模型都通了。

再让使用者去钉钉里搜机器人名字对话。如果搜不到或行为不对，按下表排查：

| 现象 | 原因 | 怎么办 |
| --- | --- | --- |
| 钉钉里搜不到机器人 | 版本还在 `AUDIT`，没发布 | 催审批人通过；用 `dws dev app version status` 查状态 |
| 只有创建者能看到 | 可见范围里只有创建者 | `dws dev app member add` 加人 |
| 命令行答得对，钉钉答得不对 | 钉钉进程用的是旧配置 | `bash scripts/start.sh` 重启 |
| 一直回答固定的英文句子 | 没检索到证据，命中了转人工提示 | 这句话是配置里的固定文本，不是模型生成的。补知识库内容后重启 |
| 报 `tsc: not found` | 开发依赖没装全 | 进 `runtime/` 跑 `npm install` |
| 报 `connect timed out` | 重启太快 | 等 5 秒重试 |
| 答"没找到依据"但资料里明明有 | 检索是关键词匹配，问句里的额外字词稀释了匹配度 | 在知识库标题里补上使用者的原话问法，用 `/` 分隔多种说法 |

最后一条实测过：标题只写 `## 值班时间` 时，问"值班时间是几点到几点"会答不出来；
改成 `## 值班时间是几点到几点 / 值班时间 / 什么时候有人` 就能答对。**帮使用者
沉淀知识时，一定要把他原本的问法写进标题。**

## 步骤 8：沉淀知识

这是数字员工能越用越准的关键。每次回答完新问题，把问答对追加到
`knowledge/` 目录下的 markdown 文件里，然后重启。

写作要求见 [docs/04-沉淀知识库.md](docs/04-沉淀知识库.md)。核心是：**用使用者
真实提问的说法当标题**，这样检索才命中得准。

---

## 参考：能挂哪些数据源

`runtime/configs/local.json` 的 `sources` 数组支持三种类型：

| 类型 | 用途 | 关键字段 |
| --- | --- | --- |
| `filesystem` | 本地目录下的 `.md/.mdx/.txt/.json` | `root`、`include` |
| `git` | 公开 HTTPS 仓库（浅克隆后按本地文件处理） | `remote`（不能带账号密码）、`ref`、`subdirectory` |
| `dws` | 钉钉文档 / AI 听记 / 群聊 / 知识库 / 钉盘 | `profile`、`approvedQueries` |

`dws` 类型没有"自动发现"，必须逐条列出要读什么。要加的时候先问使用者具体是哪个
文档节点或哪个群，不要自己去搜。
