# tmux

Config: `tmux.conf` (live copy: `~/.tmux.conf`). Tested on tmux 3.6 in Alacritty.
The status bar uses powerline arrows, so it needs a Nerd Font (same as the nvim lualine).

## Install

```sh
cp new_tmux/tmux.conf ~/.tmux.conf
tmux            # or: tmux new -As dev   (attach to "dev", or create it)
```

Reload in a running session: `Alt-Space r`. A tmux server that is already
running keeps its old config until you reload or `tmux kill-server`.

## The prefix is Alt-Space

Every key below is pressed after `Alt-Space` (release, then press the key).
Not `C-Space`: Ctrl+Space and Ctrl+\` both send NUL, and the prefix would
swallow them before nvim sees them. Alt-Space is unused by nvim, kvim,
Alacritty and niri. `Alt-Space Alt-Space` sends a literal Alt-Space to the app inside.

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
| `h` `j` `k` `l` | Move left / down / up / right |
| `H` `J` `K` `L` | Resize (repeatable without pressing the prefix again) |
| `\` | Split side by side |
| `-` | Split stacked |
| `z` | Zoom this pane to the whole window, again to restore the layout |
| `c` | Make this pane fill its column, again to restore the old split |
| `x` | Close this pane |

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
| `[` | Copy mode (vi keys, `q` leaves). The mouse wheel also scrolls history |

Mouse is on: click a pane to focus it, drag a border to resize.

## Status bar

Left: session name + state. Grey `NORMAL`, yellow `PREFIX` while the prefix
is pressed, blue `COPY` in copy mode, `ZOOM` when a pane is zoomed (same idea as
the nvim mode colours).
Middle: windows, the current one as a darker block (`Z` marks a zoomed window).
Right (fades like lualine): git branch, `pane/total` + time, and on the far
right what the current pane is running (`nvim`, `zsh`, ...).

Colours are the koda-glade ones from the nvim lualine (see the comment above
the statusline in `tmux.conf`).

## Unchanged tmux defaults that still work

`o` is no longer "next pane" (it is previous window). `;` last pane, `q` pane
numbers, `{` `}` swap panes, `!` break pane to its own window.
