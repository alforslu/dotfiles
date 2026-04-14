#!/bin/bash

# Get current profile
current=$(powerprofilesctl get)

# Define options
options="power-saver\nbalanced\nperformance"

# Show rofi menu
chosen=$(echo -e "$options" | wofi -dmenu -p "Power Profile ($current)" -theme-str 'window {width: 300px;}')

# Apply chosen profile
if [ -n "$chosen" ]; then
    powerprofilesctl set "$chosen"
fi
