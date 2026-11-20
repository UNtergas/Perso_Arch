#!/usr/bin/env python3
# Lane-based expand / restore for the Alt-e c (COLUMN) and Alt-e C (ROW) keys. Copy of new_tmux/expand.py, lives in
# ~/.tmux/expand.py. Needs python3 and tmux 3.7+.
#
# usage: expand.py toggle col|row <pane_id>   expand the pane's lane, or restore it
#        expand.py clear <window_id>          forget every expansion of a window (used by Alt-e =)
#        expand.py gc <window_id>             forget expansions whose owner pane no longer exists (hooks)
#
# A lane is the strip of panes the expansion squeezes: for COLUMN the panes whose columns overlap the pane's columns,
# for ROW the panes whose rows overlap the pane's rows. An expansion remembers the size of every pane in its lane
# (as a fraction of the window, so a resized terminal still restores sensibly) and puts three pane options on the lane:
#   @exp_kind  col | row      the statusline shows COLUMN / ROW from this
#   @exp_owner pane id        the pane that was expanded
#   @exp_saved "id=frac,..."  only on the owner
# Pressing the key on the owner restores its lane. Pressing it on any other pane first restores every expansion whose
# lane shares a pane with the new lane, then expands. Expansions with disjoint lanes live side by side.
import subprocess
import sys

FRAC = 1000.0
BIG = "95%"


def tmux(*args):
    r = subprocess.run(["tmux", *args], capture_output=True, text=True)
    return r.stdout.strip() if r.returncode == 0 else ""


def panes(target):
    fmt = "#{pane_id}|#{pane_left}|#{pane_top}|#{pane_width}|#{pane_height}|#{@exp_kind}|#{@exp_owner}|#{@exp_saved}"
    out = []
    for line in tmux("list-panes", "-t", target, "-F", fmt).splitlines():
        i, l, t, w, h, kind, owner, saved = line.split("|", 7)
        out.append(dict(id=i, l=int(l), t=int(t), w=int(w), h=int(h), kind=kind, owner=owner, saved=saved))
    return out


def window_size(target):
    w, h = tmux("display-message", "-p", "-t", target, "#{window_width} #{window_height}").split()
    return int(w), int(h)


def lane(ps, p, kind):
    if kind == "col":
        a0, a1 = p["l"], p["l"] + p["w"]
        return [q["id"] for q in ps if q["l"] < a1 and q["l"] + q["w"] > a0]
    a0, a1 = p["t"], p["t"] + p["h"]
    return [q["id"] for q in ps if q["t"] < a1 and q["t"] + q["h"] > a0]


def clear_marks(ids):
    for i in ids:
        for o in ("@exp_kind", "@exp_owner", "@exp_saved"):
            tmux("set", "-p", "-u", "-t", i, o)


def restore(owner, ps, kind):
    o = next((q for q in ps if q["id"] == owner), None)
    members = [q["id"] for q in ps if q["owner"] == owner]
    if o and o["saved"]:
        ww, wh = window_size(owner)
        total = ww if kind == "row" else wh
        flag = "-x" if kind == "row" else "-y"
        items = [s.split("=") for s in o["saved"].split(",") if "=" in s]
        for _ in range(2):  # two passes: each resize steals from a neighbour, the second pass settles the rest
            for pid, frac in items:
                size = max(1, round(float(frac) / FRAC * total))
                tmux("resize-pane", "-t", pid, flag, str(size))
    clear_marks(members)


def gc(window):
    ps = panes(window)
    ids = {q["id"] for q in ps}
    for q in ps:
        if q["owner"] and q["owner"] not in ids:
            clear_marks([q["id"]])


def get(ps, pane):
    return next(q for q in ps if q["id"] == pane)


def toggle(kind, pane):
    gc(pane)
    ps = panes(pane)
    p = get(ps, pane)

    if p["owner"] == p["id"] and p["kind"] == kind:
        restore(p["id"], ps, kind)
        return

    new_lane = lane(ps, p, kind)
    conflicts = {q["owner"] for q in ps if q["owner"] and q["id"] in new_lane}
    for owner in conflicts:
        k = next((q["kind"] for q in ps if q["owner"] == owner), kind)
        restore(owner, ps, k)
    if conflicts:
        ps = panes(pane)
        p = get(ps, pane)
        new_lane = lane(ps, p, kind)

    ww, wh = window_size(pane)
    total = ww if kind == "row" else wh
    by_id = {q["id"]: q for q in ps}
    saved = ",".join(
        "%s=%.2f" % (i, (by_id[i]["w"] if kind == "row" else by_id[i]["h"]) / total * FRAC) for i in new_lane
    )
    for i in new_lane:
        tmux("set", "-p", "-t", i, "@exp_kind", kind)
        tmux("set", "-p", "-t", i, "@exp_owner", pane)
    tmux("set", "-p", "-t", pane, "@exp_saved", saved)
    tmux("resize-pane", "-t", pane, "-x" if kind == "row" else "-y", BIG)


def main():
    a = sys.argv[1:]
    if len(a) == 3 and a[0] == "toggle" and a[1] in ("col", "row"):
        toggle(a[1], a[2])
    elif len(a) == 2 and a[0] == "clear":
        clear_marks([q["id"] for q in panes(a[1]) if q["owner"] or q["kind"]])
    elif len(a) == 2 and a[0] == "gc":
        gc(a[1])
    else:
        sys.exit(__doc__)


main()
