#!/usr/bin/env sh
set -eu

cad-mitcad-info

MITCAD_OUTPUT="$(mitcad-cli --version)"
case "$MITCAD_OUTPUT" in
    *"${MITCAD_VERSION}"*) ;;
    *) echo "mitcad-cli: expected version ${MITCAD_VERSION}, got: $MITCAD_OUTPUT" >&2; exit 1 ;;
esac

if command -v solidcraft-cli >/dev/null 2>&1; then
    echo "unexpected solidcraft-cli in Mitcad runtime" >&2
    exit 1
fi
if command -v cadcraft-cli >/dev/null 2>&1; then
    echo "unexpected cadcraft-cli in Mitcad runtime" >&2
    exit 1
fi

python - <<'PY'
import importlib.util
import json
import subprocess
import tempfile

for name in (
    "cad_verification", "cadquery", "build123d", "pythonscad", "pybosl2",
    "trimesh", "scipy", "matplotlib",
):
    if importlib.util.find_spec(name) is not None:
        raise SystemExit(f"unexpected {name} package in Mitcad runtime")

with tempfile.TemporaryDirectory(prefix="mitcad-runtime-smoke-") as workspace:
    p = subprocess.Popen(
        ["mitcad-cli", "mcp", "--workspace", workspace],
        stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        text=True, encoding="utf-8",
    )
    assert p.stdin is not None and p.stdout is not None
    next_id = 0
    def rpc(method, params=None):
        global next_id
        next_id += 1
        msg = {"jsonrpc": "2.0", "id": next_id, "method": method}
        if params is not None:
            msg["params"] = params
        p.stdin.write(json.dumps(msg, separators=(",", ":")) + "\n")
        p.stdin.flush()
        line = p.stdout.readline()
        if not line:
            err = p.stderr.read() if p.stderr is not None else ""
            raise SystemExit("Mitcad MCP closed before reply: " + err.strip())
        reply = json.loads(line)
        if reply.get("id") != next_id:
            raise SystemExit("Mitcad MCP response id mismatch")
        if "error" in reply:
            raise SystemExit(f"Mitcad MCP {method} failed: {reply['error']}")
        return reply["result"]
    try:
        initialized = rpc("initialize", {
            "protocolVersion": "2025-11-25",
            "capabilities": {},
            "clientInfo": {"name": "cad-mitcad-runtime-smoke", "version": "1"},
        })
        if initialized.get("protocolVersion") != "2025-11-25":
            raise SystemExit("unexpected Mitcad MCP protocol")
        p.stdin.write(json.dumps(
            {"jsonrpc": "2.0", "method": "notifications/initialized"},
            separators=(",", ":"),
        ) + "\n")
        p.stdin.flush()
        resource = rpc("resources/read", {"uri": "mitcad://reference/commands"})
        contents = resource.get("contents")
        if not isinstance(contents, list) or not contents:
            raise SystemExit("Mitcad command reference is empty")
        text = contents[0].get("text") if isinstance(contents[0], dict) else None
        if not isinstance(text, str) or "add_feature" not in text or "add_parameter" not in text:
            raise SystemExit("Mitcad command reference lacks required commands")
    finally:
        p.stdin.close()
        try:
            p.wait(timeout=10)
        except subprocess.TimeoutExpired:
            p.kill(); p.wait(timeout=10)

print("Mitcad MCP smoke: PASS")
PY

echo "Mitcad runtime smoke test: PASS"
