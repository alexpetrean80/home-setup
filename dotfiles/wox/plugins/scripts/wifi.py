#!/usr/bin/env python3
# {
#   "Id": "com.alexp.wifi",
#   "Name": "Wi-Fi",
#   "Author": "Alex Petrean",
#   "Version": "1.0.0",
#   "MinWoxVersion": "2.0.0",
#   "Description": "List saved and nearby Wi-Fi networks, connect, toggle power, forget (macOS).",
#   "Icon": "emoji:📶",
#   "TriggerKeywords": ["wifi"],
#   "SupportedOS": ["darwin"],
#   "Features": [
#     { "Name": "debounce", "Params": { "intervalMs": "400" } }
#   ]
# }
#
# macOS Wi-Fi launcher plugin (Wox v2 script plugin, JSON-RPC over stdin/stdout).
#
# Everything: current status, saved (preferred) networks, nearby scan, connect
# (prompts for password when needed), toggle power, forget network.
#
# NOTE ON macOS PRIVACY: since macOS Sonoma, the live SSID and nearby-scan names
# are hidden ("<redacted>") from any process without Location Services permission.
# Saved networks always read clear. Connecting works regardless. To see live/nearby
# names, grant Location Services to Wox (the plugin surfaces a hint + shortcut).
#
# Two modes:
#   - JSON-RPC mode (default): Wox pipes a request on stdin.
#   - Worker mode (argv[1] == "__worker__"): a detached child that runs the
#     interactive/slow bits (password dialog, connect, admin forget) outside
#     Wox's 10s per-invocation timeout.

import json
import os
import re
import subprocess
import sys
import tempfile
import time

NETWORKSETUP = "/usr/sbin/networksetup"
SYSTEM_PROFILER = "/usr/sbin/system_profiler"
OSASCRIPT = "/usr/bin/osascript"
OPEN = "/usr/bin/open"

SCAN_CACHE = os.path.join(tempfile.gettempdir(), "wox_wifi_scan.json")
SCAN_TTL = 8  # seconds; system_profiler scan is slow, so cache briefly
REDACTED = "<redacted>"
LOCATION_SETTINGS = (
    "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices"
)


# ---------------------------------------------------------------------------
# shell helpers
# ---------------------------------------------------------------------------
def run(args, timeout=8):
    try:
        p = subprocess.run(
            args, capture_output=True, text=True, timeout=timeout, check=False
        )
        return p.returncode, (p.stdout or ""), (p.stderr or "")
    except Exception as e:  # noqa: BLE001 - never let a shell error crash the RPC
        return 1, "", str(e)


def wifi_device():
    """Resolve the Wi-Fi hardware device (usually en0, but detect it)."""
    _, out, _ = run([NETWORKSETUP, "-listallhardwareports"])
    dev = None
    is_wifi = False
    for line in out.splitlines():
        line = line.strip()
        if line.startswith("Hardware Port:"):
            is_wifi = "Wi-Fi" in line
        elif line.startswith("Device:") and is_wifi:
            dev = line.split(":", 1)[1].strip()
            break
    return dev or "en0"


def power_on(dev):
    _, out, _ = run([NETWORKSETUP, "-getairportpower", dev])
    return "on" in out.lower()


def preferred_networks(dev):
    """Saved networks. These read clear without Location Services permission."""
    _, out, _ = run([NETWORKSETUP, "-listpreferredwirelessnetworks", dev])
    nets = []
    for line in out.splitlines():
        s = line.strip()
        if not s or s.startswith("Preferred networks"):
            continue
        nets.append(s)
    return nets


# ---------------------------------------------------------------------------
# system_profiler parsing (current network + nearby scan)
# ---------------------------------------------------------------------------
def _indent(line):
    return len(line) - len(line.lstrip(" "))


