#!/usr/bin/env bash
# 用官方 recipe 生成一个可移植员工包（Agent-native 路径）。
#
# 用法：bash scripts/employee-new.sh <名字> [recipe]
#   recipe 可选 minimal-answer.v1（默认）或 structured-action.v1
#
# 生成的包放在 employees/<名字>/，包含 employee.json、SKILL.md、
# schemas/、knowledge/、evals/ —— 这就是引擎的 employee-package.v1alpha1 规范。

set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

require_runtime

NAME="${1:-}"
RECIPE="${2:-minimal-answer.v1}"

if [ -z "$NAME" ]; then
  err "用法：bash scripts/employee-new.sh <名字> [recipe]"
  echo
  dim "可用 recipe："
  dim "  minimal-answer.v1     只读问答，答案带出处（默认）"
  dim "  structured-action.v1  产出结构化动作提案，只提案不执行"
  exit 1
fi

# 提前拦掉拼错的 recipe，避免让使用者去看引擎的报错
case " $RECIPES " in
  *" $RECIPE "*) ;;
  *) die "不认识的 recipe：$RECIPE（只支持：$RECIPES）" ;;
esac

TARGET="$(resolve_employee_dir "$NAME")"
[ -e "$TARGET" ] && die "目标已存在：$TARGET（换个名字，或先删掉它）"

mkdir -p "$EMPLOYEES_DIR"

AUTHOR="${EMPLOYEE_AUTHOR:-$(git config user.name 2>/dev/null || echo your-team)}"

info "用 $RECIPE 生成员工包……"
run_cli init "$TARGET" --recipe "$RECIPE" --author "$AUTHOR"

echo
ok "已生成：$TARGET"
echo
dim "包里各文件的作用："
dim "  employee.json  身份、宿主协议、权限策略（只读/网络/文件范围）"
dim "  SKILL.md       给 Agent Host 的行为说明书，这是你主要要改的文件"
dim "  schemas/       输入输出的 JSON Schema，约束回答格式"
dim "  knowledge/     这个员工能读的资料"
dim "  evals/         离线验收用例，改完用 employee-check.sh 验证"
echo
info "下一步：bash scripts/employee-check.sh $NAME"
