#!/bin/bash
# intero — Anthropic peak hours detection
# Peak: weekdays 5am-11am Pacific Time

peak_check() {
  local day hour_pt

  # Get current hour in Pacific time
  hour_pt=$(TZ="America/Los_Angeles" date +%H 2>/dev/null)
  day=$(TZ="America/Los_Angeles" date +%u 2>/dev/null)  # 1=Mon, 7=Sun

  PEAK_ACTIVE=0
  PEAK_REMAINING=""

  # Weekday check (Mon-Fri = 1-5)
  (( day > 5 )) && return

  # Hour check (5am-11am PT = hours 5-10)
  hour_pt=$((10#$hour_pt))  # force base-10
  if (( hour_pt >= 5 && hour_pt < 11 )); then
    PEAK_ACTIVE=1
    local mins_pt
    mins_pt=$(TZ="America/Los_Angeles" date +%M 2>/dev/null)
    mins_pt=$((10#$mins_pt))
    local remaining_mins=$(( (11 - hour_pt) * 60 - mins_pt ))
    local rh=$((remaining_mins / 60))
    local rm=$((remaining_mins % 60))
    if (( rh > 0 )); then
      PEAK_REMAINING="${rh}h${rm}m"
    else
      PEAK_REMAINING="${rm}m"
    fi
  fi
}

# Render peak hours indicator
peak_section() {
  if (( PEAK_ACTIVE )); then
    clr_peak; bld; printf "%s PEAK %s" "$IC_PEAK" "$PEAK_REMAINING"; rst
  fi
}
