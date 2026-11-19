#!/usr/bin/env bash
# Compact popup prompts. Usage: dialog.sh ACTION TARGET
# display-popup does not expand #{...} in its command, so the target argument arrives
# unexpanded. Resolve the stable ID here instead, from the client the popup belongs to.
set -u
# While a dialog is open the status bar's mode label shows COMMAND in dark purple (@dialog, see status-left in tmux.conf).
tmux set -g @dialog 1 \; refresh-client -S 2>/dev/null
trap 'tmux set -gu @dialog \; refresh-client -S 2>/dev/null' EXIT
action=${1:?action required}
case "$action" in
  kill-pane|command|find-window|pane-title|copy-*) fmt='#{pane_id}' ;;
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
  window-number)
    printf ' window (1-9): '
    IFS= read -rsn1 key || exit 0
    case "$key" in [0-9]) tmux select-window -t "${target}:$key" ;; esac
    exit 0 ;;
  preset)
    printf ' layout: 1 = left + right   2 = top + bottom '
    IFS= read -rsn1 key || exit 0
    case "$key" in 1|2) tmux set -g @preset "$key" ;; esac
    exit 0 ;;
  command) prompt=' : ' ;;
  pane-title) query=$(tmux display-message -p -t "$target" '#{pane_title}'); prompt=' pane title: ' ;;
  copy-search-down) prompt=' search down: ' ;;
  copy-search-up) prompt=' search up: ' ;;
  copy-goto-line) prompt=' goto line: ' ;;
  copy-jump-forward|copy-jump-backward|copy-jump-to-forward|copy-jump-to-backward)
    case "$action" in
      copy-jump-forward) label='jump forward' x=jump-forward ;;
      copy-jump-backward) label='jump backward' x=jump-backward ;;
      copy-jump-to-forward) label='jump to forward' x=jump-to-forward ;;
      *) label='jump to backward' x=jump-to-backward ;;
    esac
    printf ' %s: ' "$label"
    IFS= read -rsn1 key || exit 0
    [[ -n "$key" && "$key" != $'\e' ]] && tmux send-keys -t "$target" -X "$x" -- "$key"
    exit 0 ;;
  copy-repeat) # a count (digits, first one given as the second argument) and then the key to repeat
    n=${2:-}
    while true; do
      printf '\r\033[K repeat: %s' "$n"
      IFS= read -rsn1 key || exit 0
      case "$key" in
        [0-9]) n=$n$key ;;
        ''|$'\e') exit 0 ;;
        *) [[ -n "$n" ]] && tmux send-keys -t "$target" -N "$n" -- "$key"; exit 0 ;;
      esac
    done ;;
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
  pane-title) tmux select-pane -t "$target" -T "$out" ;;
  copy-search-down) tmux send-keys -t "$target" -X search-forward -- "$out" ;;
  copy-search-up) tmux send-keys -t "$target" -X search-backward -- "$out" ;;
  copy-goto-line) tmux send-keys -t "$target" -X goto-line -- "$out" ;;
  jump-window) tmux select-window -t "${target}:$out" ;;
  move-window) tmux move-window -s "$target" -t "$out" ;;
  find-window) tmux find-window -t "$target" -- "$out" ;;
esac
