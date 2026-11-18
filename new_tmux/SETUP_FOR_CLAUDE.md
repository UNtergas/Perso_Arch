# tmux setup, for a Claude session on a new machine

Tell the user what you are about to do, then follow the steps. The config is `new_tmux/tmux.conf`; it needs the helper
scripts next to it in `~/.tmux/`. Without them `[` / `]` do nothing or print errors.

| What | From this repo | Goes to |
|---|---|---|
| Config | `new_tmux/tmux.conf` | `~/.tmux.conf` |
| `[` / `]` consume-or-expel panes | `new_tmux/pane-col.sh` | `~/.tmux/pane-col.sh` (executable) |
| The `Alt-e` key dropdown | `new_tmux/which-key.sh` | `~/.tmux/which-key.sh` (executable) |
| New-window name dialog (`N`, `a`, `d`) | `new_tmux/ask-name.sh` | `~/.tmux/ask-name.sh` (executable) |
| Rename/close/command popups | `new_tmux/dialog.sh` | `~/.tmux/dialog.sh` (executable) |
| Claude Code notifications (`Stop` / `Notification` hooks) | `new_tmux/notify.sh` | `~/.tmux/notify.sh` (executable) |
| Notification list (the bell, `Alt-e g`) | `new_tmux/notifications.sh` | `~/.tmux/notifications.sh` (executable) |
| Marks notifications read (hooks, bell count) | `new_tmux/notif-read.sh` | `~/.tmux/notif-read.sh` (executable) |
| `Alt-e =` equal sizes for the whole window | `new_tmux/equalize.sh` | `~/.tmux/equalize.sh` (executable; needs `python3`) |
| Key guide for the user | `new_tmux/KEY_GUIDE.md` | stays in the repo |

## 1. Prerequisites (check each, tell the user what is missing)

- **tmux 3.7 or later is required; 3.8 is tested on this machine.** Check `command -v tmux` and `tmux -V`.
  Relative line numbers in copy mode require 3.7+. Do not omit `copy-mode-line-numbers relative` to support an older version:
  upgrade tmux using the instructions below. The popup bindings also need `display-popup -b` and `send-keys -K`.
- A Nerd Font in the terminal (the statusline arrows and the OS icon are Nerd Font glyphs).
- Copy mode yanks to the clipboard with `wl-copy` (Wayland) or `xclip` (X11): one of them must be installed.
- `fzf` (the name dialog is fzf used as a text box; without it `N`, `a` and `d` open no window).
- True colour: the config sets `terminal-overrides ",*:RGB"`; the terminal must support it.

### Upgrade tmux when the package manager offers an older version

Check the package manager first (`apt-cache policy tmux` on Ubuntu). On Ubuntu 26.04 it may only offer 3.6a.
Use the official release tarball to install 3.8 into `/usr/local`, preserving the distro binary in `/usr/bin`:

```sh
sudo apt update
sudo apt install build-essential libevent-dev libncurses-dev bison pkg-config curl
mkdir -p ~/Downloads/tmux-build
cd ~/Downloads/tmux-build
curl -fLO https://github.com/tmux/tmux/releases/download/3.8/tmux-3.8.tar.gz
tar -xzf tmux-3.8.tar.gz
cd tmux-3.8
./configure --prefix=/usr/local
make -j"$(nproc)"
sudo make install
```

Refresh shell command lookup (`rehash` in zsh, `hash -r` in bash), then verify `command -v tmux` selects
`/usr/local/bin/tmux` and `tmux -V` reports 3.8. Official instructions: https://github.com/tmux/tmux/wiki/Installing.

**Installing a new binary does not upgrade a running server.** Check the target server with
`tmux display-message -p '#{version}'`. Do not kill a user's server or running programs to upgrade it.
If the server is older than 3.7, keep it running and start a separate upgraded server:
`tmux -L upgraded new -s coding`. Use `tmux -L upgraded ...` for reloads and checks on that server.
An old default server can be replaced after the user has finished and exited all its sessions.

## 2. Install

