#!/bin/bash

# Script to toggle laptop monitor (eDP-1) in Hyprland
# Save this as ~/.config/hypr/scripts/toggle-laptop-monitor.sh

MONITOR="eDP-1"
STATUS_FILE="/tmp/hypr-monitor-${MONITOR}-status"

# Check if status file exists, if not create it with "enabled" status
if [ ! -f "$STATUS_FILE" ]; then
    echo "enabled" > "$STATUS_FILE"
fi

# Read current status
CURRENT_STATUS=$(cat "$STATUS_FILE")

if [ "$CURRENT_STATUS" = "enabled" ]; then
    # Disable the monitor
    hyprctl keyword monitor "${MONITOR},disable"
    echo "disabled" > "$STATUS_FILE"
    notify-send "Monitor Toggle" "Laptop display disabled" -t 2000
else
    # Re-enable the monitor with your original settings
    hyprctl keyword monitor "${MONITOR},2256x1504@60,0x0,1.566667"
    echo "enabled" > "$STATUS_FILE"
    notify-send "Monitor Toggle" "Laptop display enabled" -t 2000
fi
