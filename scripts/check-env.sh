#!/usr/bin/env bash
# 检查搭建数字员工所需的环境。只读，不会改动任何东西。

set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

problems=0

echo "检查运行环境……"
echo

# --- Node.js ---
if command -v node >/dev/null 2>&1; then
  node_version="$(node -v)"
  major="$(printf '%s' "$node_version" | sed -E 's/^v([0-9]+)\..*/\1/')"
  if [ "$major" -ge 20 ] 2>/dev/null; then
    ok "Node.js $node_version"
  else
    err "Node.js 版本太低：$node_version（需要 20 或更高）"
    dim "  升级方式：https://nodejs.org/ 下载 20 LTS，或用 nvm install 20"
    problems=$((problems + 1))
  fi
else
  err "没装 Node.js（需要 20 或更高）"
  dim "  安装方式：https://nodejs.org/ 下载 20 LTS 安装包"
  problems=$((problems + 1))
fi

# --- git ---
if command -v git >/dev/null 2>&1; then
  ok "git $(git --version | awk '{print $3}')"
else
  err "没装 git"
  dim "  安装方式：https://git-scm.com/downloads"
  problems=$((problems + 1))
fi

# --- dws CLI ---
if command -v dws >/dev/null 2>&1; then
  ok "dws $(dws --version 2>/dev/null | head -1 | awk '{print $3}')"
else
  err "没装 dws（钉钉工作空间命令行工具，用来创建钉钉应用）"
  dim "  安装方式见：https://github.com/DingTalk-Real-AI/dingtalk-workspace-cli"
  problems=$((problems + 1))
fi

echo

# --- 钉钉登录状态 ---
if command -v dws >/dev/null 2>&1; then
  profile_output="$(dws profile list --format json 2>/dev/null || echo '{}')"
  current_profile="$(
    printf '%s' "$profile_output" | node -e '
      let raw = "";
      process.stdin.on("data", (c) => (raw += c));
      process.stdin.on("end", () => {
        try {
          const data = JSON.parse(raw);
          process.stdout.write(data?.currentProfile || "");
        } catch { /* 无输出即未登录 */ }
      });
    ' 2>/dev/null || true
  )"
  if [ -n "$current_profile" ]; then
    ok "钉钉已登录：$current_profile"
  else
    warn "钉钉还没登录 —— 下一步需要跑：dws auth login --device"
    dim "  （服务器 / 容器 / SSH 环境必须加 --device，否则回调地址访问不到）"
  fi
fi

# --- 本项目状态 ---
if [ -f "$ENV_FILE" ]; then ok "已有 .env 文件"; else
  warn "还没有 .env 文件 —— 需要复制：cp .env.example .env"
fi

if runtime_installed; then ok "引擎已安装（runtime/）"; else
  warn "引擎还没装 —— 需要跑：bash scripts/setup-runtime.sh"
fi

if [ -f "$CONFIG_FILE" ]; then ok "已有配置文件"; else
  warn "还没生成配置 —— 需要跑：bash scripts/make-config.sh"
fi

echo
if [ "$problems" -gt 0 ]; then
  die "有 $problems 项必需的软件没装好，先按上面的提示安装。"
fi
ok "基础软件都齐了。"
