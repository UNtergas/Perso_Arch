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
  kill-pane|kill-other-panes|size-col|size-row|command|find-window|pane-title|move-pane|pull-pane|copy-*) fmt='#{pane_id}' ;;
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
  kill-other-panes) # every pane of this window except the one you are on (like Ctrl-w o in vim)
    n=$(tmux list-panes -t "$target" -F '#{?@toast_src,,x}' | grep -c x)
    n=$(( n - 1 ))
    if [ "$n" -lt 1 ]; then printf ' No other pane in this window'; sleep 1; exit 0; fi
    printf ' Close the other %s pane%s? [y/N] ' "$n" "$([ "$n" -gt 1 ] && echo s)"
    IFS= read -rsn1 answer || exit 0
    case "$answer" in y|Y) tmux kill-pane -a -t "$target" ;; esac
    exit 0 ;;
  size-col|size-row) # this pane takes N x 10% of its column's height (size-col) / its row's width (size-row)
    if [ "$action" = size-col ]; then printf ' height of the column, 1-9 = 10%%-90%%: '; flag=y; else printf ' width of the row, 1-9 = 10%%-90%%: '; flag=x; fi
    IFS= read -rsn1 key || exit 0
    case "$key" in [1-9]) tmux resize-pane -t "$target" -"$flag" "${key}0%" ;; esac
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
  move-pane) # send this pane to another window (it goes beside that window's panes, or into a new window) and follow it there
    list=$( { printf '%s\t%s\n' '+ new window' ''
      tmux list-windows -a -F '#{session_name}:#{window_index}  #{window_name}  (#{window_panes} pane#{?#{==:#{window_panes},1},,s})' \
        -f "#{!=:#{window_id},$(tmux display-message -p -t "$target" '#{window_id}')}" | awk '{t=$1; sub(/^[^ ]+ +/,""); print $0 "\t" t}'; } )
    pick=$(printf '%s\n' "$list" | fzf --delimiter $'\t' --with-nth 1 --no-info --no-separator --prompt ' move pane to: ' --pointer ' ' \
      --color 'bg:#161514,fg:#d4cec4,prompt:#5e8099,pointer:#5e8099,hl:#999187,hl+:#999187,bg+:#211f1d' --height 100% --layout reverse) || exit 0
    dest=${pick##*$'\t'}
    if [ -z "$dest" ]; then tmux break-pane -s "$target"
    else tmux join-pane -h -s "$target" -t "$dest" \; select-window -t "$dest" \; select-pane -t "$target"; fi
    exit 0 ;;
  pull-pane) # bring a pane of another window into this one (it goes beside the current pane)
    here=$(tmux display-message -p -t "$target" '#{window_id}')
    pick=$(tmux list-panes -a -F '#{pane_id}'$'\t''#{session_name}:#{window_index} #{window_name}  #{pane_current_command}  #{b:pane_current_path}' -f "#{!=:#{window_id},$here}" \
      | fzf --delimiter $'\t' --with-nth 2 --no-info --no-separator --prompt ' pull pane here: ' --pointer ' ' \
        --color 'bg:#161514,fg:#d4cec4,prompt:#5e8099,pointer:#5e8099,hl:#999187,hl+:#999187,bg+:#211f1d' --height 100% --layout reverse) || exit 0
    src=${pick%%$'\t'*}
    [ -n "$src" ] && tmux join-pane -h -s "$src" -t "$target" \; select-pane -t "$src"
    exit 0 ;;
  command) # tmux command line with suggestions: type to filter the command names, Tab completes the highlighted one, Enter runs what is typed
    pick=$(tmux list-commands | awk '{n=$1; u=$0; sub(/^[^ ]+ \([^)]*\) */,"",u); printf "%s\t%s\n", n, u}' \
      | fzf --print-query --delimiter $'\t' --nth 1 --with-nth '1,2' --no-info --no-separator --prompt ' : ' --pointer ' ' --tiebreak begin \
        --bind 'tab:transform-query(echo {1} )' \
        --color 'bg:#161514,fg:#d4cec4,prompt:#5e8099,pointer:#5e8099,hl:#999187,hl+:#999187,bg+:#211f1d,query:#d4cec4' \
        --height 100% --layout reverse)
    out=${pick%%$'\n'*}; out=${out%% }
    [ -n "$out" ] && tmux "$out"
    exit 0 ;;
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
  --color 'bg:#161514,fg:#d4cec4,prompt:#5e8099,query:#d4cec4,bg+:#161514' \
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
