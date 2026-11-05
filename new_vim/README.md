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
blink.cmp (completion), mason + lspconfig, telescope, oil, nvim-tree, flash,
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
