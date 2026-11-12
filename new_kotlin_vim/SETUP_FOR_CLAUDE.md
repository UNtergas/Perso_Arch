# kvim setup, for a Claude session on a new machine

`kvim` is a second Neovim, for Kotlin and Android work. It never touches the normal `nvim`.
`NVIM_APPNAME=kvim` gives it its own config, plugins and state:

| What | Where |
|---|---|
| Config | `~/.config/kvim/` (from `new_kotlin_vim/kvim/` in this repo) |
| Plugins, Mason servers | `~/.local/share/kvim/` |
| LSP log | `~/.local/state/kvim/lsp.log` |
| Server symbol index (per project) | `~/.cache/kvim/kotlin-language-server/<project>-<hash>/` |
| Library sources extracted for `gd` | `~/.cache/kvim/kotlin-sources/` |

Tell the user what you are about to do, then follow the steps. Do not skip the checks.

## 1. Prerequisites (check each, tell the user what is missing)

- `nvim --version` is 0.12 or later.
- `tree-sitter --version` is 0.26.1 or later. If not: `cargo install tree-sitter-cli --locked`
  (not npm, and apt may be too old). Same reason as the root `CLAUDE.md`: without it the parsers
  (Kotlin included) cannot be built.
- `rg` (ripgrep), `unzip` and `git` are installed. `unzip` is needed for library sources (see below).
- A **JDK 21** exists. `init.lua` hard-codes `JAVA_HOME = "/usr/lib/jvm/java-21-openjdk-amd64"` for
  `kotlin_language_server`, because its embedded Kotlin compiler crashes on Java 25.0.4.1
  (`IllegalArgumentException: 25.0.4.1`). On another machine run `ls /usr/lib/jvm` and, if the path
  differs, change that one line (`grep -n java-21 ~/.config/kvim/init.lua`). Only JDK 21 was tested; 25.0.4.1 is known to crash it.
- Optional: Gradle's cache `~/.gradle/caches/modules-2/files-2.1` with `*-sources.jar` files. Without them,
  `gd` on `kotlin.*` and `kotlinx.*` imports says "No definition found". Android Studio or Gradle
  downloads them when you "download sources".

## 2. Install the config

1. If `~/.config/kvim` exists, back it up: `cp -a ~/.config/kvim ~/.config/kvim.bak-$(date +%Y%m%d-%H%M%S)`.
2. `mkdir -p ~/.config/kvim && cp -r new_kotlin_vim/kvim/. ~/.config/kvim/`
   Always take `lazy-lock.json` from the repo, never from an older machine or backup (an old one pins a
   `nvim-lspconfig` with no `lsp/` folder, so no server starts).
3. Add the alias to the user's shell rc (`~/.zshrc`; check first with `grep -n kvim ~/.zshrc`, do not duplicate):
   ```sh
   # kvim: separate Neovim for Kotlin work; own config (~/.config/kvim), plugins and state (~/.local/share/kvim), so plain nvim is untouched
   alias kvim='NVIM_APPNAME=kvim nvim'
   ```
   `nvim` itself stays the normal Neovim. An alias only works in interactive shells. If the user needs
   `kvim` from scripts or as `$EDITOR`, make `~/.local/bin/kvim` a small script instead:
   `exec env NVIM_APPNAME=kvim nvim "$@"`.
4. Install the plugins at the locked versions: `NVIM_APPNAME=kvim nvim --headless '+Lazy! restore' +qa`
5. Install the Kotlin server and let the parsers build:
   `NVIM_APPNAME=kvim nvim --headless '+MasonInstall kotlin-language-server' '+lua vim.wait(60000, function() return require("mason-registry").is_installed("kotlin-language-server") end, 1000)' +qa`
   Mason also installs `clangd`, `ts_ls`, `pyright`, `jdtls` and `rust_analyzer` from `ensure_installed`;
   some need node or python and can fail without affecting Kotlin. Parsers compile on the first real start,
   so the first `kvim` launch is slow.
6. Tell the user to restart the shell (or `source ~/.zshrc`) and to open a Kotlin file in a Gradle project with `kvim`.

## 3. Verify (headless where possible)

- `NVIM_APPNAME=kvim nvim --headless '+lua vim.wait(1500)' '+lua print(vim.g.colors_name, vim.o.background)' +qa`
  prints `koda-glade light`.
- `ls ~/.local/share/kvim/mason/bin/kotlin-language-server` exists.
- In a real Kotlin file in a Gradle project, wait 1 to 2 minutes (the server imports Gradle and indexes), then:
  the **Kotlin icon at the start of the tabline** is **purple** when a server is attached and idle,
  **amber** while it is busy, **grey** when no Kotlin server is attached. Then try `K` (hover),
  `gd` on an import, `gr` (references in Trouble), `SPC c r` (rename), `Ctrl-T` (workspace symbols).
  Also `:checkhealth vim.lsp`.

## 4. What is customised for Kotlin, and why (do not "clean up" these)

