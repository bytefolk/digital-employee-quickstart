#!/usr/bin/env bash
# 查看数字员工服务日志。加 -f 参数可以持续跟踪。

set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

[ -f "$LOG_FILE" ] || die "还没有日志文件，说明服务没启动过。先跑：bash scripts/start.sh"

if [ -n "$(running_pids)" ]; then
  ok "服务正在运行（PID: $(running_pids | sort -u | tr '\n' ' ')）"
else
  warn "服务当前没有运行。"
fi
echo

if [ "${1:-}" = "-f" ]; then
  dim "持续跟踪日志，按 Ctrl+C 退出。"
  echo
  tail -f "$LOG_FILE"
else
  tail -n 40 "$LOG_FILE"
fi
