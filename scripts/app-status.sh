#!/usr/bin/env bash
# 查看钉钉应用 / 机器人 / 版本审批的当前状态。只读。

set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

command -v dws >/dev/null 2>&1 || die "没装 dws，先跑 bash scripts/check-env.sh"

APP_INFO="$PROJECT_ROOT/.dingtalk-app.json"
[ -f "$APP_INFO" ] || die "找不到 $APP_INFO，说明还没创建钉钉应用。"

UNIFIED_APP_ID="$(json_field "$APP_INFO" unifiedAppId)"
ROBOT_NAME="$(json_field "$APP_INFO" robotName)"

echo "机器人名称：$ROBOT_NAME"
echo

# --- 机器人状态 ---
robot_status="$(
  dws dev app robot get --unified-app-id "$UNIFIED_APP_ID" --format json 2>/dev/null | node -e '
    let raw = "";
    process.stdin.on("data", (c) => (raw += c));
    process.stdin.on("end", () => {
      try {
        const d = JSON.parse(raw);
        process.stdout.write(`${d?.robotStatus || "?"}|${d?.mode || "?"}`);
      } catch {}
    });
  ' || true
)"
if [ -n "$robot_status" ]; then
  echo "机器人状态：${robot_status%%|*}（模式：${robot_status##*|}）"
fi

# --- 版本审批状态 ---
VERSION_STATE="$PROJECT_ROOT/.dingtalk-version.json"
if [ -f "$VERSION_STATE" ]; then
  VERSION_ID="$(json_field "$VERSION_STATE" versionId)"
  version_status="$(
    dws dev app version status \
      --unified-app-id "$UNIFIED_APP_ID" --version-id "$VERSION_ID" --format json 2>/dev/null | node -e '
      let raw = "";
      process.stdin.on("data", (c) => (raw += c));
      process.stdin.on("end", () => {
        try { process.stdout.write(JSON.parse(raw)?.versionStatus || ""); } catch {}
      });
    ' || true
  )"
  echo "版本状态：  ${version_status:-未知}"
  echo
  case "$version_status" in
    AUDIT)  warn "还在等审批 —— 机器人此时在钉钉里搜不到，需要催审批人。" ;;
    INIT)   warn "版本已创建但还没提交发布 —— 跑 bash scripts/publish-app.sh" ;;
    RELEASE|ONLINE|PUBLISHED) ok "已发布，机器人可以在钉钉里搜到了。" ;;
    *)      dim "如果长时间不变化，去钉钉开放平台后台看一眼这个应用的版本管理。" ;;
  esac
else
  echo "版本状态：  还没创建版本"
  echo
  warn "跑 bash scripts/publish-app.sh 创建并提交发布。"
fi

# --- 可见范围 ---
echo
members="$(
  dws dev app member list --unified-app-id "$UNIFIED_APP_ID" --format json 2>/dev/null | node -e '
    let raw = "";
    process.stdin.on("data", (c) => (raw += c));
    process.stdin.on("end", () => {
      try {
        const list = JSON.parse(raw)?.members || [];
        process.stdout.write(list.map((m) => `${m.name}(${m.memberType})`).join("、"));
      } catch {}
    });
  ' || true
)"
[ -n "$members" ] && echo "可见范围：  $members"

# --- 本地服务状态 ---
echo
if [ -n "$(running_pids)" ]; then
  ok "本地服务正在运行。"
  if [ -f "$LOG_FILE" ] && grep -q "connect success" "$LOG_FILE" 2>/dev/null; then
    dim "  钉钉长连接已建立。"
  fi
else
  warn "本地服务没有运行 —— 跑 bash scripts/start.sh"
fi
