#!/usr/bin/env bash
# 停止正在运行的数字员工服务。

set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

pids="$(running_pids | sort -u | tr '\n' ' ' | sed 's/ *$//')"

if [ -z "$pids" ]; then
  ok "服务本来就没在运行。"
  rm -f "$PID_FILE"
  exit 0
fi

info "停止进程：$pids"
# shellcheck disable=SC2086
kill $pids 2>/dev/null || true

# 这个进程没有处理 SIGTERM 做优雅下线，普通 kill 可能不退出，所以要等一下再强杀
for _ in 1 2 3 4 5; do
  sleep 1
  remaining="$(running_pids | sort -u | tr '\n' ' ' | sed 's/ *$//')"
  [ -z "$remaining" ] && break
done

remaining="$(running_pids | sort -u | tr '\n' ' ' | sed 's/ *$//')"
if [ -n "$remaining" ]; then
  warn "进程没有响应正常退出信号，强制结束：$remaining"
  # shellcheck disable=SC2086
  kill -9 $remaining 2>/dev/null || true
  sleep 1
fi

rm -f "$PID_FILE"
ok "服务已停止。"
