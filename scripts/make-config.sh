#!/usr/bin/env bash
# 根据 .env 生成引擎配置 runtime/configs/local.json。
# 可以反复运行，会覆盖上一次生成的配置。

set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

require_runtime
load_env

require_env_vars DINGTALK_CLIENT_ID DINGTALK_CLIENT_SECRET OPENAI_API_KEY \
                 MODEL_BASE_URL MODEL_NAME

DISPLAY_NAME="${EMPLOYEE_DISPLAY_NAME:-数字员工}"
# 转人工提示语：默认中文。这句话是固定文本，不由模型生成 —— 检索不到证据时原样返回。
ESCALATION_MESSAGE="${ESCALATION_MESSAGE:-我在已批准的资料里没找到足够依据，这个问题需要请同事帮忙确认。}"

[ -d "$KNOWLEDGE_DIR" ] || die "找不到知识库目录：$KNOWLEDGE_DIR"

markdown_count="$(find "$KNOWLEDGE_DIR" -maxdepth 3 -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')"
if [ "$markdown_count" -eq 0 ]; then
  warn "知识库目录里还没有 .md 文件，数字员工将无法回答任何问题。"
  dim "  往 $KNOWLEDGE_DIR 里放 markdown 资料后重新运行本脚本。"
fi

mkdir -p "$(dirname "$CONFIG_FILE")"

# 用 node 做替换，避免路径里的斜杠影响 sed
node -e '
  const fs = require("fs");
  const [template, output, displayName, baseUrl, modelName, knowledgeRoot, escalation] =
    process.argv.slice(1);
  const raw = fs.readFileSync(template, "utf8");
  const filled = raw
    .replace("__DISPLAY_NAME__", JSON.stringify(displayName).slice(1, -1))
    .replace("__MODEL_BASE_URL__", JSON.stringify(baseUrl).slice(1, -1))
    .replace("__MODEL_NAME__", JSON.stringify(modelName).slice(1, -1))
    .replace("__KNOWLEDGE_ROOT__", JSON.stringify(knowledgeRoot).slice(1, -1))
    .replace("__ESCALATION_MESSAGE__", JSON.stringify(escalation).slice(1, -1));
  JSON.parse(filled); // 生成后立刻校验一遍 JSON 合法性
  fs.writeFileSync(output, filled);
' \
  "$PROJECT_ROOT/templates/config.template.json" \
  "$CONFIG_FILE" \
  "$DISPLAY_NAME" \
  "$MODEL_BASE_URL" \
  "$MODEL_NAME" \
  "$KNOWLEDGE_DIR" \
  "$ESCALATION_MESSAGE"

ok "配置已生成：$CONFIG_FILE"
echo
dim "  机器人显示名 : $DISPLAY_NAME"
dim "  模型地址     : $MODEL_BASE_URL"
dim "  模型名称     : $MODEL_NAME"
dim "  知识库目录   : $KNOWLEDGE_DIR（$markdown_count 个 .md 文件）"
dim "  钉钉 ClientID: $(mask "$DINGTALK_CLIENT_ID")"
echo
warn "配置文件里不含任何密钥，密钥通过 .env 的环境变量注入。"
echo
info "下一步：bash scripts/ask.sh \"随便问个问题\"  先在命令行验证一下"
