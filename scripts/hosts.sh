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
dim "  not_ready  → 装了但还差条件。有两种原因，看 blocked 代码区分："
dim "                 *_version_not_conformance_verified → 版本不在认证区间"
dim "                 *_api_key_not_configured           → 密钥没配"
dim "  not_found  → 没装"
dim "  probe-only → 引擎只探测不支持运行（Codex 属于此类）"
echo
dim "各 host 需要的版本和密钥："
dim "  claude-code → Claude Code >=2.1.214 <2.2.0 ·  ANTHROPIC_API_KEY"
dim "  qoder       → Qoder CLI 1.1.x            ·  QODER_PERSONAL_ACCESS_TOKEN"
dim "  qwen-code   → Qwen Code 0.17.1           ·  OPENAI_API_KEY + OPENAI_MODEL"
dim "  codebuddy   → CodeBuddy Code 2.106.4     ·  CODEBUDDY_API_KEY + CODEBUDDY_MODEL"
echo
dim "密钥可以写进项目根目录的 .env，employee-run.sh 会自动载入。"
dim "注意 doctor 只检查密钥【有没有配】，不验证真假 —— 真伪只有真实运行才知道。"
