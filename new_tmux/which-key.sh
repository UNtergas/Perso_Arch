#!/usr/bin/env bash
# The key dropdown: Alt-e (root binding in tmux.conf) opens this in a popup under the status bar. It lists the keys,
# reads ONE key, closes, and hands that key to tmux's prefix table, so every prefix binding works as before
# (including the stock ones that are not listed here). Esc closes it. Alt-e again sends a literal Alt-e to the pane.
# Copy of new_tmux/which-key.sh, lives in ~/.tmux/which-key.sh. usage: which-key.sh <client_name> <pane_id>
client=$1 pane=$2
tmux set -g @popup 1 \; refresh-client -S 2>/dev/null
trap 'tmux set -gu @popup \; refresh-client -S 2>/dev/null' EXIT

B=$'\e[1m' D=$'\e[0m' H=$'\e[1;38;2;74;106;106m' K=$'\e[1;38;2;20;32;31m' G=$'\e[38;2;90;110;110m'
row() { printf '  %s%-13s%s %s\n' "$K" "$1" "$D" "$2"; }
sec() { printf ' %s%s%s\n' "$H" "$1" "$D"; }
printf ' %sAlt-e%s  %s(press a key, Esc closes)%s\n' "$B" "$D" "$G" "$D"
sec "Presets (here if 1 pane, else new window)"
row "a"          "big one left 65% | 2 stacked right 35%"
row "d"          "one on top 70% | 2 side by side below"
sec "Panes"
row "h j k l"    "focus left / down / up / right"
row "arrows"     "move the pane (swap with its neighbour)"
row "H J K L"    "resize"
row "\\  -"      "split side by side / stacked"
row "z"          "zoom, again to restore"
row "x"          "close the pane"
row "m"          "focus mode: pane big on the left"
row "n"          "focus mode: pane on top, others below"
row "c"          "fill the column, again to restore"
row "C"          "fill the row, again to restore"
row "[  ]"       "consume into / expel from a column"
row "b"          "top edge (box) on / off"
sec "Windows"
row "N"          "new window"
row "o  p"       "previous / next window"
row ","          "rename window"
row "1..9"       "jump to window"
row "w"          "tree of sessions and windows"
row "&"          "close the window"
sec "Sessions and other"
row "Q"          "detach"
row "s  ( )"     "session picker / previous / next"
row "\$"         "rename session"
row "v"          "copy mode (v select, y copy, q leave)"
row "r"          "reload ~/.tmux.conf"
row ":"          "tmux command prompt"
row "?"          "every key binding"
row "Alt-e"      "send a literal Alt-e to the program"

IFS= read -rsn1 k || exit 0
case "$k" in
  $'\e')
    IFS= read -rsn2 -t 0.05 rest
    case "$rest" in
      "")        exit 0 ;;
      "[A"|"OA") name=Up ;;
      "[B"|"OB") name=Down ;;
      "[C"|"OC") name=Right ;;
      "[D"|"OD") name=Left ;;
      e*)        tmux run-shell -b "sleep 0.1; tmux send-keys -t '$pane' M-e"; exit 0 ;;
      *)         exit 0 ;;
    esac ;;
  " ")  name=Space ;;
  "")   exit 0 ;;
  *)    name=$k ;;
esac
q=$(printf '%q' "$name")
tmux run-shell -b "sleep 0.1; tmux switch-client -c '$client' -T prefix; tmux send-keys -K -c '$client' -- $q"
