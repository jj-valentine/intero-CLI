#!/bin/bash
CACHE_DIR="${HOME}/.cache/intero"
CACHE_FILE="${CACHE_DIR}/summary-model"

# Seam for future ops matrix YAML — no-op until YAML exists
if [[ -n "${INTERO_TAB_MODEL_MATRIX:-}" && -r "${INTERO_TAB_MODEL_MATRIX}" ]]; then
  : # Future: parse YAML → update CACHE_FILE if changed
fi

if [[ -f "$CACHE_FILE" ]]; then
  model=$(cat "$CACHE_FILE")
  if [[ -n "$model" ]]; then
    echo "$model"
    exit 0
  fi
fi

exit 1
