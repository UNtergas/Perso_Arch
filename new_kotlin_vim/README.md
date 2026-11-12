# new_kotlin_vim

`kvim`: a separate Neovim for Kotlin and Android projects. It is a copy of `new_vim/nvim/` plus the
Kotlin language server setup. It runs with `NVIM_APPNAME=kvim`, so it has its own config, plugins and
state and never touches the normal `nvim`.

- `kvim/` goes to `~/.config/kvim/` (`init.lua`, `lazy-lock.json`, `colors/`, `lua/`).
- `alias kvim='NVIM_APPNAME=kvim nvim'` goes in `~/.zshrc`.
- **`SETUP_FOR_CLAUDE.md`** has the full install steps, checks, the reasons for every Kotlin-specific
  customisation, and the rules for working on it. Point a new Claude session at it:
  "set up kvim from `new_kotlin_vim/`".

Status: being tested. Edit `~/.config/kvim/init.lua` first, then sync it here.
