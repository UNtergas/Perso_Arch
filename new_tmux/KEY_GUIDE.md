# tmux

Config: `tmux.conf` (live copy: `~/.tmux.conf`). Tested on tmux 3.8 in Alacritty.
The status bar uses powerline arrows, so it needs a Nerd Font (same as the nvim lualine).

## Install

```sh
mkdir -p ~/.tmux && cp new_tmux/pane-col.sh new_tmux/which-key.sh new_tmux/ask-name.sh new_tmux/dialog.sh ~/.tmux/ && chmod +x ~/.tmux/*.sh
cp new_tmux/tmux.conf ~/.tmux.conf
tmux            # or: tmux new -As dev   (attach to "dev", or create it)
```

`pane-col.sh` (`[` / `]`), `which-key.sh` (the `Alt-e` dropdown) `ask-name.sh` (the new-window name dialog, needs `fzf`) and `dialog.sh` (rename, close and command popups) must be in `~/.tmux/`.
`SETUP_FOR_CLAUDE.md` has the full steps, the checks and the rules for changing the config.

Reload in a running session: `Alt-e R`. A tmux server that is already
running keeps its old config until you reload or `tmux kill-server`.

## The prefix is Alt-e (it opens a key dropdown)

Every key below is pressed after `Alt-e` (release, then press the key).
Alt-e is unused by nvim, kvim, zsh, Alacritty and niri. Not `Alt-k` (nvim/kvim
half page up), not `C-Space` (Alacritty sends the same NUL for Ctrl+\`).

Pressing `Alt-e` opens a dropdown under the status bar, at the right, that lists the
main keys. Press a key and it runs; `Esc` closes the dropdown. Keys that are not
listed (the stock ones in this guide) work too: the dropdown passes any key on to
tmux. `Alt-e Alt-e` sends a literal Alt-e to the program in the pane. While the
dropdown is open the mode label in the status bar shows `PREFIX`.

How it works: the real tmux prefix is switched off (`prefix None`). `Alt-e` is an
ordinary key bound to a popup running `~/.tmux/which-key.sh`, which reads one key
and hands it to tmux's prefix table. So every "prefix + key" binding is unchanged.

## Presets

| Keys | Does |
|---|---|
| `a` | 3 terminals: one big terminal on the left (65%), 2 stacked on the right (35%) |
| `d` | 3 terminals: one on top (70% of the height), 2 side by side below it (30%) |

If the current window has a single pane, the preset turns that window into the layout: the pane you are in
stays and 2 more are added. If the window already has several panes, it is not touched and the preset opens a
new window instead. It opens the same name dialog first (prefilled `side` for `a`, `stacked` for `d`; Esc cancels). Panes start in the current pane's directory;
`a` focuses the left terminal, `d` the top one.

## Panes

| Keys | Does |
|---|---|
| `h` `j` `k` `l` | Move focus left / down / up / right |
| `←` `↓` `↑` `→` | Move the pane itself: swaps places with its neighbour in that direction, focus goes with it (repeatable). Wraps around at the edge, and the pane takes the size of the slot it lands in |
| `H` `J` `K` `L` | Resize the pane in steps of 10% of the window (width for `H` / `L`, height for `J` / `K`), repeatable without pressing the prefix again. Same steps as `C-k h/j/k/l` in nvim |
| `=` | Equal sizes for the whole window, at every level: one big pane on the left and two on the right becomes left 50% and right 50%, with the two right panes 50% of the height each. Same idea as `C-k =` in nvim, but no toggle back. Needs `~/.tmux/equalize.sh` and `python3`. Replaces stock `=` (choose a paste buffer) |
| `\` | Split side by side |
| `-` | Split stacked |
| `z` | Zoom this pane to the whole window, again to restore the layout |
| `[` / `]` | Like niri's `Mod+[` / `Mod+]` (consume-or-expel): a pane alone in its column is consumed into the column on the left / right (stacked below that pane). A pane in a stack is expelled into its own full-height column at the left / right edge. col1 \| col2, `[` on col2 gives col1 over col2, `[` again gives col2 \| col1, `]` reverses. Other columns keep their width: a consumed pane frees its width to the column it joins, an expelled pane takes half of its old column's width. Does nothing at the edge. Expelling goes to the window edge, so with 3+ columns it does not land next to its old column. Replaces stock `]` (paste buffer) |
| `m` | Focus mode: this pane moves to the big 65% slot on the left, all the other panes stack on the right (35%). One way only, no toggle back: use `=` for equal sizes. Only `z`, `c` and `C` toggle |
| `n` | Focus mode, top version: this pane moves to the top (70% of the height), all the other panes sit side by side below it (30%). One way only, like `m` |
| `c` | Make this pane fill its column (full height), again to restore the old split |
| `C` | Make this pane fill its row (95% of the width), again to restore the old split |
| `x` | Close this pane (popup confirmation: y confirms, any other key cancels) |
| `b` | Turn the pane numbers on / off for this window. On by default: every pane has its number (the one `1`..`9` and `q` use) on its top border, dark on the active pane |

`c` does nothing visible on a pane that already fills its column (the big left
terminal of the `a` preset): use it on one of the two right terminals. `C` is the same
for rows: use it on one of the two bottom terminals of the `d` preset.

### Resize and layouts (stock tmux keys that still work)

| Keys | Does |
|---|---|
| `Ctrl-←` `↓` `↑` `→` | Resize by 1 cell (repeatable) |
| `Alt-←` `↓` `↑` `→` | Resize by 5 cells (repeatable). `H` `J` `K` `L` above resize with vim keys, in 10% steps |
| `Alt-1` | Layout: even-horizontal (all panes side by side) |
| `Alt-2` | Layout: even-vertical (all panes stacked) |
| `Alt-3` / `Alt-4` | Layout: main-horizontal / main-vertical (one big pane, the others in a row / column). They use the sizes set in the config: 70% of the height for `Alt-3`, 65% of the width for `Alt-4` |
| `Alt-5` | Layout: tiled |
| `Alt-6` / `Alt-7` | Layout: main-horizontal-mirrored / main-vertical-mirrored |
| `E` | Spread the panes out evenly |
| `Ctrl-o` / `Alt-o` | Rotate the panes forward / backward |
| `{` / `}` | Swap this pane with the previous / next one |
| `!` | Break this pane out into its own window |
| `;` | Last (previously active) pane |
| `q` | Show pane numbers (press a number to jump to it) |
| `"` / `%` | Stock splits (stacked / side by side). They do not keep the directory, use `-` and `\` |
| `M` | Clear the marked pane |

`Space` (stock: cycle layouts) is unbound. `Alt-e Space` does nothing.

Divider arrow: in a window with exactly **two** panes only the half of the divider next to the active pane is dark, and a small arrow near the start of the divider (tmux cannot move it to the middle) points at the active pane. The arrow takes the colour of the half it sits on, so it is faint when the active pane is the bottom or right one. With three or more panes the borders are plain again, no arrow (tmux option `pane-border-indicators`, switched per window by a hook).

## Windows (tabs)

| Keys | Does |
|---|---|
| `N` | New window in the current directory. A floating name dialog opens first (Enter on an empty name keeps the automatic name, Esc cancels) |
| `o` | Previous window |
| `p` | Next window |
| `1`..`9` | Jump to the pane with that number (the same numbers `q` shows) |
| `e` then `1`..`9` | Jump to window by number (`Alt-e e 3`): a small "go to window" dialog like `N` and `&`, any other key closes it |
| `,` | Rename window in a popup (current name prefilled) |
| `&` | Close the whole window (popup: y confirms, any other key cancels) |
| `w` | Tree of all sessions and windows (`j`/`k`, Enter, `x` kills the highlighted one) |
| `Alt-n` / `Alt-p` | Next / previous window that has an alert (activity, bell) |
| `f` | Find a window by the text in its panes |
| `'` | Jump to a window by number or name (prompt) |
| `.` | Move this window to another index (prompt) |
| `<` / `>` | Menu for the window / pane (swap, kill, rename, mark, ...). The same menus open with a right-click |
| `i` | Show info about the current window |

A dot after a window name means something happened there while you were not looking, and you also get a message: a coloured toast on the tmux message line for 5 s if you are in tmux (terminal focused), or a desktop notification if the terminal is not focused. Selecting the window (or refocusing the terminal) clears it. Green: Claude Code finished, or a shell command that ran 30 s or more succeeded. Orange: Claude needs you. Red: a long shell command failed. Blue: a bell (`\a`) rang. A bell never replaces a green, orange or red dot. Needs `~/.tmux/notify.sh`, the Claude Code `Stop` / `Notification` hooks, and for long commands the block from `new_zsh/notify.zsh` in `~/.zshrc` (threshold: `TMUX_NOTIFY_SECS`, default 30; nvim, ssh, less, man, claude and similar are skipped).

### Notification list (the bell)

The bell at the right of the status line keeps every notification. It is white when you have read everything and orange with a count when something is new. `Alt-e g`, or a click on the bell, opens a list under the status bar, newest first: a coloured dot (same colours as the tab dots), how long ago, the text and `session:window`. The count only holds what you have not looked at: visiting a window (or returning to the terminal on it) removes that window's notifications from the count, and opening the list marks all as read. Read notifications stay in the list.

| Key | Does |
|---|---|
| `Enter` | Jump to that window |
| `Ctrl-x` | Remove the highlighted notification |
| `Ctrl-l` | Clear all |
| type | Filter the list |
| `Esc` | Close |

Needs `~/.tmux/notifications.sh` (copy of `new_tmux/notifications.sh`) and `fzf`.

The window name follows the running command (`automatic-rename` is on) until you rename it with `,`.
A window also closes when its last pane closes (`exit`, `Ctrl-D`, or `x`).

## Sessions

| Keys / command | Does |
|---|---|
| `Q` | Detach: leave tmux, everything keeps running |
| `s` | Session picker |
| `(` / `)` | Previous / next session |
| `$` | Rename session in a popup (current name prefilled) |
| `X` | Close this session (popup confirmation) |
| `D` | Choose which attached client to detach |
| `tmux ls` | List sessions |
| `tmux attach -t NAME` (or `tmux a`) | Resume |
| `tmux kill-session -t NAME` | Close one session for good |
| `tmux kill-server` | Close every session |

Closing the last window of a session ends it.

## Copy mode and clipboard

`Alt-e v` enters copy mode (`Alt-e PageUp` enters it and scrolls up a page). `q`, `Esc` or `Ctrl-c` leaves.
The mode uses vi keys. Selecting and copying:

| Keys | Does |
|---|---|
| `v` or `Space` | Start selecting |
| `V` | Select whole lines |
| `Ctrl-v` | Block (rectangle) selection |
| `o` | Jump to the other end of the selection |
| `y` | Copy to the system clipboard and leave (`wl-copy` on Wayland, `xclip` on X11) |
| `Enter` or `Ctrl-j` | Copy to tmux's own buffer only and leave |
| `A` | Append the selection to the buffer and leave |
| `D` | Copy from the cursor to the end of the line and leave |
| `Esc` | Leave (the config binds it to cancel) |

Moving and searching in copy mode:

| Keys | Does |
|---|---|
| `h` `j` `k` `l` | Cursor left / down / up / right |
| `w` `b` `e` | Next word / previous word / end of word (`W` `B` `E` for whitespace-separated words) |
| `0` `^` `$` | Start of line / first non-blank / end of line |
| `g` / `G` | Top / bottom of the history |
| `H` `M` `L` | Top / middle / bottom line of the screen |
| `{` / `}` | Previous / next paragraph |
| `%` | Matching bracket |
| `Ctrl-u` / `Ctrl-d` | Half page up / down |
| `Ctrl-b` / `Ctrl-f` | Page up / down |
| `Ctrl-y` / `Ctrl-e` | Scroll one line up / down |
| `[` / `]` | Scroll down / up one line; hold to repeat (no prefix in copy mode) |
| `z` | Scroll so the cursor is in the middle |
| `/` / `?` | Search forward / backward (prompt) |
| `n` / `N` | Next / previous match |
| `*` / `#` | Search forward / backward for the word under the cursor |
| `f` `F` `t` `T` + a character | Jump to / before that character on the line. `;` repeats, `,` repeats the other way |
| `X` / `Alt-x` | Set a mark / jump to it |
| `1`..`9` | Count prefix (for example `5j`) |
| `:` | Go to a line number |
| `r` | Refresh from the pane |

Pasting: stock `Alt-e ]` (paste the tmux buffer) is taken by consume-or-expel, so paste the system clipboard with the
terminal's own paste (`Ctrl-Shift-v` in Alacritty). `Alt-e =` lists the tmux buffers and pastes the one you pick, `Alt-e #` just lists them.

## Mouse

The mouse is on.

| Action | Does |
|---|---|
| Click a pane | Focus it |
| Click a window tab | Switch to that window |
| Wheel over a pane | Scroll the history (enters copy mode); over a full-screen app such as nvim it is sent to the app |
| Wheel over the status bar | Previous / next window |
| Drag inside a pane | Select text; releasing copies it to tmux's buffer (use `y` in copy mode to be sure it reaches the system clipboard) |
| Double-click / triple-click | Select a word / a line (and copy) |
| Drag a border | Resize the panes |
| Right-click a pane / a tab / the left of the status bar | Menus (pane actions, window actions, session actions) |

## Other

| Keys | Does |
|---|---|
| `R` | Reload `~/.tmux.conf` (was `r`; `r` is the resize mode now) |
| `r` | Resize mode, like i3: `h` `j` `k` `l` resize the active pane in 10% steps, `=` equal sizes, `Esc` / `Enter` / `q` leave (any other key leaves too). The status label shows RESIZE while it is on |
| `:` | tmux command prompt |
| `?` | List every key binding (searchable) |
| `/` then a key | Describe what that key does |
| `t` | Clock (any key leaves) |
| `~` | Show the last messages |

| `Ctrl-z` | Suspend the tmux client |
| `Alt-e` `Alt-e` | Send a literal `Alt-e` to the program in the pane |

## Status bar

Far left, on the darkest colour: the OS icon (Nerd Font, picked from
`/etc/os-release`) and the current user.
Then: the mode label. Grey `NORMAL`, yellow `PREFIX` while the prefix is pressed,
blue `COPY` in copy mode, lilac `ZOOM` when a pane is zoomed (same idea as the nvim mode
colours). Next to it, joined: `pane/total` and what the current pane is running
(`nvim`, `zsh`, ...).
Right side: the window tabs (the current one as a darker block, `Z` marks a zoomed
window), then date + time, and on the far right `Session <name>` with an icon on
the same dark colour as the user. The key hints are in the `Alt-e` dropdown, not in
the status bar.

Colours are the koda-glade ones from the nvim lualine (see the comment above
the statusline in `tmux.conf`).

## Keys that changed from stock tmux

| Key | Stock | Here |
|---|---|---|
| prefix | `Ctrl-b` | `Alt-e` (opens the key dropdown) |
| `d` | detach | `stacked` preset: 3 terminals, 1 on top (detach is `Q`) |
| `a` | (unused) | `side` preset: 3 terminals, 65 / 35 |
| `C` | customize mode | fill the row |
| `o` | next pane | previous window |
| `p` | previous window | next window |
| `n` | next window | focus mode, top version |
| `N` | (unused) | new window |
| `c` | new window | grow the pane to fill its column |
| `[` / `]` | copy mode / paste | consume / expel panes (copy mode is `v`) |
| `\` / `-` | (unused) / (unused) | split side by side / stacked |
| `←` `↓` `↑` `→` | focus | move the pane (focus is `h` `j` `k` `l`) |
| `H` `J` `K` `L` | (unused) | resize |
| `Space` | cycle layouts | unbound |
| `b` | (unused) | box on / off |
| `m` | (unused; `M` clears the marked pane) | focus mode |

### Compact prompts

Rename (`Alt-e ,` / `$`), close (`x` / `&` / `X`), command (`:`), and window jump/move/search (`'` / `.` / `f`) use the same rounded, three-row popup as the new-window dialog. Rename/input accepts Enter and cancels with Esc or Ctrl-C. Close accepts only `y` or `Y`; any other key cancels. `Q` still detaches without closing programs.
