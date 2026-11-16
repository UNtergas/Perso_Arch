# tmux setup, for a Claude session on a new machine

Tell the user what you are about to do, then follow the steps. The config is `new_tmux/tmux.conf`; it needs the helper
scripts next to it in `~/.tmux/`. Without them the box (top edge) and `[` / `]` do nothing or print errors.

| What | From this repo | Goes to |
|---|---|---|
| Config | `new_tmux/tmux.conf` | `~/.tmux.conf` |
| Top edge of the box, and the `Alt-e b` toggle | `new_tmux/box.sh` | `~/.tmux/box.sh` (executable) |
| `[` / `]` consume-or-expel panes | `new_tmux/pane-col.sh` | `~/.tmux/pane-col.sh` (executable) |
| The `Alt-e` key dropdown | `new_tmux/which-key.sh` | `~/.tmux/which-key.sh` (executable) |
| New-window name dialog (`N`, `a`, `d`) | `new_tmux/ask-name.sh` | `~/.tmux/ask-name.sh` (executable) |
| Rename/close/command popups | `new_tmux/dialog.sh` | `~/.tmux/dialog.sh` (executable) |
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
2. `mkdir -p ~/.tmux && cp new_tmux/box.sh new_tmux/pane-col.sh new_tmux/which-key.sh new_tmux/ask-name.sh new_tmux/dialog.sh ~/.tmux/ && chmod +x ~/.tmux/*.sh`
3. `cp new_tmux/tmux.conf ~/.tmux.conf`
4. Inside tmux: `tmux source ~/.tmux.conf`, or start a fresh server (see the reload note below).
5. Enable relative line numbers by default: the config must contain `setw -g copy-mode-line-numbers relative`.
   On the target server, verify `tmux show-options -gwv copy-mode-line-numbers` prints `relative`.
   Enter copy mode with **Alt-e then v**: line numbers should be relative to the cursor, making `5k` / `3j` easy.
   Mouse-entered copy mode keeps line numbers hidden by tmux design.
6. Check: the status is 2 rows (row 1 the statusline, row 2 the top edge), `Alt-e b` toggles row 2, and with a split
   the part of row 2 over the active pane is dark. The prefix is `Alt-e` (see `KEY_GUIDE.md`).

## 3. How the pieces fit (so you can change them without breaking them)

- **The box** is only a second status row. `status 2` and `@box 1` in `tmux.conf` turn it on by default;
  `status-format[1]` just prints the window option `@topedge`. `~/.tmux/box.sh edge` builds that string from the real
  pane positions (dark over the active pane, light over the others, `┳` at each divider, one plain line while zoomed).
  Hooks (`after-select-pane`, `window-layout-changed`, `after-new-window`, `after-new-session`, `after-select-window`)
  call it. `Alt-e b` runs `box.sh toggle` (sets `@box` to 0 and `status on`, or back). The colours are at the top of
  `box.sh` (`D` active, `L` inactive) and must match `pane-border-style` / `pane-active-border-style` in `tmux.conf`.
- **Borders**: heavy lines, active `#4a6a6a`, inactive `#dde5e5`. nvim and kvim use the same teal for the active window.
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
