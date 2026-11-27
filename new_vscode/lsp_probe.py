#!/usr/bin/env python3
"""Headless probe of the JetBrains Kotlin server (the one the VS Code extension bundles) on a Gradle / Android project.

It speaks LSP over stdio like VS Code would, opens a few Kotlin files, waits for project import and diagnostics, and prints
what the server says: import progress, the diagnostics of each file (the ones that matter: "Unresolved reference"), and the
answers to definition / hover / documentSymbol requests. It never writes to the project: run it on a COPY.

usage: lsp_probe.py SERVER_DIR PROJECT_COPY SYSTEM_PATH FILE [FILE ...] [--wait SECONDS] [--def FILE:LINE:COL ...]
SERVER_DIR is <extension>/server (it has bin/intellij-server). Files are relative to PROJECT_COPY.
Not accepted here: the EULA. The server must already have recorded it (the VS Code extension asks for it the first time).
"""
import json, os, subprocess, sys, threading, time, queue, pathlib, urllib.parse

args = sys.argv[1:]
wait = 600
defs = []
files = []
pos = []
i = 0
while i < len(args):
    if args[i] == "--wait": wait = int(args[i + 1]); i += 2
    elif args[i] == "--def": defs.append(args[i + 1]); i += 2
    else: pos.append(args[i]); i += 1
server_dir, project, system_path = pos[:3]
files = pos[3:]
project = os.path.abspath(project)

def uri(p): return "file://" + urllib.parse.quote(os.path.abspath(p))

cmd = [os.path.join(server_dir, "bin", "intellij-server"), "--stdio", "--system-path", system_path, "--data-sharing", "none", "--region", "europe"]
env = dict(os.environ)
env["JAVA_HOME"] = env.get("JAVA_HOME_FOR_PROBE", "")  # the server ships its own runtime; do not let JAVA_HOME override it
env.pop("JAVA_HOME", None)
proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, cwd=project, env=env)

inbox = queue.Queue()
def reader():
    f = proc.stdout
    while True:
        headers = {}
        while True:
            line = f.readline()
            if not line: inbox.put(None); return
            line = line.decode().strip()
            if not line: break
            k, _, v = line.partition(":"); headers[k.lower()] = v.strip()
        n = int(headers.get("content-length", 0))
        body = f.read(n)
        try: inbox.put(json.loads(body))
        except Exception as e: print("bad json", e, body[:200])
threading.Thread(target=reader, daemon=True).start()
def errreader():
    for line in proc.stderr:
        sys.stderr.write("[server stderr] " + line.decode(errors="replace"))
threading.Thread(target=errreader, daemon=True).start()

def send(msg):
    data = json.dumps(msg).encode()
    proc.stdin.write(b"Content-Length: %d\r\n\r\n" % len(data) + data); proc.stdin.flush()
_id = 0
def request(method, params):
    global _id
    _id += 1; send({"jsonrpc": "2.0", "id": _id, "method": method, "params": params}); return _id
def notify(method, params): send({"jsonrpc": "2.0", "method": method, "params": params})

t0 = time.time()
def log(*a): print(f"[{time.time()-t0:7.1f}s]", *a, flush=True)

diag = {}          # uri -> list
progress = {}      # token -> title
responses = {}
def pump(timeout=1.0):
    try: m = inbox.get(timeout=timeout)
    except queue.Empty: return "idle"
    if m is None: return "closed"
    if "method" in m and "id" in m:   # server -> client request
        meth = m["method"]
        if meth == "workspace/configuration": send({"jsonrpc": "2.0", "id": m["id"], "result": [None] * len(m["params"].get("items", []))})
        elif meth == "workspace/workspaceFolders": send({"jsonrpc": "2.0", "id": m["id"], "result": [{"uri": uri(project), "name": os.path.basename(project)}]})
        else: send({"jsonrpc": "2.0", "id": m["id"], "result": None})
        if meth == "window/workDoneProgress/create": progress[m["params"]["token"]] = ""
    elif "method" in m:
        meth, p = m["method"], m.get("params", {})
        if meth == "textDocument/publishDiagnostics": diag[p["uri"]] = p["diagnostics"]
        elif meth == "$/progress":
            v = p["value"]; kind = v.get("kind")
            if kind == "begin": progress[p["token"]] = v.get("title", ""); log("progress begin:", v.get("title"), v.get("message", ""))
            elif kind == "report" and v.get("message"): log("   ...", progress.get(p["token"], ""), "|", v.get("message"), v.get("percentage", ""))
            elif kind == "end": log("progress end:  ", progress.get(p["token"], ""), v.get("message", ""))
        elif meth in ("window/showMessage", "window/logMessage"):
            if p.get("type", 4) <= 2: log("server message:", p.get("message", "")[:300])
    elif "id" in m:
        responses[m["id"]] = m
    return "ok"

