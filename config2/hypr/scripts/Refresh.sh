#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Scripts for refreshing ags waybar, rofi, swaync, wallust

SCRIPTSDIR=$HOME/.config/hypr/scripts
UserScripts=$HOME/.config/hypr/UserScripts

# Export DBus session to ensure it works for GUI applications
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"

# Define file_exists function
file_exists() {
    if [ -e "$1" ]; then
        return 0  # File exists
    else
        return 1  # File does not exist
    fi
}

# Kill already running processes
_ps=(rofi swaync ags)
for _prs in "${_ps[@]}"; do
    if pidof "${_prs}" >/dev/null; then
        pkill "${_prs}"
    fi
done

# Quit ags
ags -q

sleep 0.3

# Restart Waybar with DBus session correctly passed
pkill waybar && env DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS waybar &

# Relaunch swaync
sleep 0.5
swaync > /dev/null 2>&1 &

# Relaunch ags
ags &

exit 0
