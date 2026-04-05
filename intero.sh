#!/bin/bash
# intero — Claude Code status line
# Reads JSON from stdin, outputs 3-line colored status

set -o pipefail

INTERO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source libraries
source "$INTERO_DIR/lib/colors.sh"
source "$INTERO_DIR/lib/icons.sh"
source "$INTERO_DIR/lib/bars.sh"
source "$INTERO_DIR/lib/format.sh"
source "$INTERO_DIR/lib/git.sh"
source "$INTERO_DIR/lib/pr.sh"
source "$INTERO_DIR/lib/peak.sh"

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
TOTAL_TOKENS=$((CTX_INPUT + CTX_OUTPUT))
BURN_RATE=$(calc_burn_rate "$TOTAL_TOKENS" "$DURATION_MS")
CACHE_RATIO=$(calc_cache_ratio "$CACHE_READ" "$CACHE_CREATE" "$CACHE_INPUT")
WEIGHT=$(model_weight "$MODEL_ID")

# Thinking effort — try to read from settings
THINKING_EFFORT=""
if [[ -f "$HOME/.claude/settings.json" ]]; then
  THINKING_EFFORT=$(jq -r '.effortLevel // empty' "$HOME/.claude/settings.json" 2>/dev/null)
fi

# ── Collect external data ────────────────────────────────────────────────────
git_collect "$CWD"
pr_collect "$CWD"
peak_check

# MCP health (read from cache, don't probe)
MCP_HEALTHY=0; MCP_TOTAL=0
MCP_CACHE="/tmp/intero-mcp-${SESSION_ID}"
[[ -f "$MCP_CACHE" ]] && source "$MCP_CACHE"

# Tab summary
TAB_SUMMARY=""
TAB_FILE="/tmp/claude-tab-${SESSION_ID}"
[[ -f "$TAB_FILE" ]] && TAB_SUMMARY=$(cat "$TAB_FILE")

# ── Set tab title ────────────────────────────────────────────────────────────
TAB_DIR="${CWD/#$HOME/~}"
TAB_TITLE="$TAB_DIR"
[[ -n "$GIT_BRANCH" ]] && TAB_TITLE="$TAB_TITLE · $GIT_BRANCH"
[[ -n "$TAB_SUMMARY" ]] && TAB_TITLE="$TAB_TITLE · $TAB_SUMMARY"
printf '\e]0;%s\a' "$TAB_TITLE" >/dev/tty 2>/dev/null

# ── Line 1: Identity + Git ──────────────────────────────────────────────────
# Model + thinking
clr_model; bld; printf "%s %s" "$IC_MODEL" "$MODEL_NAME"; rst
if [[ -n "$THINKING_EFFORT" ]]; then
  clr_thinking; printf " · %s" "$THINKING_EFFORT"; rst
fi

# Worktree indicator
if [[ -n "$WORKTREE_NAME" ]]; then
  sep; c_teal; printf "%s %s" "$IC_WORKTREE" "$WORKTREE_NAME"; rst
fi

# Agent indicator
if [[ -n "$AGENT_NAME" ]]; then
  sep; c_sapphire; printf "agent:%s" "$AGENT_NAME"; rst
fi

# Lines changed
sep
clr_add; printf "+%d" "$LINES_ADD"; rst
clr_del; printf " -%d" "$LINES_DEL"; rst

# Git branch
if (( GIT_IN_REPO )); then
  sep; git_branch_section

  # Sync status
  sep; git_sync_status
fi

# PR status (always show placeholder)
sep
pr_section_out=$(pr_section)
if [[ -n "$pr_section_out" ]]; then
  printf "%s" "$pr_section_out"
else
  clr_dim; printf "%s no PR" "$IC_PR"; rst
fi

# Duration
sep; clr_duration; printf "%s %s" "$IC_CLOCK" "$(fmt_duration "$DURATION_MS")"; rst

# Peak hours warning
if (( PEAK_ACTIVE )); then
  sep; peak_section
fi

echo ""

# ── Line 2: Context + Burn + Cache + MCP ───────────────────────────────────
# Context bar
clr_ctx; printf "%s ctx " "$IC_CTX"; rst
render_bar "$CTX_PCT" 10 c_sky
clr_dim; printf " %d%%" "$CTX_PCT"; rst
dim; clr_dim; printf " %s/%s" "$(fmt_tokens "$TOTAL_TOKENS")" "$(fmt_tokens "$CTX_SIZE")"; rst

# Burn rate
sep
burn_color=clr_burn_low
(( BURN_RATE > 2000 )) && burn_color=clr_burn_mid
(( BURN_RATE > 5000 )) && burn_color=clr_burn_hi
$burn_color; printf "%s %s/m" "$IC_BURN" "$(fmt_tokens "$BURN_RATE")"; rst

# Cache ratio
sep
clr_cache; printf "%s cache %d%%" "$IC_CACHE" "$CACHE_RATIO"; rst

# MCP health (always show)
sep
if (( MCP_TOTAL > 0 )); then
  if (( MCP_HEALTHY == MCP_TOTAL )); then
    clr_mcp_ok
  else
    clr_mcp_bad; bld
  fi
  printf "%s %d/%d" "$IC_MCP" "$MCP_HEALTHY" "$MCP_TOTAL"
else
  clr_dim; printf "%s 0" "$IC_MCP"
fi
rst

echo ""

# ── Lines 3-4: Rate Limits (stacked, always shown) ────────────────────────
# 5h rate limit
display_5h=${RATE_5H_PCT:-0}
if (( WEIGHT > 1 && display_5h > 0 )); then
  display_5h=$((display_5h * WEIGHT / 5))
  (( display_5h > 100 )) && display_5h=100
fi
clr_rate5h; printf "%s 5h " "$IC_RATE"; rst
render_bar "$display_5h" 10 c_teal
clr_dim; printf " %d%%" "$display_5h"; rst
if [[ -n "$RATE_5H_RESET" ]]; then
  dim; clr_dim; printf " resets %s" "$(fmt_reset "$RATE_5H_RESET")"; rst
fi
echo ""

# 7d rate limit
display_7d=${RATE_7D_PCT:-0}
clr_rate7d; printf "%s 7d " "$IC_RATE"; rst
render_bar "$display_7d" 10 c_lavender
clr_dim; printf " %d%%" "$display_7d"; rst
if [[ -n "$RATE_7D_RESET" ]]; then
  dim; clr_dim; printf " resets %s" "$(fmt_reset "$RATE_7D_RESET")"; rst
fi
  echo ""
fi
