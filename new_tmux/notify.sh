#!/usr/bin/env bash
# Tells you when Claude Code (running in another tmux window) is done or needs you.
# Called by Claude Code hooks (Stop -> done, Notification -> wait), by the tmux alert-bell hook (bell) and by the zsh
# long-command hook (new_zsh/notify.zsh: done or fail). Copy of new_tmux/notify.sh, lives in ~/.tmux/notify.sh.
# usage: notify.sh done|wait|bell|fail [label]     (label = the command name for shell commands; default "Claude")
# - marks the window tab (@claude = done|wait|bell|fail; tmux.conf draws a coloured dot, cleared when you select the window)
# - sends a desktop notification (notify-send), unless you are already looking at that window
kind=${1:-done} label=${2:-Claude}
[ -n "$TMUX_PANE" ] || exit 0
[ -t 0 ] || cat >/dev/null 2>&1   # drain the hook's JSON from stdin

IFS='|' read -r wid wname sname active < <(tmux display-message -p -t "$TMUX_PANE" '#{window_id}|#{window_name}|#{session_name}|#{&&:#{window_active},#{session_attached}}')
[ -n "$wid" ] || exit 0

# Looking at it right now (window shown in an attached client whose terminal has focus): nothing to tell.
if [ "$active" = 1 ] && tmux list-clients -t "${sname}" -F '#{client_flags}' 2>/dev/null | grep -q focused; then
  exit 0
fi

# A bare bell must not hide a more useful dot (done / wait / fail); every other event overwrites.
if [ "$kind" = bell ] && [ -n "$(tmux show -wqv -t "$wid" @claude)" ]; then exit 0; fi
tmux set -w -t "$wid" @claude "$kind" \; refresh-client -S 2>/dev/null

case "$kind" in
  wait) title="Claude needs you";   urgency=critical ;;
  fail) title="$label failed";      urgency=critical ;;
  bell) title="Bell";               urgency=normal ;;
  *)    title="$label finished";    urgency=normal ;;
esac
command -v notify-send >/dev/null && notify-send -a Claude -u "$urgency" "$title" "$sname:$wname" 2>/dev/null
exit 0
