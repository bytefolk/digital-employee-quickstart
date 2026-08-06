#!/usr/bin/env bash
# 下载并安装数字员工引擎（Digital Employee）到 runtime/ 目录。

set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

command -v git  >/dev/null 2>&1 || die "没装 git，先跑 bash scripts/check-env.sh"
command -v node >/dev/null 2>&1 || die "没装 Node.js，先跑 bash scripts/check-env.sh"

if [ -d "$RUNTIME_DIR/.git" ]; then
  info "引擎已存在，拉取最新代码……"
  git -C "$RUNTIME_DIR" pull --ff-only
else
  info "下载引擎（浅克隆）……"
  git clone --depth 1 "$RUNTIME_REPO" "$RUNTIME_DIR"
fi

info "安装依赖（含开发依赖，构建需要 TypeScript 编译器）……"
# 必须完整安装：只装生产依赖会导致构建时报 tsc: not found
( cd "$RUNTIME_DIR" && npm install )

info "编译……"
( cd "$RUNTIME_DIR" && npm run build --silent )

echo
ok "引擎装好了：$RUNTIME_DIR"
dim "版本：$(json_field "$RUNTIME_DIR/package.json" version 2>/dev/null || echo 未知)"
echo
info "下一步：bash scripts/make-config.sh"
