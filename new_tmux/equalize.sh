#!/usr/bin/env bash
# Equal sizes for the whole window, at every level of the layout (prefix + =). Copy of new_tmux/equalize.sh, lives in
# ~/.tmux/equalize.sh. One big pane on the left and two on the right becomes left 50% | right column 50%, and the two right
# panes get 50% of the height each. `select-layout -E` only spreads the neighbours of a single pane and ignores a neighbour
# that is itself a split, so the layout is rebuilt here: tmux 3.8 prints the layout as JSON, every container gets equal
# children (borders are one cell), and the result goes back through select-layout. On a tmux that prints the old
# layout format it falls back to running -E for every pane.
# usage: equalize.sh [pane_id]
target=${1:-$(tmux display-message -p '#{pane_id}')}
layout=$(tmux display-message -p -t "$target" '#{window_layout}')
case "$layout" in
  '{'*) ;;
  *) for pass in 1 2; do for p in $(tmux list-panes -t "$target" -F '#{pane_id}'); do tmux select-layout -t "$p" -E; done; done; exit 0 ;;
esac
new=$(printf '%s' "$layout" | python3 -c '
import json, sys
d = json.load(sys.stdin)
def fit(cell, w, h, x, y):
    cell["w"], cell["h"], cell["x"], cell["y"] = w, h, x, y
    kids = cell.get("c")
    if not kids:
        return
    n = len(kids)
    if cell["t"] == "h":                      # side by side: split the width
        avail = w - (n - 1)
        base, extra = divmod(avail, n)
        cx = x
        for i, k in enumerate(kids):
            kw = base + (1 if i < extra else 0)
            fit(k, kw, h, cx, y)
            cx += kw + 1
    else:                                     # stacked: split the height
        avail = h - (n - 1)
        base, extra = divmod(avail, n)
        cy = y
        for i, k in enumerate(kids):
            kh = base + (1 if i < extra else 0)
            fit(k, w, kh, x, cy)
            cy += kh + 1
root = d["L"]
fit(root, root["w"], root["h"], root["x"], root["y"])
print(json.dumps(d, separators=(",", ":")))
') || exit 0
tmux select-layout -t "$target" "$new"
