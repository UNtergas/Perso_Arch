#!/usr/bin/env python3
"""Flash-style jump for tmux copy mode (like flash.nvim's `s`).

Runs in a borderless popup laid exactly over the pane (tmux.conf: copy-mode-vi `s`). It redraws the visible text of the pane
in gray, you type one or more characters, every match is highlighted and gets a label right after it (like flash.nvim),
and a label key moves the copy-mode cursor to that match. Enter jumps to the first match, Backspace edits the pattern,
Esc cancels. Copy of new_tmux/flash.py, lives in ~/.tmux/flash.py.
"""
import os
import re
import subprocess
import sys
import termios
import tty

LABELS = "asdfghjklqwertyuiopzxcvbnmASDFGHJKLQWERTYUIOPZXCVBNM"
GRAY = "\033[38;2;138;138;138m"        # backdrop: everything that is not a match
MATCH = "\033[1;38;2;26;47;85;48;2;184;208;240m"  # match: dark blue on light blue
LABEL = "\033[1;38;2;255;255;255;48;2;255;0;124m"  # label: white on pink, like flash.nvim
RESET = "\033[0m"
NUMBER = "\033[2;38;2;179;179;179m"       # the relative line numbers of copy mode (copy-mode-line-numbers relative)
GUTTER = 4                                # "%3d " : copy mode draws the numbers in the first four columns, the text starts after them


def tmux(*args):
    return subprocess.run(["tmux", *args], capture_output=True, text=True).stdout


def main():
    pane = tmux("display-message", "-p", "#{pane_id}").strip()
    info = tmux("display-message", "-p", "-t", pane,
                "#{pane_width} #{pane_height} #{?scroll_position,#{scroll_position},0} #{copy_cursor_x} #{copy_cursor_y}").split()
    width, height, scroll, cx, cy = (int(v) for v in info)
    avail = width - GUTTER  # columns left for the text
    # the lines copy mode shows: the visible grid when not scrolled, else shifted up by the scroll position
    text = tmux("capture-pane", "-p", "-t", pane, "-S", str(-scroll), "-E", str(height - 1 - scroll))
    lines = text.split("\n")[:height]
    lines += [""] * (height - len(lines))
    lines = [ln[:avail].ljust(avail) for ln in lines]

    def find(pattern):
        """matches as (row, col, length), nearest to the cursor first"""
        if not pattern:
            return []
        flags = 0 if any(c.isupper() for c in pattern) else re.IGNORECASE  # smartcase
        rx = re.compile(re.escape(pattern), flags)
        found = [(r, m.start(), len(pattern)) for r, ln in enumerate(lines) for m in rx.finditer(ln)]
        found.sort(key=lambda m: (abs(m[0] - cy) * 3 + abs(m[1] - cx), m[0], m[1]))
        return found

    def assign(found):
        """label for each match; a label that equals the character after some match is not used (it could continue the pattern)"""
        follow = {lines[r][c + n].lower() for r, c, n in found if c + n < avail}
        pool = [ch for ch in LABELS if ch.lower() not in follow]
        return {m: pool[i] for i, m in enumerate(found) if i < len(pool)}

    def draw(pattern, found, labels):
        marks = {}
        for (r, c, n) in found:
            for k in range(n):
                marks[(r, c + k)] = ("m", None)
            if (r, c, n) in labels and c + n < avail:
                marks[(r, c + n)] = ("l", labels[(r, c, n)])
        out = []
        for r, ln in enumerate(lines):
            row = [f"\033[{r + 1};1H{RESET}{NUMBER}{abs(r - cy):3d} {RESET}{GRAY}"]
            for c, ch in enumerate(ln):
                mk = marks.get((r, c))
                if mk is None:
                    row.append(ch)
                elif mk[0] == "m":
                    row.append(f"{RESET}{MATCH}{ch}{RESET}{GRAY}")
                else:
                    row.append(f"{RESET}{LABEL}{mk[1]}{RESET}{GRAY}")
            row.append(RESET)
            out.append("".join(row))
        # the typed pattern at the bottom right corner, like flash's prompt
        tag = f" {pattern} "
        out.append(f"\033[{height};{max(1, width - len(tag) + 1)}H{LABEL}{tag}{RESET}")
        sys.stdout.write("".join(out))
        sys.stdout.flush()

    def jump(m):
        r, c, _ = m
        tmux("send-keys", "-t", pane, "-X", "top-line")
        if r:
            tmux("send-keys", "-t", pane, "-N", str(r), "-X", "cursor-down")
        tmux("send-keys", "-t", pane, "-X", "start-of-line")
        if c:
            tmux("send-keys", "-t", pane, "-N", str(c), "-X", "cursor-right")

    fd = sys.stdin.fileno()
    old = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        sys.stdout.write("\033[?25l")  # hide the cursor
        pattern, found, labels = "", [], {}
        draw(pattern, found, labels)
        while True:
            data = os.read(fd, 32)
            if not data:
                return
            key = data.decode("utf-8", "ignore")
            if key in ("\x1b", "\x03") or key.startswith("\x1b"):  # Esc, Ctrl-C, or an escape sequence (arrows ...): cancel
                return
            if key in ("\r", "\n"):
                if found:
                    jump(found[0])
                return
            if key in ("\x7f", "\x08"):
                pattern = pattern[:-1]
            elif key.isprintable():
                by_label = {v: k for k, v in labels.items()}
                if pattern and key in by_label:
                    jump(by_label[key])
                    return
                pattern += key
            found = find(pattern)
            labels = assign(found) if pattern else {}
            if pattern and not found:  # nothing matches: drop the last character, like flash
                pattern = pattern[:-1]
                found = find(pattern)
                labels = assign(found) if pattern else {}
            draw(pattern, found, labels)
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old)
        sys.stdout.write("\033[?25h" + RESET)
        sys.stdout.flush()


if __name__ == "__main__":
    try:
        main()
    except Exception:  # a popup that dies shows nothing: keep the traceback in ~/.tmux/flash.log
        import traceback
        with open(os.path.expanduser("~/.tmux/flash.log"), "a") as log:
            traceback.print_exc(file=log)
