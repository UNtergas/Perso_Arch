# Setting up zsh (fzf) on a machine

Files: `fzf.zsh` (the settings), `KEY_GUIDE.md` (the keys).
Keys: `Ctrl-R` history, `Ctrl-P` files, `Ctrl-O` cd. The fzf defaults `Ctrl-T` and `Alt-C` are unbound.

## Steps

1. Check the tools: `fzf --version` (needs 0.48 or later, for `fzf --zsh`) and `fd --version`.
   Install if missing: Arch `sudo pacman -S fzf fd`, Debian/Ubuntu `sudo apt install fzf fd-find`
   (on Debian the binary is `fdfind`; link it with `ln -s $(which fdfind) ~/.local/bin/fd`).
   If apt's fzf is older than 0.48, install from https://github.com/junegunn/fzf instead.
2. Back up: `cp ~/.zshrc ~/.zshrc.bak`.
3. Add the block once. Skip this if `~/.zshrc` already has `fzf --zsh`:
   ```sh
   grep -q 'fzf --zsh' ~/.zshrc || cat new_zsh/fzf.zsh >> ~/.zshrc
   ```
   Do not duplicate the block. The `bindkey` lines must come after the `source <(fzf --zsh)` line.
4. Load it: `source ~/.zshrc`, or open a new shell.
5. Check the keys:
   ```sh
   zsh -ic 'for k in "^P" "^O" "^R" "^T"; do bindkey "$k"; done' 2>&1 | grep -v zle
   ```
   Expect `fzf-file-widget`, `fzf-cd-widget`, `fzf-history-widget`, and `undefined-key` for `^T`.
   The `can't change option: zle` message in a non-interactive test is harmless.
6. Press `Ctrl-O` in a real terminal. If nothing happens, check the terminal does not capture the key.

## Rules

- Never replace `~/.zshrc` with a copy from another machine. Only append the fzf block.
- Keep `fzf.zsh` and the fzf block in `~/.zshrc` the same. Edit both together.
- Tell the user if the key overlaps (`Ctrl-P` was `up-line-or-history`, `Ctrl-O` was `accept-line-and-down-history`).
