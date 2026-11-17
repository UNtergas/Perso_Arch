#!/usr/bin/env bash
# The notification list (runs in a tmux popup, opened by Alt-e g or a click on the bell in the status bar).
# Reads ~/.tmux/notifications.log (written by notify.sh): time, kind, text, session:window, window id.
# Enter jumps to the window, Ctrl-x removes the highlighted one, Ctrl-l clears all, Esc closes. Copy of new_tmux/notifications.sh.
# usage: notifications.sh      (internal: notifications.sh --list, prints the fzf rows)
# display-popup does not expand #{...} in its command, so the client is resolved here, like dialog.sh does.
log=${TMUX_NOTIFY_LOG:-$HOME/.tmux/notifications.log}

list() {
  if [ ! -s "$log" ]; then printf '\033[38;2;90;110;110m  No notifications\033[0m\t\t0\n'; return 0; fi
  awk -F'\t' -v now="$(date +%s)" '
    function age(s) { s = now - s; if (s < 60) return s "s"; if (s < 3600) return int(s/60) "m"; if (s < 86400) return int(s/3600) "h"; return int(s/86400) "d" }
    { n[NR] = NR; l[NR] = $0 }
    END {
      for (i = NR; i >= 1; i--) {
        split(l[i], f, "\t")
        c = (f[2] == "done") ? "47;107;58" : (f[2] == "wait") ? "178;91;0" : (f[2] == "fail") ? "179;38;30" : "58;95;168"
        printf "\033[38;2;%sm●\033[0m %4s  %-28s \033[38;2;90;110;110m%s\033[0m\t%s\t%d\n", c, age(f[1]), f[3], f[4], f[5], i
      }
    }' "$log"
}
if [ "$1" = "--list" ]; then list; exit 0; fi

client=$(tmux display-message -p '#{client_name}')
# Opening the list counts as reading everything.
tmux set -g @notif_n 0 \; refresh-client -S 2>/dev/null

hdr="Enter open   ^x remove   ^l clear all   Esc close"
self=$(printf '%q' "$0")
sel=$(list | fzf --ansi --no-sort --delimiter $'\t' --with-nth 1 --layout reverse --height 100% \
  --no-info --no-separator --prompt ' search: ' --pointer '▶' --header "$hdr" \
  --color 'bg:#eef1f1,fg:#14201f,bg+:#cbd6d6,fg+:#14201f,pointer:#4a6a6a,prompt:#4a6a6a,header:#5a6e6e,hl:#b25b00,hl+:#b25b00' \
  --bind "ctrl-x:execute-silent(sed -i {3}d '$log')+reload($self --list)" \
  --bind "ctrl-l:execute-silent(: > '$log')+reload($self --list)") || exit 0

wid=$(printf '%s' "$sel" | cut -f2)
[ -n "$wid" ] || exit 0
sid=$(tmux display-message -p -t "$wid" '#{session_id}' 2>/dev/null)
if [ -z "$sid" ]; then tmux display-message -c "$client" "That window is closed"; exit 0; fi
tmux switch-client -c "$client" -t "$sid" \; select-window -t "$wid"
exit 0
