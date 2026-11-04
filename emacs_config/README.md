# Doom Emacs config

Doom Emacs set up as a VSCode replacement: same theme (Alabaster), font, vim
keys and VSCode keybinds. See [KEYBINDS.md](KEYBINDS.md) for every changed key.

```
emacs_config/
├── README.md        this file: setup steps
├── KEYBINDS.md      changed keybinds vs Doom defaults
└── doom/            -> copy to ~/.config/doom
    ├── init.el      enabled Doom modules
    ├── packages.el  extra packages (alabaster-themes, evil-snipe disabled)
    ├── config.el    theme, font, keybinds
    └── snippets/    empty; exists only to silence a yasnippet warning
```

## What it gives

- Theme `alabaster-themes-light`, font JetBrainsMono Nerd Font 15, relative
  line numbers, tab width 2, soft word wrap, ligatures, indent guides.
- Evil (vim) everywhere, leader `SPC`.
- LSP (lsp-mode) for Python (pyright), Rust (rust-analyzer), TS/JS
  (typescript-language-server), HTML/CSS (vscode-langservers-extracted).
- Manual formatting only (`SPC c f`), no format on save. Uses the LSP formatter
  if it has one, otherwise black (Python) / rustfmt (Rust).
- Multiple cursors on `C-d`, treemacs sidebar, magit, vterm.

## Setup on a new machine (Arch / EndeavourOS)

Instructions written so Claude (or you) can run them top to bottom. Steps that
need `sudo` must be run by the user (Claude can't type the password): in Claude
Code, prefix them with `!`.

### 1. System packages (sudo)

```sh
sudo pacman -S --needed emacs-wayland git ripgrep fd ttf-jetbrains-mono-nerd rustup
```

Use `emacs` instead of `emacs-wayland` on X11.

### 2. Language tooling (no sudo)

Needs Node (here via nvm) and `uv`.

```sh
# Rust: toolchain + rustfmt + rust-analyzer
rustup default stable
rustup component add rust-analyzer rustfmt
# Arch's rustup ships no rust-analyzer proxy -> make one (rustup dispatches on argv[0])
mkdir -p ~/.local/bin && ln -sf "$(command -v rustup)" ~/.local/bin/rust-analyzer

# Python LSP + formatter
npm i -g pyright
uv tool install black

# TS/JS + HTML/CSS LSPs
npm i -g typescript typescript-language-server vscode-langservers-extracted
```

`npm` may warn that it blocked a `core-js` install script. Harmless (donation
banner).

### 3. Doom itself

```sh
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
mkdir -p ~/.config/doom
cp -r doom/. ~/.config/doom/          # run from this emacs_config folder
~/.config/emacs/bin/doom install --force --no-config --env
```

Add Doom to PATH (`~/.zshrc`):

```sh
# doom emacs
export PATH="$HOME/.config/emacs/bin:$PATH"
```

### 4. Check

```sh
which pyright-langserver rust-analyzer typescript-language-server \
      vscode-html-language-server black rustfmt
doom doctor
```

Then `emacs &`.

## Gotchas

- **`doom sync` can hang forever** on a hidden y/n prompt when run
  non-interactively (e.g. from Claude). Always use `doom sync -!` (auto-yes).
- **Env file**: Doom snapshots your shell `PATH` into an env file so a GUI
  Emacs launched from the app menu finds nvm / cargo / `~/.local/bin` tools.
  Re-run `doom sync --env -!` after installing tools in new PATH dirs or
  changing Node version.
- After editing `init.el` or `packages.el`: `doom sync -!`, then restart
  Emacs. `config.el` needs no sync (`SPC h r r` reloads).
- `emacsclient` only works if a daemon runs (`emacs --daemon`, or
  `emacsclient -c -a ''` to auto-start one). Plain `emacs` is fine otherwise.
- Font size 15 is set in `config.el` (`doom-font`); adjust per screen DPI.

## Refactoring support

| Language | Rename symbol across project (`SPC c r`) | Imports updated on file move/rename |
|---|---|---|
| Python | yes | **no** (pyright lacks it; only Pylance has it) |
| Rust | yes | yes (`mod` / `use`) |
| TS/JS | yes | yes |

File move/rename must go through Emacs (`SPC f R`, `R` in dired, treemacs
rename) while the LSP server is running. Not `mv` in a shell. Edited buffers are
left unsaved: `SPC b S` saves all.

Python workaround after moving a module: `SPC s p` old path → `C-c C-e` →
`:%s/old.mod/new.mod/g` → `C-c C-c`.

## Not ported from VSCode

- Shift-Shift quick open (Emacs can't detect a double Shift tap) → `SPC SPC`.
- Sticky scroll, error lens, typst/tinymist.
