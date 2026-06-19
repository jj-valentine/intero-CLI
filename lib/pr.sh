#!/bin/bash
# intero — PR status via gh CLI (30s TTL cache)

PR_CACHE_TTL=30

_pr_cache_file() {
  local cwd=$1
  local key
  key=$(echo -n "$cwd" | md5 2>/dev/null || echo -n "$cwd" | md5sum 2>/dev/null | cut -d' ' -f1)
  echo "$INTERO_CACHE_DIR/pr-${key}"
}

# Collect PR data for current branch
# Populates: PR_NUMBER, PR_STATE, PR_TITLE, PR_URL, PR_CHECKS_PASS, PR_CHECKS_TOTAL
pr_collect() {
  local cwd=$1
  local cache_file
  cache_file=$(_pr_cache_file "$cwd")

  PR_NUMBER="" ; PR_STATE="" ; PR_TITLE="" ; PR_URL="" ; PR_CHECKS_PASS=0 ; PR_CHECKS_TOTAL=0

  # Check cache
  if [[ -f "$cache_file" ]]; then
    local now file_age
    now=$(date +%s)
    file_age=$(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null)
    if (( now - file_age < PR_CACHE_TTL )); then
      source "$cache_file"
      return
    fi
  fi

  # Fetch PR data (may fail if no PR exists)
  local pr_json
  pr_json=$(cd "$cwd" && gh pr view --json number,state,title,url,body 2>/dev/null) || {
    # No PR on current branch
    cat > "$cache_file" <<'CACHE'
PR_NUMBER=""
PR_STATE=""
PR_TITLE=""
PR_URL=""
PR_CHECKS_PASS=0
PR_CHECKS_TOTAL=0
CACHE
    return
  }

  PR_NUMBER=$(echo "$pr_json" | jq -r '.number // empty')
  PR_STATE=$(echo "$pr_json" | jq -r '.state // empty')
  PR_TITLE=$(echo "$pr_json" | jq -r '.title // empty')
  PR_URL=$(echo "$pr_json" | jq -r '.url // empty')

  # Parse test plan checkboxes from PR body
  local body
  body=$(echo "$pr_json" | jq -r '.body // ""')
  if [[ -n "$body" ]]; then
    PR_CHECKS_TOTAL=$(echo "$body" | grep -c '\- \[.\]' 2>/dev/null || echo 0)
    PR_CHECKS_PASS=$(echo "$body" | grep -c '\- \[x\]' 2>/dev/null || echo 0)
  fi

  # Write cache (printf %q escapes shell metacharacters to prevent injection)
  {
    printf 'PR_NUMBER=%q\n' "$PR_NUMBER"
    printf 'PR_STATE=%q\n' "$PR_STATE"
    printf 'PR_TITLE=%q\n' "$PR_TITLE"
    printf 'PR_URL=%q\n' "$PR_URL"
    printf 'PR_CHECKS_PASS=%d\n' "$PR_CHECKS_PASS"
    printf 'PR_CHECKS_TOTAL=%d\n' "$PR_CHECKS_TOTAL"
  } > "$cache_file"
}

# Render PR section
pr_section() {
  [[ -z "$PR_NUMBER" ]] && return

  clr_pr; printf "%s " "$IC_PR"; rst
  [[ -n "$PR_URL" ]] && link_open "$PR_URL"
  clr_pr; printf "#%s" "$PR_NUMBER"; rst
  [[ -n "$PR_URL" ]] && link_close

  case "$PR_STATE" in
    OPEN)   c_green; printf " OPEN"; rst ;;
    MERGED) c_mauve; printf " MERGED"; rst ;;
    CLOSED) c_red; printf " CLOSED"; rst ;;
  esac

  if (( PR_CHECKS_TOTAL > 0 )); then
    if (( PR_CHECKS_PASS == PR_CHECKS_TOTAL )); then
      c_green
    else
      c_yellow
    fi
    printf " %s%d∕%d" "$IC_SYNCED" "$PR_CHECKS_PASS" "$PR_CHECKS_TOTAL"
    rst
  fi
}
