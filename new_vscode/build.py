#!/usr/bin/env python3
"""Generates the nvim-mirroring parts of the VS Code config (VSCodeVim bindings in settings.json, keybindings.json).
Usage: build.py [USER_DIR]   (default ~/.config/Code/User). Idempotent: it rewrites only the blocks it owns."""
import json, re, sys, os

USER = sys.argv[1] if len(sys.argv) > 1 else os.path.expanduser("~/.config/Code/User")

def J(o): return json.dumps(o, ensure_ascii=False)
def k(*keys): return list(keys)
def b(before, cmd=None, after=None, desc=None):
    d = {"before": before}
    if after: d["after"] = after
    if cmd is not None: d["commands"] = cmd if isinstance(cmd, list) else [cmd]
    return d

L = "<leader>"
normal = [
    # --- existing flash-like jump (easymotion n-char search with labels and a dimmed backdrop)
    b(["s"], after=[L, L, "/"]),
    # --- files and buffers
    b([L, L], "workbench.action.quickOpen"),
    b([L, "."], "workbench.action.quickOpen"),
    b([L, ","], "workbench.action.showAllEditors"),
    b([L, "b", "b"], "workbench.action.showAllEditors"),
    b([L, "b", "S"], "workbench.action.files.saveAll"),
    b([L, ":"], "workbench.action.showCommands"),
    b([L, "e"], "workbench.view.explorer"),
    *[b([L, str(n)], f"workbench.action.openEditorAtIndex{n}") for n in range(1, 10)],
    # --- jumping
    b(["g", "d"], "editor.action.revealDefinition"),
    b(["g", "D"], "editor.action.revealDeclaration"),
    b(["g", "i"], "editor.action.goToImplementation"),
    b(["g", "r"], "editor.action.goToReferences"),
    b(["g", "R"], "references-view.findReferences"),
    b(["g", "p"], "editor.action.peekDefinition"),
    b(["K"], "editor.action.showHover"),
    b(["]", "d"], "editor.action.marker.next"),
    b(["[", "d"], "editor.action.marker.prev"),
    b(["]", "g"], "workbench.action.editor.nextChange"),
    b(["[", "g"], "workbench.action.editor.previousChange"),
    b(["]", "x"], "merge-conflict.next"),
    b(["[", "x"], "merge-conflict.previous"),
    # --- search and replace
    b([L, "s", "s"], "actions.find"),
    b([L, "s", "p"], "workbench.action.findInFiles"),
    b([L, "f", "g"], "workbench.action.findInFiles"),
    b([L, "s", "w"], "workbench.action.findInFiles", after=["v", "i", "w"]),
    b([L, "s", "r"], "workbench.action.replaceInFiles"),
    b([L, "s", "o"], "outline.focus"),
    b([L, "s", "u"], "timeline.focus"),
    # --- code intelligence
    b([L, "c", "r"], "editor.action.rename"),
    b([L, "r", "n"], "editor.action.rename"),
    b([L, "c", "a"], "editor.action.quickFix"),
    b([L, "c", "f"], "editor.action.formatDocument"),
    b([L, "c", "x"], "workbench.actions.view.problems"),
    b([L, "c", "X"], "workbench.actions.view.problems"),
    b([L, "d"], "editor.action.showHover"),
    # --- git
    b([L, "g", "m"], "git.openMergeEditor"),
    b([L, "g", "r"], "git.revertSelectedRanges"),
    b([L, "g", "g"], {"command": "workbench.action.terminal.newWithProfile", "args": {"profileName": "lazygit", "location": "editor"}}),
    b([L, "g", "f"], {"command": "workbench.action.terminal.newWithProfile", "args": {"profileName": "lazygit-file", "location": "editor"}}),
    b([L, "g", "h"], "timeline.focus"),
    b([L, "g", "H"], "git-graph.view"),
    b([L, "g", "l"], "git-graph.view"),
    b([L, "g", "o"], "merge-conflict.accept.current"),
    b([L, "g", "t"], "merge-conflict.accept.incoming"),
    b([L, "g", "b"], "merge-conflict.accept.both"),
    b([L, "t", "b"], "git.blame.toggleEditorDecoration"),
    # --- terminal, help, misc
    b([L, "o", "t"], "workbench.action.terminal.toggleTerminal"),
    b([L, "h", "b"], "workbench.action.openGlobalKeybindings"),
    b([L, "h", "k"], "workbench.action.openGlobalKeybindings"),
    b([L, "h", "r"], "workbench.action.reloadWindow"),
    b([L, "q"], "workbench.action.closePanel"),
    # --- harpoon (extension tobias-z.vscode-harpoon): a = add, h / d = edit the list, 1..9 jump, s N set slot N
    b([L, "h", "a"], "vscode-harpoon.addEditor"),
    b([L, "h", "h"], "vscode-harpoon.editEditors"),
    b([L, "h", "d"], "vscode-harpoon.editEditors"),
    *[b([L, "h", str(n)], f"vscode-harpoon.gotoEditor{n}") for n in range(1, 10)],
    *[b([L, "h", "s", str(n)], f"vscode-harpoon.addEditor{n}") for n in range(1, 10)],
    # --- surround shortcuts of nvim-surround
    b(["y", "s", "w"], after=["y", "s", "i", "w"]),
    b(["y", "s", "W"], after=["y", "s", "i", "W"]),
    b(["y", "s", "p"], after=["y", "s", "i", "p"]),
    *[b(["y", "s", c], after=["y", "s", "i", c]) for c in "({[<"],
    # --- ; is :
    b([";"], after=[":"]),
]
visual = [
    b(["s"], after=[L, L, "/"]),
    b(["g", "s"], after=["S"]),          # gs = surround the selection
    b([L, "c", "f"], "editor.action.formatSelection"),
    b([L, "c", "a"], "editor.action.quickFix"),
    b([L, "s", "r"], "workbench.action.replaceInFiles"),
    b([";"], after=[":"]),
]

