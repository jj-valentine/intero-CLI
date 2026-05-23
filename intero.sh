#!/bin/bash
# intero — Claude Code status line
# Reads JSON from stdin, outputs 3-line colored status

set -o pipefail

INTERO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

INTERO_CACHE_DIR="${TMPDIR:-${XDG_RUNTIME_DIR:-/tmp}}/intero"
mkdir -m 700 -p "$INTERO_CACHE_DIR"

# Source libraries
source "$INTERO_DIR/lib/colors.sh"
source "$INTERO_DIR/lib/icons.sh"
source "$INTERO_DIR/lib/bars.sh"
source "$INTERO_DIR/lib/format.sh"
source "$INTERO_DIR/lib/git.sh"
source "$INTERO_DIR/lib/pr.sh"
source "$INTERO_DIR/lib/peak.sh"
source "$INTERO_DIR/lib/status.sh"
source "$INTERO_DIR/lib/sections.sh"

# Source user config if present
[[ -f "$INTERO_DIR/config.sh" ]] && source "$INTERO_DIR/config.sh"

# ── Read JSON from stdin ─────────────────────────────────────────────────────
INPUT=$(cat)
jq_get() { echo "$INPUT" | jq -r "$1 // empty" 2>/dev/null; }

CWD=$(jq_get '.cwd')
[[ -z "$CWD" ]] && exit 0

SESSION_ID=$(jq_get '.session_id')

# ── Parse JSON fields ────────────────────────────────────────────────────────
MODEL_NAME=$(jq_get '.model.display_name')
MODEL_ID=$(jq_get '.model.id')

CTX_PCT=$(jq_get '.context_window.used_percentage' | cut -d. -f1)
CTX_PCT=${CTX_PCT:-0}
CTX_INPUT=$(jq_get '.context_window.total_input_tokens')
CTX_INPUT=${CTX_INPUT:-0}
CTX_OUTPUT=$(jq_get '.context_window.total_output_tokens')
CTX_OUTPUT=${CTX_OUTPUT:-0}
CTX_SIZE=$(jq_get '.context_window.context_window_size')
CTX_SIZE=${CTX_SIZE:-200000}

CACHE_READ=$(echo "$INPUT" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0' 2>/dev/null)
CACHE_CREATE=$(echo "$INPUT" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0' 2>/dev/null)
CACHE_INPUT=$(echo "$INPUT" | jq -r '.context_window.current_usage.input_tokens // 0' 2>/dev/null)

RATE_5H_PCT=$(echo "$INPUT" | jq -r '.rate_limits.five_hour.used_percentage // empty' 2>/dev/null | cut -d. -f1)
RATE_5H_RESET=$(echo "$INPUT" | jq -r '.rate_limits.five_hour.resets_at // empty' 2>/dev/null)
RATE_7D_PCT=$(echo "$INPUT" | jq -r '.rate_limits.seven_day.used_percentage // empty' 2>/dev/null | cut -d. -f1)
RATE_7D_RESET=$(echo "$INPUT" | jq -r '.rate_limits.seven_day.resets_at // empty' 2>/dev/null)

LINES_ADD=$(echo "$INPUT" | jq -r '.cost.total_lines_added // 0' 2>/dev/null)
LINES_DEL=$(echo "$INPUT" | jq -r '.cost.total_lines_removed // 0' 2>/dev/null)
DURATION_MS=$(echo "$INPUT" | jq -r '.cost.total_duration_ms // 0' 2>/dev/null)

WORKTREE_NAME=$(jq_get '.worktree.name')
AGENT_NAME=$(jq_get '.agent.name')

# ── Derived values ───────────────────────────────────────────────────────────
WINDOW_TOKENS=$((CACHE_INPUT + CACHE_CREATE + CACHE_READ))

# Cumulative session tokens — survives context compaction
TOKEN_ACC=0; PREV_WINDOW=0; PREV_OUTPUT=0
if [[ -n "$SESSION_ID" ]]; then
  TOKEN_CACHE="$INTERO_CACHE_DIR/tokens-${SESSION_ID}"
  [[ -f "$TOKEN_CACHE" ]] && source "$TOKEN_CACHE"
  if (( WINDOW_TOKENS < PREV_WINDOW )); then
    TOKEN_ACC=$((TOKEN_ACC + PREV_WINDOW + PREV_OUTPUT))
  fi
  cat > "$TOKEN_CACHE" <<TOK
TOKEN_ACC=$TOKEN_ACC
PREV_WINDOW=$WINDOW_TOKENS
PREV_OUTPUT=$CTX_OUTPUT
TOK
fi
TOTAL_TOKENS=$((TOKEN_ACC + WINDOW_TOKENS + CTX_OUTPUT))

BURN_RATE=$(calc_burn_rate "$TOTAL_TOKENS" "$DURATION_MS")
CACHE_RATIO=$(calc_cache_ratio "$CACHE_READ" "$CACHE_CREATE" "$CACHE_INPUT")
WEIGHT=$(model_weight "$MODEL_ID")

# Thinking effort — try to read from settings
THINKING_EFFORT=""
if [[ -f "$HOME/.claude/settings.json" ]]; then
  THINKING_EFFORT=$(jq -r '.effortLevel // empty' "$HOME/.claude/settings.json" 2>/dev/null)
fi

# ── Default layout (override in config.sh) ──────────────────────────────────
: "${INTERO_LINE1:=model dir agent lines git}"
: "${INTERO_LINE2:=context cache tokens burn duration peak status}"
: "${INTERO_LINE3:=rate5h mcp}"
: "${INTERO_LINE4:=rate7d}"

# ── Collect external data ────────────────────────────────────────────────────
git_collect "$CWD"
pr_collect "$CWD"
peak_check
if [[ "$INTERO_LINE1 $INTERO_LINE2 $INTERO_LINE3 $INTERO_LINE4" == *status* ]]; then
  status_collect
fi

# MCP health (read from cache, don't probe)
MCP_HEALTHY=0; MCP_TOTAL=0
MCP_CACHE="$INTERO_CACHE_DIR/mcp-${SESSION_ID}"
[[ -f "$MCP_CACHE" ]] && source "$MCP_CACHE"

# Tab summary
TAB_SUMMARY=""
TAB_FILE="$INTERO_CACHE_DIR/tab-${SESSION_ID}"
[[ -f "$TAB_FILE" ]] && TAB_SUMMARY=$(cat "$TAB_FILE")

# ── Set tab title ────────────────────────────────────────────────────────────
TAB_DIR="${CWD/#$HOME/~}"
TAB_TITLE="$TAB_DIR"
[[ -n "$GIT_BRANCH" ]] && TAB_TITLE="$TAB_TITLE · $GIT_BRANCH"
[[ -n "$TAB_SUMMARY" ]] && TAB_TITLE="$TAB_TITLE · $TAB_SUMMARY"
printf '\e]0;%s\a' "$TAB_TITLE" >/dev/tty 2>/dev/null

# ── Render ──────────────────────────────────────────────────────────────────
# Word-split intentionally: each variable is a space-separated list of section names.
# shellcheck disable=SC2086
render_line $INTERO_LINE1
# shellcheck disable=SC2086
render_line $INTERO_LINE2
# shellcheck disable=SC2086
render_line $INTERO_LINE3
# shellcheck disable=SC2086
render_line $INTERO_LINE4
