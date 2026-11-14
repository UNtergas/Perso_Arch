#!/bin/sh
# Name dialog for new windows (runs inside a tmux popup). Usage: ask-name.sh [default name]
# Enter: sets @wok=1 and @wname=<typed name> on the tmux server. Esc / Ctrl-C: leaves @wok unset (cancel).
# fzf over an empty list is a one-line text box; --print-query hands back what was typed.
out=$(fzf --print-query --query "$1" --disabled --no-info --no-separator --prompt ' name: ' --pointer ' ' \
  --color 'bg:#eef1f1,fg:#14201f,prompt:#4a6a6a,query:#14201f,bg+:#eef1f1' \
  --height 100% --layout reverse </dev/null)
rc=$?
[ "$rc" -eq 130 ] && exit 0   # Esc / Ctrl-C
tmux set -g @wname "$(printf '%s\n' "$out" | head -n1)" \; set -g @wok 1
