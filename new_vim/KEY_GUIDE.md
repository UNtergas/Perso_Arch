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
| `SPC .` | n | Find any file (includes hidden) |
| `SPC ,` / `SPC b b` | n | Buffer manager (buffer_manager.nvim): Enter opens, `dd` closes a buffer, `:w` applies edits, `q` / Esc closes |
| `SPC :` | n | Command palette |
| `C-n` | n v | Toggle Oil file browser: opens at the current file's folder, again goes back |
| `SPC e` | n | Oil file browser (edit files as text). It also opens for `nvim .` and `:e .` instead of netrw |
| `C-b` | n v | Buffer manager (same as `SPC b b`) |
| `C-k a` | n v | New file (creates parent folders) |
| `C-k A` | n v | New folder |
| `C-s` | n v | Save |
| `C-s` | i | Save and back to normal mode |
| `S-CR` | n v i | Same as Enter |
| `Tab` / `S-Tab` | i (completion) | Next / previous item |
| `SPC b S` | n | Save all buffers |

## 2. Jumping around

| Key | Mode | Does |
|---|---|---|
| `s` | n v o | Flash jump (type chars, press label) |
| `S` | n v o | Flash treesitter select |
| `gd` / `gD` / `gi` | n | Definition / declaration / implementation |
| `gr` | n | References with editable preview (Lspsaga Finder) |
| `]f` / `[f` | Finder | Jump to next / previous file header; counts work (e.g. `2]f`) |
| `K` | n | Hover docs (Lspsaga); repeat to focus the popup |
| `gp` | n | Peek definition in an editable popup; Esc closes |
| `SPC s o` | n | Toggle document outline tree; Enter expands/jumps, o jumps directly, q closes |
| `C-t` | n | Find symbol in workspace (VSCode) |
| `M-j` / `M-k` | n x | Scroll half a page down / up (animated, about 150 ms). Not `C-k`: it starts the window chords |
| `]d` / `[d` | n | Next / previous diagnostic, without popups (counts work) |
| `]g` / `[g` | n | Next / previous git hunk |

## 3. Search and replace

| Key | Mode | Does |
|---|---|---|
| `C-f` | n v | Search in buffer (same as `/`) |
| `/`, `n`, `N` | n | Search, next, previous |
| `SPC s s` | n | Fuzzy search lines in buffer |
| `SPC s p` | n | Search project (live grep) |
| `SPC s w` | n | Search the word under the cursor in the project, whole word only |
| `SPC s r` | n v | Search and replace in the project, grouped by file (grug-far). `SPC s` syncs all, `SPC l` this line, `SPC n` / `SPC p` this line then next / previous, `SPC v` this file. `dd` drops a result. `g?` lists every key. `SPC r` (Replace) is off |
| `SPC f g` | n | Search project (live grep, old bind) |
| `C-q` | Telescope | Send the results to the quickfix list |
| `Esc` | n | Clear search highlight |
| `:%s/a/b/g` | n | Replace in buffer (`/gc` asks each) |

## 4. Windows and splits

