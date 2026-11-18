#!/usr/bin/env bash
# Tells you when Claude Code (running in another tmux window) is done or needs you.
# Called by Claude Code hooks (Stop -> done, Notification -> wait), by the tmux alert-bell hook (bell) and by the zsh
# long-command hook (new_zsh/notify.zsh: done or fail). Copy of new_tmux/notify.sh, lives in ~/.tmux/notify.sh.
# usage: notify.sh done|wait|bell|fail [label]     (label = the command name for shell commands; default "Claude")
# - marks the window tab (@claude = done|wait|bell|fail; tmux.conf draws a coloured dot, cleared when you select the window)
# - you are in tmux (a focused client): a dialog popup in its top right corner, no OS popup; terminal not focused: notify-send
# - every event is also logged to ~/.tmux/notifications.log and counted on the status-bar bell (@notif_n)
# - the desktop popup is closed again when you come back to that window (notif-read.sh)
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
  # In tmux, in another window: a small dialog popup in the top right corner of the focused clients, no OS popup.
  # It closes by itself after TMUX_NOTIFY_MS (5 s) or on any key (that key is used up closing it). The text goes in through
  # the environment so a command name is never read as a format or as shell code. If the client already shows an overlay
  # (your own popup, a menu) tmux does not open this one: the tab dot and the bell count still tell you.
  where="$sname:$wname"
  w=$(( ${#title} > ${#where} ? ${#title} : ${#where} )); w=$(( w + 8 )); [ "$w" -lt 28 ] && w=28; [ "$w" -gt 64 ] && w=64
  # popup -y is the row just below the popup (its bottom edge), so the top edge sits under a top status line at y = height + 1
  top=4; [ "$(tmux show -gv status-position 2>/dev/null)" = top ] && top=5
  secs=$(( ${TMUX_NOTIFY_MS:-5000} / 1000 )); [ "$secs" -lt 1 ] && secs=1
  # display-popup waits until the popup is closed, so it runs in the background: the hook that called us must not wait 5 s
  # the popup reads one key with a timeout: any key (used up) or the timeout closes it, so you never type blind for 5 s
  script='printf "\033[1;38;2;%d;%d;%dm \342\227\217 %s\033[0m\n \033[2m%s\033[0m" $((0x${NT_COLOR:1:2})) $((0x${NT_COLOR:3:2})) $((0x${NT_COLOR:5:2})) "$NT_TITLE" "$NT_WHERE"; read -rsn1 -t "$NT_SECS"'
  for c in "${focused[@]}"; do
    tmux display-popup -c "$c" -x R -y "$top" -w "$w" -h 4 -E -b rounded -s "bg=#f4f7f7,fg=#1d2b2a" -S "fg=$bg" \
      -e "NT_TITLE=$title" -e "NT_WHERE=$where" -e "NT_COLOR=$bg" -e "NT_SECS=$secs" \
      bash -c "$script" </dev/null >/dev/null 2>&1 &
  done
else
  # Not in tmux (another app has focus, or nothing is attached): normal desktop notification.
  # -p prints the popup's id: it is kept per window so notif-read.sh can close the popup when you come back to that window
  # (a "wait" popup is critical, it never times out, and used to stay on screen after you had already seen the window)
  if command -v notify-send >/dev/null; then
    osf=${TMUX_NOTIFY_OS:-$HOME/.tmux/notifications.os}
    id=$(notify-send -p -a Claude -u "$urgency" "$title" "$sname:$wname" 2>/dev/null)
    case "$id" in ''|*[!0-9]*) ;; *)
      printf '%s\t%s\n' "$wid" "$id" >> "$osf"
      if [ "$(wc -l < "$osf")" -gt 60 ]; then tail -n 40 "$osf" > "$osf.tmp" && mv "$osf.tmp" "$osf"; fi ;;
    esac
  fi
fi
exit 0