def _parse_block(lines, start):
    """Parse networks under a section header at lines[start].

    Returns (list_of_networks, index_after_section). Each network is
    {"ssid": str, "props": {key: value}}.
    """
    base = _indent(lines[start])
    i = start + 1
    # child indent = indentation of the SSID header lines within the section
    child = None
    nets = []
    cur = None
    while i < len(lines):
        line = lines[i]
        if line.strip() == "":
            i += 1
            continue
        ind = _indent(line)
        if ind <= base:  # dedented out of the section
            break
        if child is None:
            child = ind
        stripped = line.strip()
        if ind == child and stripped.endswith(":") and ": " not in stripped:
            # new SSID header (no inline value)
            cur = {"ssid": stripped[:-1], "props": {}}
            nets.append(cur)
        elif cur is not None and ind > child and ": " in stripped:
            k, v = stripped.split(": ", 1)
            cur["props"][k.strip()] = v.strip()
        i += 1
    return nets, i


def scan(force=False):
    """Return {"connected": bool, "current": net|None, "nearby": [net,...]}.

    net = {"ssid","security","signal","channel","phy"}. Uses a short-lived disk
    cache because system_profiler is slow and runs on every keystroke.
    """
    if not force:
        try:
            st = os.stat(SCAN_CACHE)
            if time.time() - st.st_mtime < SCAN_TTL:
                with open(SCAN_CACHE) as f:
                    return json.load(f)
        except Exception:
            pass

    _, out, _ = run([SYSTEM_PROFILER, "SPAirPortDataType"], timeout=9)
    lines = out.split("\n")
    result = {"connected": False, "current": None, "nearby": []}

    for idx, line in enumerate(lines):
        s = line.strip()
        if s == "Status: Connected":
            result["connected"] = True
        elif s == "Current Network Information:":
            nets, _ = _parse_block(lines, idx)
            if nets:
                result["current"] = _net(nets[0])
        elif s == "Other Local Wi-Fi Networks:":
            nets, _ = _parse_block(lines, idx)
            result["nearby"] = [_net(n) for n in nets]

    try:
        with open(SCAN_CACHE, "w") as f:
            json.dump(result, f)
    except Exception:
        pass
    return result


def _net(raw):
    p = raw.get("props", {})
    return {
        "ssid": raw.get("ssid", ""),
        "security": p.get("Security", ""),
        "signal": p.get("Signal / Noise", ""),
        "channel": p.get("Channel", ""),
        "phy": p.get("PHY Mode", ""),
    }


def is_open(security):
    s = (security or "").lower()
    return s == "" or "none" in s or s == "open"


def signal_bars(signal):
    """Map 'Signal / Noise: -52 dBm / -93 dBm' to a bar glyph."""
    m = re.search(r"(-?\d+)\s*dBm", signal or "")
    if not m:
        return ""
    dbm = int(m.group(1))
    if dbm >= -55:
        return "▂▄▆█"
    if dbm >= -67:
        return "▂▄▆_"
    if dbm >= -75:
        return "▂▄__"
    return "▂___"


# ---------------------------------------------------------------------------
# JSON-RPC result construction
# ---------------------------------------------------------------------------
def item(title, subtitle="", score=50, icon=None, actions=None):
    it = {"title": title, "subtitle": subtitle, "score": score}
    if icon:
        it["icon"] = icon
    it["actions"] = actions or []
    return it


def connect_action(ssid, name="Connect"):
    return {"id": "connect", "name": name, "data": ssid}