caps = {"textDocument": {"publishDiagnostics": {"relatedInformation": True}, "definition": {"linkSupport": True}, "hover": {"contentFormat": ["plaintext", "markdown"]},
                         "documentSymbol": {"hierarchicalDocumentSymbolSupport": True}, "synchronization": {"didSave": True}},
        "workspace": {"workspaceFolders": True, "configuration": True, "didChangeWatchedFiles": {"dynamicRegistration": True}},
        "window": {"workDoneProgress": True}}
rid = request("initialize", {"processId": os.getpid(), "rootUri": uri(project), "rootPath": project, "capabilities": caps,
                             "workspaceFolders": [{"uri": uri(project), "name": os.path.basename(project)}], "clientInfo": {"name": "lsp_probe"}})
log("initialize sent")
while rid not in responses:
    st = pump(2)
    if st == "closed": log("SERVER CLOSED before initialize finished"); sys.exit(2)
    if time.time() - t0 > 300: log("initialize timeout"); proc.kill(); sys.exit(3)
r = responses[rid]
if "error" in r: log("initialize ERROR:", r["error"]); proc.kill(); sys.exit(4)
log("initialized; server:", r["result"].get("serverInfo"), "| capabilities:", sorted(r["result"]["capabilities"].keys())[:12], "...")
notify("initialized", {})
notify("workspace/didChangeConfiguration", {"settings": {}})

docs = {}
for f in files:
    p = os.path.join(project, f)
    text = pathlib.Path(p).read_text()
    docs[f] = uri(p)
    notify("textDocument/didOpen", {"textDocument": {"uri": uri(p), "languageId": "kotlin", "version": 1, "text": text}})
    log("opened", f)

def summary(f):
    ds = diag.get(docs[f])
    if ds is None: return None
    return ds

deadline = time.time() + wait
quiet_since = None
last_progress_event = time.time()
while time.time() < deadline:
    st = pump(2)
    if st == "closed": log("SERVER CLOSED"); break
    got = [f for f in files if summary(f) is not None]
    # done when every file has diagnostics and no progress ran for 45 s
    if len(got) == len(files):
        quiet_since = quiet_since or time.time()
        if time.time() - quiet_since > 45: break

print("\n==== diagnostics ====")
for f in files:
    ds = summary(f)
    if ds is None: print(f"{f}: NO diagnostics received"); continue
    sev = {1: "error", 2: "warning", 3: "info", 4: "hint"}
    print(f"{f}: {len(ds)} diagnostics ({sum(1 for d in ds if d.get('severity') == 1)} errors)")
    for d in ds[:12]:
        print(f"   L{d['range']['start']['line']+1}:{d['range']['start']['character']+1} {sev.get(d.get('severity'), '?')}: {d['message'][:140]}")

print("\n==== requests ====")
for f in files[:1]:
    rid = request("textDocument/documentSymbol", {"textDocument": {"uri": docs[f]}})
    t = time.time()
    while rid not in responses and time.time() - t < 60: pump(1)
    res = responses.get(rid, {}).get("result")
    print(f"documentSymbol {f}:", (len(res) if isinstance(res, list) else res))
for d in defs:
    f, line, col = d.rsplit(":", 2)
    if f not in docs:
        p = os.path.join(project, f); docs[f] = uri(p)
        notify("textDocument/didOpen", {"textDocument": {"uri": docs[f], "languageId": "kotlin", "version": 1, "text": pathlib.Path(p).read_text()}})
    for meth in ("textDocument/definition", "textDocument/hover"):
        rid = request(meth, {"textDocument": {"uri": docs[f]}, "position": {"line": int(line) - 1, "character": int(col) - 1}})
        t = time.time()
        while rid not in responses and time.time() - t < 90: pump(1)
        res = responses.get(rid, {})
        out = json.dumps(res.get("result", res.get("error")))[:300]
        print(f"{meth} {f}:{line}:{col} -> {out}")

try:
    request("shutdown", None); time.sleep(1); notify("exit", None)
except Exception: pass
time.sleep(2)
proc.kill()
log("done")
