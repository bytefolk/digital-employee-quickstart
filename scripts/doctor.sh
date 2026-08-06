#!/usr/bin/env bash
# 一条命令看清整套东西现在处于什么状态、下一步该做什么。只读，不改任何东西。

set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

echo "══════════════════════════════════════════"
echo " 数字员工状态体检"
echo "══════════════════════════════════════════"
echo

next_step=""
# 只记录第一个待办（最靠前的那一步）。
# 注意结尾的 `return 0`：少了它，当 next_step 已有值时 [ -z ] 会返回 1，
# 在 set -e 下会直接终止整个脚本。
note_next() {
  [ -z "$next_step" ] && next_step="$1"
  return 0
}

# 1. 基础软件
printf '【1/6】基础软件      '
missing=""
for tool in node git dws; do
  command -v "$tool" >/dev/null 2>&1 || missing="$missing $tool"
done
if [ -z "$missing" ]; then
  printf '%s\n' "${C_GREEN}齐了${C_RESET}"
else
  printf '%s\n' "${C_RED}缺:$missing${C_RESET}"
  note_next "bash scripts/check-env.sh   # 看缺什么怎么装"
fi

# 2. 钉钉登录
printf '【2/6】钉钉登录      '
if command -v dws >/dev/null 2>&1; then
  profile="$(dws profile list --format json 2>/dev/null | node -e '
    let raw=""; process.stdin.on("data",c=>raw+=c);
    process.stdin.on("end",()=>{try{process.stdout.write(JSON.parse(raw)?.currentProfile||"")}catch{}});
  ' 2>/dev/null || true)"
  if [ -n "$profile" ]; then
    printf '%s\n' "${C_GREEN}已登录${C_RESET}"
  else
    printf '%s\n' "${C_YELLOW}未登录${C_RESET}"
    note_next "dws auth login --device    # 用企业管理员账号扫码"
  fi
else
  printf '%s\n' "${C_DIM}跳过（没装 dws）${C_RESET}"
fi

# 3. 钉钉应用
printf '【3/6】钉钉应用      '
APP_INFO="$PROJECT_ROOT/.dingtalk-app.json"
if [ -f "$APP_INFO" ]; then
  printf '%s\n' "${C_GREEN}已创建（$(json_field "$APP_INFO" robotName 2>/dev/null || echo ?)）${C_RESET}"
else
  printf '%s\n' "${C_YELLOW}还没创建${C_RESET}"
  note_next 'bash scripts/setup-dingtalk.sh "机器人名字"'
fi

# 4. 发布审批
printf '【4/6】发布审批      '
if [ -f "$APP_INFO" ] && [ -f "$PROJECT_ROOT/.dingtalk-version.json" ] && command -v dws >/dev/null 2>&1; then
  vstatus="$(dws dev app version status \
      --unified-app-id "$(json_field "$APP_INFO" unifiedAppId)" \
      --version-id "$(json_field "$PROJECT_ROOT/.dingtalk-version.json" versionId)" \
      --format json 2>/dev/null | node -e '
    let raw=""; process.stdin.on("data",c=>raw+=c);
    process.stdin.on("end",()=>{try{process.stdout.write(JSON.parse(raw)?.versionStatus||"")}catch{}});
  ' 2>/dev/null || true)"
  case "$vstatus" in
    RELEASE|ONLINE|PUBLISHED) printf '%s\n' "${C_GREEN}已通过${C_RESET}" ;;
    AUDIT) printf '%s\n' "${C_YELLOW}等审批中（机器人此时搜不到，去催审批人）${C_RESET}" ;;
    INIT)  printf '%s\n' "${C_YELLOW}还没提交${C_RESET}"; note_next "bash scripts/publish-app.sh" ;;
    *)     printf '%s\n' "${C_DIM}${vstatus:-未知}${C_RESET}" ;;
  esac
elif [ -f "$APP_INFO" ]; then
  printf '%s\n' "${C_YELLOW}还没创建版本${C_RESET}"
  note_next "bash scripts/publish-app.sh"
else
  printf '%s\n' "${C_DIM}跳过${C_RESET}"
fi

# 5. 引擎 + 配置 + 知识库
printf '【5/6】引擎与配置    '
if ! runtime_installed; then
  printf '%s\n' "${C_YELLOW}引擎没装${C_RESET}"
  note_next "bash scripts/setup-runtime.sh"
elif [ ! -f "$ENV_FILE" ]; then
  printf '%s\n' "${C_YELLOW}没有 .env${C_RESET}"
  note_next "cp .env.example .env       # 然后填模型信息"
elif [ ! -f "$CONFIG_FILE" ]; then
  printf '%s\n' "${C_YELLOW}没生成配置${C_RESET}"
  note_next "bash scripts/make-config.sh"
else
  count="$(find "$KNOWLEDGE_DIR" -maxdepth 3 -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')"
  printf '%s\n' "${C_GREEN}就绪（知识库 $count 个文件）${C_RESET}"
  [ "$count" -eq 0 ] && note_next "往 knowledge/ 放 .md 资料，然后 bash scripts/make-config.sh"
fi

# 6. 服务
printf '【6/6】服务运行      '
if [ -n "$(running_pids)" ]; then
  if [ -f "$LOG_FILE" ] && grep -q "connect success" "$LOG_FILE" 2>/dev/null; then
    printf '%s\n' "${C_GREEN}运行中，钉钉已连接${C_RESET}"
  else
    printf '%s\n' "${C_YELLOW}进程在跑，但没看到连接成功${C_RESET}"
    note_next "bash scripts/logs.sh       # 看日志找原因"
  fi
else
  printf '%s\n' "${C_YELLOW}没运行${C_RESET}"
  [ -f "$CONFIG_FILE" ] && note_next "bash scripts/start.sh"
fi

# 以上 6 项都是 standalone-v1 路径（钉钉/HTTP）的状态。
# Agent-native 路径（员工包）是独立的一套，单独列出来，避免两条路径的状态混淆。
echo
printf '【附加】员工包        '
if [ -d "$EMPLOYEES_DIR" ] && [ -n "$(ls -A "$EMPLOYEES_DIR" 2>/dev/null)" ]; then
  pkg_count="$(find "$EMPLOYEES_DIR" -maxdepth 2 -name employee.json 2>/dev/null | wc -l | tr -d ' ')"
  printf '%s\n' "${C_GREEN}$pkg_count 个${C_RESET}"
else
  printf '%s\n' "${C_DIM}无（可选，见 cases/03-minimal-answer）${C_RESET}"
fi

echo
echo "──────────────────────────────────────────"
if [ -n "$next_step" ]; then
  printf '%s\n' "${C_BLUE}下一步：${C_RESET}"
  echo
  echo "    $next_step"
else
  ok "全部就绪。在钉钉里搜机器人名字就能对话了。"
  echo
  dim "  日常：改完 knowledge/ 里的资料后跑 bash scripts/start.sh 重启生效"
fi
echo
dim "其他场景见 cases/README.md：HTTP 接口、可移植员工包、结构化审批提案、多宿主运行"
echo