def render(name, items, comment):
    out = [f'  // {comment}', f'  "{name}": [']
    for i, it in enumerate(items):
        out.append("    " + J(it) + ("," if i < len(items) - 1 else ""))
    out.append("  ],")
    return "\n".join(out)

block = "\n".join([
    "  // ==== nvim keys (generated by new_vscode/build.py from the nvim setup: edit the script, not this block) ====",
    render("vim.normalModeKeyBindingsNonRecursive", normal, "normal mode: leader (SPC) maps, g / ] / [ maps, ; = :"),
    render("vim.visualModeKeyBindingsNonRecursive", visual, "visual mode"),
    '  "vim.hlsearch": true,', '  "vim.incsearch": true,', '  "vim.ignorecase": true,', '  "vim.smartcase": true,',
    '  "vim.highlightedyank.enable": true,',
    '  "editor.cursorSurroundingLines": 5,',
    '  "terminal.integrated.profiles.linux": {',
    '    "lazygit": { "path": "lazygit", "icon": "git-branch" },',
    '    "lazygit-file": { "path": "lazygit", "args": ["-f", "${file}"], "icon": "git-branch" }',
    '  },',
    "  // ==== end of the nvim keys block ====",
])

sp = os.path.join(USER, "settings.json")
s = open(sp).read()
if "==== nvim keys" in s:
    s = re.sub(r"  // ==== nvim keys.*?// ==== end of the nvim keys block ====", lambda m: block, s, flags=re.S)
else:
    # replace the old hand-written vim blocks (s / ]d / [d) with the generated block
    a = s.index("  // s / S -> n-char incremental search")
    z = s.index('  "window.density.editorTabHeight"')
    s = s[:a] + block + "\n" + s[z:]
open(sp, "w").write(s)

# ---------------- keybindings.json
kp = os.path.join(USER, "keybindings.json")
raw = re.sub(r"^\s*//.*$", "", open(kp).read(), flags=re.M)
raw = re.sub(r",(\s*[}\]])", r"\1", raw)   # VS Code accepts trailing commas, json does not
kb = json.loads(raw)
drop = {("ctrl+k down", "workbench.action.splitEditorDown"), ("ctrl+k up", "workbench.action.splitEditorUp"),
        ("ctrl+k up", "views.moveViewUp"), ("ctrl+k left", "workbench.action.splitEditorLeft"),
        ("ctrl+k right", "workbench.action.splitEditorRight"), ("ctrl+k h", "workbench.action.moveEditorToLeftGroup"),
        ("ctrl+k l", "workbench.action.moveEditorToRightGroup"), ("ctrl+k k", "workbench.action.moveEditorToAboveGroup"),
        ("ctrl+k j", "workbench.action.moveEditorToBelowGroup")}
