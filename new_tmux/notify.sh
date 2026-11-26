#!/usr/bin/env bash
# Tells you when Claude Code (running in another tmux window) is done or needs you.
# Called by Claude Code hooks (Stop -> done, Notification -> wait), by the tmux alert-bell hook (bell) and by the zsh
# long-command hook (new_zsh/notify.zsh: done or fail). Copy of new_tmux/notify.sh, lives in ~/.tmux/notify.sh.
# usage: notify.sh done|wait|bell|fail [label]     (label = the command name for shell commands; default "Claude")
# - marks the window tab (@claude = done|wait|bell|fail; tmux.conf draws a coloured dot, cleared when you select the window)
# - you are in tmux (a focused client): a floating dialog pane in its top left corner (never takes keys), no OS popup; terminal not focused: notify-send
# - every event is also logged to ~/.tmux/notifications.log and counted on the status-bar bell (@notif_n)
# - the desktop popup is closed again when you come back to that window (notif-read.sh)
# - nothing at all if you are already looking at that window and its pane is visible (zoomed away / squeezed by c, C = not)
kind=${1:-done} label=${2:-Claude}
[ -n "$TMUX_PANE" ] || exit 0
[ -t 0 ] || cat >/dev/null 2>&1   # drain the hook's JSON from stdin

IFS='|' read -r wid wname sname zoomed pact pw ph < <(tmux display-message -p -t "$TMUX_PANE" \
  '#{window_id}|#{window_name}|#{session_name}|#{window_zoomed_flag}|#{pane_active}|#{pane_width}|#{pane_height}')
[ -n "$wid" ] || exit 0
# Is the pane that sent this really on screen? Not when the window is zoomed on another pane (z), and not when it was
# squeezed to a sliver by c / C (fill the column / row): then you are "in" the window but cannot see the pane.
visible=1
{ [ "$zoomed" = 1 ] && [ "$pact" != 1 ]; } && visible=0
{ [ "${pw:-99}" -lt 10 ] || [ "${ph:-99}" -lt 4 ]; } && visible=0

# Clients whose terminal has focus (needs focus-events on): you are using tmux right now.
# For list-clients the window format is the window that client is showing.
focused=() focused_win=() looking=0
while IFS='|' read -r cname flags cwid; do
  case "$flags" in *focused*) focused+=("$cname"); focused_win+=("$cwid"); [ "$cwid" = "$wid" ] && [ "$visible" = 1 ] && looking=1 ;; esac
done < <(tmux list-clients -F '#{client_name}|#{client_flags}|#{window_id}' 2>/dev/null)

# Looking at that very window (and the pane is visible there): nothing to tell.
[ "$looking" = 1 ] && exit 0

# A bare bell must not hide a more useful dot (done / wait / fail); every other event overwrites.
if [ "$kind" = bell ] && [ -n "$(tmux show -wqv -t "$wid" @claude)" ]; then exit 0; fi
tmux set -w -t "$wid" @claude "$kind" \; refresh-client -S 2>/dev/null

case "$kind" in
  wait) title="Claude needs you";   urgency=critical; bg='#d29a5c' ;;
  fail) title="$label failed";      urgency=critical; bg='#ba6e61' ;;
  bell) title="Bell";               urgency=normal;   bg='#999187' ;;
  *)    title="$label finished";    urgency=normal;   bg='#6b9d66' ;;
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
  # In tmux, in another window: a large dialog in the top left corner of the window each focused client is showing, no OS
  # popup. It is a floating pane (tmux 3.8 new-pane), so it never takes your keys: you keep typing in the pane you were in.
  # It closes after TMUX_NOTIFY_MS (5 s) or when you go to the window that sent it (notif-read.sh kills the panes tagged
  # with that window). The text goes in through the environment so a command name is never read as a format or shell code.
  where="$sname:$wname"
  # big box (7 rows, at least 44 wide) with the title in capitals: a terminal cannot draw a bigger font
  title_big=$(printf %s "$title" | tr '[:lower:]' '[:upper:]')
  w=$(( ${#title_big} > ${#where} ? ${#title_big} : ${#where} )); w=$(( w + 12 )); [ "$w" -lt 44 ] && w=44; [ "$w" -gt 90 ] && w=90
  secs=$(( ${TMUX_NOTIFY_MS:-5000} / 1000 )); [ "$secs" -lt 1 ] && secs=1
  script='printf "\n  \033[1;38;2;%d;%d;%dm\342\227\217  %s\033[0m\n\n  \033[1m%s\033[0m" $((0x${NT_COLOR:1:2})) $((0x${NT_COLOR:3:2})) $((0x${NT_COLOR:5:2})) "$NT_TITLE" "$NT_WHERE"; sleep "$NT_SECS"'
  for i in "${!focused[@]}"; do
    cw=${focused_win[$i]}
    ww=$(tmux display-message -p -t "$cw" '#{window_width}' 2>/dev/null) || continue
    id=$(tmux new-pane -d -A -P -F '#{pane_id}' -t "$cw" -x "$w" -y 7 -X 1 -Y 0 -B heavy \
      -s "bg=#161514,fg=#d4cec4" -S "fg=$bg" -R "fg=$bg" \
      -e "NT_TITLE=$title_big" -e "NT_WHERE=$where" -e "NT_COLOR=$bg" -e "NT_SECS=$secs" \
      bash -c "$script" 2>/dev/null) && [ -n "$id" ] && tmux set -p -t "$id" @toast_src "$wid" 2>/dev/null
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
