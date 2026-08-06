#!/usr/bin/env bash
# 启动数字员工服务（钉钉 Stream 长连接）。
# 会自动停掉已有进程，所以改完配置或知识库之后直接跑这个就是"重启"。

set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

require_runtime
require_config
load_env
require_env_vars DINGTALK_CLIENT_ID DINGTALK_CLIENT_SECRET OPENAI_API_KEY

# 先停掉旧进程 —— 配置和知识库都是启动时一次性读入内存的，不重启不生效
if [ -n "$(running_pids)" ]; then
  info "检测到服务正在运行，先停掉旧进程……"
  bash "$PROJECT_ROOT/scripts/stop.sh"
  # 钉钉服务端清理上一条长连接需要几秒，太快重连会报 connect timed out
  info "等待钉钉服务端释放上一条连接（5 秒）……"
  sleep 5
fi

info "启动服务……"
: > "$LOG_FILE"
(
  cd "$RUNTIME_DIR"
  nohup node ./dist/apps/cli/bin.js legacy start \
    --config ./configs/local.json \
    --channel dingtalk \
    >> "$LOG_FILE" 2>&1 &
  echo $! > "$PID_FILE"
)

# 等待长连接建立，最多 40 秒
connected=0
for i in $(seq 1 40); do
  sleep 1
  if grep -q "connect success" "$LOG_FILE" 2>/dev/null; then
    connected=1
    break
  fi
  if grep -qiE "timed out|error|failed" "$LOG_FILE" 2>/dev/null; then
    break
  fi
  # 进程死了就不用等了
  if [ -z "$(running_pids)" ] && [ "$i" -gt 5 ]; then
    break
  fi
done

echo
if [ "$connected" -eq 1 ]; then
  ok "服务已启动，钉钉长连接建立成功。"
  dim "  日志：$LOG_FILE（用 bash scripts/logs.sh 查看）"
  echo
  info "现在可以在钉钉里搜索机器人名字开始对话。"
  dim "  如果搜不到，大概率是应用版本还没通过发布审批 —— 见 docs/05-常见问题.md"
else
  err "长连接没有建立成功，最后几行日志："
  echo
  tail -n 15 "$LOG_FILE" 2>/dev/null | sed 's/^/    /'
  echo
  if grep -qi "timed out" "$LOG_FILE" 2>/dev/null; then
    warn "看到连接超时 —— 通常是上一条连接还没释放。等 10 秒再跑一次本脚本即可。"
  else
    warn "排查建议见 docs/05-常见问题.md"
  fi
  exit 1
fi
