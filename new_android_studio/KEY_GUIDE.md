# Key guide: Android Studio with the nvim keys

`ideavimrc` (installed as `~/.ideavimrc`) gives Android Studio the same keys and navigation as `new_vim/nvim/init.lua`,
as far as an IDE allows. `SPC` = Space. Reload without restarting the IDE: `SPC h r`. Press `SPC` (or `g`, `]`, `[`) and wait a moment: the
Which-Key plugin (Marketplace, by Tobias Völzel, 0.11.2) lists what follows. `SPC :` searches every IDE action with its key.

Not tested in a running IDE (the setup session could not start Android Studio): every `<Action>` id in the file was checked
against the installed 2026.2.1 build, but the keys themselves still need a first try. See "First run" at the end.

## Same keys, same meaning

| Keys | Does |
|---|---|
| `SPC SPC` / `SPC .` | Go to file |
| `SPC ,` / `SPC b b` / `C-b` | Recent files (Delete removes one, like `dd` in the buffer manager) |
| `SPC :` / `SPC h b` / `SPC h k` | Search every action and its key (command palette) |
| `SPC e` / `C-n` | Project tool window (Oil stand-in). With the NERDTree plugin on, `j` `k` move and Enter opens |
| `SPC 1` .. `SPC 9` | Nth editor tab |
| `C-s` | Save all (also from insert and visual mode) |
| `C-f` | Search in the file (`/`) |
| `SPC s s` | Find in file |
| `SPC s p` / `SPC f g` | Find in project |
| `SPC s w` | Find the word under the cursor in the project |
| `SPC s r` | Replace in project |
| `SPC s o` | Structure tool window (outline) |
| `SPC s u` | Local history (undo tree stand-in) |
| `gd` / `gD` / `gi` | Definition / type declaration / implementation |
| `gr` | Usages popup (grouped by file, with a preview you can edit) |
| `gR` | The same usages in the Find tool window (stays open) |
| `gp` | Peek the definition in an editable popup (Quick Definition) |
| `K` | Documentation popup; press it again to move into the popup |
| `C-t` / `C-S-t` | Symbol in the project / in this file |
| `]d` `[d` | Next / previous error |
| `]g` `[g` | Next / previous changed block |
| `]b` `[b` / `]B` `[B` | Next / previous editor tab (Neovim's built-in buffer keys) / last / first |
| `M-j` / `M-k` | Half page down / up (`C-d` is multi-cursor, as in nvim) |
| `M-p` / `M-o` | Indent / outdent (normal, insert, visual) |
| `M-.` / `SPC c a` | Intention actions (code action) |
| `SPC c r` / `SPC r n` | Rename the symbol |
| `SPC f R` | Rename the file |
| `SPC c f` | Reformat code |
| `SPC c x` / `SPC c X` / `C-w d` | Problems tool window |
| `SPC d` | Error description at the caret |
| `C-d` | Multi-cursor on the word, again for each next match (IdeaVim's `Alt-n` plugin keys also work: `Alt-x` skips, `Alt-p` removes) |
| `C-S-Down` / `C-S-Up` | Add a cursor below / above |
| `gc` / `gcc` | Comment |
| `ys` `ds` `cs`, `ysw`, `ysW`, `ysp`, `ys(` `ys{` `ys[` `ys<`, `gs` (visual) | Surround, as in nvim |
| `za` `zc` `zo` `zM` `zR` | Folds (IdeaVim built in) |
| `;` | `:` (command line) |
| `Esc` | Clear the search highlight |
| `C-w \` / `C-w -` | Split side by side / stacked |
| `C-w x` | Close the split |
| `C-w C-w` / `C-w a` | Close this editor / all editors |
| `C-w z` | Maximise the editor, again to restore |
| `C-w =` | Unsplit everything |
| `C-M-<arrows>` | Focus the split in that direction |
| `SPC o t` / `C-\` | Terminal tool window |
| `C-k a` / `C-k A` | New file / folder (the IDE's New dialog) |
| `SPC g m` | Resolve conflicts (merge tool) |
| `SPC g r` | Roll back the changed block under the caret |
| `SPC g g` | Lazygit in its own terminal window (an External Tool, see "Lazygit" below) |
| `SPC g f` | Lazygit filtered to this file's history |
| `SPC g v` | Version Control tool window |
| `SPC g h` | History of this file (the IDE's own) |
| `SPC g H` / `SPC g l` | Git log |
| `SPC t b` | Git blame (annotate), again to hide |
| `SPC h r` | Reload `~/.ideavimrc` |
| `SPC q` / `M-q` | Clear the highlight / hide the tool windows |

## Harpoon (the HarpoonIJ plugin)

| Keys | Does |
|---|---|
| `SPC h a` | Add this file to the first empty slot |
| `SPC h s 1` .. `SPC h s 5` | Put this file in slot N |
| `SPC h 1` .. `SPC h 5` | Jump to slot N |
| `SPC h h` / `SPC h d` | Open the list as an editor: `dd` deletes a line, `dd` then `p` moves it, Enter jumps, `Esc` closes and saves |

Limits: the plugin only has direct jumps for slots 1 to 5 (nvim had 1 to 9; the list itself can be longer, reach the rest with
`SPC h h`). It has no "remove this file" action: open the list and `dd` the line (so `SPC h d` just opens the list).

## Plugins and tools to install once

| What | How | For |
|---|---|---|
| Which-Key (Tobias Völzel) | Settings > Plugins > Marketplace | the key popup after `SPC`, `g`, `]`, `[` |
| AceJump and IdeaVim-EasyMotion | Settings > Plugins > Marketplace (both) | `s` flash jump with labels. Without them `set easymotion` is rejected on `:source` |
| HarpoonIJ | Settings > Plugins > Marketplace | `SPC h ...` |
| Two External Tools (group `Vim`) | Settings > Tools > External Tools | `SPC g g` and `SPC g f` (lazygit) |

All three Marketplace plugins were checked against this build (AI-262.9437.185) through the Marketplace's own compatibility
query: IdeaVim-EasyMotion 1.16, AceJump 3.8.22 and HarpoonIJ 0.2.0 are offered for it. The "LazyGit in Editor Terminal" plugin is
not (it returns nothing for this build), which is why lazygit goes through External Tools. Restart the IDE after installing plugins.

### Flash (`s`)

`s` then the characters you look for, then type the (lower case) label of the match: `map s <Plug>(easymotion-sn)` works in normal,
visual and operator-pending mode, like flash. `S` grows the selection by syntax (the IDE's Extend Selection), the closest to
flash's treesitter select. `gs` in visual mode is the surround command (as in nvim).

### Lazygit

Create two tools in Settings > Tools > External Tools (`+`), both with Group `Vim`, no console, "Open console" off:

| Field | Tool 1 | Tool 2 |
|---|---|---|
| Name | `lazygit` | `lazygit_file` |
| Program | `alacritty` | `alacritty` |
| Arguments | `--working-directory $ProjectFileDir$ -e lazygit` | `--working-directory $ProjectFileDir$ -e lazygit -f $FilePath$` |
| Working directory | `$ProjectFileDir$` | `$ProjectFileDir$` |

Their action ids are `Tool_Vim_lazygit` and `Tool_Vim_lazygit_file`, which the `ideavimrc` already uses. Lazygit then opens in its own
alacritty window; quitting lazygit closes that window. A niri window rule could float it, like nvim's floating lazygit.

## Different or missing

| nvim | In Android Studio |
|---|---|
| `s` flash labels | Needs the AceJump and IdeaVim-EasyMotion plugins (see above); labels are lower case, and `s` takes any number of characters like flash |
| `gD` (declaration) | Type declaration, the closest the IDE has |
| `SPC b b` / `C-b` buffer manager (edit the list: `dd` closes a buffer) | The Recent Files popup: type to filter, `Delete` removes an entry from the list (it does not close the editor; close with `C-w C-w`). I found no Marketplace plugin with an editable open-files list |
| `C-w q` number the windows, `C-w r` resize mode, `C-k h/j/k/l` resize, `C-w <arrows>` move a window | No equivalent. Resize splits with the mouse or the IDE's own actions (`SPC :`) |
| `C-w c` / `C-w C` fill column / row | None (`C-w z` maximises the whole editor) |
| Oil editing files as text | Use the Project tool window. Rename and move go through the IDE's refactoring |
| `SPC g o` `g t` `g b` `g 0`, `]x` `[x` conflict keys | Do it in the merge tool (`SPC g m`) |
| Telescope pickers, `C-q` to the quickfix list | The IDE's search popups and Find tool window |
| `]f` `[f` in the references finder | None |
| Lspsaga peek editing, finder preview | The IDE's own popups |
| The keys block, the tab row, statusline colours | Not possible in an IDE |
| `SPC c d` / `SPC c D` (cd) | None (the IDE has a project root) |
| hjkl repeat limiter (blocks holding `j`) | Not ported |
| Esc Esc in the terminal | The terminal tool window handles its own keys |

## Keys that stay with the IDE

`C-c`, `C-v` (clipboard) and `C-z` (undo) are not taken over, so copy and paste work as usual. The keys `ideavimrc` takes over for
Vim (`sethandler`): `C-d`, `C-f`, `C-s`, `C-n`, `C-b`, `C-t`, `C-w`, `C-k`, `C-\`, `C-S-t`, `C-S-Down`, `C-S-Up`, `C-A-<arrows>`,
`A-j`, `A-k`, `A-p`, `A-o`, `A-.`, `A-d`, `A-q`. If one of them breaks an IDE shortcut you need, delete its `sethandler` line.

## First run

1. Start Android Studio, open any Kotlin file and type `:source ~/.ideavimrc` (the first time; later `SPC h r`). Then press `SPC` and wait: the which-key popup should list the groups.
2. If IdeaVim shows an error, it names the option or line of `~/.ideavimrc`: send it to Claude.
3. Try `SPC SPC`, `gd`, `C-d`, `C-s`, `SPC h r`.
