# Perso_Arch

## Reminder: nvim needs tree-sitter-cli on every machine

Since commit `cd81b544`, nvim-treesitter runs on its `main` branch, which needs `tree-sitter-cli` 0.26.1 or later. Without it, parsers can't be built, and TS/JS highlighting and folds stop working.

Before applying `new_vim/nvim/` on a machine, tell the user about this and check it:

1. Run `tree-sitter --version`. If it's missing or older than 0.26.1, run `cargo install tree-sitter-cli --locked`. Don't use npm (the plugin says not to), and apt may be too old (Ubuntu 26.04 has 0.25.9).
2. Check `nvim --version` is 0.12 or later.
3. Back up, then copy `new_vim/nvim/init.lua` and `lazy-lock.json` to `~/.config/nvim/`.
4. Run `nvim --headless '+Lazy! restore' +qa`. Parsers install on the next start.
5. Run `:checkhealth nvim-treesitter`. The `is not in runtimepath` error is a false alarm caused by a trailing slash in the check.
6. Check the language servers work, because a clean startup doesn't prove it. `nvim-lspconfig` must be at `d5c7e7bc` or later, and `~/.local/share/nvim/lazy/nvim-lspconfig/lsp/ts_ls.lua` must exist. Then open a real code file and run `:checkhealth vim.lsp`, or try `gd` and `gr`.

An older `lazy-lock.json` brings back a bug: `nvim-lspconfig` at `8a1529e4` (March 2025) has no `lsp/` folder, so no server starts, `gd` and `gr` do nothing, and Ctrl-click gives `E433: No tags file`. `lsp.log` shows `invalid "ts_ls" config ... cmd`. Always copy the lockfile from `new_vim/nvim/`, never from an older machine or backup.

`trouble.nvim` (`gr`, `C-g` in Telescope) and `grug-far.nvim` (`SPC s r`) were added in commit `a7129a36`. Check both are installed after step 4. `SPC s r` needs `ripgrep`.

Delete this section once every machine is done.
