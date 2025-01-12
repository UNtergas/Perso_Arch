#!/bin/bash

# Define the keyboard layouts to cycle through
LAYOUTS=("xkb:us::eng" "Unikey")

CURRENT_LAYOUT=$(ibus engine)

# Find the next layout index
NEXT_INDEX=0
for i in "${!LAYOUTS[@]}"; do
    if [[ "${LAYOUTS[$i]}" == "$CURRENT_LAYOUT" ]]; then
        NEXT_INDEX=$(( (i + 1) % ${#LAYOUTS[@]} ))
        break
    fi
done

# Set the next layout
NEXT_LAYOUT=${LAYOUTS[$NEXT_INDEX]}
ibus engine "$NEXT_LAYOUT"

# Send a notification
notify-send "Keyboard Layout Changed" "New Layout: $NEXT_LAYOUT"