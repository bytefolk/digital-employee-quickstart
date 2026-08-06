#!/usr/bin/env bash
# 在 Agent Host 上真实跑一次员工包（Agent-native 路径）。
#
# 用法：bash scripts/employee-run.sh <名字> <agent-host> "你的问题"
#
# 【这一步会真的调模型】，需要：
#   1. 本机装了指定版本区间内的 Agent Host（用 scripts/hosts.sh 查）
#   2. 该 Agent Host 自己的 API Key 已配好
#
# 注意：这是一次性调用，输入进、结果出。它【不提供】钉钉/HTTP 常驻服务 ——
# 那条路径是 standalone-v1，见 cases/01-dingtalk-qa 和 cases/02-http-api。

set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

require_runtime

NAME="${1:-}"
HOST="${2:-}"
shift 2 2>/dev/null || true
QUESTION="${*:-}"

if [ -z "$NAME" ] || [ -z "$HOST" ] || [ -z "$QUESTION" ]; then
  err '用法：bash scripts/employee-run.sh <名字> <agent-host> "你的问题"'
  dim "  可运行的 host：$RUNNABLE_HOSTS"
  dim "  （codex 是 probe-only，不能用来运行）"
  exit 1
fi

case " $RUNNABLE_HOSTS " in
  *" $HOST "*) ;;
  *) die "不支持的 host：$HOST（可运行的只有：$RUNNABLE_HOSTS）" ;;
esac

TARGET="$(resolve_employee_dir "$NAME")"
[ -d "$TARGET" ] || die "找不到员工包：$TARGET"

# .env 里可能放着 Agent Host 需要的密钥
[ -f "$ENV_FILE" ] && load_env

info "在 $HOST 上运行 $NAME……"
echo

set +e
run_cli run "$TARGET" --engine "$HOST" --question "$QUESTION"
status=$?
set -e

if [ "$status" -ne 0 ]; then
  echo
  err "运行失败（退出码 $status）"
  dim "  先跑 bash scripts/hosts.sh $HOST 看这个 host 是不是 ready。"
  dim "  常见 blocked 代码："
  dim "    host_not_ready                        → 没装，或版本不在认证区间"
  dim "    *_version_not_conformance_verified    → 版本号不匹配，需要装引擎指定的版本"
  dim "    agent_host_incompatible               → 包声明的能力这个 host 给不了"
  exit "$status"
fi
