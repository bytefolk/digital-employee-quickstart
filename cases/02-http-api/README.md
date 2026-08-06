# 案例 02：HTTP 接口

> **路径**：standalone-v1 · **产出**：本地 HTTP 服务 · **需要模型 key**：是

把数字员工接进**你自己的系统**——工单系统、内网页面、企业微信、飞书，或任何能发
HTTP 请求的地方，而不局限在钉钉里。

和案例 01 用的是**同一份 `knowledge/` 和同一个 `.env`**，只是换了个入口。

## 前置条件

| 需要 | 说明 |
| --- | --- |
| 一个 OpenAI 兼容的模型 key | 填在 `.env` 的 `OPENAI_API_KEY` |
| 已跑过 `make-config.sh` | 生成 `runtime/configs/local.json` |

**不需要**钉钉账号，也**不需要** Agent Host。如果你只想要个接口、不要钉钉机器人，
可以跳过案例 01 的全部钉钉步骤。

## 怎么做

```bash
bash scripts/setup-runtime.sh && bash scripts/make-config.sh
```

```bash
bash scripts/serve.sh 3000
```

另开一个终端。先确认服务活着：

```bash
curl -s http://127.0.0.1:3000/health
```

```json
{"status":"ok","employee":"team-answer","documents":1}
```

`documents` 是加载到的知识片段数量，**如果是 0，说明知识库没读到**。

然后提问（注意路径是 `/v1/ask`，不是 `/ask`）：

```bash
curl -s -X POST http://127.0.0.1:3000/v1/ask -H 'content-type: application/json' -d '{"message":"值班时间是几点到几点"}'
```

实际返回：

```json
{
  "ok": true,
  "status": "answered",
  "requestId": "1900a0f2-...",
  "sessionId": "http-1900a0f2-...",
  "answer": "工作日09:00到18:00",
  "confidence": 1,
  "citations": [
    {
      "label": "团队手册（示例，请替换成你们自己的内容）",
      "uri": "source://team-knowledge/示例-团队手册.md",
      "sourceType": "filesystem",
      "sourceUpdatedAt": "2026-08-06T01:59:39.776Z"
    }
  ],
  "escalation": null,
  "error": null
}
```

接入你自己的系统时，重点看这几个字段：

| 字段 | 用途 |
| --- | --- |
| `status` | `answered` 表示答出来了；证据不足时会是转人工状态 |
| `answer` | 答案正文 |
| `citations` | 出处，建议在界面上展示出来供用户核对 |
| `escalation` | 非 `null` 表示需要转人工，你的系统应该据此走人工流程 |

## 安全边界（对外暴露前必读）

引擎内置的 HTTP 入口是**刻意做得很克制**的，不是拿来直接对公网的：

- **默认无状态**，不保留多轮会话。
- **拒绝客户端自选 `requestId` / `actorId` / `sessionId`**。这是防止多个调用方共用
  一个 Bearer Token 时，A 能通过伪造会话标识读到 B 的历史。
- 要做多轮会话或对外服务，**必须在它前面加一层按用户鉴权的网关**，由网关来管会话归属。

换句话说：把它当成一个内网的、无状态的问答函数，不要当成完整的对话服务。

## 和案例 01 的关系

两者可以**同时跑**，共用知识库：

```
knowledge/  ──┬──> scripts/start.sh   → 钉钉机器人（案例 01）
              └──> scripts/serve.sh   → HTTP 接口（案例 02）
```

注意两者是独立进程，**各自都要重启**才能吃到新的知识库内容。