1. Back up an existing `~/.tmux.conf`.
2. `mkdir -p ~/.tmux && cp new_tmux/pane-col.sh new_tmux/which-key.sh new_tmux/ask-name.sh new_tmux/dialog.sh new_tmux/notify.sh new_tmux/notifications.sh new_tmux/notif-read.sh new_tmux/equalize.sh ~/.tmux/ && chmod +x ~/.tmux/*.sh`
3. `cp new_tmux/tmux.conf ~/.tmux.conf`
4. Inside tmux: `tmux source ~/.tmux.conf`, or start a fresh server (see the reload note below).
5. Enable relative line numbers by default: the config must contain `setw -g copy-mode-line-numbers relative`.
   On the target server, verify `tmux show-options -gwv copy-mode-line-numbers` prints `relative`.
   Enter copy mode with **Alt-e then v**: line numbers should be relative to the cursor, making `5k` / `3j` easy.
   Mouse-entered copy mode keeps line numbers hidden by tmux design.
6. Check: the status is 2 rows (row 1 the statusline, row 2 the top edge), `Alt-e b` toggles row 2, and with a split
   the part of row 2 over the active pane is dark. The prefix is `Alt-e` (see `KEY_GUIDE.md`).

## 3. How the pieces fit (so you can change them without breaking them)

- **Pane numbers** are tmux's own `pane-border-status top` with `pane-border-format` (` #{pane_index} `, a dark block on the
  active pane, light on the others; empty for the notification toast panes, which carry `@toast_src`). The label line is the
  divider that already exists for a pane with another pane above it, and for the top row of panes it replaces the old "box"
  (a second status row drawn by a script, `box.sh`, now deleted), so the status is a single row and no space is lost.
  `Alt-e b` toggles `pane-border-status` between `top` and `off` for the current window. The colours must match
  `pane-border-style` / `pane-active-border-style`. The numbers are the pane indexes (`pane-base-index 1`), the same ones
  `Alt-e 1..9` and `Alt-e q` use.
- **Divider arrow**: `pane-border-indicators` is a window option. It is `colour` globally (half-dark divider for 2 panes); hooks on `window-layout-changed` and `after-new-window` set it to `both` (adds the arrow, drawn by tmux one cell in from the start of the divider, not in the middle; it takes the style of the half it sits on, so it is light when the active pane is the bottom or right one; not configurable, the user chose to leave it) when `#{window_panes}` is 2, and back to `colour` otherwise, because tmux would also draw arrows with 3+ panes. Windows that already had 2 panes before a reload keep `colour` until their layout changes.
- **Borders**: heavy lines, active `#4a6a6a`, inactive `#f0f4f4` (the inactive number label is `#f4f7f7` with `#7a8a8a` text). nvim and kvim use the same teal for the active window.
- **Statusline**: left = OS icon + user, mode label (grey `NORMAL`, yellow `PREFIX`, blue `COPY`, grey `ZOOM`),
  pane n/total, running command. Right (`status-justify right` puts the window tabs there) = tabs, time, then
  `<name>` with an icon on the same dark colour as the user. The key hints are in the `Alt-e` dropdown.
- **The `Alt-e` dropdown**: the real prefix is off (`set -g prefix None`). `Alt-e` is a root key (`bind -n M-e`) that opens a
  popup running `~/.tmux/which-key.sh`. The script prints the key list, reads one key, closes, and then runs
  `switch-client -T prefix` + `send-keys -K` so the key goes through the normal prefix table (every `bind` in the
  config, listed or not, keeps working; `Alt-e Alt-e` sends a literal Alt-e). The status label shows `PREFIX` while the
  popup is open through the global option `@popup` (the script sets and unsets it). `display-popup -h` does not take a
  format, so `tmux.conf` has two popup commands, chosen by the terminal height. When you add a key to `tmux.conf`, add
  a row to the list in `which-key.sh` and to `KEY_GUIDE.md`.
