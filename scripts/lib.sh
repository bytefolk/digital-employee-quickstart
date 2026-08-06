#!/usr/bin/env bash
# 公共函数库，被其他脚本 source 引用。不要直接执行。

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME_DIR="$PROJECT_ROOT/runtime"
KNOWLEDGE_DIR="$PROJECT_ROOT/knowledge"
ENV_FILE="$PROJECT_ROOT/.env"
CONFIG_FILE="$RUNTIME_DIR/configs/local.json"
LOG_FILE="$PROJECT_ROOT/.runtime.log"
PID_FILE="$PROJECT_ROOT/.runtime.pid"
# Agent-native 路径产出的可移植员工包放这里（与 standalone-v1 的 configs/ 分开）
EMPLOYEES_DIR="$PROJECT_ROOT/employees"

CLI="./dist/apps/cli/bin.js"

RUNTIME_REPO="https://github.com/fullstack-ai-infra/digital-employee.git"

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  C_RESET=$'\033[0m'; C_RED=$'\033[31m'; C_GREEN=$'\033[32m'
  C_YELLOW=$'\033[33m'; C_BLUE=$'\033[34m'; C_DIM=$'\033[2m'
else
  C_RESET=; C_RED=; C_GREEN=; C_YELLOW=; C_BLUE=; C_DIM=
fi

info()  { printf '%s\n' "${C_BLUE}▶${C_RESET} $*"; }
ok()    { printf '%s\n' "${C_GREEN}✓${C_RESET} $*"; }
warn()  { printf '%s\n' "${C_YELLOW}!${C_RESET} $*"; }
err()   { printf '%s\n' "${C_RED}✗${C_RESET} $*" >&2; }
dim()   { printf '%s\n' "${C_DIM}$*${C_RESET}"; }

die() { err "$@"; exit 1; }

# 载入 .env 到当前 shell 环境
load_env() {
  [ -f "$ENV_FILE" ] || die "找不到 $ENV_FILE，请先复制 .env.example 成 .env 并填好。"
  set -a
  # shellcheck disable=SC1090
  . "$ENV_FILE"
  set +a
}

# 检查 .env 里必填项是否都有值
require_env_vars() {
  local missing=()
  local name
  for name in "$@"; do
    if [ -z "${!name:-}" ]; then missing+=("$name"); fi
  done
  if [ ${#missing[@]} -gt 0 ]; then
    err ".env 里这些项还没填：${missing[*]}"
    die "请编辑 $ENV_FILE 补齐后重试。"
  fi
}

# 用 node 从 json 文件里取一个顶层字段（避免依赖 jq）
json_field() {
  local file="$1" field="$2"
  node -e '
    const fs = require("fs");
    const [file, field] = process.argv.slice(1);
    let data;
    try { data = JSON.parse(fs.readFileSync(file, "utf8")); }
    catch { process.exit(3); }
    const value = data?.[field];
    if (value === undefined || value === null) process.exit(4);
    process.stdout.write(String(value));
  ' "$file" "$field"
}

# 打码显示密钥，只留头尾各 4 位
mask() {
  local value="$1"
  local length=${#value}
  if [ "$length" -le 8 ]; then printf '%s' "****"; else
    printf '%s...%s' "${value:0:4}" "${value: -4}"
  fi
}

runtime_installed() {
  [ -f "$RUNTIME_DIR/package.json" ] && [ -d "$RUNTIME_DIR/node_modules" ]
}

require_runtime() {
  runtime_installed || die "引擎还没装好，请先运行：bash scripts/setup-runtime.sh"
}

require_config() {
  [ -f "$CONFIG_FILE" ] || die "还没生成配置，请先运行：bash scripts/make-config.sh"
}

# 在引擎目录里跑 CLI。所有 Agent-native 命令都经由这里，
# 保证用的是同一个编译产物，也避免各脚本重复写路径。
run_cli() {
  ( cd "$RUNTIME_DIR" && node "$CLI" "$@" )
}

# 把员工包名解析成绝对路径。允许传名字（employees/ 下）或直接传路径。
resolve_employee_dir() {
  local input="$1"
  case "$input" in
    /*) printf '%s' "$input" ;;
    */*) printf '%s' "$(cd "$(dirname "$input")" 2>/dev/null && pwd)/$(basename "$input")" ;;
    *) printf '%s' "$EMPLOYEES_DIR/$input" ;;
  esac
}

# 引擎当前认可的 recipe。init 只接受这两个值。
RECIPES="minimal-answer.v1 structured-action.v1"

# 可实际运行的 Agent Host（codex 是 probe-only，不能跑，故不列入）。
RUNNABLE_HOSTS="claude-code qoder qwen-code codebuddy"

# 读取某个进程的工作目录（Linux 用 /proc，macOS 用 lsof）
process_cwd() {
  local pid="$1"
  if [ -r "/proc/$pid/cwd" ]; then
    readlink "/proc/$pid/cwd" 2>/dev/null || true
  elif command -v lsof >/dev/null 2>&1; then
    lsof -a -p "$pid" -d cwd -Fn 2>/dev/null | sed -n 's/^n//p' | head -1
  fi
}

# 找出【本项目】正在运行的引擎进程 PID（可能多个）。
#
# 这里有两个坑必须防：
# 1. 同一台机器上别的目录也可能跑着 digital-employee，误杀别人的进程后果很糟
#    → 校验进程的工作目录必须是本项目的 runtime/。
# 2. pgrep 会匹配到自己 —— 模式串本身出现在调用方的命令行里
#    → 用 `^node ` 锚定只匹配 node 进程，并显式排除当前 shell 及其父进程。
running_pids() {
  local pid cwd runtime_real
  runtime_real="$(cd "$RUNTIME_DIR" 2>/dev/null && pwd -P || printf '%s' "$RUNTIME_DIR")"
  while IFS= read -r pid; do
    [ -n "$pid" ] || continue
    [ "$pid" = "$$" ] && continue
    [ "$pid" = "${PPID:-}" ] && continue
    cwd="$(process_cwd "$pid")"
    if [ "$cwd" = "$RUNTIME_DIR" ] || [ "$cwd" = "$runtime_real" ]; then
      printf '%s\n' "$pid"
    fi
  done < <(pgrep -f '^node .*bin\.js legacy start' 2>/dev/null || true)
}
