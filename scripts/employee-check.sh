#!/usr/bin/env bash
# 校验员工包：静态结构检查 + 离线验收用例（Agent-native 路径）。
#
# 用法：bash scripts/employee-check.sh <名字> [agent-host]
#
# 两步都【完全离线】：不调模型、不连 Agent Host、不访问网络。
# 所以没装任何 Agent Host 也能跑，很适合放进 CI。
# 传第二个参数才会额外做宿主兼容性检查（仍然只是本地探测版本号）。

set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

require_runtime

NAME="${1:-}"
HOST="${2:-}"
[ -n "$NAME" ] || die "用法：bash scripts/employee-check.sh <名字> [agent-host]"

TARGET="$(resolve_employee_dir "$NAME")"
[ -d "$TARGET" ] || die "找不到员工包：$TARGET"

# 分开记录两类失败：包本身的问题 vs 宿主环境的问题。
# 混在一起报会误导人 —— 宿主不兼容不代表包写错了。
package_failed=0
host_failed=0

info "1/2 静态包校验……"
if [ -n "$HOST" ]; then
  run_cli validate "$TARGET" --engine "$HOST" || host_failed=1
else
  run_cli validate "$TARGET" || package_failed=1
fi

echo
info "2/2 离线验收用例……"
run_cli eval "$TARGET" || package_failed=1

echo
if [ "$package_failed" -eq 0 ] && [ "$host_failed" -eq 0 ]; then
  ok "全部通过。"
  [ -z "$HOST" ] && dim "  想顺带检查某个 Agent Host 是否兼容：bash scripts/employee-check.sh $NAME claude-code"
  exit 0
fi

if [ "$package_failed" -ne 0 ]; then
  err "员工包本身有问题。"
  dim "  常见原因：SKILL.md 改动后与 schemas/ 不一致，"
  dim "  或 evals/cases.json 里的期望输出不满足 output.schema.json。"
fi

if [ "$host_failed" -ne 0 ]; then
  warn "包是好的，但本机的 $HOST 不满足运行条件。"
  dim "  这【不影响】包的正确性 —— 离线校验和验收用例仍然可以照常跑。"
  dim "  只有真正要用 employee-run.sh 调模型时才需要处理它。"
  dim "  查详情：bash scripts/hosts.sh $HOST"
fi

exit 1