- **Server: `kotlin_language_server` (fwcd, via Mason).** The JetBrains `Kotlin/kotlin-lsp` (alpha) is
  **not enabled**. Its Gradle import failed on `snowpack-android` with AGP 8.13.2 (`Querying the mapped
  value of property(...) before task ':androidapi:generateDebugAndroidTestBuildConfig' has completed
  is not supported`), so it had no project model. Its config block is still in `init.lua`, with the
  `vim.lsp.enable` line commented out. It is not installed by this repo. If retrying, the standalone
  Linux archive is on `download.jetbrains.com/language-server/kotlin-server/<version>/` (see the repo's
  `RELEASES.md`), unpacked to `~/.local/share/kvim/kotlin-lsp/current/`.
- **`JAVA_HOME` = JDK 21** for the server (see prerequisites).
- **`storagePath` per project** (`before_init`): the server's `kls_database.db` index lives in
  `~/.cache/kvim/...`, not in the project. A stale `kls_database.db` in a project root had broken `gd`,
  and it also stays out of git status. If a project still has a `kls_database.db` from before, the user may delete it.
- **`gd` fallback chain** (Kotlin buffers only): server definition, then the server's `workspace/symbol`
  search for the exact name, then a library source file. Why: when a module has a previous build's
  compiled output in `<module>/build/` (for example `androidapi/build/tmp/kotlin-classes`), the server
  resolves **top-level functions** (`getTokenType`, `isLegacyJWT`) to the compiled class and returns no
  location (classes still work). Gradle-cache **library** symbols (`kotlin.*`, `kotlinx.*`) have no
  location either. For those, `gd` extracts the newest `*-sources.jar` from the Gradle cache into
  `~/.cache/kvim/kotlin-sources/`, finds the file by its `package` line, and opens the declaration
  read-only. It uses the newest version found, which can differ from the project's. Only `kotlin` and
  `kotlinx` are covered.
- **`workspace/symbol` range filler** (`on_attach` wraps `client.request`): the server answers symbol search
  with `location = { uri }` and no range; `vim.lsp.util.symbols_to_items` drops those, so Telescope
  (`Ctrl-T`) showed nothing. The filler adds a range by finding the declaration line.
- **dropbar `ttl_init = 300`**: the server takes 1 to 2 minutes to answer `documentSymbol` after a Gradle
  project opens; the default 60 one-second retries gave up first and left the noisy treesitter breadcrumb.
- **Kotlin icon in the tabline** (kvim only), first item; colour shows the LSP state (see Verify).
- **Theme**: `koda-glade` (koda.nvim, light) is the startup colour scheme, same as `nvim`. Its background is
  dimmed from `#f7f7f7` to `#f3f3f3` by a `ColorScheme` autocmd in the koda block (`koda_glade_bg`), a small
  step because the string and type colours are light. Alabaster stays installed with its own default colours;
  the earlier patches that made it resemble VS Code (blue class and function names, custom grey background,
  treesitter name rules) were removed on purpose, so do not add them back unless the user asks.
  `onedark.nvim` is installed but lazy. `:Theme <name>` switches for the session (`alabaster`,
  `koda-dark/light/moss/glade`, `onedark-dark/darker/cool/deep/warm/warmer/light`). The lualine
  second-section grey is hard-coded for light themes, so it may look off on the dark ones.
- Same as `nvim`: lualine statusline and tabline, `Esc Esc` leaves terminal mode, the cowboy limit.

## 5. Known limits

- **Nested classes are not suggested** while typing (for example `TenantService`, declared inside
  `SnowpackPlatformAPI`). Importing it explicitly makes it complete.
- Results in the first 1 to 2 minutes after opening a Gradle project are empty or partial.
- A bare `foo.` on a new line before other statements can return keywords instead of members;
  a partial name (`foo.ba`) or a dot on an existing line works.
- If `gr`, rename or completion misbehave on an Android module that has a `build/` folder, the compiled
  output is the usual cause (see the `gd` bullet). `./gradlew clean` removes it. It is the user's call.

## 6. Rules for working on this (learned the hard way)

- **Never run kvim, the server or Gradle against `~/Tuan/...`.** It is read-only for Claude, and the server
  writes into the project folder. Test on a copy: `git ls-files -z` plus `local.properties` through
  `rsync -a --from0 --files-from=-` (that copies **no directory contents**, so copy folders like `build/`
  with a plain `rsync -a`), under `~/.cache/<name>/`, and delete the copy afterwards.
- **Memory:** each server can use 1 to 3 GB and a pile of test copies and servers once overflowed memory and
  rebooted the machine. Run **one** headless test at a time, with `JAVA_OPTS=-Xmx1g`, and check for
  leftover servers afterwards: `ps -eo pid,rss,etime,args | grep '[j]ava.*kotlinLanguageServer'`.
- Delete test copies with **literal paths**: a `rm -rf "$VAR"` is blocked by a safety check.
- **Workflow:** edit the live `~/.config/kvim/init.lua` first, test it, then copy it into
  `new_kotlin_vim/kvim/`. Commit only when the user asks, and do not push until they say so
  (they test `kvim` for a day before pushing).
- Headless tests: `NVIM_APPNAME=kvim nvim --headless -n <file.kt> "+luafile probe.lua" '+qa!'`; use
  `vim.lsp.buf_request_sync` for definition, references, `workspace/symbol`; use `nvim -l` with
  `loadfile` as a syntax check after every edit.
