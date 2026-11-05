# Key guide

All keybinds in this Doom setup, grouped by what they do, with a group per
function. Two kinds:

- **Custom**: set in `doom/config.el`. Most are ported from VSCode.
- **Doom default**: ship with Doom, not changed by this config.

State: **N** normal, **V** visual, **I** insert, **M** motion, **all** every
state. `SPC` = leader, `M-` = Alt, `C-` = Ctrl.

Change log of custom binds vs Doom defaults: [KEYBINDS.md](KEYBINDS.md).
Refactoring: [REFACTOR_GUIDE.md](REFACTOR_GUIDE.md).

If a key does nothing, look it up: `SPC h k` then the key. Search every bind:
`SPC h b b`.

---

## 1. Files and navigation

| Key | State | Does | Kind |
|---|---|---|---|
| `SPC SPC` / `SPC p f` | N | Find file in project (VSCode Ctrl+P) | Doom default |
| `SPC .` | N | Find any file | Doom default |
| `SPC ,` | N | Switch buffer | Doom default |
| `SPC p p` | N | Switch project | Doom default |
| `SPC f R` | N | Rename / move current file | Doom default |
| `C-k a` | N V | New file | Custom |
| `C-k A` | N V | New folder | Custom |
| `C-s` | N V I | Save buffer | Custom |
| `SPC b S` | N | Save all buffers | Doom default |
| `C-b` | N V G | Toggle treemacs sidebar | Custom |
| `C-n` | N V G | Focus treemacs | Custom |

## 2. Jumping around

| Key | State | Does | Kind |
|---|---|---|---|
| `s` + chars + label | N V | Jump to any visible text (easymotion) | Custom |
| `gd` | N | Go to definition | Doom default |
| `gr` | N M | Show references | Custom |
| `K` | N | Docs on hover | Doom default |
| `]d` / `[d` | M | Next / previous diagnostic | Custom |
| `]g` / `[g` | M | Next / previous git hunk | Custom |

## 3. Search and replace

| Key | State | Does | Kind |
|---|---|---|---|
| `SPC s s` | N | Search lines in buffer | Doom default |
| `SPC s p` | N | Search project (ripgrep) | Doom default |
| `C-c C-e` | in results | Edit search results (wgrep) | Doom default |
| `C-c C-c` | in results | Apply edited results | Doom default |
| `C-c C-k` | in results | Abort edited results | Doom default |
| `:%s/a/b/g` | N | Replace in buffer (`/gc` asks each) | Doom default |
| `/` , `n` , `N` | N | Search in buffer, next, previous | Doom default |

## 4. Windows and splits

| Key | State | Does | Kind |
|---|---|---|---|
| `C-k <arrow>` | N V | Split toward the arrow, focus the new window | Custom |
| `C-k h/j/k/l` | N V | Move window left/down/up/right | Custom |
| `C-M-<arrows>` | all | Focus window in that direction | Custom |
| `C-w q` | all | Close buffer | Custom |
| `C-w C-w` | all | Close buffer | Custom |
| `C-w a` | all | Close all buffers | Custom |
| `C-w v` / `C-w s` | N | Vertical / horizontal split | Doom default |
| `C-w h/j/k/l` | N | Focus window | Doom default |

## 5. Editing

| Key | State | Does | Kind |
|---|---|---|---|
| `M-p` | N I | Indent line | Custom |
| `M-o` | N I | Outdent line | Custom |
| `M-p` | V | Indent selection | Custom |
| `M-o` | V | Outdent selection | Custom |
| `gcc` / `gc` + motion | N | Toggle comment | Doom default |
| `za` | N | Fold toggle | Doom default |
| `SPC s u` | N | Undo tree | Doom default |
| `gQ` + motion | N | Format region | Doom default |
| `SPC c f` | N V | Format buffer / selection (manual) | Doom default |

## 6. Multiple cursors

| Key | State | Does | Kind |
|---|---|---|---|
| `C-d` | N | Select word under cursor, then add next match | Custom |
| `C-d` | V | Add next match of the selection | Custom |
| `c` / `i` / `a` | with matches | Edit all selections | Doom default |
| `Esc` | with matches | Leave multi-cursor | Doom default |
| `R` | V | Select all matches | Doom default |
| `gz…` | N V | evil-mc cursors | Doom default |

## 7. Code intelligence (LSP)

| Key | State | Does | Kind |
|---|---|---|---|
| `SPC c r` | N | Rename symbol (project wide) | Doom default |
| `SPC c a` | N | Code action | Doom default |
| `SPC c x` | N | Diagnostics list | Doom default |
| `SPC e` | N | Errors (check with `SPC h k` on your machine) | Doom default |

## 8. Git

| Key | State | Does | Kind |
|---|---|---|---|
| `SPC g g` | N | Magit | Doom default |
| `SPC g r` | N | Revert git hunk | Doom default |
| `]g` / `[g` | M | Next / previous hunk | Custom |

## 9. Tools

| Key | State | Does | Kind |
|---|---|---|---|
| `SPC o t` | N | Terminal (vterm) | Doom default |
| `SPC :` | N | M-x (command palette) | Doom default |

## 10. Help and config

| Key | State | Does | Kind |
|---|---|---|---|
| `SPC h k` | N | Describe a key | Doom default |
| `SPC h b b` | N | Search all keybinds | Doom default |
| `SPC h f` | N | Describe a function | Doom default |
| `SPC h v` | N | Describe a variable | Doom default |
| `SPC h r r` | N | Reload config | Doom default |

---

## Removed or moved

| Key | Was | Now |
|---|---|---|
| `C-s` | Incremental search | Save |
| `C-d` | Scroll half page down | Multi-cursor |
| `M-d` / `M-D` | Multi-cursor | Emacs default (`kill-word`) |
| `]d` / `[d` | Git hunk | Diagnostic (hunk moved to `]g` / `[g`) |
| `s` | evil-snipe | Jump (easymotion) |
| `C-b` | Scroll page up | Toggle treemacs |
| `C-n` | Next paste | Focus treemacs |

Half-page scroll down is gone with `C-d`. Use `C-f` (page) or `}`.

## Not verified

The Doom default rows are from memory of Doom's standard bindings and were
not checked on this machine. The custom rows are read from `config.el`.