- **The name dialog**: `N`, and `a` / `d` when they open a new window, run `display-popup -E` with `~/.tmux/ask-name.sh <default>`. The script runs fzf over an empty list (`--print-query`), so Enter returns the typed text and Esc returns 130. It sets `@wok` and `@wname` on the server; the binding then does `new-window` and `rename-window` only if `@wok` is set (empty name keeps the auto name). The popup is 50% wide, centred, its bottom edge at 40% of the height + 2.
- **Known quirk**: tmux colours each stretch of a divider with the style of the pane that owns it, so a tall pane next
  to a stack can leave its divider half dark. Do not try to fix it with a `pane-border-style` format that looks at the
  neighbours: it was tried, and it darkens dividers that are not next to the active pane.

## 4. Rules for changing it

- **Reload note**: `tmux source` does not undo a setting that was deleted from the file, and `set-hook -g` leaves old
  array entries. The config starts its hooks with `set-hook -gu ...` for that reason. When you remove a setting, also
  run `tmux set -gu <option>` in the live server, or restart it.
- **Test in a separate server, never in the user's live one.** Example:
  `tmux -L t -f ~/.tmux.conf new-session -d -x 80 -y 14`, then attach it inside another throwaway server
  (`tmux -L o -f /dev/null new-session -d "TMUX= tmux -L t attach"`) and read the screen with
  `tmux -L o capture-pane -p -e`. Kill both with `tmux -L t kill-server` / `tmux -L o kill-server`.
- Keep `new_tmux/` and the live `~/.tmux.conf`, `~/.tmux/*.sh` identical (the user edits live first, then copies here).

## Compact action dialogs

Install `dialog.sh` along with the other helpers. It supplies the same popup placement and colours as the new-window name dialog for rename-window/session, kill-pane/window/session, command input, and jump/move/find-window. Targets are stable IDs captured when the popup opens; existing names are read inside the helper and input is passed as a single argument. Confirmation only accepts y/Y; other keys cancel. Test on a separate server before reloading live sessions.

## Window notifications (Claude Code, bell, long commands)

`notify.sh done|wait|bell|fail [label]` uses `$TMUX_PANE` to find the window and does nothing if a focused client is showing it **and the pane is really on screen**: when the window is zoomed on another pane (`z`) or the sending pane was squeezed by `c` / `C` (height under 4 or width under 10), you are in the window but cannot see the pane, so you still get the toast. Otherwise it sets the window option `@claude` (the tab dot) and then picks where to tell you: if some client's terminal has focus (`focus-events on`, flag `focused` in `list-clients`) it opens a small dialog in the top right corner of the window that client is showing: a **floating pane** (tmux 3.8 `new-pane -d -A -X <ww-w-1> -Y 0 -x <w> -y 4 -B single`, border and text in the kind's colour; `-B rounded` is not accepted, `pane-border-lines` has no rounded value). Unlike `display-popup` it is not modal, so it never takes your keys: you keep typing in the pane you were in. It runs `bash -c` with `sleep <secs>` (`TMUX_NOTIFY_MS`, 5000) and closes when that ends, and `notify.sh` tags it with the pane option `@toast_src` (the id of the window that sent the notification) so `notif-read.sh` kills it as soon as you select that window (or the terminal regains focus on it). `-A` keeps it visible over a zoomed pane. While it is open the window has one more pane, so the status counter and the one-pane / two-pane checks (`a`, `d`, the border-indicator hooks) use `#{E:@tiled}` (`#{n:#{P:#{?@toast_src,,x}}}`, the panes without `@toast_src`) instead of `#{window_panes}` and sends no OS notification.  if no client is focused it calls `notify-send` (libnotify-bin). Three callers:

- Claude Code hooks in `~/.claude/settings.json`: `Stop` -> `done`, `Notification` -> `wait`. Sessions started before the hooks existed must be restarted.
  This file is not in the repo, so add the hooks by hand on each machine. Merge them into an existing `hooks` key instead of overwriting it:

  ```json
  "hooks": {
    "Stop": [{"hooks": [{"type": "command", "command": "~/.tmux/notify.sh done"}]}],
    "Notification": [{"hooks": [{"type": "command", "command": "~/.tmux/notify.sh wait"}]}]
  }
  ```
