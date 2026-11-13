# tmux

Config: `tmux.conf` (live copy: `~/.tmux.conf`). Tested on tmux 3.6 in Alacritty.
The status bar uses powerline arrows, so it needs a Nerd Font (same as the nvim lualine).

## Install

```sh
cp new_tmux/tmux.conf ~/.tmux.conf
tmux            # or: tmux new -As dev   (attach to "dev", or create it)
```

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

A window also closes when its last pane closes (`exit`, `Ctrl-D`, or `x`).

## Sessions

| Keys / command | Does |
|---|---|
| `Q` | Detach: leave tmux, everything keeps running |
| `s` | Session picker |
| `(` / `)` | Previous / next session |
| `$` | Rename session |
| `tmux ls` | List sessions |
| `tmux attach -t NAME` (or `tmux a`) | Resume |
| `tmux kill-session -t NAME` | Close one session for good |
| `tmux kill-server` | Close every session |

Closing the last window of a session ends it.

## Other

| Keys | Does |
|---|---|
| `r` | Reload `~/.tmux.conf` |
| `v` | Copy mode (vi keys, `q` leaves). The mouse wheel also scrolls history. Was `[` in stock tmux |
| in copy mode | `v` starts selecting (`V` whole lines, `C-v` block), `y` yanks to the system clipboard and leaves, `Esc` leaves. `Enter` copies to tmux's own buffer only |

Mouse is on: click a pane to focus it, drag a border to resize.

## Status bar

Far left, on the darkest colour: the OS icon (Nerd Font, picked from
`/etc/os-release`) and the current user.
Then: the mode label. Grey `NORMAL`, yellow `PREFIX` while the prefix is pressed,
blue `COPY` in copy mode, `ZOOM` when a pane is zoomed (same idea as the nvim mode
colours). The session name is on the far right (`Session <name>` with an icon, on
the same dark colour as the user); it is hidden while the prefix hint is shown.
Middle: windows, the current one as a darker block (`Z` marks a zoomed window).
Right (fades like lualine): `pane/total`, date + time, and on the far
right what the current pane is running (`nvim`, `zsh`, ...).

Colours are the koda-glade ones from the nvim lualine (see the comment above
the statusline in `tmux.conf`).

## Unchanged tmux defaults that still work

`o` is no longer "next pane" (it is previous window). `;` last pane, `q` pane
numbers, `{` `}` swap panes, `!` break pane to its own window.
