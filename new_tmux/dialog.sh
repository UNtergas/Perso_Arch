#!/usr/bin/env bash
# Compact popup prompts. Usage: dialog.sh ACTION TARGET
# display-popup does not expand #{...} in its command, so the target argument arrives
# unexpanded. Resolve the stable ID here instead, from the client the popup belongs to.
set -u
action=${1:?action required}
case "$action" in
  kill-pane|command|find-window) fmt='#{pane_id}' ;;
  kill-window|rename-window|move-window) fmt='#{window_id}' ;;
  *) fmt='#{session_id}' ;;
esac
target=$(tmux display-message -p "$fmt")
query= prompt=
case "$action" in
  rename-window) query=$(tmux display-message -p -t "$target" '#{window_name}'); prompt=' name: ' ;;
  rename-session) query=$(tmux display-message -p -t "$target" '#{session_name}'); prompt=' name: ' ;;
  kill-window|kill-pane|kill-session)
    printf ' Close %s? [y/N] ' "${action#kill-}"
    IFS= read -rsn1 answer || exit 0
    case "$answer" in y|Y) tmux "$action" -t "$target" ;; esac
    exit 0 ;;
  command) prompt=' : ' ;;
  jump-window) prompt=' window: ' ;;
  move-window) prompt=' index: ' ;;
  find-window) prompt=' find: ' ;;
  *) exit 2 ;;
esac
out=$(fzf --print-query --query "$query" --disabled --no-info --no-separator \
  --prompt "$prompt" --pointer ' ' \
  --color 'bg:#eef1f1,fg:#14201f,prompt:#4a6a6a,query:#14201f,bg+:#eef1f1' \
  --height 100% --layout reverse </dev/null)
rc=$?
# fzf returns 1 on Enter when its empty candidate list has no match; the query is still valid.
case "$rc" in 0|1) ;; *) exit 0 ;; esac
out=${out%%$'\n'*}
[[ -n "$out" ]] || exit 0
case "$action" in
  rename-window|rename-session) tmux "$action" -t "$target" -- "$out" ;;
  command) tmux "$out" ;;
  jump-window) tmux select-window -t "${target}:$out" ;;
  move-window) tmux move-window -s "$target" -t "$out" ;;
  find-window) tmux find-window -t "$target" -- "$out" ;;
esac
