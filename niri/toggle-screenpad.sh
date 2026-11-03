#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/niri_screenpad_state"
OUTPUT="DP-1"
DEVICE="asus_screenpad"

if [ -f "$STATE_FILE" ]; then
    niri msg output "$OUTPUT" on
    brightnessctl set 100% --device="$DEVICE"
    rm -f "$STATE_FILE"
else
    niri msg output "$OUTPUT" off
    brightnessctl set 0% --device="$DEVICE"
    touch "$STATE_FILE"
fi
