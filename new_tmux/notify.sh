#!/usr/bin/env bash
# Tells you when Claude Code (running in another tmux window) is done or needs you.
# Called by Claude Code hooks (Stop -> done, Notification -> wait), by the tmux alert-bell hook (bell) and by the zsh
# long-command hook (new_zsh/notify.zsh: done or fail). Copy of new_tmux/notify.sh, lives in ~/.tmux/notify.sh.
# usage: notify.sh done|wait|bell|fail [label]     (label = the command name for shell commands; default "Claude")
# - marks the window tab (@claude = done|wait|bell|fail; tmux.conf draws a coloured dot, cleared when you select the window)
# - you are in tmux (a focused client): a toast on its message line, no OS popup; terminal not focused: notify-send
# - every event is also logged to ~/.tmux/notifications.log and counted on the status-bar bell (@notif_n)
# - nothing at all if you are already looking at that window
kind=${1:-done} label=${2:-Claude}
[ -n "$TMUX_PANE" ] || exit 0
[ -t 0 ] || cat >/dev/null 2>&1   # drain the hook's JSON from stdin

IFS='|' read -r wid wname sname < <(tmux display-message -p -t "$TMUX_PANE" '#{window_id}|#{window_name}|#{session_name}')
[ -n "$wid" ] || exit 0

# Clients whose terminal has focus (needs focus-events on): you are using tmux right now.
# For list-clients the window format is the window that client is showing.
focused=() looking=0
while IFS='|' read -r cname flags cwid; do
  case "$flags" in *focused*) focused+=("$cname"); [ "$cwid" = "$wid" ] && looking=1 ;; esac
done < <(tmux list-clients -F '#{client_name}|#{client_flags}|#{window_id}' 2>/dev/null)

# Looking at that very window: nothing to tell.
[ "$looking" = 1 ] && exit 0

# A bare bell must not hide a more useful dot (done / wait / fail); every other event overwrites.
if [ "$kind" = bell ] && [ -n "$(tmux show -wqv -t "$wid" @claude)" ]; then exit 0; fi
tmux set -w -t "$wid" @claude "$kind" \; refresh-client -S 2>/dev/null

case "$kind" in
  wait) title="Claude needs you";   urgency=critical; bg='#b25b00' ;;
  fail) title="$label failed";      urgency=critical; bg='#b3261e' ;;
  bell) title="Bell";               urgency=normal;   bg='#3a5fa8' ;;
  *)    title="$label finished";    urgency=normal;   bg='#2f6b3a' ;;
esac

# Keep it for the notification list (bell in the status bar, Alt-e g): time, kind, text, session:window, window id, unread (1).
# The bell counts the unread ones; notif-read.sh clears a window's entries when you visit that window.
log=${TMUX_NOTIFY_LOG:-$HOME/.tmux/notifications.log}
(
  flock 9
  printf '%s\t%s\t%s\t%s\t%s\t1\n' "$(date +%s)" "$kind" "$(printf %s "$title" | tr '\t\n' '  ')" \
    "$(printf %s "$sname:$wname" | tr '\t\n' '  ')" "$wid" >> "$log"
  if [ "$(wc -l < "$log")" -gt 300 ]; then tail -n 200 "$log" > "$log.tmp" && mv "$log.tmp" "$log"; fi
) 9>"$log.lock"
"$(dirname "$0")/notif-read.sh" none

if [ "${#focused[@]}" -gt 0 ]; then
  # In tmux, in another window: show it inside tmux (a toast on the message line of the focused clients), no OS popup.
  # The text goes through "-l"-style escaping of # so a command name cannot be read as a format.
  msg="${title//#/##} · ${sname//#/##}:${wname//#/##}"
  for c in "${focused[@]}"; do
    tmux display-message -c "$c" -d "${TMUX_NOTIFY_MS:-5000}" "#[bg=$bg,fg=#ffffff,bold] ● #[nobold] $msg "
  done
else
  # Not in tmux (another app has focus, or nothing is attached): normal desktop notification.
  command -v notify-send >/dev/null && notify-send -a Claude -u "$urgency" "$title" "$sname:$wname" 2>/dev/null
fi
exit 0
