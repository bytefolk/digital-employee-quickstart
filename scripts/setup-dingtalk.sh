#!/usr/bin/env bash
# 在钉钉开放平台创建企业内部应用 + Stream 模式机器人，并把凭证写进 .env。
#
# 注意：这是**写操作**，会在你的真实企业里创建一个应用。执行前会要求确认。
# 用法：bash scripts/setup-dingtalk.sh "机器人名字"

set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

command -v dws  >/dev/null 2>&1 || die "没装 dws，先跑 bash scripts/check-env.sh"
command -v node >/dev/null 2>&1 || die "没装 Node.js，先跑 bash scripts/check-env.sh"

ROBOT_NAME="${1:-}"
[ -n "$ROBOT_NAME" ] || die "用法：bash scripts/setup-dingtalk.sh \"机器人名字\""

ROBOT_DESC="${2:-团队答疑数字员工}"

# --- 确认钉钉已登录 ---
current_profile="$(
  dws profile list --format json 2>/dev/null | node -e '
    let raw = "";
    process.stdin.on("data", (c) => (raw += c));
    process.stdin.on("end", () => {
      try { process.stdout.write(JSON.parse(raw)?.currentProfile || ""); } catch {}
    });
  ' || true
)"

if [ -z "$current_profile" ]; then
  err "钉钉还没登录。"
  echo
  info "请先运行下面这条命令，然后用【企业管理员】账号扫码授权："
  echo
  echo "    dws auth login --device"
  echo
  dim "（服务器 / 容器 / SSH 环境必须加 --device）"
  exit 1
fi

ok "钉钉已登录：$current_profile"
echo

# --- 确认写操作 ---
warn "接下来会在你的企业里【真实创建】一个钉钉企业内部应用："
echo
echo "    应用/机器人名称：$ROBOT_NAME"
echo "    描述：          $ROBOT_DESC"
echo "    所属企业：      $current_profile"
echo
printf '确认创建吗？输入 yes 继续，其他任意输入取消：'
read -r answer
if [ "$answer" != "yes" ]; then
  info "已取消，没有创建任何东西。"
  exit 0
fi
echo

TMP_JSON="$(mktemp)"
trap 'rm -f "$TMP_JSON"' EXIT

# --- 1. 创建应用 ---
info "创建应用……"
dws dev app create --name "$ROBOT_NAME" --desc "$ROBOT_DESC" --yes --format json > "$TMP_JSON"

APP_KEY="$(json_field "$TMP_JSON" appKey)"
UNIFIED_APP_ID="$(json_field "$TMP_JSON" unifiedAppId)"
[ -n "$APP_KEY" ] && [ -n "$UNIFIED_APP_ID" ] || die "创建应用失败，返回内容异常。"
ok "应用已创建（Client ID: $(mask "$APP_KEY")）"

# --- 2. 读取 appSecret ---
info "读取应用凭证……"
dws dev app credentials get --unified-app-id "$UNIFIED_APP_ID" --format json > "$TMP_JSON"
APP_SECRET="$(json_field "$TMP_JSON" appSecret)"
[ -n "$APP_SECRET" ] || die "读取 appSecret 失败。"
ok "凭证已读取（Client Secret: $(mask "$APP_SECRET")）"

# 立刻清掉临时文件里的凭证
: > "$TMP_JSON"

# --- 3. 配置 Stream 模式机器人 ---
# 注意：必须先 robot config 创建机器人；直接 robot enable 会报"机器人不存在"
info "配置机器人为 Stream 模式……"
dws dev app robot config \
  --unified-app-id "$UNIFIED_APP_ID" \
  --name "$ROBOT_NAME" \
  --brief "$ROBOT_DESC" \
  --mode STREAM \
  --add-scope \
  --yes --format json > "$TMP_JSON"

robot_status="$(json_field "$TMP_JSON" robotStatus 2>/dev/null || echo "")"
if [ "$robot_status" = "ONLINE" ]; then
  ok "机器人已配置为 Stream 模式，状态 ONLINE。"
else
  warn "机器人已配置，但状态是：${robot_status:-未知}"
fi
: > "$TMP_JSON"

# --- 4. 写入 .env ---
info "把凭证写入 .env（不会打印到屏幕上）……"
[ -f "$ENV_FILE" ] || cp "$PROJECT_ROOT/.env.example" "$ENV_FILE"
chmod 600 "$ENV_FILE"

node -e '
  const fs = require("fs");
  const [envFile, clientId, clientSecret, displayName] = process.argv.slice(1);
  let text = fs.readFileSync(envFile, "utf8");
  const upsert = (key, value) => {
    const line = `${key}=${value}`;
    const pattern = new RegExp(`^${key}=.*$`, "m");
    text = pattern.test(text) ? text.replace(pattern, line) : `${text.replace(/\n*$/, "\n")}${line}\n`;
  };
  upsert("DINGTALK_CLIENT_ID", clientId);
  upsert("DINGTALK_CLIENT_SECRET", clientSecret);
  upsert("EMPLOYEE_DISPLAY_NAME", displayName);
  fs.writeFileSync(envFile, text, { mode: 0o600 });
' "$ENV_FILE" "$APP_KEY" "$APP_SECRET" "$ROBOT_NAME"

ok "凭证已写入 $ENV_FILE"

# --- 5. 记录应用信息（非敏感，方便后续查状态）---
cat > "$PROJECT_ROOT/.dingtalk-app.json" <<EOF
{
  "robotName": "$ROBOT_NAME",
  "appKey": "$APP_KEY",
  "unifiedAppId": "$UNIFIED_APP_ID",
  "profile": "$current_profile"
}
EOF
ok "应用信息已记录到 .dingtalk-app.json（不含密钥）"

echo
echo "─────────────────────────────────────────────"
ok "钉钉侧创建完成。"
echo "─────────────────────────────────────────────"
echo
warn "机器人现在还搜不到 —— 必须先发布版本并通过审批。"
echo
info "下一步：bash scripts/publish-app.sh"