kb = [e for e in kb if (e["key"], e["command"]) not in drop]

def kbe(key, command, when=None, args=None):
    e = {"key": key, "command": command}
    if when: e["when"] = when
    if args is not None: e["args"] = args
    return e

ED = "editorTextFocus && !editorReadonly"
VIMN = "editorTextFocus && vim.active && (vim.mode == 'Normal' || vim.mode == 'Visual' || vim.mode == 'VisualLine' || vim.mode == 'VisualBlock')"
new = [
    # Ctrl-w windows
    kbe("ctrl+w \\", "workbench.action.splitEditorRight"), kbe("ctrl+w -", "workbench.action.splitEditorDown"),
    kbe("ctrl+w v", "workbench.action.splitEditorRight"), kbe("ctrl+w s", "workbench.action.splitEditorDown"),
    kbe("ctrl+w x", "workbench.action.closeEditorsAndGroup"), kbe("ctrl+w ctrl+x", "workbench.action.closeEditorsAndGroup"),
    kbe("ctrl+w z", "workbench.action.toggleMaximizeEditorGroup"), kbe("ctrl+w =", "workbench.action.evenEditorWidths"),
    kbe("ctrl+w h", "workbench.action.focusLeftGroup"), kbe("ctrl+w j", "workbench.action.focusBelowGroup"),
    kbe("ctrl+w k", "workbench.action.focusAboveGroup"), kbe("ctrl+w l", "workbench.action.focusRightGroup"),
    kbe("ctrl+w d", "workbench.actions.view.problems"), kbe("ctrl+w ctrl+d", "workbench.actions.view.problems"),
    kbe("ctrl+w left", "workbench.action.moveEditorToLeftGroup"), kbe("ctrl+w down", "workbench.action.moveEditorToBelowGroup"),
    kbe("ctrl+w up", "workbench.action.moveEditorToAboveGroup"), kbe("ctrl+w right", "workbench.action.moveEditorToRightGroup"),
    # Ctrl-k resize
    kbe("ctrl+k h", "workbench.action.decreaseViewWidth"), kbe("ctrl+k l", "workbench.action.increaseViewWidth"),
    kbe("ctrl+k j", "workbench.action.increaseViewHeight"), kbe("ctrl+k k", "workbench.action.decreaseViewHeight"),
    # cursors and symbols
    kbe("ctrl+shift+down", "editor.action.insertCursorBelow", ED), kbe("ctrl+shift+up", "editor.action.insertCursorAbove", ED),
    {"key": "ctrl+shift+t", "command": "-workbench.action.reopenClosedEditor"},
    kbe("ctrl+shift+t", "workbench.action.gotoSymbol", "editorTextFocus"),
    # half page scroll, code action, popups, terminal
    kbe("alt+j", "vim.remap", VIMN, {"after": ["<C-d>"]}), kbe("alt+k", "vim.remap", VIMN, {"after": ["<C-u>"]}),
    kbe("alt+.", "editor.action.quickFix", "editorTextFocus"),
    kbe("alt+q", "workbench.action.closePanel"),
    {"key": "ctrl+\\", "command": "-workbench.action.splitEditor"},
    kbe("ctrl+\\", "workbench.action.terminal.toggleTerminal"),
]
# idempotent: drop earlier copies of the entries generated here (same key and command), then append
gen = {(e["key"], e["command"]) for e in new}
kb = [e for e in kb if (e["key"], e["command"]) not in gen] + new
body = json.dumps(kb, indent=2, ensure_ascii=False)
open(kp, "w").write("// Place your key bindings in this file to override the defaults\n// (the nvim entries at the end of the list are generated by new_vscode/build.py)\n" + body + "\n")
print("settings.json and keybindings.json updated in", USER)
