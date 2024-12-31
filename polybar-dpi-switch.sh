#!/bin/bash

# Define your monitors
laptop_monitor="eDP-1"
external_monitors=("DP-1" "DP-2")  # Array to handle multiple external monitors

# DPI values for each monitor
laptop_dpi=192
external_dpi=96

# Detect the active monitor using xrandr
active_monitor=$(xrandr --query | grep " connected primary" | cut -d" " -f1)

# Determine DPI based on the active monitor
if [[ "$active_monitor" == "$laptop_monitor" ]]; then
    dpi=$laptop_dpi
elif [[ " ${external_monitors[@]} " =~ " $active_monitor " ]]; then
    dpi=$external_dpi
else
    dpi=96  # Fallback DPI
fi

# Export the DPI to an environment variable for Polybar
export POLYBAR_DPI=$dpi

# Restart Polybar with the new DPI
polybar-msg cmd quit
killall -q polybar

# Launch polybar
polybar mybar & disown
