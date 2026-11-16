# new_vim (Neovim config)

Neovim set up as a VSCode / Doom Emacs replacement: Alabaster light theme,
the same keybinds as `../emacs_config`, LSP, git, multi-cursor.

```
new_vim/
├── README.md           this file: setup + how it is organised
├── KEY_GUIDE.md        every keybind, grouped by function
├── REFACTOR_GUIDE.md   rename / move + imports, automatic and manual
└── nvim/               -> copy to ~/.config/nvim
    ├── init.lua        the whole config (one file)
    └── lazy-lock.json  pinned plugin versions
```

## Install

```sh
mkdir -p ~/.config/nvim
cp nvim/init.lua nvim/lazy-lock.json ~/.config/nvim/
nvim            # lazy.nvim bootstraps itself and installs every plugin
```

Needs `git`, `ripgrep`, `fd`, Node (for `ts_ls`), and a Nerd Font in the
terminal. LSP servers install through Mason (`:Mason`): clangd, ts_ls, pyright,
jdtls, rust_analyzer, html, cssls. Formatters: `black`, `rustfmt` on `PATH`.

## What is in `init.lua`

Plugins (lazy.nvim): alabaster (theme), treesitter + context (sticky scroll),
blink.cmp (completion), mason + lspconfig, telescope, oil, flash,
indent-blankline, snacks (file rename with LSP import updates, buffer close),
which-key, gitsigns, git-conflict, diffview, rainbow-delimiters, nvim-surround, undotree,
conform (manual format), multicursor.

Sections of the file: options, theme, plugins, then the keymaps block at the
bottom (ported from the Emacs config).

## Notes

- Formatting is manual only (`SPC c f`), no format on save.
- `ts_ls` runs with automatic type acquisition off and a 3 GB memory cap.
- Not ported from Emacs: `SPC p p` project switching, Alabaster comments are
  bright yellow by design (set `vim.g.alabaster_dim_comments = true` to dim).
- This config is the single file `nvim/init.lua`. The old NvChad files in the
  repo's `nvim/` folder are not used by it.

## Lspsaga trial

Lspsaga currently supplies the symbol breadcrumbs (replacing Dropbar), reference finder (`gr`),
and diagnostic displays (`SPC d`, `SPC c x`).
Finder: `]f` / `[f` jump between file headers; Enter opens a result; `[w` switches between results and preview; Esc closes.
Trouble has been removed; Telescope can still send results to quickfix with Ctrl-Q.
`[d` / `]d` only jump, without popups or automatic code-action requests. Use `SPC d` for
diagnostic details and Ctrl-. / Alt-. / `SPC c a` for the original native LSP code-action
menu presented through Snacks. Disabled actions are hidden.
Hover (`K`), symbol rename (`SPC c r` / `SPC r n`), definition peek (`gp`), and document outline
(`SPC s o`) also use Lspsaga. The outline is a right sidebar: Enter expands/jumps, `o` jumps directly,
`q` or Esc closes. Ctrl-Shift-T retains the Telescope document-symbol picker.
Rename: Enter confirms, Ctrl-C cancels; files are not saved automatically.
Direct definition jumps (`gd`) are unchanged. Automatic lightbulbs are disabled.
The same UI is now synced to kvim, with its additional Kotlin definition adapter; see `../new_kotlin_vim/README.md`.

Backup for this machine before the trial:
`~/.config-backups/nvim-before-lspsaga-20261116-130239/` contains both the live `nvim/` config
and the previous `new_vim-repo/` directory, including plugin locks. To revert, close Neovim,
restore those files, then run `nvim --headless '+Lazy! restore' +qa`.

Breadcrumbs use `lua/saga_breadcrumb.lua` with Lspsaga symbol data and styling. The renderer
uses each window's own buffer/cursor, handles unsorted symbols and column ranges, and clears
outdated scope labels while symbols refresh. Copy the entire config directory when installing.
