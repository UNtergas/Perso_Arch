# Key guide (Neovim)

All custom keybinds, grouped by function. Everything is in the keymaps block
at the bottom of `nvim/init.lua` (plus a few inside plugin specs).

`SPC` = leader (Space). `M-` = Alt. `C-` = Ctrl. Modes: **n** normal,
**v** visual, **i** insert, **t** terminal.

Find any bind: `SPC h b` (Telescope keymaps) or press `SPC` and wait
(which-key). Same layout as [../emacs_config/KEY_GUIDE.md](../emacs_config/KEY_GUIDE.md).

## 1. Files and navigation

| Key | Mode | Does |
|---|---|---|
| `SPC SPC` | n | Find file in project |
| `C-p` | n | Find file in project (VSCode) |
| `SPC .` | n | Find any file (includes hidden) |
| `SPC ,` / `SPC b b` | n | Switch buffer |
| `SPC :` | n | Command palette |
| `C-n` | n v | Toggle nvim-tree sidebar |
| `SPC e` | n | Oil file browser (edit files as text). It also opens for `nvim .` and `:e .` instead of netrw |
| `C-b` | n v | List all buffers (same as `SPC b b`) |
| `C-k a` | n v | New file (creates parent folders) |
| `C-k A` | n v | New folder |
| `C-s` | n v i | Save |
| `SPC b S` | n | Save all buffers |

## 2. Jumping around

| Key | Mode | Does |
|---|---|---|
| `s` | n v o | Flash jump (type chars, press label) |
| `S` | n v o | Flash treesitter select |
| `gd` / `gD` / `gi` | n | Definition / declaration / implementation |
| `gr` | n | References (Telescope) |
| `K` | n | Hover docs |
| `C-t` | n | Find symbol in workspace (VSCode) |
| `]d` / `[d` | n | Next / previous diagnostic |
| `]g` / `[g` | n | Next / previous git hunk |

## 3. Search and replace

| Key | Mode | Does |
|---|---|---|
| `C-f` | n v | Search in buffer (same as `/`) |
| `/`, `n`, `N` | n | Search, next, previous |
| `SPC s s` | n | Fuzzy search lines in buffer |
| `SPC s p` | n | Search project (live grep) |
| `SPC s w` | n | Search the word under the cursor in the project, whole word only |
| `SPC f g` | n | Search project (live grep, old bind) |
| `Esc` | n | Clear search highlight |
| `:%s/a/b/g` | n | Replace in buffer (`/gc` asks each) |

## 4. Windows and splits

| Key | Mode | Does |
|---|---|---|
| `C-k <arrow>` | n v | Split toward the arrow, focus the new window |
| `C-k h/j/k/l` | n v | Move window left/down/up/right |
| `C-M-<arrows>` | n | Focus window in that direction |
| `C-w q` | n | Close buffer |
| `C-w C-w` | n | Close buffer |
| `C-w a` | n | Close all buffers |
| `C-w v` / `C-w s` | n | Vertical / horizontal split (Vim default) |

## 5. Editing

| Key | Mode | Does |
|---|---|---|
| `M-p` | n i v | Indent |
| `M-o` | n i v | Outdent |
| `gc` / `gcc` | n v | Toggle comment (Neovim built in) |
| `ys` / `ds` / `cs` | n | Surround add / delete / change |
| `gs` | v | Surround selection |
| `SPC s u` | n | Undo tree |
| `SPC c f` | n v | Format (manual; black, rustfmt, else LSP) |

### Folding

Treesitter folds. An arrow shows in the gutter on the line where a fold starts
(down = open, right = closed): click it, or use the keys. Everything starts
unfolded.

| Key | Mode | Does |
|---|---|---|
| click the gutter arrow | mouse | Fold / unfold that block |
| `za` | n | Toggle fold |
| `zc` / `zo` | n | Close / open fold |
| `zM` / `zR` | n | Close all / open all |

## 6. Multiple cursors

| Key | Mode | Does |
|---|---|---|
| `C-d` | n | Select the word under the cursor and add a cursor on its next match (press again for each further match) |
| `C-d` | v | Add cursor on next match of the selection |
| `Esc` | with cursors | Disable cursors, `Esc` again clears them |

### Harpoon (jump list)

| Key | Mode | Does |
|---|---|---|
| `SPC h a` | n | Add the current file to the harpoon list |
| `SPC 1` … `SPC 4` | n | Jump to the file in slot 1 to 4 |
| `SPC h d` | n | Remove the current file from the list |
| `SPC h h` | n | Open the list. `dd` deletes a line, `dd` then `p` moves one, Enter jumps. Close the menu with `q` or `Esc` to save |

The bottom statusline starts with the current directory name in brackets (e.g. `[snowpack-android]`, follows `:cd`), then the git branch when inside a repo (e.g. `[main]`, updates on its own after a checkout, short commit when detached), then shows error (`E2`, red), warning (`W1`, yellow), info (`I1`) and hint (`H1`, e.g. "declared but never read") counts after the file name. The harpoon slots have their own row at the top, e.g. ` 1:a.ts  2:b.ts `, with the current file highlighted.

