#!/bin/bash
# intero — Design mock with fake data
# Run: bash mock.sh
# Tweak fake data below to preview different states

INTERO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$INTERO_DIR/lib/colors.sh"
source "$INTERO_DIR/lib/icons.sh"
source "$INTERO_DIR/lib/bars.sh"

# ── Fake data (tweak to preview states) ──────────────────────────────────────

MODEL="Opus 4.6"
THINKING="high"
BRANCH="main"
AHEAD=0
BEHIND=0
DIRTY=2
STAGED=1
UNTRACKED=1
STASH=0
GIT_OP=""           # set to MERGING / REBASING / CHERRY-PICK to test
SYNC_STATE="synced" # synced | behind | ahead | diverged | stale | no-upstream

CTX_PCT=34
CTX_TOKENS="68k"
CTX_TOTAL="200k"

RATE_5H=23
RATE_5H_RESET="4:12pm"
RATE_7D=41
RATE_7D_RESET="Apr 8"

LINES_ADD=156
LINES_DEL=23
DURATION="47m"
BURN_LEVEL="low"    # low | mid | high
CACHE_PCT=87

MCP_OK=3
MCP_TOTAL=3

PR_NUM=42
PR_STATE="OPEN"
PR_CHECKS_PASS=2
PR_CHECKS_TOTAL=5

PEAK=0              # 0 or 1
PEAK_LEFT="2h14m"

WORKTREE=""         # set to name to test
AGENT=""            # set to name to test

# ── Render ───────────────────────────────────────────────────────────────────
echo ""

# ── Line 1: Identity + Git + Sync ───────────────────────────────────────────
clr_model; bld; printf "%s %s" "$IC_MODEL" "$MODEL"; rst
clr_thinking; printf " · %s" "$THINKING"; rst

if [[ -n "$WORKTREE" ]]; then
  sep; c_teal; printf "%s %s" "$IC_WORKTREE" "$WORKTREE"; rst
fi
if [[ -n "$AGENT" ]]; then
  sep; c_sapphire; printf "agent:%s" "$AGENT"; rst
fi

# Branch
sep
clr_branch; printf "%s %s" "$IC_BRANCH" "$BRANCH"; rst
if (( DIRTY > 0 )); then c_peach; printf " %s%d" "$IC_DIRTY" "$DIRTY"; rst; fi
if (( STAGED > 0 )); then c_green; printf " %s%d" "$IC_STAGED" "$STAGED"; rst; fi
if (( UNTRACKED > 0 )); then c_overlay0; printf " %s%d" "$IC_UNTRACKED" "$UNTRACKED"; rst; fi

# Sync status
sep
if [[ -n "$GIT_OP" ]]; then
  clr_op; bld; printf "%s" "$GIT_OP"; rst
elif [[ "$SYNC_STATE" == "behind" ]]; then
  clr_sync_bad; printf "%s %d behind — pull needed" "$IC_WARNING" "${BEHIND:-12}"; rst
elif [[ "$SYNC_STATE" == "ahead" ]]; then
  c_yellow; printf "%s %d to push" "$IC_PUSH" "${AHEAD:-3}"; rst
elif [[ "$SYNC_STATE" == "diverged" ]]; then
  clr_sync_bad; printf "%s %s3 %s12 diverged" "$IC_WARNING" "$IC_PUSH" "$IC_PULL"; rst
elif [[ "$SYNC_STATE" == "stale" ]]; then
  c_red; printf "%s fetched 3d ago" "$IC_REFRESH"; rst
elif [[ "$SYNC_STATE" == "no-upstream" ]]; then
  c_peach; printf "%s no upstream" "$IC_WARNING"; rst
else
  clr_sync_ok; printf "%s synced" "$IC_SYNCED"; rst
fi

if (( STASH > 0 )); then
  sep; clr_stash; printf "%s %d stashed" "$IC_STASH" "$STASH"; rst
fi

# Duration
sep; clr_duration; printf "%s %s" "$IC_CLOCK" "$DURATION"; rst

# Peak
if (( PEAK )); then
  sep; clr_peak; bld; printf "%s PEAK %s" "$IC_PEAK" "$PEAK_LEFT"; rst
fi

echo ""

# ── Line 2: Context + Activity ──────────────────────────────────────────────
clr_ctx; printf "%s ctx " "$IC_CTX"; rst
render_bar "$CTX_PCT" 10 c_sky
clr_dim; printf " %d%%" "$CTX_PCT"; rst
dim; clr_dim; printf " %s/%s" "$CTX_TOKENS" "$CTX_TOTAL"; rst

sep
clr_add; printf "%s +%d" "$IC_DIFF" "$LINES_ADD"; rst
clr_del; printf " -%d" "$LINES_DEL"; rst

sep
case "$BURN_LEVEL" in
  high) clr_burn_hi ;;
  mid)  clr_burn_mid ;;
  *)    clr_burn_low ;;
esac
printf "%s" "$IC_BURN"; rst

sep
clr_cache; printf "%s cache %d%%" "$IC_CACHE" "$CACHE_PCT"; rst

echo ""

# ── Line 3: Rate Limits + MCP + PR ──────────────────────────────────────────
clr_rate5h; printf "%s 5h " "$IC_RATE"; rst
render_bar "$RATE_5H" 10 c_teal
clr_dim; printf " %d%%" "$RATE_5H"; rst
dim; clr_dim; printf " %s%s" "$IC_REFRESH" "$RATE_5H_RESET"; rst

sep
clr_rate7d; printf "7d "; rst
render_bar "$RATE_7D" 10 c_lavender
clr_dim; printf " %d%%" "$RATE_7D"; rst
dim; clr_dim; printf " %s%s" "$IC_REFRESH" "$RATE_7D_RESET"; rst

# MCP
sep
if (( MCP_OK == MCP_TOTAL )); then clr_mcp_ok; else clr_mcp_bad; bld; fi
printf "%s %d/%d" "$IC_MCP" "$MCP_OK" "$MCP_TOTAL"; rst

# PR
if [[ -n "$PR_NUM" ]]; then
  sep
  clr_pr; printf "%s #%d" "$IC_PR" "$PR_NUM"; rst
  case "$PR_STATE" in
    OPEN)   c_green; printf " OPEN"; rst ;;
    MERGED) c_mauve; printf " MERGED"; rst ;;
    CLOSED) c_red; printf " CLOSED"; rst ;;
  esac
  if (( PR_CHECKS_TOTAL > 0 )); then
    if (( PR_CHECKS_PASS == PR_CHECKS_TOTAL )); then c_green; else c_yellow; fi
    printf " %s%d/%d" "$IC_SYNCED" "$PR_CHECKS_PASS" "$PR_CHECKS_TOTAL"; rst
  fi
fi

echo ""
echo ""
