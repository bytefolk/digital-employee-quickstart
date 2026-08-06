#!/usr/bin/env bash
# 以 HTTP 接口方式提供问答服务（standalone-v1 路径）。
#
# 用法：bash scripts/serve.sh [端口]   端口默认 3000
#
# 用途：把数字员工接进你自己的系统（工单系统、内网页面、企业微信……），
# 而不是只能在钉钉里用。用的是同一份 knowledge/ 和同一个 .env。

set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

require_runtime
require_config
load_env
require_env_vars OPENAI_API_KEY

PORT="${1:-3000}"
case "$PORT" in
  ''|*[!0-9]*) die "端口必须是数字：$PORT" ;;
esac

info "启动 HTTP 服务，端口 $PORT ……"
echo
dim "  健康检查："
dim "    curl -s http://127.0.0.1:$PORT/health"
echo
dim "  提问（注意路径是 /v1/ask）："
dim "    curl -s -X POST http://127.0.0.1:$PORT/v1/ask \\"
dim "      -H 'content-type: application/json' \\"
dim "      -d '{\"message\":\"值班时间是几点到几点\"}'"
echo
warn "内置 HTTP 入口默认无状态，且会拒绝客户端自选会话标识。"
dim "  要做多轮会话或对外暴露，必须在前面加一层带鉴权的网关。"
dim "  按 Ctrl+C 停止。"
echo

cd "$RUNTIME_DIR"
exec node "$CLI" legacy serve --config ./configs/local.json --port "$PORT"