- tmux's `alert-bell` hook (`monitor-bell on`, `bell-action other`) -> `bell`. A bell never overwrites an existing dot.
- zsh: `new_zsh/notify.zsh`, appended once to `~/.zshrc`, calls `done` / `fail` with the command name when a command ran for `TMUX_NOTIFY_SECS` (default 30) or more. It skips interactive programs (nvim, ssh, less, claude, ...) and exit 130.

`tmux.conf` draws the dot on the tab (green done, orange wait, red fail, blue bell) and clears `@claude` on `after-select-window` and `client-focus-in`. Keep `notify.zsh` and the block in `~/.zshrc` identical.

### Notification list (bell + dropdown)

`notify.sh` also appends every delivered event to `~/.tmux/notifications.log` (tab separated: time, kind, text, `session:window`, window id; trimmed to 200 lines past 300) with a last field `1` (unread). `@notif_n` is the number of unread lines, recomputed by `notif-read.sh`. That script also marks a window's lines read (`0`): `after-select-window` and `client-focus-in` call `notif-read.sh #{window_id}`, so visiting the window that sent a notification removes it from the bell count (the line stays in the list). `flock` on `<log>.lock` keeps appends and rewrites apart. `tmux.conf` draws the bell at the start of the right side of the status line (a dim bell at 0, an orange bell plus the count otherwise) inside `#[range=user|bell]`. `Alt-e g`, or a click on the bell (`MouseDown1Status` checks `#{mouse_status_range}`; any other click still runs `switch-client -t =`), opens `notifications.sh` in a popup under the status bar. The script marks everything read (`notif-read.sh all`) when it opens, lists the log newest first through fzf, and `Enter` jumps to the window (if it still exists), `Ctrl-x` deletes the highlighted line (`sed -i {3}d`), `Ctrl-l` empties the log. The popup command gets no arguments: `display-popup` does not expand `#{...}` in its command (same reason as `dialog.sh`), so the script asks tmux for `#{client_name}` itself; passing `'#{client_name}'` arrived as the literal text and made the jump fail. Testing: `send-keys -K` blocks while a `display-popup -E` is open, so run it in the background or with `timeout`. Set `TMUX_NOTIFY_LOG` to test with a scratch log. **Desktop popups:** when no client is focused, `notify.sh` sends the popup with `notify-send -p` and keeps `window id<TAB>popup id` in `~/.tmux/notifications.os` (last 40 lines past 60; `TMUX_NOTIFY_OS` for tests). `notif-read.sh <window_id>|all` (the same hooks as above) closes that window's popups with `org.freedesktop.Notifications.CloseNotification` through `gdbus`, so a critical "Claude needs you" popup, which never times out, goes away once you are back in that window.

## Equal sizes (`Alt-e =`)

`equalize.sh` rebuilds the layout so every container has equal children at every level (left 50% | right column 50%, the right panes 50% of the height each). `select-layout -E` is not enough: it only spreads the siblings of one pane and skips a sibling that is itself a split. tmux 3.8 prints `#{window_layout}` as JSON, so the script reads it with `python3`, sets each cell's width, height and offsets (borders are one cell), and applies the result with `select-layout`. On an older tmux that prints the classic layout string it falls back to `select-layout -E` for every pane. Note for any script that stores a layout: the 3.8 JSON contains double quotes, so inside `run-shell` it needs `#{q:...}`. `m` and `n` (focus modes) used to save and restore the layout this way and silently failed to restore on 3.8; the user does not want them to toggle back, so they are one-way now. Only `z`, `c` and `C` toggle.

## Resize mode (`Alt-e r`) and reload (`Alt-e R`)

`r` switches the client to the key table `resize` (`bind r switch-client -T resize`). In that table `h` `j` `k` `l` run the same 10% `resize-pane` commands as `H` `J` `K` `L`, `=` runs `equalize.sh`, and each binding ends with `switch-client -T resize` so the mode stays on; `Escape`, `Enter` and `q` switch back to `root`, and any key not in the table also drops back to root (tmux discards it). The status label shows RESIZE (peach) while `#{client_key_table}` is `resize`. Reload moved from `r` to `R`.
