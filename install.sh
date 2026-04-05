#!/bin/bash
# intero — Install script
# Symlinks pulse.sh into ~/.claude/ and updates settings.json

set -e

INTERO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"

echo "Installing intero..."

# Create symlink
ln -sf "$INTERO_DIR/intero.sh" "$CLAUDE_DIR/statusline-command.sh"
echo "  ✓ Symlinked intero.sh → ~/.claude/statusline-command.sh"

# Update settings.json statusLine config
if [[ -f "$SETTINGS" ]]; then
  # Check if statusLine already exists
  if jq -e '.statusLine' "$SETTINGS" &>/dev/null; then
    # Update existing
    tmp=$(mktemp)
    jq --arg cmd "bash $INTERO_DIR/intero.sh" '.statusLine.command = $cmd' "$SETTINGS" > "$tmp"
    mv "$tmp" "$SETTINGS"
    echo "  ✓ Updated statusLine command in settings.json"
  else
    # Add statusLine
    tmp=$(mktemp)
    jq --arg cmd "bash $INTERO_DIR/intero.sh" '. + {statusLine: {type: "command", command: $cmd}}' "$SETTINGS" > "$tmp"
    mv "$tmp" "$SETTINGS"
    echo "  ✓ Added statusLine config to settings.json"
  fi
else
  echo "  ⚠ settings.json not found at $SETTINGS"
fi

# Copy example config if no config exists
if [[ ! -f "$INTERO_DIR/config.sh" ]]; then
  cp "$INTERO_DIR/config.example.sh" "$INTERO_DIR/config.sh"
  echo "  ✓ Created config.sh from example (customize as needed)"
fi

echo ""
echo "Done. Restart Claude Code to see the status line."
echo "Run 'bash $INTERO_DIR/mock.sh' to preview the design."
