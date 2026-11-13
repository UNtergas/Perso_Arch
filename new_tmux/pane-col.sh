#!/usr/bin/env bash
# prefix + [ / ]: niri-like consume-or-expel, keeping the other columns' widths.
# usage: pane-col.sh left|right <pane_id>
#   pane alone in its column -> joined into the neighbouring column (stacked below its pane);
#                               the freed width goes to that column, other columns keep theirs
#   pane in a stack          -> expelled into a new full-height column at the left / right edge;
#                               the new column takes half of the old column's width, others keep theirs
dir=$1 pane=$2
win=$(tmux display -p -t "$pane" '#{window_id}')
wh=$(tmux display -p -t "$pane" '#{window_height}')
myleft=$(tmux display -p -t "$pane" '#{pane_left}')
myh=$(tmux display -p -t "$pane" '#{pane_height}')

read_cols() { # fills L[] and W[]: one entry per column, left to right
  L=() W=()
  while read -r l w; do L+=("$l"); W+=("$w"); done < <(
    tmux list-panes -t "$win" -F '#{pane_left} #{pane_width}' | sort -n -u -k1,1)
}
read_cols
n=${#W[@]}
for i in "${!L[@]}"; do [ "${L[$i]}" = "$myleft" ] && c=$i; done

if [ "$myh" = "$wh" ]; then # alone in its column: consume
  if [ "$dir" = left ]; then
    [ "$c" -eq 0 ] && { tmux display-message "nothing to the left"; exit 0; }
    t=$((c - 1)); tmux join-pane -v -s "$pane" -t "$win.{left-of}" || exit 1
  else
    [ "$c" -eq $((n - 1)) ] && { tmux display-message "nothing to the right"; exit 0; }
    t=$((c + 1)); tmux join-pane -v -s "$pane" -t "$win.{right-of}" || exit 1
  fi
  W[$t]=$((W[t] + W[c] + 1))
  W=("${W[@]:0:c}" "${W[@]:c+1}")
else # in a stack: expel
  h=$(((W[c] - 1) / 2))
  W[$c]=$((W[c] - h - 1))
  if [ "$dir" = left ]; then
    tmux join-pane -f -h -b -s "$pane" -t "$win.{next}" || exit 1
    W=("$h" "${W[@]}")
  else
    tmux join-pane -f -h -s "$pane" -t "$win.{next}" || exit 1
    W=("${W[@]}" "$h")
  fi
fi

# one pane per column after the join, left to right; set every width but the last
mapfile -t ids < <(tmux list-panes -t "$win" -F '#{pane_left} #{pane_id}' | sort -n -u -k1,1 | cut -d' ' -f2)
for ((i = 0; i < ${#ids[@]} - 1; i++)); do
  tmux resize-pane -t "${ids[$i]}" -x "${W[$i]}"
done
tmux select-pane -t "$pane"
