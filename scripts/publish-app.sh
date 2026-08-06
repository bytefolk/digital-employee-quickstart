#!/usr/bin/env bash
# 提交钉钉应用版本发布审批。机器人在审批通过前是搜不到的。
#
# 不带参数运行：创建版本 + 列出候选审批人（只读，不提交）
# 带 userId 运行：用指定审批人提交审批
#   bash scripts/publish-app.sh <审批人userId>

set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

command -v dws >/dev/null 2>&1 || die "没装 dws，先跑 bash scripts/check-env.sh"

APP_INFO="$PROJECT_ROOT/.dingtalk-app.json"
[ -f "$APP_INFO" ] || die "找不到 $APP_INFO，请先跑：bash scripts/setup-dingtalk.sh \"机器人名字\""

UNIFIED_APP_ID="$(json_field "$APP_INFO" unifiedAppId)"
ROBOT_NAME="$(json_field "$APP_INFO" robotName)"
APPROVER_USER_ID="${1:-}"

VERSION_STATE="$PROJECT_ROOT/.dingtalk-version.json"

# --- 复用已有版本，或创建新版本 ---
if [ -f "$VERSION_STATE" ]; then
  VERSION_ID="$(json_field "$VERSION_STATE" versionId 2>/dev/null || echo "")"
fi

if [ -z "${VERSION_ID:-}" ]; then
  info "创建应用版本……"
  TMP_JSON="$(mktemp)"
  trap 'rm -f "$TMP_JSON"' EXIT
  dws dev app version create \
    --unified-app-id "$UNIFIED_APP_ID" \
    --desc "初始版本：开启 Stream 机器人能力" \
    --yes --format json > "$TMP_JSON"
  VERSION_ID="$(json_field "$TMP_JSON" versionId)"
  VERSION_NO="$(json_field "$TMP_JSON" version 2>/dev/null || echo "")"
  [ -n "$VERSION_ID" ] || die "创建版本失败。"
  cat > "$VERSION_STATE" <<EOF
{
  "versionId": "$VERSION_ID",
  "version": "$VERSION_NO"
}
EOF
  ok "版本已创建：${VERSION_NO:-?}（versionId: $VERSION_ID）"
else
  info "复用已创建的版本：$VERSION_ID"
fi
echo

# --- 查当前状态 ---
current_status="$(
  dws dev app version status \
    --unified-app-id "$UNIFIED_APP_ID" \
    --version-id "$VERSION_ID" --format json 2>/dev/null | node -e '
    let raw = "";
    process.stdin.on("data", (c) => (raw += c));
    process.stdin.on("end", () => {
      try { process.stdout.write(JSON.parse(raw)?.versionStatus || ""); } catch {}
    });
  ' || true
)"

case "$current_status" in
  AUDIT)
    warn "这个版本已经提交审批，正在等待审批人处理（versionStatus: AUDIT）。"
    echo
    info "机器人在审批通过之前搜不到。请去催审批人在钉钉里点通过。"
    dim "  查状态：bash scripts/app-status.sh"
    exit 0
    ;;
  RELEASE|ONLINE|PUBLISHED)
    ok "版本已发布（$current_status）。机器人应该可以在钉钉里搜到了：$ROBOT_NAME"
    exit 0
    ;;
esac

# --- 没指定审批人：列出候选，不提交 ---
if [ -z "$APPROVER_USER_ID" ]; then
  info "查询发布是否需要审批……"
  echo
  CHECK_JSON="$(mktemp)"
  trap 'rm -f "$CHECK_JSON"' EXIT
  dws dev app version check-approval \
    --unified-app-id "$UNIFIED_APP_ID" \
    --version-id "$VERSION_ID" --format json > "$CHECK_JSON"

  node -e '
    const fs = require("fs");
    const data = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
    if (!data.requiresApproval) {
      console.log("这个版本不需要审批，可以直接发布。");
      console.log("");
      console.log("运行：bash scripts/publish-app.sh --no-approver");
      process.exit(0);
    }
    console.log(data.approvalPromptText || "需要选择一位审批人。");
    console.log("");
    console.log("选好之后运行（把 <userId> 换成上面对应的一串数字）：");
    console.log("");
    console.log("    bash scripts/publish-app.sh <userId>");
  ' "$CHECK_JSON"
  exit 0
fi

# --- 提交审批 ---
if [ "$APPROVER_USER_ID" = "--no-approver" ]; then
  info "提交发布（无需审批人）……"
  dws dev app version publish \
    --unified-app-id "$UNIFIED_APP_ID" \
    --version-id "$VERSION_ID" \
    --yes --format json > /dev/null
else
  info "提交发布审批，审批人 userId：$APPROVER_USER_ID"
  dws dev app version publish \
    --unified-app-id "$UNIFIED_APP_ID" \
    --version-id "$VERSION_ID" \
    --approver-user-id "$APPROVER_USER_ID" \
    --yes --format json > /dev/null
fi

echo
ok "已提交。"
echo
warn "接下来要等审批人在钉钉里点通过，这一步不在你手上。"
dim "  查状态：bash scripts/app-status.sh"