## Start screen

`nvim` with no file shows a start screen with just an ASCII cat. Open anything
(`SPC SPC`, `C-n`) to leave it.

### nvim-tree keys (inside the sidebar)

Only these exist; the defaults (live filter, search, etc.) are removed.

| Key | Does |
|---|---|
| `Enter` / `o` / double-click | Open file or fold/unfold folder |
| `C-v` / `C-x` | Open in vertical / horizontal split |
| `a` | New file (end the name with `/` for a folder) |
| `r` | Rename |
| `d` | Delete |
| `x`, `c`, `p` | Cut, copy, paste (move or copy a file) |
| `y` / `Y` / `gy` | Copy name / relative path / absolute path |
| `R` | Refresh |
| `H` | Toggle dotfiles |
| `E` / `W` | Expand all / collapse all |
| `q` | Close the sidebar |
| `g?` | Show these keys |

## 7. Code intelligence (LSP)

| Key | Mode | Does |
|---|---|---|
| `SPC c r` / `SPC r n` | n | Rename symbol (project wide) |
| `SPC c a` | n v | Code action |
| `SPC c x` | n | Diagnostics list (Telescope) |
| `SPC d` | n | Line diagnostics float |
| `SPC f R` | n | Rename current file (updates imports) |

## 8. Git

| Key | Mode | Does |
|---|---|---|
| `SPC g m` | n | Merge tool: ours / merged / theirs (middle is the result you edit) |
| `SPC g q` | n | Close the merge tool |
| `]x` / `[x` | n | Next / previous conflict block |
| `SPC g o` / `g t` / `g b` / `g 0` | n | Conflict under cursor: keep ours / theirs / both / none |
| `SPC g r` | n | Revert hunk |
| `]g` / `[g` | n | Next / previous hunk |

## 9. Terminal

| Key | Mode | Does |
|---|---|---|
| ``C-` `` | n i t | Toggle bottom terminal (VSCode) |
| `C-@` | n i t | Same (many terminals send Ctrl+` as this). Opens at half the screen height |
| `SPC o t` | n | Same, from the leader |
| `SPC o m` | n | Read the Markdown file rendered by glow in a buffer (`q` goes back) |
| `C-\ C-n` | t | Leave terminal mode, back to normal |

Alacritty may not send Ctrl+` distinctly. If it does nothing, use `C-@`
(Ctrl+Space) or `SPC o t`.

## 10. Directory and project

| Key | Mode | Does |
|---|---|---|
| `SPC c d` | n | `cd` to the current file's folder |
| `SPC c D` | n | `cd` to the git root |
| `:cd path` | cmd | Change directory (global) |
| `:lcd path` / `:tcd path` | cmd | Change for this window / tab only |
| `:pwd` | cmd | Show the current directory |

Telescope (`SPC SPC`, `SPC s p`) searches from the current directory, so set it
first. The tree follows `:cd`; change the directory from Oil:
`` ` `` runs `:cd` to the shown folder, `~` runs `:tcd`, `-` goes to parent.

## 11. Help

| Key | Mode | Does |
|---|---|---|
| `SPC` (wait) | n | which-key popup |
| `SPC h b` / `SPC h k` | n | Search all keybinds |
| `SPC f h` | n | Help tags |
| `:Lazy` | cmd | Plugin manager |
| `:Mason` | cmd | Language servers |

---

## Changed from Neovim defaults

| Key | Was | Now |
|---|---|---|
| `C-d` | Scroll half page | Multi-cursor |
| `C-f` | Scroll page | Search in buffer |
| `C-p` | Previous line | Find file |
| `C-t` | Tag stack pop | Find symbol |
| `C-w q`, `C-w C-w` | Close window, next window | Close buffer |
| `C-b` / `C-n` | Scroll back, next line | List buffers, toggle sidebar |
| `grr`, `gra`, `grn`, `gri`, `grt` | Neovim 0.11 LSP defaults | Removed so `gr` has no delay |

Scrolling down is gone with `C-d` and `C-f`. Use `}`, `G` or `C-e`.

## Gutter marks

Left to right: fold arrow, one sign column, line number.
- Git (gitsigns): green `┃` added, orange `┃` changed, red `▁` deleted.
- Diagnostics: the line number turns red (error) or yellow (warning). Info and hints are not marked.

## Sticky function header

`nvim-treesitter-context` pins the enclosing function / loop / block above the
code. It only shows when the cursor is a few lines below the top of the window,
so `scrolloff` is set to 5. With `scrolloff = 0` it stays empty whenever the
cursor sits on the first visible line.

## Not verified

The binds were checked to load without errors in headless Neovim, not typed
interactively. Terminal-dependent keys (`C-``, `C-M-arrows`, `M-p`, `M-o`)
depend on your terminal sending them.
