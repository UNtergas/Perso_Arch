# Refactor guide (Neovim)

How to rename / move things and keep imports working. Two modes:

- **Automatic**: the LSP rewrites imports for you.
- **Manual**: the LSP can't do it, so you search and replace.

Same ideas as [../emacs_config/REFACTOR_GUIDE.md](../emacs_config/REFACTOR_GUIDE.md).

## What the LSP can do

| Language | Rename symbol (`SPC c r`) | Imports updated on file/folder move |
|---|---|---|
| TS/JS (`ts_ls`) | yes | yes |
| Rust (`rust_analyzer`) | yes | yes |
| Python (`pyright`) | yes | **no** (pyright lacks it) |

TS/JS and Rust: automatic. Python moves: manual.

---

## Automatic mode

### Prerequisites

1. The project has a running LSP server for the file you are in (`:LspInfo`
   or `:checkhealth vim.lsp`).
2. Rename or move from **inside Neovim**, with one of the ways below. A `mv`
   in a shell is invisible to the LSP, so imports are not updated.
3. Afterwards save the edited buffers: `SPC b S`.

### Rename a variable / function / class

1. Cursor on the symbol.
2. `SPC c r`, type the new name, `Enter`.
3. Every reference in the project is renamed. `SPC b S` to save.

Only in the current file: `C-d` (multi-cursor on the word), type the new name,
`Esc`.

### Rename or move the current file

`SPC f R`, then the new path (new name, or a new folder to move it).
`Snacks.rename` asks the LSP to update the imports.

### Rename a folder or file in the sidebar (nvim-tree)

1. `C-b` to open, put the cursor on the item.
2. Rename: `r`, type the new name.
3. Move: `x` (cut) on the item, go to the target folder, `p` (paste).
   Moves and renames both trigger the import update (nvim-tree sends a rename
   event to Snacks).

### Rename or move in Oil (edit the file list as text)

1. `SPC e` opens the folder as a buffer.
2. Edit a name, or cut/paste a line (`dd` then `p` in another folder's buffer)
   to move it.
3. `:w` applies the changes. Oil moves also call Snacks, so imports update.

### Check afterwards

- `]d` / `[d` jump through diagnostics, `SPC c x` lists them. Unresolved
  imports show up as errors.
- `SPC b S`, then run the project's type check (`tsc --noEmit`,
  `cargo check`).

---

## Manual mode

For Python moves, files moved outside Neovim, or imports the LSP missed.

### Replace an import path across the project

1. Move the file or folder.
2. `SPC s p` (live grep), type the old path or module, e.g. `old.mod`.
3. `C-q` sends the matches to the quickfix list.
4. Replace in every file and save:

   ```vim
   :cfdo %s/old\.mod/new.mod/gc | update
   ```

   `/gc` asks before each change; use `/g` to replace all at once.
5. Run the tests / type check for leftovers.

### Rename a symbol without the LSP

Same recipe: `SPC s p` the old name, `C-q`, then
`:cfdo %s/\<old\>/new/gc | update`. `\<` and `\>` match whole words only, so
`old` does not touch `older`.

### Rename inside one file

`:%s/old/new/g`, or `C-d` to add cursors on each match.

### Git as a safety net

Commit or stash before a big manual replace. Review with `git diff` in the terminal
or `SPC g m`. Undo a bad replace with `u`, or `SPC s u` for the undo tree.

---

## Quick reference

| Task | Automatic | Manual |
|---|---|---|
| Rename variable | `SPC c r` | `SPC s p` → `C-q` → `:cfdo %s/…/…/gc \| update` |
| Rename folder | nvim-tree `r`, or Oil `:w` | move, then project search + replace |
| Move folder | nvim-tree `x` + `p`, or Oil | move, then project search + replace |
| Rename/move file | `SPC f R` | move, then project search + replace |
| Save all | `SPC b S` | `SPC b S` |

## Caveats

- I have not tested the import updates on a real project. Try it on a
  throwaway folder first, especially folder moves.
- If the LSP isn't attached, the rename works but imports are not touched.
  Restart it with `:LspRestart`.
- Telescope's `C-q` (send to quickfix) is a Telescope default. If it does
  nothing, use `<M-q>` for the selected items only.
