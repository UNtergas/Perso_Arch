# zsh

Settings: `fzf.zsh` (live copy: the fzf block at the end of `~/.zshrc`).
fzf defaults are Ctrl-T and Alt-C; here they are rebound to Ctrl-P and Ctrl-O.
Needs `fzf` 0.48 or later (for `fzf --zsh`) and `fd`.

## Install

```sh
cat new_zsh/fzf.zsh >> ~/.zshrc
source ~/.zshrc
```

## fzf keys (at the shell prompt)

| Key | What it does |
|---|---|
| `Ctrl-R` | Fuzzy search of command history. Enter puts the command on the line. |
| `Ctrl-P` | Fuzzy file picker (files only, recursive, dotfiles included). Pastes the path at the cursor. `Tab` marks several files. |
| `Ctrl-O` | Fuzzy directory picker (recursive, below the current directory). Enter runs `cd` into it. |
| `**<Tab>` | Fuzzy completion, e.g. `nvim **<Tab>`, `kill <Tab>`. |

Inside the picker: type to filter, `Up` / `Down` or `Ctrl-J` / `Ctrl-K` to move, `Enter` to accept, `Esc` to cancel.

## Notes

- `Ctrl-P` and `Ctrl-O` use `fd`, which skips anything in `.gitignore` (`node_modules`, `build/`). Add `--no-ignore` to the `FZF_*_COMMAND` lines to include them.
- Both search from the current directory only. Start from the project root. In `~` the list is huge.
- No preview pane is set. Add `--preview 'bat {}'` to `FZF_CTRL_T_OPTS` if you want one.
- No clash with tmux (its prefix is `Alt-e`) or nvim (Telescope is separate).
