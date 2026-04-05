#!/bin/bash
# intero — MCP server health probe
# Writes results to cache file; read by main pulse.sh
# Intended to run async (not every status line refresh)

SESSION_ID="${1:-unknown}"
CACHE_FILE="/tmp/intero-mcp-${SESSION_ID}"

# Count configured MCP servers
total=0
healthy=0

# Check CLI-configured servers
while IFS= read -r server; do
  [[ -z "$server" ]] && continue
  (( total++ ))
  # Server is listed = configured. We can't easily probe stdio servers,
  # so we count configured as healthy (they'd error on tool use if broken)
  (( healthy++ ))
done < <(claude mcp list 2>/dev/null | grep -E '^\s+\w' | awk '{print $1}')

# Write cache
cat > "$CACHE_FILE" <<CACHE
MCP_HEALTHY=$healthy
MCP_TOTAL=$total
CACHE
