# Refactor guide (Doom Emacs)

How to rename / move things and keep imports working.
Two modes:

- **Automatic**: Emacs + the LSP server rewrites the imports for you.
- **Manual**: the LSP can't do it (or you moved files outside Emacs), so you
  fix imports with search and replace.

Keys here are the Doom defaults plus the changes in [KEYBINDS.md](KEYBINDS.md).
If a key does nothing, look it up with `SPC h k` then the key.

## What the LSP can do

| Language | Rename symbol (`SPC c r`) | Imports updated on file/folder move |
|---|---|---|
| TS/JS | yes | yes |
| Rust | yes (`mod` / `use`) | yes |
| Python | yes | **no** (pyright lacks it; only Pylance has it) |

So: TS/JS and Rust → automatic. Python moves → manual.

---

## Automatic mode

### Prerequisites

1. The file you are working in belongs to a project with a running LSP server
   (open any file of the project; check the modeline for the LSP indicator).
2. Do the move/rename **from inside Emacs**, never with `mv` in a shell. The
   LSP only sees renames made through Emacs.
3. Afterwards save the buffers the LSP edited: `SPC b S` (save all). They are
   left modified but unsaved.

### Rename a variable / function / class

1. Put the cursor on the symbol.
2. `SPC c r` (`lsp-rename`), type the new name, `RET`.
3. It renames every reference in the project. `SPC b S` to save.

Only inside the current file: `C-d` (select symbol + next matches, multiple
cursors), type the new name, `Esc`.

### Rename a folder (imports updated)

- **Treemacs**: `C-b` to open, cursor on the folder, `R`, type the new name.
- **Dired**: `SPC f d`, cursor on the folder, `R`, type the new name.

### Move a folder to a new position (imports updated)

- **Treemacs**: cursor on the folder, `R`, type the **full new path**.
- **Dired**: cursor on the folder, `R`, type the new directory. You can mark
  several items with `m` first and move them together.

### Rename or move a single file

- Current file: `SPC f R`, then the new path (new name or new directory).
- Treemacs / dired: same `R` as above.

### Check afterwards

- `SPC e` (or `]d` / `[d`) walks through diagnostics. Unresolved imports show
  up as errors.
- `SPC b S` to save all, then run the project's build / type check
  (`tsc --noEmit`, `cargo check`).

---

## Manual mode

Use this for Python moves, for files moved outside Emacs, or when the LSP
missed some imports.

### Replace an import path across the project

1. Move the file/folder (any way you like).
2. `SPC s p`: search the whole project with ripgrep for the **old** path or
   module, e.g. `old.mod`.
3. `C-c C-e`: export the results to an editable buffer (wgrep).
4. Edit with a normal replace: `:%s/old.mod/new.mod/g`.
5. `C-c C-c` to apply the edits to the files. `SPC b S` to save all.
6. Run the project's tests / type check to find leftovers.

Use `C-c C-k` instead of `C-c C-c` to abort without changing anything.

### Rename a symbol without the LSP

Same recipe: `SPC s p` the old name, `C-c C-e`, `:%s/old/new/g`, `C-c C-c`.
Check the matches first. Plain text replace also hits comments and strings,
and unrelated names that contain the old one (use word boundaries:
`:%s/\<old\>/new/g`).

### Rename inside one file only

- `:%s/old/new/g` in normal mode, or
- `C-d` to select the symbol and next matches, type the new name.

### Git as a safety net

Before a big manual replace, commit or stash. After it, review with
`SPC g g` (magit) and `d` on the file, or just `git diff`.

---

## Quick reference

| Task | Automatic | Manual |
|---|---|---|
| Rename variable | `SPC c r` | `SPC s p` → `C-c C-e` → `:%s` → `C-c C-c` |
| Rename folder | treemacs / dired `R` | move, then project search + replace |
| Move folder | treemacs / dired `R` with full path | move, then project search + replace |
| Rename/move file | `SPC f R` | move, then project search + replace |
| Save all edited buffers | `SPC b S` | `SPC b S` |

## Caveats

- I have not tested every step here on this machine. In particular, whether
  treemacs `R` on a *folder* triggers the LSP's import update should be tried
  on a throwaway folder before relying on it.
- If the LSP server crashed or has not started, the rename works but the
  imports are not touched. Restart it with `M-x lsp-restart-workspace`.
