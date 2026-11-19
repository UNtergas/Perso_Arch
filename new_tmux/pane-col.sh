#!/usr/bin/env bash
# prefix + [ / ]: niri-like consume-or-expel, keeping the other columns' widths.
# usage: pane-col.sh left|right <pane_id>
#   pane alone in its column -> joined into the neighbouring column on that side (stacked below its pane); at the edge
#                               it uses the neighbour on the other side, so [ and ] both merge;
#                               the freed width goes to that column, other columns keep theirs
#   pane in a stack          -> expelled into a new full-height column at the left / right edge;
#                               the new column takes half of the old column's width, others keep theirs
dir=$1 pane=$2
win=$(tmux display -p -t "$pane" '#{window_id}')
myleft=$(tmux display -p -t "$pane" '#{pane_left}')
# tiled panes only: a floating notification pane (see notify.sh) is not part of any column
tiled() { tmux list-panes -t "$win" -F "#{?pane_floating_flag,,$1}" | grep .; }

read_cols() { # fills L[] and W[]: one entry per column, left to right
  L=() W=()
  while read -r l w; do L+=("$l"); W+=("$w"); done < <(
    tiled '#{pane_left} #{pane_width}' | sort -n -u -k1,1)
}
read_cols
n=${#W[@]}
for i in "${!L[@]}"; do [ "${L[$i]}" = "$myleft" ] && c=$i; done

# alone in its column? Count the tiled panes at the same left edge (comparing heights does not work: the pane number label on the
# top border takes a row, so a full-height pane is one row shorter than the window)
alone=$(tiled '#{pane_left}' | grep -c "^$myleft$")
if [ "$alone" = 1 ]; then # alone in its column: consume
  # no column on the side you asked for (the pane is at the edge): use the neighbour on the other side, so [ and ] both merge
  [ "$n" -lt 2 ] && { tmux display-message "no other column"; exit 0; }
  [ "$dir" = left ] && [ "$c" -eq 0 ] && dir=right
  [ "$dir" = right ] && [ "$c" -eq $((n - 1)) ] && dir=left
  if [ "$dir" = left ]; then
    t=$((c - 1)); tmux join-pane -v -s "$pane" -t "$win.{left-of}" || exit 1
  else
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
mapfile -t ids < <(tiled '#{pane_left} #{pane_id}' | sort -n -u -k1,1 | cut -d' ' -f2)
for ((i = 0; i < ${#ids[@]} - 1; i++)); do
  tmux resize-pane -t "${ids[$i]}" -x "${W[$i]}"
done
tmux select-pane -t "$pane"
