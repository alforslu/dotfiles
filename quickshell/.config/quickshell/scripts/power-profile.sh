#!/bin/bash

# Get current profile
current=$(busctl --system get-property \
    org.freedesktop.UPower.PowerProfiles \
    /org/freedesktop/UPower/PowerProfiles \
    org.freedesktop.UPower.PowerProfiles ActiveProfile) || exit 1
# busctl returns a typed string such as s "balanced".
current=${current#s \"}
current=${current%\"}

# Define options
options="power-saver\nbalanced\nperformance"

# Show the power profile menu
chosen=$(printf '%b\n' "$options" | wofi --dmenu --prompt "Power Profile ($current)" --width 300 --no-custom-entry)

# Apply chosen profile
case "$chosen" in
    power-saver|balanced|performance) powerprofilesctl set "$chosen" ;;
    "") ;;
    *) printf 'Invalid power profile: %s\n' "$chosen" >&2; exit 1 ;;
esac