def build_items(search):
    dev = wifi_device()
    items = []

    if not power_on(dev):
        items.append(
            item(
                "Wi-Fi is Off",
                "Turn Wi-Fi on",
                score=100,
                icon="emoji:📴",
                actions=[{"id": "toggle-power", "name": "Turn On", "data": "on"}],
            )
        )
        return _filter(items, search)

    info = scan()
    seen = set()

    # --- current connection -------------------------------------------------
    if info.get("connected"):
        cur = info.get("current") or {}
        ssid = cur.get("ssid") or ""
        if ssid and ssid != REDACTED:
            seen.add(ssid.lower())
            sub = " · ".join(
                x for x in [cur.get("security", ""), signal_bars(cur.get("signal"))] if x
            )
            items.append(
                item(
                    "✓ " + ssid,
                    "Connected" + (" · " + sub if sub else ""),
                    score=100,
                    icon="emoji:🟢",
                    actions=[
                        {"id": "copy-to-clipboard", "name": "Copy SSID", "text": ssid},
                        {"id": "toggle-power", "name": "Turn Wi-Fi Off", "data": "off"},
                    ],
                )
            )
        else:
            items.append(
                item(
                    "✓ Connected (name hidden)",
                    "Grant Location Services to Wox to show the network name",
                    score=100,
                    icon="emoji:🟢",
                    actions=[
                        {
                            "id": "open-settings",
                            "name": "Open Location Services",
                            "data": LOCATION_SETTINGS,
                        }
                    ],
                )
            )

    # --- nearby scan --------------------------------------------------------
    nearby = info.get("nearby") or []
    redacted_nearby = sum(1 for n in nearby if n.get("ssid") == REDACTED)
    saved = set(n.lower() for n in preferred_networks(dev))

    for n in nearby:
        ssid = n.get("ssid") or ""
        if not ssid or ssid == REDACTED or ssid.lower() in seen:
            continue
        seen.add(ssid.lower())
        lock = "🔓" if is_open(n.get("security")) else "🔒"
        tags = [t for t in [n.get("security", ""), signal_bars(n.get("signal"))] if t]
        if ssid.lower() in saved:
            tags.insert(0, "saved")
        items.append(
            item(
                ssid,
                " · ".join(tags) if tags else "In range",
                score=80,
                icon="emoji:" + lock,
                actions=[
                    connect_action(ssid),
                    {"id": "copy-to-clipboard", "name": "Copy SSID", "text": ssid},
                    {"id": "forget", "name": "Forget Network", "data": ssid}
                    if ssid.lower() in saved
                    else {"id": "copy-to-clipboard", "name": "Copy SSID", "text": ssid},
                ],
            )
        )

    # --- saved networks not currently in range ------------------------------
    for ssid in preferred_networks(dev):
        if ssid.lower() in seen:
            continue
        seen.add(ssid.lower())
        items.append(
            item(
                ssid,
                "Saved · not in range",
                score=40,
                icon="emoji:💾",
                actions=[
                    connect_action(ssid),
                    {"id": "forget", "name": "Forget Network", "data": ssid},
                    {"id": "copy-to-clipboard", "name": "Copy SSID", "text": ssid},
                ],
            )
        )

    # --- location-permission hint ------------------------------------------
    if redacted_nearby:
        items.append(
            item(
                "%d nearby network(s) have hidden names" % redacted_nearby,
                "Grant Location Services to Wox to reveal nearby SSIDs",
                score=10,
                icon="emoji:📍",
                actions=[
                    {
                        "id": "open-settings",
                        "name": "Open Location Services",
                        "data": LOCATION_SETTINGS,
                    }
                ],
            )
        )

    # --- power toggle always available -------------------------------------
    items.append(
        item(
            "Turn Wi-Fi Off",
            "Disable the Wi-Fi radio",
            score=5,
            icon="emoji:📴",
            actions=[{"id": "toggle-power", "name": "Turn Off", "data": "off"}],
        )
    )

    return _filter(items, search)


def _filter(items, search):
    s = (search or "").strip().lower()
    if not s:
        return items
    return [it for it in items if s in it["title"].lower()]


# ---------------------------------------------------------------------------
# RPC dispatch
# ---------------------------------------------------------------------------
def handle_query(params, rid):
    search = params.get("search", "")
    try:
        items = build_items(search)
    except Exception as e:  # noqa: BLE001
        items = [item("Wi-Fi error", str(e), score=100, icon="emoji:⚠️", actions=[])]
    return {"jsonrpc": "2.0", "result": {"items": items}, "id": rid}


