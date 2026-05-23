#!/bin/bash
# intero — Claude platform status (via status.claude.com Statuspage API)

: "${INTERO_STATUS_TTL:=120}"
STATUS_CACHE="/tmp/intero-status"
STATUS_URL="https://status.claude.com/api/v2/summary.json"

# Map Statuspage status string → severity int
# 0=operational, 1=degraded, 2=partial_outage, 3=major_outage, -1=unknown
_status_severity() {
  case "$1" in
    operational)           echo 0 ;;
    degraded_performance)  echo 1 ;;
    partial_outage)        echo 2 ;;
    major_outage)          echo 3 ;;
    *)                     echo -1 ;;
  esac
}

# Collect status for Claude Code + Claude API
# Populates: STATUS_CC (0-3, -1=unknown), STATUS_API (0-3, -1=unknown)
status_collect() {
  STATUS_CC=-1; STATUS_API=-1

  if [[ -f "$STATUS_CACHE" ]]; then
    local now file_age
    now=$(date +%s)
    file_age=$(stat -f %m "$STATUS_CACHE" 2>/dev/null || stat -c %Y "$STATUS_CACHE" 2>/dev/null)
    if (( now - file_age < INTERO_STATUS_TTL )); then
      source "$STATUS_CACHE"
      return
    fi
  fi

  local json
  json=$(curl -s --max-time 2 "$STATUS_URL" 2>/dev/null) || {
    cat > "$STATUS_CACHE" <<'CACHE'
STATUS_CC=-1
STATUS_API=-1
CACHE
    return
  }

  local cc_raw api_raw
  cc_raw=$(echo "$json" | jq -r '.components[] | select(.name == "Claude Code") | .status' 2>/dev/null)
  api_raw=$(echo "$json" | jq -r '.components[] | select(.name | startswith("Claude API")) | .status' 2>/dev/null)

  STATUS_CC=$(_status_severity "$cc_raw")
  STATUS_API=$(_status_severity "$api_raw")

  cat > "$STATUS_CACHE" <<CACHE
STATUS_CC=$STATUS_CC
STATUS_API=$STATUS_API
CACHE
}
