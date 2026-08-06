#!/usr/bin/env bash
# 在命令行里直接问数字员工一个问题（不经过钉钉）。
# 用途：排查问题时先确认"知识库 + 模型"这条链路是通的。
# 每次都是新进程，所以能读到最新的配置和知识库，不受运行中的服务影响。

set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

if [ $# -eq 0 ]; then
  die "用法：bash scripts/ask.sh \"你要问的问题\""
fi

require_runtime
require_config
load_env

question="$*"

( cd "$RUNTIME_DIR" && node ./dist/apps/cli/bin.js legacy ask \
    --config ./configs/local.json \
    --question "$question" )
