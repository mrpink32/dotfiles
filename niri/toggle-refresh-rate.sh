#!/usr/bin/env bash
set -euo pipefail

MODE_FILE="${XDG_RUNTIME_DIR:-/tmp}/niri-edp1-mode"

if [ -f "$MODE_FILE" ] && grep -q "120" "$MODE_FILE"; then
    niri msg output eDP-1 mode "3840x2160@60.000"
    echo "60" > "$MODE_FILE"
else
    niri msg output eDP-1 mode "3840x2160@120.030"
    echo "120" > "$MODE_FILE"
fi
