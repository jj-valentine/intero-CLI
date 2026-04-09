#!/bin/bash
# intero — Modular section renderers
# Each render_<name>() prints its section inline (no trailing newline).
# Sections are composed into lines via config arrays in config.sh.

# ── Line 1 sections ─────────────────────────────────────────────────────────

render_model() {
  clr_model; bld; printf "%s %s" "$IC_MODEL" "$MODEL_NAME"; rst
  if [[ -n "$THINKING_EFFORT" ]]; then
    clr_thinking; printf " · %s" "$THINKING_EFFORT"; rst
  fi
}

render_worktree() {
  if [[ -n "$WORKTREE_NAME" ]]; then
    c_teal; printf "%s %s" "$IC_WORKTREE" "$WORKTREE_NAME"; rst
  else
    clr_dim; printf "%s" "$IC_WORKTREE"; rst
  fi
}

render_agent() {
  if [[ -n "$AGENT_NAME" ]]; then
    c_sapphire; printf "agent:%s" "$AGENT_NAME"; rst
  else
    clr_dim; printf "agent:idle"; rst
  fi
}

render_lines() {
  clr_add; printf "+%d" "$LINES_ADD"; rst
  clr_del; printf " -%d" "$LINES_DEL"; rst
}

render_branch() {
  if (( GIT_IN_REPO )); then
    git_branch_section
  else
    clr_dim; printf "%s" "$IC_BRANCH"; rst
  fi
}

render_sync() {
  if (( GIT_IN_REPO )); then
    git_sync_status
  else
    clr_dim; printf "%s" "$IC_SYNCED"; rst
  fi
}

render_pr() {
  local out
  out=$(pr_section)
  if [[ -n "$out" ]]; then
    printf "%s" "$out"
  else
    clr_dim; printf "%s no PR" "$IC_PR"; rst
  fi
}

render_duration() {
  clr_duration; printf "%s %s" "$IC_CLOCK" "$(fmt_duration "$DURATION_MS")"; rst
}

render_peak() {
  if (( PEAK_ACTIVE )); then
    peak_section
  else
    clr_dim; printf "%s" "$IC_PEAK"; rst
  fi
}

# ── Line 2 sections ─────────────────────────────────────────────────────────

render_context() {
  clr_ctx; printf "%s ctx " "$IC_CTX"; rst
  render_bar "$CTX_PCT" 10 c_sky
  clr_dim; printf " %d%%" "$CTX_PCT"; rst
  dim; clr_dim; printf " %s/%s" "$(fmt_tokens "$WINDOW_TOKENS")" "$(fmt_tokens "$CTX_SIZE")"; rst
}

render_tokens() {
  clr_dim; printf "%s session" "$(fmt_tokens "$TOTAL_TOKENS")"; rst
}

render_burn() {
  local burn_color=clr_burn_low
  (( BURN_RATE > 2000 )) && burn_color=clr_burn_mid
  (( BURN_RATE > 5000 )) && burn_color=clr_burn_hi
  $burn_color; printf "%s %s/m" "$IC_BURN" "$(fmt_tokens "$BURN_RATE")"; rst
}

render_cache() {
  clr_cache; printf "%s  cache %d%%" "$IC_CACHE" "$CACHE_RATIO"; rst
}

render_mcp() {
  if (( MCP_TOTAL > 0 )); then
    if (( MCP_HEALTHY == MCP_TOTAL )); then
      clr_mcp_ok
    else
      clr_mcp_bad; bld
    fi
    printf "%s  %d/%d" "$IC_MCP" "$MCP_HEALTHY" "$MCP_TOTAL"
  else
    clr_dim; printf "%s  0" "$IC_MCP"
  fi
  rst
}

# ── Line 3-4 sections ───────────────────────────────────────────────────────

render_rate5h() {
  local display_5h=${RATE_5H_PCT:-0}
  if (( WEIGHT > 1 && display_5h > 0 )); then
    display_5h=$((display_5h * WEIGHT / 5))
    (( display_5h > 100 )) && display_5h=100
  fi
  clr_rate5h; printf "%s  5h " "$IC_RATE"; rst
  render_bar "$display_5h" 10 c_teal
  clr_dim; printf " %d%%" "$display_5h"; rst
  if [[ -n "$RATE_5H_RESET" ]]; then
    dim; clr_dim; printf " resets %s" "$(fmt_reset "$RATE_5H_RESET")"; rst
  fi
}

render_rate7d() {
  local display_7d=${RATE_7D_PCT:-0}
  clr_rate7d; printf "%s  7d " "$IC_RATE"; rst
  render_bar "$display_7d" 10 c_lavender
  clr_dim; printf " %d%%" "$display_7d"; rst
  if [[ -n "$RATE_7D_RESET" ]]; then
    dim; clr_dim; printf " resets %s" "$(fmt_reset "$RATE_7D_RESET")"; rst
  fi
}

# ── Render engine ───────────────────────────────────────────────────────────

# render_line <section1> <section2> ...
# Calls render_<name> for each, inserting sep between successful renders.
render_line() {
  local first=1
  for section in "$@"; do
    local fn="render_${section}"
    if type -t "$fn" &>/dev/null; then
      # Capture output to check if section produced anything
      local out
      out=$("$fn" 2>/dev/null)
      if [[ -n "$out" ]]; then
        (( first )) || sep
        printf "%s" "$out"
        first=0
      fi
    fi
  done
  (( first )) || echo ""
}
