# tmux

Config: `tmux.conf` (live copy: `~/.tmux.conf`). Tested on tmux 3.6 in Alacritty.
The status bar uses powerline arrows, so it needs a Nerd Font (same as the nvim lualine).

## Install

```sh
mkdir -p ~/.tmux && cp new_tmux/box.sh new_tmux/pane-col.sh ~/.tmux/ && chmod +x ~/.tmux/*.sh
cp new_tmux/tmux.conf ~/.tmux.conf
tmux            # or: tmux new -As dev   (attach to "dev", or create it)
```

`box.sh` (the top edge and `b`) and `pane-col.sh` (`[` / `]`) must be in `~/.tmux/`.
`SETUP_FOR_CLAUDE.md` has the full steps, the checks and the rules for changing the config.

Reload in a running session: `Alt-e r`. A tmux server that is already
running keeps its old config until you reload or `tmux kill-server`.

## The prefix is Alt-e

Every key below is pressed after `Alt-e` (release, then press the key).
Alt-e is unused by nvim, kvim, zsh, Alacritty and niri. Not `Alt-k` (nvim/kvim
half page up), not `C-Space` (Alacritty sends the same NUL for Ctrl+\`).
`Alt-e Alt-e` sends a literal Alt-e to the app inside.

While the prefix is waiting for its key, the status bar shows a yellow hint
line with these keys, and goes back to normal after the chord.

## Presets

| Keys | Does |
|---|---|
| `d` | New `dev` window: nvim 65% on the left, 2 terminals stacked on the right (35%) |
| `a` | New `kdev` window: same layout, `kvim` on the left |

Both start in the current pane's directory and focus the nvim pane.

## Panes

| Keys | Does |
|---|---|
| `h` `j` `k` `l` | Move focus left / down / up / right |
| `←` `↓` `↑` `→` | Move the pane itself: swaps places with its neighbour in that direction, focus goes with it (repeatable). Wraps around at the edge, and the pane takes the size of the slot it lands in |
| `H` `J` `K` `L` | Resize (repeatable without pressing the prefix again) |
| `\` | Split side by side |
| `-` | Split stacked |
| `z` | Zoom this pane to the whole window, again to restore the layout |
| `[` / `]` | Like niri's `Mod+[` / `Mod+]` (consume-or-expel): a pane alone in its column is consumed into the column on the left / right (stacked below that pane). A pane in a stack is expelled into its own full-height column at the left / right edge. col1 \| col2, `[` on col2 gives col1 over col2, `[` again gives col2 \| col1, `]` reverses. Other columns keep their width: a consumed pane frees its width to the column it joins, an expelled pane takes half of its old column's width. Does nothing at the edge. Expelling goes to the window edge, so with 3+ columns it does not land next to its old column. Replaces stock `]` (paste buffer) |
| `m` | Focus mode: this pane moves to the big 65% slot on the left, all the other panes stack on the right (35%). Again to put everything back exactly as before. If you add or close a pane in between, it just applies focus mode again |
| `c` | Make this pane fill its column, again to restore the old split |
| `x` | Close this pane |
| `b` | Turn the active-pane box on / off for this session. On by default: the status becomes 2 rows, row 2 is a top edge that is dark over the active pane (plain line while zoomed). Needs `~/.tmux/box.sh` (copy of `new_tmux/box.sh`) |

`c` does nothing visible on a pane that already fills its column (the nvim
pane in the presets): use it on one of the two right terminals.

### Resize and layouts (stock tmux keys that still work)

| Keys | Does |
|---|---|
| `Ctrl-←` `↓` `↑` `→` | Resize by 1 cell (repeatable) |
| `Alt-←` `↓` `↑` `→` | Resize by 5 cells (repeatable). `H` `J` `K` `L` above do the same with vim keys |
| `Alt-1` | Layout: even-horizontal (all panes side by side) |
| `Alt-2` | Layout: even-vertical (all panes stacked) |
| `Alt-3` / `Alt-4` | Layout: main-horizontal / main-vertical (one big pane, the others in a row / column). They use the 65% size set in the config |
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

## Windows (tabs)

| Keys | Does |
|---|---|
| `n` | New window in the current directory |
| `o` | Previous window |
| `p` | Next window |
| `1`..`9` | Jump to window by number |
| `,` | Rename window |
| `&` | Close the whole window (asks y/n) |
| `w` | Tree of all sessions and windows (`j`/`k`, Enter, `x` kills the highlighted one) |
| `Alt-n` / `Alt-p` | Next / previous window that has an alert (activity, bell) |
| `f` | Find a window by the text in its panes |
| `'` | Jump to a window by number or name (prompt) |
| `.` | Move this window to another index (prompt) |
| `<` / `>` | Menu for the window / pane (swap, kill, rename, mark, ...). The same menus open with a right-click |
| `i` | Show info about the current window |

The window name follows the running command (`automatic-rename` is on) until you rename it with `,`.
A window also closes when its last pane closes (`exit`, `Ctrl-D`, or `x`).

## Sessions

| Keys / command | Does |
|---|---|
| `Q` | Detach: leave tmux, everything keeps running |
| `s` | Session picker |
| `(` / `)` | Previous / next session |
| `$` | Rename session |
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
| `r` | Reload `~/.tmux.conf` |
| `:` | tmux command prompt |
| `?` | List every key binding (searchable) |
| `/` then a key | Describe what that key does |
| `t` | Clock (any key leaves) |
| `~` | Show the last messages |
| `C` | Customize mode: browse and edit options and keys |
| `Ctrl-z` | Suspend the tmux client |
| `Alt-e Alt-e` | Send a literal `Alt-e` to the program in the pane |

## Status bar

Far left, on the darkest colour: the OS icon (Nerd Font, picked from
`/etc/os-release`) and the current user.
Then: the mode label. Grey `NORMAL`, yellow `PREFIX` while the prefix is pressed,
blue `COPY` in copy mode, `ZOOM` when a pane is zoomed (same idea as the nvim mode
colours). Next to it, joined: `pane/total` and what the current pane is running
(`nvim`, `zsh`, ...).
Right side: the window tabs (the current one as a darker block, `Z` marks a zoomed
window), then date + time, and on the far right `Session <name>` with an icon on
the same dark colour as the user. While the prefix is pressed the right side shows
the key hint instead (the session name is hidden then; in a window narrower than
about 150 columns the hint does not fit and is dropped).

Colours are the koda-glade ones from the nvim lualine (see the comment above
the statusline in `tmux.conf`).

## Keys that changed from stock tmux

| Key | Stock | Here |
|---|---|---|
| prefix | `Ctrl-b` | `Alt-e` |
| `d` | detach | `dev` preset (detach is `Q`) |
| `a` | (unused) | `kdev` preset |
| `o` | next pane | previous window |
| `p` | previous window | next window |
| `n` | next window | new window |
| `c` | new window | grow the pane to fill its column |
| `[` / `]` | copy mode / paste | consume / expel panes (copy mode is `v`) |
| `\` / `-` | (unused) / (unused) | split side by side / stacked |
| `←` `↓` `↑` `→` | focus | move the pane (focus is `h` `j` `k` `l`) |
| `H` `J` `K` `L` | (unused) | resize |
| `Space` | cycle layouts | unbound |
| `b` | (unused) | box on / off |
| `m` | (unused; `M` clears the marked pane) | focus mode |
