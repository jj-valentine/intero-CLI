#!/bin/bash
# intero — Formatting utilities

# Abbreviate token counts: 134938 → "135k", 1500000 → "1.5M"
fmt_tokens() {
  local n=$1
  if (( n >= 1000000 )); then
    printf "%.1fM" "$(echo "scale=1; $n / 1000000" | bc)"
  elif (( n >= 1000 )); then
    printf "%.0fk" "$(echo "scale=0; $n / 1000" | bc)"
  else
    printf "%d" "$n"
  fi
}

# Duration: milliseconds → "47m", "1h 23m", "2h"
fmt_duration() {
  local ms=$1
  local secs=$((ms / 1000))
  local mins=$((secs / 60))
  local hrs=$((mins / 60))
  mins=$((mins % 60))

  if (( hrs > 0 && mins > 0 )); then
    printf "%dh %dm" "$hrs" "$mins"
  elif (( hrs > 0 )); then
    printf "%dh" "$hrs"
  elif (( mins > 0 )); then
    printf "%dm" "$mins"
  else
    printf "%ds" "$secs"
  fi
}

# Relative time from unix epoch: "just now", "3m ago", "2h ago", "3d ago"
fmt_relative() {
  local then=$1
  local now
  now=$(date +%s)
  local diff=$((now - then))

  if (( diff < 60 )); then
    printf "just now"
  elif (( diff < 3600 )); then
    printf "%dm ago" "$((diff / 60))"
  elif (( diff < 86400 )); then
    printf "%dh ago" "$((diff / 3600))"
  else
    printf "%dd ago" "$((diff / 86400))"
  fi
}

# Rate limit reset: unix epoch → "4:12pm" (today) or "Apr 8" (future date)
fmt_reset() {
  local epoch=$1
  local today
  today=$(date +%Y-%m-%d)
  local reset_day
  reset_day=$(date -r "$epoch" +%Y-%m-%d 2>/dev/null)

  if [[ "$reset_day" == "$today" ]]; then
    date -r "$epoch" +"%l:%M%p" 2>/dev/null | tr -d ' ' | tr '[:upper:]' '[:lower:]'
  else
    date -r "$epoch" +"%b %-d" 2>/dev/null
  fi
}

# Burn rate: tokens/min from cumulative tokens and duration_ms
# Returns: tokens_per_min (integer)
calc_burn_rate() {
  local total_tokens=$1 duration_ms=$2
  if (( duration_ms <= 0 )); then
    echo 0
    return
  fi
  local mins=$((duration_ms / 60000))
  (( mins <= 0 )) && mins=1
  echo $((total_tokens / mins))
}

# Cache hit ratio: percentage of tokens served from cache
calc_cache_ratio() {
  local cache_read=$1 cache_create=$2 input=$3
  local total=$((cache_read + cache_create + input))
  if (( total <= 0 )); then
    echo 0
    return
  fi
  echo $((cache_read * 100 / total))
}

# Weighted token multiplier by model
# Opus counts 5x toward rate limits vs Sonnet/Haiku
model_weight() {
  local model_id=$1
  case "$model_id" in
    *opus*)  echo 5 ;;
    *sonnet*) echo 1 ;;
    *haiku*) echo 1 ;;
    *) echo 1 ;;
  esac
}