| Key | Mode | Does |
|---|---|---|
| `C-w <arrow>` | n v | Move the window to the far left/bottom/top/right (replaces the built-in C-w arrows, which only focus; use `C-M-h/j/k/l` to focus) |
| `C-k h/j/k/l` | n v | Resize the window by moving a divider in that direction, in steps of 10% of the screen (columns for `h` `l`, rows for `j` `k`). A window with a neighbour on the right / below grows with `l` / `j` and shrinks with `h` / `k`; the rightmost / bottom-most window has its divider on the left / top, so `h` / `k` grow it and `l` / `j` shrink it. Same as tmux. A window with no neighbour in that direction does nothing |
| `C-w =` | n v | Equal window sizes; press again to put the previous sizes back (forgotten when the number of windows changes) |
| `C-w r` | n v | Resize mode, like i3 (replaces the built-in C-w r, rotate): `h` `j` `k` `l` resize the window in 10% steps, `=` equal sizes (no toggle back), `Esc` / `Enter` / `q` leave (any other key leaves too). The command line shows `-- RESIZE --` while it is on |
| `C-w -` | n | Split stacked (new window below) |
| `C-w \` | n | Split side by side (new window to the right) |
| `C-M-<arrows>` | n | Focus window in that direction |
| `C-w q` | n | Number every window (a big digit in its middle, like tmux's `Alt-e q`); press the number to jump to that window, anything else cancels. Windows are numbered left to right, then top to bottom, up to 9 |
| `C-w C-w` | n | Close buffer |
| `C-w C-w` | n | Close buffer |
| `C-w a` | n | Close all buffers |
| `C-w z` | n | Zoom this window to the whole screen, again to restore (like tmux `z`) |
| `C-w c` | n | This window fills its column (full height), again to restore (like tmux `c`) |
| `C-w C` | n | This window fills its row (full width), again to restore (like tmux `C`) |
| `C-w v` / `C-w s` | n | Vertical / horizontal split (Vim default) |

## 5. Editing

| Key | Mode | Does |
|---|---|---|
| `M-p` | n i v | Indent |
| `M-o` | n i v | Outdent |
| `gc` / `gcc` | n v | Toggle comment (Neovim built in) |
| `ys` / `ds` / `cs` | n | Surround add / delete / change |
| `ysw` / `ysW` | n | Surround the word / WORD under the cursor (same as `ysiw` / `ysiW`) |
| `ysp` / `ys(` / `ys{` / `ys[` / `ys<` | n | Surround the paragraph / inside the brackets (same as `ysip`, `ysi(`...); `yst` stays the "till char" motion, use `ysit` for tags |
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
| `C-d` | n | Start vim-visual-multi on the word under the cursor; press again for each next match. Typing shows at every cursor live, as you type |
| `C-S-Down` / `C-S-Up` | n | Add a cursor below the bottom-most / above the top-most cursor, like VS Code: the set keeps growing both ways |
| `i` `a` `A` `c`... | VM | Act at every cursor, live. In VM's extend mode (words selected) `c` changes every selection |
| `n` / `N`, `q`, `Q` | VM | Next / previous match, skip the current match, remove the current cursor |
| `Alt-n` / `Alt-N` | VM | Jump to the next / previous cursor (VM's `]` / `[`, moved because those clash with other maps here) |
| `Tab` | VM | Switch between cursor mode and extend mode |
| `Esc` | VM | Leave VM and clear the cursors |

While VM is on, its info (mode, cursor n / total, search pattern) shows in the winbar in place of the file path, and the statusline stays as it is. The path comes back when VM ends.

The multicursor.nvim setup (Alt-d / `SPC m c` cursor mode, no live typing) is disabled in favour of vim-visual-multi; its config is still in `init.lua`.

### Harpoon (jump list)

| Key | Mode | Does |
|---|---|---|
| `SPC h a` | n | Add the current file to the harpoon list |
| `SPC h 1` … `SPC h 9` | n | Jump to the file in harpoon slot 1 to 9 |
| `SPC h d` | n | Remove the current file from the list |
| `SPC h h` | n | Open the list. `dd` deletes a line, `dd` then `p` moves one, Enter jumps. Close the menu with `q` or `Esc` to save |

There is no command-line row under the statusline (`cmdheight` is 0): the statusline is the last line. It starts with the mode word (`NORMAL`, `INSERT`, `VISUAL`... coloured by mode), then the git branch when inside a repo (cut to 18 characters from the start with `…` when longer, updates on its own after a checkout), then shows error (`E2`, red), warning (`W1`, yellow), info (`I1`) and hint (`H1`, e.g. "declared but never read") counts after the file name. The top row is the tab bar: every open buffer as a tab (` 1 a.ts  2 b.ts `, in the Buffer manager order, the current one highlighted, a red error count when the file has errors, a blue dot when unsaved, click to switch, `‹ ›` when they do not all fit). `SPC 1` … `SPC 9` jump to tab 1 to 9, the bar follows the current tab, and `SPC [` / `SPC ]` (or a click on `‹` / `›`) scroll it to the hidden tabs without changing buffer (switching buffer makes it follow again); `[b` / `]b` move to the previous / next buffer. Each window's winbar starts with the project block (folder icon and the directory name, follows `:cd`), an arrow, then its file path, the unsaved dot and that file's git counts; the focused window also shows the harpoon slots at the right end (`[󰀱] [1] [2]`, the current file's slot underlined).

## Start screen

`nvim` with no file shows a start screen: an ASCII cat and a menu. Press the key
shown, or open anything (`SPC SPC`, `C-n`) to leave it.

| Key | Does |
|---|---|
| `p` | Open old project: pick one, `cd` into it, browse it in Oil |
| `e` | File explorer: Oil on the folder nvim started in |
| `n` | Empty buffer |
| `l` | Lazy plugin manager, then `U` to update |
| `m` | Mason: install and update LSP servers and tools (`q` closes) |
| `h` | Plugin health check (`q` closes) |
| `s` | LSP health check (`q` closes) |
| `q` | Exit |

### Oil keys (inside the file browser)

Oil is a text buffer: edit the list like normal text, and `:w` applies the
changes after a confirmation. Multi-cursor, `:s`, macros and `.` work on it.
The top row of every Oil window shows the full path of the folder it lists
(read-only, `~` for home, a too-long path is cut from its left end).

| Key | Does |
|---|---|
| `C-n` | Close Oil, back to where you were (refuses while there are unsaved changes) |
| `Enter` | Open file or enter folder |
| `M-Enter` | Enter a folder and keep going down while it holds only one folder (Java `com/application/app`). Stops at a folder with a file or several entries. On a file: same as `Enter` |
| `-` | Parent folder |
| `C-s` / `C-h` | Open in vertical / horizontal split |
| `C-p` | Preview |
| `o`, type a name, `:w` | New file (end the name with `/` for a folder) |
| Edit the name, `:w` | Rename (imports update) |
| `dd`, `:w` | Delete (to the trash, see section 10) |
| `dd`, go to the folder, `p`, `:w` | Move (imports update) |
| `yy`, go to the folder, `p`, `:w` | Copy |
| `gx` | Open with the default app (PDF, images) |
| `C-l` | Refresh |
| `g.` | Toggle dotfiles (shown by default) |
| `gs` | Change the sort order |
| `` ` `` | `:cd` to the shown folder |
| `g\` | Show this folder's trash |
| `g?` | Show all keys |

## 7. Code intelligence (LSP)

| Key | Mode | Does |
|---|---|---|
| `SPC c r` / `SPC r n` | n | Rename symbol in a popup (project wide); Enter confirms, Ctrl-C cancels |
| `SPC c a` | n v | Code action |
| `SPC c x` | n | Workspace diagnostics popup (Lspsaga) |
| `SPC c X` | n | Diagnostics list for the whole project (Telescope) |
| `C-w d` / `C-w Ctrl-d` | n | Diagnostics of the current buffer only (Lspsaga window); replaces the built-in float with the diagnostics under the cursor |
| `SPC d` | n | Line diagnostics popup (Lspsaga) |
| `SPC f R` | n | Rename current file (updates imports) |

## 8. Git

| Key | Mode | Does |
|---|---|---|
| `SPC g m` | n | Merge tool: ours / merged / theirs (middle is the result you edit) |
| `SPC g q` | n | Close the merge tool |
| `]x` / `[x` | n | Next / previous conflict block |
| `SPC g o` / `g t` / `g b` / `g 0` | n | Conflict under cursor: keep ours / theirs / both / none |
| `SPC g r` | n | Revert hunk |
| `SPC t b` | n | Toggle git blame of the current line: a gray note at the end of the line with the author, the date and the commit message (appears after a short pause on the line) |
| `]g` / `[g` | n | Next / previous hunk |

## 9. Terminal

| Key | Mode | Does |
|---|---|---|
| `SPC o t` / `C-\` | n | Toggle bottom terminal (opens at half the screen height). From inside the terminal: `C-\ C-\` |
| `SPC o m` | n | Read the Markdown file rendered by glow in a buffer (`q` goes back) |
| `Esc Esc` | t | Leave terminal mode, back to normal (a single `Esc` still reaches the program inside) |
| `C-\ C-n` | t | Leave terminal mode, back to normal |

## 10. Directory and project

| Key | Mode | Does |
|---|---|---|
| `SPC c d` | n | `cd` to the current file's folder |
| `SPC c D` | n | `cd` to the git root |
| `:cd path` | cmd | Change directory (global) |
| `:lcd path` | cmd | Change for this window only |
| `:pwd` | cmd | Show the current directory |

Telescope (`SPC SPC`, `SPC s p`) searches from the current directory, so set it
first. Change the directory from Oil:
`` ` `` runs `:cd` to the shown folder, `-` goes to parent.

Deleting in Oil sends files to the trash. To get one back: `g\` in the folder it was deleted from shows its trash, `dd` the file, `g\` back, `p`, `:w`. `:Oil --trash /` lists everything in the trash. A delete inside the trash view that is not pasted anywhere purges the file for good.

## 11. Help

| Key | Mode | Does |
|---|---|---|
| `SPC` (wait) | n | which-key popup |
| `SPC h b` / `SPC h k` | n | Search all keybinds |
| `SPC h r` / `:Reload` | n | Reload the config without closing: saves all files, writes a session and restarts nvim into it (same files, windows and cursor, fresh config; lazy.nvim does not support re-sourcing `init.lua`). Needs nvim 0.12+. Cancels with a warning if a buffer cannot be saved or a terminal job is running |
| `SPC f h` | n | Help tags |
| `:Lazy` | cmd | Plugin manager |
| `:Mason` | cmd | Language servers |

---

## Changed from Neovim defaults

| Key | Was | Now |
|---|---|---|
| `C-d` | Scroll half page | Multi-cursor |
| `C-f` | Scroll page | Search in buffer |
| `C-t` | Tag stack pop | Find symbol |
| `C-w T` | Move window to a new tab | Disabled |
| `;` | Repeat `f`/`t` | Same as `:` (normal and visual). To repeat, press `f`/`t` again; `,` goes back |
| `C-w q` | Close window | Number the windows, press a number to jump |
| `C-w C-w` | Next window | Close buffer |
| `C-b` / `C-n` | Scroll back, next line | List buffers, toggle Oil |
| `grr`, `gra`, `grn`, `gri`, `grt` | Neovim 0.11 LSP defaults | Removed so `gr` has no delay |

Scrolling down is gone with `C-d` and `C-f`. Use `}`, `G` or `C-e`.

One tab per nvim: the keys that open a tab are removed (Oil, Telescope, `C-w T`). Move between files with buffers (`C-b`) and Harpoon. The merge tool (`SPC g m`) still opens its own tab, and `SPC g q` closes it.

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
interactively. Terminal-dependent keys (`C-M-arrows`, `M-p`, `M-o`)
depend on your terminal sending them.

The right end of the statusline shows keys typed so far in a pending command (`d`, `2d`, `"a`), the macro being recorded (`● @q`), the search count, the language server, `utf-8`, the indent (`SPC:4` for spaces, `TAB:4` for tabs; click it, or `SPC t i`, to change it), the position and how far down the file you are in one block (`76:42 | 5%`, `Top` / `Bot` at the ends) and the file type.

Messages ("written", substitutions, yanks, errors, warnings, `:echo`, shell output) are toasts at the bottom right (noice routes them to nvim-notify); the search count, the recording notice and the pending keys are not repeated as messages. `:messages` opens the history. `SPC t c` brings the command-line row back (and takes it away again) if a plugin misbehaves.
