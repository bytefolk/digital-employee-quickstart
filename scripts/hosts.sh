#!/usr/bin/env bash
# 查看本机 Agent Host 就绪情况（Agent-native 路径专用）。
#
# Agent Host 是真正跑模型的程序（Claude Code / Qoder CLI / Qwen Code / CodeBuddy）。
# 只有 Agent-native 路径（employee 包）需要它；钉钉那条 standalone-v1 路径不需要。
#
# 这条命令只做本地探测（跑一次 `<host> --version`），不联网、不调模型、不认证。

set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

require_runtime

if [ $# -gt 0 ]; then
  run_cli doctor --engine "$1"
else
  run_cli doctor
fi

echo
dim "状态含义："
dim "  ready      → 可以用它跑 employee 包"
dim "  not_ready  → 装了但版本不在引擎认证区间内，需要升级/降级到指定版本"
dim "  not_found  → 没装"
dim "  probe-only → 引擎只探测不支持运行（Codex 属于此类）"
echo
dim "各 host 需要的密钥："
dim "  claude-code → ANTHROPIC_API_KEY"
dim "  qoder       → QODER_PERSONAL_ACCESS_TOKEN"
dim "  qwen-code   → OPENAI_API_KEY + OPENAI_MODEL"
dim "  codebuddy   → CODEBUDDY_API_KEY + CODEBUDDY_MODEL"
