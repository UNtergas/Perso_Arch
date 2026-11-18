#!/usr/bin/env bash
# Marks notifications as read and refreshes the unread count on the status-bar bell (@notif_n).
# usage: notif-read.sh <window_id>|all|none      none = only recount.
# Also closes the desktop popups of that window. Called by tmux hooks when you select a window or the terminal regains focus (so a notification disappears from the
# count once you have visited its window), by notifications.sh, and by notify.sh. Copy of new_tmux/notif-read.sh.
log=${TMUX_NOTIFY_LOG:-$HOME/.tmux/notifications.log}
target=${1:-none}
if [ -s "$log" ]; then
  exec 9>"$log.lock"; flock 9
  awk -F'\t' -v OFS='\t' -v w="$target" '{ if (NF < 6) $6 = 0; if (w == "all" || $5 == w) $6 = 0; print }' "$log" > "$log.tmp" && mv "$log.tmp" "$log"
  n=$(awk -F'\t' '$6 == 1' "$log" | wc -l)
else
  n=0
fi
# Close the desktop popups (notify.sh keeps "window id <TAB> popup id" lines) of the window you reached, or all of them.
osf=${TMUX_NOTIFY_OS:-$HOME/.tmux/notifications.os}
if [ "$target" != none ] && [ -s "$osf" ] && command -v gdbus >/dev/null; then
  while IFS=$'\t' read -r w id; do
    if [ "$target" = all ] || [ "$w" = "$target" ]; then
      gdbus call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications \
        --method org.freedesktop.Notifications.CloseNotification "$id" >/dev/null 2>&1
    fi
  done < "$osf"
  if [ "$target" = all ]; then : > "$osf"; else awk -F'\t' -v w="$target" '$1 != w' "$osf" > "$osf.tmp" && mv "$osf.tmp" "$osf"; fi
fi
tmux set -g @notif_n "$n" \; refresh-client -S 2>/dev/null
exit 0
