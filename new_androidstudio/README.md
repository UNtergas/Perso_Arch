# Tender Nvim: Android Studio colour scheme

Editor colour scheme that matches the nvim (tender) setup: background `#202020` (neutral grey, same as nvim, tmux and the DMS theme), tender syntax colours, the same selection, search and diff colours.
It is a child of Darcula, so anything it does not set falls back to Darcula.

## Install

1. Copy `Tender Nvim.icls` to `~/.config/Google/AndroidStudio<version>/colors/` (create the `colors` folder if it is missing), and restart Android Studio.
   Or: Settings > Editor > Color Scheme > gear icon > Import Scheme > pick the file.
2. Settings > Editor > Color Scheme > choose **Tender Nvim**.

Only the editor, console, diff and log colours are covered. The IDE chrome (tool windows, tabs, menus) stays on the IDE theme: pick Darcula or the dark IDE theme to go with it.

## Palette

| Use | Colour |
|---|---|
| Background | `#202020` (same as nvim, tmux and the DMS theme) |
| Text / identifiers | `#eeeeee` / `#dadada` |
| Keywords, types, braces | `#73cef4` |
| Functions | `#b3deef` |
| Strings | `#d3b987` |
| Numbers, constants | `#ffc24b` |
| Operators, errors | `#f43753` |
| Annotations, labels | `#c9d05c` |
| Comments | `#666666` |
| Selection | `#3d5a6b` |
