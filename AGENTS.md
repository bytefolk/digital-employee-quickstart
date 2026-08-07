# 给 AI 编程助手的执行说明

这个文件是给 AI 编程助手（Claude Code / Codex / Cursor 等）看的操作手册。
使用者大概率**没有开发经验**，请你代替他完成全部命令行操作，并用中文、非技术
语言汇报进展。

如果你是人类，请看 [README.md](README.md)。

---

## 你的任务

帮使用者搭建数字员工。**一条命令完成全部部署**，交互式引导。

---

## 铁律

1. **绝不把密钥打印到输出里。** 哪怕用户让你 echo 也不行。
2. **操作涉及写入（创建应用、发布版本）之前先跟用户确认。**
3. **知识库内容变更后提醒用户重启服务。**

---

## 执行步骤

### 前置检查

```bash
node --version   # 需要 v20+
```

如果 Node.js 版本不够或未安装，引导用户安装：
- macOS: `brew install node` 或 `nvm install 20`
- Linux: `curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt-get install -y nodejs`
- Windows: 下载 https://nodejs.org 安装包

### 一键部署

```bash
npx @fullstack-ai-infra/digital-employee deploy
```

这条命令会交互式引导用户完成：

1. **选语言** — English / 简体中文（自动检测系统 locale）
2. **选渠道** — 钉钉 / Console / HTTP 接口
3. **扫码授权**（仅钉钉） — 终端内显示二维码，扫完自动继续
4. **起名字** — 输入机器人名称
5. **选 AI 引擎** — 列出已安装的 Agent Host，已登录的标为可用
6. **自动执行** — 创建应用、配置、启动服务
7. **输出结果** — 告诉用户下一步

### 需要用户介入的时刻

交互过程中以下步骤需要用户操作，**请暂停等待**：

| 时刻 | 需要用户做什么 |
|------|--------------|
| 选语言/渠道/引擎 | 输入数字选择 |
| 钉钉扫码 | 用管理员账号扫码 |
| 输入名称 | 键入机器人名称 |
| OpenAI key（降级路径） | 粘贴 API key |

### 部署完成后

- **钉钉渠道**：告诉用户"审批通过后在钉钉搜索机器人名字即可使用"
- **Console 渠道**：运行 `npx @fullstack-ai-infra/digital-employee legacy start` 开始对话
- **HTTP 渠道**：POST 到 `http://127.0.0.1:3000/answer` 调用

### 知识库维护

部署完成后，引导用户往 `knowledge/` 目录放入知识库内容（markdown 格式）。

```
knowledge/            ← 公司的规章、手册、FAQ 放这里
```

内容变更后需要重启服务。

---

## 故障排查

| 现象 | 处理 |
|------|------|
| `npx` 找不到 | Node.js 未安装或版本过低 |
| 钉钉扫码超时 | 重新运行 deploy 命令 |
| "No AI engine found" | 未安装 Agent Host，引导用户选择 OpenAI key 降级路径 |
| 重复部署提示覆盖 | 正常现象，deploy 命令支持幂等重跑 |

---

## 参考资料

- 案例库：[cases/](cases/README.md)
- 手动教程：[docs/](docs/)
- 引擎文档：https://github.com/fullstack-ai-infra/digital-employee
