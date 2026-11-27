#!/bin/sh
# Name dialog for new windows (runs inside a tmux popup). Usage: ask-name.sh [default name]
# Enter: sets @wok=1 and @wname=<typed name> on the tmux server. Esc / Ctrl-C: leaves @wok unset (cancel).
# fzf over an empty list is a one-line text box; --print-query hands back what was typed.
# the status bar's mode label shows COMMAND (dark purple) while this dialog is open
tmux set -g @dialog 1 \; refresh-client -S 2>/dev/null
trap 'tmux set -gu @dialog \; refresh-client -S 2>/dev/null' EXIT
out=$(fzf --print-query --query "$1" --disabled --no-info --no-separator --prompt ' name: ' --pointer ' ' \
  --color 'bg:#202020,fg:#d4cec4,prompt:#5e8099,query:#d4cec4,bg+:#202020' \
  --height 100% --layout reverse </dev/null)
rc=$?
[ "$rc" -eq 130 ] && exit 0   # Esc / Ctrl-C
tmux set -g @wname "$(printf '%s\n' "$out" | head -n1)" \; set -g @wok 1
