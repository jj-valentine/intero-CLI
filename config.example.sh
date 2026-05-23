#!/bin/bash
# intero — User configuration
# Copy to config.sh and customize

# Bar style: parallelogram | blocks | dots | geometric | squares
INTERO_BAR_STYLE="parallelogram"

# Context thresholds (percentage)
# INTERO_CTX_WARN=50
# INTERO_CTX_CAUTION=70
# INTERO_CTX_CRITICAL=85

# Burn rate thresholds (tokens/min)
# INTERO_BURN_WARN=2000
# INTERO_BURN_CRITICAL=5000

# Fetch staleness thresholds (seconds)
# INTERO_FETCH_WARN=3600      # 1 hour
# INTERO_FETCH_CRITICAL=86400  # 1 day

# Feature toggles (1 = on, 0 = off)
# INTERO_SHOW_PR=1
# INTERO_SHOW_MCP=1
# INTERO_SHOW_PEAK=1
# INTERO_SHOW_CACHE=1
# INTERO_SHOW_BURN=1
# INTERO_SHOW_WEIGHTED=1
# INTERO_STATUS_TTL=120
# INTERO_STATUS_QUIET=0

# ── Layout ──────────────────────────────────────────────────────────────────
# Each line is an array of section names. Sections render left-to-right
# with │ separators. Reorder, move between lines, or remove to customize.
# Empty/missing sections are silently skipped.
#
# Available sections:
#   model worktree agent lines branch sync pr duration peak status
#   context burn cache mcp
#   rate5h rate7d

INTERO_LINE1="model agent lines branch sync pr"
INTERO_LINE2="context tokens burn cache duration peak status"
INTERO_LINE3="rate5h mcp"
INTERO_LINE4="rate7d"
