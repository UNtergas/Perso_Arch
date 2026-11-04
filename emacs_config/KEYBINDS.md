# Keybinds changed from Doom defaults

All custom binds live in `doom/config.el`. Most are ported from the VSCode
`keybindings.json` / VSCodeVim settings so muscle memory carries over.

State column: **N** normal, **V** visual, **I** insert, **M** motion, **all** =
every state.

## Custom binds

| Key | State | Now does | Replaced (Doom default) | Origin |
|---|---|---|---|---|
| `s` | N V | Jump: type chars, then press the label (`avy-goto-char-timer`) | `evil-snipe` 2-char find (package disabled) | VSCodeVim easymotion `s` |
| `]d` / `[d` | M | Next / previous diagnostic (`next-error`) | Next / previous git hunk | VSCode `]d` / `[d` |
| `]g` / `[g` | M | Next / previous git hunk | *(unbound)* | Keeps Doom's hunk nav after `]d` was taken |
| `M-p` | N I | Indent line | *(unbound)* | VSCode `alt+p` |
| `M-p` | V | Indent selection (keeps selection) | *(unbound)* | VSCode `alt+p` |
| `M-o` | N I | Outdent line | *(unbound)* | VSCode `alt+o` |
| `M-o` | V | Outdent selection (keeps selection) | *(unbound)* | VSCode `alt+o` |
| `C-b` | all | Toggle treemacs sidebar | N: scroll page up / I: back one char | VSCode `ctrl+b` |
| `C-n` | all | Focus treemacs | N: next paste in yank ring / I: completion next | VSCode `ctrl+n` |
| `C-M-<left/right/up/down>` | all | Focus window in that direction | Sexp navigation (`backward-sexp`, …) | VSCode `ctrl+alt+arrows` |
| `C-w q` | all | Close buffer (`kill-current-buffer`) | Close window (`evil-quit`) | VSCode `ctrl+w q` |
| `C-w C-w` | all | Close buffer | Next window (`other-window`) | VSCode `ctrl+w ctrl+w` |
| `C-w a` | all | Close all buffers | *(unbound)* | VSCode `ctrl+w a` |
| `C-k <arrow>` | N V | Split toward arrow + focus new window | *(unbound in N/V)* | VSCode `ctrl+k arrows` |
| `C-k a` | N V | New file (`find-file`) | *(unbound)* | VSCode `ctrl+k a` |
| `C-k A` | N V | New folder (`make-directory`) | *(unbound)* | VSCode `ctrl+k shift+a` |
| `C-k h/j/k/l` | N V | Move window left/down/up/right | *(unbound)* | VSCode `ctrl+k h/j/k/l` |
| `C-d` | N | Select word under cursor, then add next match (multi-cursor) | Scroll half page down | VSCode `ctrl+d` |
| `C-d` | V | Add next match of selection (multi-cursor) | Scroll half page down | VSCode `ctrl+d` |
| `M-d` / `M-D` | N V | *(back to Emacs default: `kill-word`)* | Multi-cursor next / prev match | Moved to `C-d` |

Notes:
- With multiple selections active, `c` / `i` / `a` edit all of them; `Esc`
  exits. Doom's other multi-cursor keys still work: `R` in visual selects all
  matches, `gz…` = evil-mc cursors.
- To half-page scroll now: `C-u` up still works; for down use `C-f` (page) or `}`.
- Insert mode `C-k` (digraph) untouched: `C-k` binds are N/V only.

## Not changed but useful (Doom defaults)

| Key | Does |
|---|---|
| `SPC SPC` / `SPC p f` | Find file in project (VSCode Shift-Shift / Ctrl+P) |
| `SPC .` | Find any file |
| `SPC ,` | Switch buffer |
| `SPC p p` | Switch project |
| `SPC :` | M-x (command palette) |
| `SPC s s` | Search lines in buffer |
| `SPC s p` | Search project (ripgrep); `C-c C-e` → editable results, `C-c C-c` apply |
| `:%s/a/b/g` | Replace in buffer (`/gc` to confirm each) |
| `gd` / `gD` | Go to definition / references |
| `K` | Docs on hover |
| `SPC c r` | LSP rename symbol (project wide) |
| `SPC c a` | Code action |
| `SPC c f` | Format buffer / selection (manual, no format on save) |
| `gQ` + motion | Format region |
| `SPC c x` | Diagnostics list |
| `SPC f R` | Rename / move current file (LSP updates imports for TS/Rust) |
| `SPC b S` | Save all buffers |
| `SPC g g` | Magit |
| `SPC g r` | Revert git hunk |
| `SPC o t` | Terminal (vterm) |
| `gcc` / `gc` + motion | Toggle comment |
| `za` | Fold toggle |
| `SPC s u` | Undo tree |
| `SPC TAB` | Workspaces |
| `SPC h b b` / `SPC h f` | Search keybinds / functions |
| `SPC h r r` | Reload config |
