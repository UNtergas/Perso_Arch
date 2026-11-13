#!/bin/sh
# The box: the status becomes 2 rows (status 2); row 1 is the normal clickable status line, row 2 is the top edge of
# the active pane (dark over the active pane, light over the others, ┳ at every divider). Panes keep their own
# dividers. Copy of new_tmux/box.sh, lives in ~/.tmux/box.sh
# On by default (status 2 and @box 1 are set in tmux.conf); prefix + b toggles it per session.
# usage: box.sh toggle|on|off | edge [window_id]
cur=${2:-$(tmux display -p '#{window_id}')}
sess=$(tmux display -p -t "$cur" '#{session_id}')
boxed() { [ "$(tmux display -p -t "$sess" '#{@box}')" = 1 ]; } # @box is 1 by default (tmux.conf), 0 once toggled off
D="#4a6a6a" L="#dde5e5" # active / inactive colour
edge() { # the top edge as one string for the 2nd status row
  boxed || return 0
  if [ "$(tmux display -p -t "$cur" '#{window_zoomed_flag}')" = 1 ]; then # zoomed: one pane, a plain line
    s="#[fg=$D]$(tmux display -p -t "$cur" '#{R:━,#{window_width}}')"
  else
    s=$(tmux list-panes -t "$cur" -F '#{pane_top} #{pane_left} #{pane_width} #{pane_active}' |
      awk '$1==0 {print $2, $3, $4}' | sort -n |
      awk -v D="$D" -v L="$L" '
        { n++; act = $3; fc = act ? D : L
          if (n > 1) out = out "#[fg=" ((act || prev) ? D : L) "]┳"
          out = out "#[fg=" fc "]"
          for (i = 0; i < $2; i++) out = out "━"
          prev = act }
        END { print out }')
  fi
  tmux set -w -t "$cur" @topedge "$s"
}
drop_margins() { # margin panes of the earlier version of the box, if any are left
  for p in $(tmux list-panes -t "$1" -F '#{pane_id} #{@margin}' | awk '$2==1{print $1}'); do tmux kill-pane -t "$p"; done
}
on() {
  tmux set -t "$sess" @box 1
  tmux set -t "$sess" status 2
  for w in $(tmux list-windows -t "$sess" -F '#{window_id}'); do drop_margins "$w"; cur=$w edge; done
}
off() {
  tmux set -t "$sess" status on
  tmux set -t "$sess" @box 0
  for w in $(tmux list-windows -t "$sess" -F '#{window_id}'); do drop_margins "$w"; tmux set -wu -t "$w" @topedge; done
}
case "$1" in
  on) on ;; off) off ;;
  edge|newwin) edge ;;
  *) if boxed; then off; else on; fi ;;
esac
