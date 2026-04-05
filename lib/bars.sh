#!/bin/bash
# intero — Bar renderer with multiple styles and threshold colors

# Bar style characters: filled / empty
declare -A BAR_FILLED BAR_EMPTY
BAR_FILLED[parallelogram]="▰"  ; BAR_EMPTY[parallelogram]="▱"
BAR_FILLED[blocks]="▓"         ; BAR_EMPTY[blocks]="▒"
BAR_FILLED[dots]="●"           ; BAR_EMPTY[dots]="○"
BAR_FILLED[geometric]="◆"     ; BAR_EMPTY[geometric]="◇"
BAR_FILLED[squares]="■"       ; BAR_EMPTY[squares]="□"

# Default style (overridable via config)
INTERO_BAR_STYLE="${INTERO_BAR_STYLE:-parallelogram}"

# Threshold color function — returns the right color for a given percentage
# Usage: threshold_color <pct> <base_color_fn>
# base_color_fn is the "cool" color to use when below 50%
threshold_color() {
  local pct=$1 base_fn=$2
  if (( pct >= 85 )); then
    c_red
  elif (( pct >= 70 )); then
    c_peach
  elif (( pct >= 50 )); then
    c_yellow
  else
    $base_fn
  fi
}

# Render a bar with threshold coloring
# Usage: render_bar <pct> <width> <base_color_fn>
# Example: render_bar 34 10 c_sky
render_bar() {
  local pct=$1 width=${2:-10} base_fn=${3:-c_sky}
  local style="${INTERO_BAR_STYLE}"
  local filled_char="${BAR_FILLED[$style]}"
  local empty_char="${BAR_EMPTY[$style]}"
  local filled=$((pct * width / 100))
  (( filled > width )) && filled=$width

  # Filled portion — color based on threshold
  threshold_color "$pct" "$base_fn"
  for ((i=0; i<filled; i++)); do printf "%s" "$filled_char"; done

  # Empty portion — dim
  c_overlay0
  for ((i=filled; i<width; i++)); do printf "%s" "$empty_char"; done
  rst
}
