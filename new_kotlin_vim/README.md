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

## Lspsaga trial

kvim now uses the same Lspsaga UI as nvim: breadcrumbs, reference Finder (`gr`),
diagnostics, hover (`K`), rename (`SPC c r`), editable definition preview (`gp`), and outline tree
(`SPC s o`). In Finder, `]f` / `[f` jump to the next/previous file; Enter opens a reference, `[w`
switches to the preview, and Esc closes. Outline: Enter expands/jumps, `o` jumps, q/Esc closes.

`lua/kotlin_definition.lua` augments only the Kotlin client's definition responses. Both `gd` and
`gp` use server definitions, exact workspace symbols, then cached Kotlin/Kotlinx sources. When
several locations match, a picker lets you choose before jumping or previewing. Library sources
remain read-only and do not start another Kotlin server. Other language clients are unaffected.
Existing source-JAR lookup limits remain: explicit imports, downloaded sources, newest cached version.

Full pre-trial backup on this machine:
`~/.config-backups/kvim-before-lspsaga-20261116-135359/` (live config and repository copy).
Run the definition adapter checks from the repo root:
`nvim --headless -u NONE -l new_kotlin_vim/tests/definition_fallbacks.lua`.

Trouble is removed. `[d` / `]d` only jump, with no popup or automatic code-action request.
Use `SPC d` for diagnostic details and Ctrl-. / Alt-. / `SPC c a` for code actions.
Code actions use the original native LSP menu through Snacks, with disabled actions hidden.
Telescope Ctrl-Q still sends results to quickfix.

Breadcrumbs use `lua/saga_breadcrumb.lua` with Lspsaga symbol data and styling. The renderer
uses each window's own buffer/cursor, handles unsorted symbols and column ranges, and clears
outdated scope labels while symbols refresh. Copy the entire config directory when installing.