def handle_action(params, rid):
    aid = params.get("id", "")
    data = params.get("data", "")
    dev = wifi_device()

    if aid == "toggle-power":
        run([NETWORKSETUP, "-setairportpower", dev, data])
    elif aid == "open-settings":
        run([OPEN, data])
    elif aid in ("connect", "forget"):
        # detach: interactive/slow work must outlive the 10s RPC timeout
        try:
            subprocess.Popen(
                [sys.executable, os.path.abspath(__file__), "__worker__", aid, data, dev],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                stdin=subprocess.DEVNULL,
                start_new_session=True,
            )
        except Exception:
            pass

    # built-in actions (copy-to-clipboard, etc.) are handled by Wox itself
    return {"jsonrpc": "2.0", "result": {}, "id": rid}


def run_rpc():
    try:
        req = json.loads(sys.stdin.read() or "{}")
    except Exception:
        req = {}
    method = req.get("method")
    params = req.get("params", {})
    rid = req.get("id")
    if method == "query":
        resp = handle_query(params, rid)
    elif method == "action":
        resp = handle_action(params, rid)
    else:
        resp = {
            "jsonrpc": "2.0",
            "error": {"code": -32601, "message": "Method not found"},
            "id": rid,
        }
    sys.stdout.write(json.dumps(resp))


# ---------------------------------------------------------------------------
# worker mode (detached child)
# ---------------------------------------------------------------------------
def notify(msg, title="Wi-Fi"):
    script = "on run argv\ndisplay notification (item 1 of argv) with title (item 2 of argv)\nend run"
    run([OSASCRIPT, "-e", script, msg, title], timeout=10)


def prompt_password(ssid):
    """Native hidden-answer dialog. Returns password, or None if cancelled."""
    script = (
        "on run argv\n"
        'set r to display dialog "Wi-Fi password for " & (item 1 of argv) '
        'default answer "" with hidden answer with title "Connect to Wi-Fi" '
        "with icon note\n"
        "return text returned of r\n"
        "end run"
    )
    rc, out, _ = run([OSASCRIPT, "-e", script, ssid], timeout=120)
    if rc != 0:  # user cancelled
        return None
    return out.strip()


def _join_failed(out, err):
    text = (out + " " + err).lower()
    return any(k in text for k in ("failed to join", "could not", "error", "not find"))


def worker_connect(ssid, dev):
    # saved / open networks join without a password (keychain-backed)
    rc, out, err = run([NETWORKSETUP, "-setairportnetwork", dev, ssid], timeout=25)
    if rc == 0 and not _join_failed(out, err):
        notify('Connected to "%s"' % ssid)
        return
    pw = prompt_password(ssid)
    if pw is None:
        return
    rc, out, err = run([NETWORKSETUP, "-setairportnetwork", dev, ssid, pw], timeout=25)
    if rc == 0 and not _join_failed(out, err):
        notify('Connected to "%s"' % ssid)
    else:
        notify('Failed to connect to "%s"' % ssid)


def worker_forget(ssid, dev):
    # removing a preferred network edits system config -> needs admin rights
    inner = 'do shell script "%s -removepreferredwirelessnetwork %s " & quoted form of (item 1 of argv) with administrator privileges' % (
        NETWORKSETUP,
        dev,
    )
    script = "on run argv\n%s\nend run" % inner
    rc, _, err = run([OSASCRIPT, "-e", script, ssid], timeout=120)
    if rc == 0:
        notify('Forgot "%s"' % ssid)
    elif "cancel" not in err.lower():
        notify('Could not forget "%s"' % ssid)


def run_worker(argv):
    op = argv[0] if argv else ""
    data = argv[1] if len(argv) > 1 else ""
    dev = argv[2] if len(argv) > 2 else wifi_device()
    if op == "connect":
        worker_connect(data, dev)
    elif op == "forget":
        worker_forget(data, dev)


# ---------------------------------------------------------------------------
if __name__ == "__main__":
    if len(sys.argv) >= 2 and sys.argv[1] == "__worker__":
        run_worker(sys.argv[2:])
    else:
        run_rpc()
