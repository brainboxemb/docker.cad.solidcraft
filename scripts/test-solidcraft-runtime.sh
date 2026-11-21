#!/usr/bin/env sh
set -eu

cad-solidcraft-info

python - <<'PY'
import importlib.util
from pathlib import Path

import PIL
import yaml

if importlib.util.find_spec("cad_verification") is not None:
    raise SystemExit("unexpected cad_verification package in SolidCraft runtime")

for module in (
    "trimesh",
    "scipy",
    "matplotlib",
    "pythonscad",
    "pybosl2",
    "cadquery",
):
    if importlib.util.find_spec(module) is not None:
        raise SystemExit(f"unexpected module in SolidCraft runtime: {module}")

if Path("/opt/build123d").exists():
    raise SystemExit("unexpected build123d environment in SolidCraft runtime")

assert PIL
assert yaml
PY

solidcraft_version="$(solidcraft-cli --version)"
printf '%s\n' "$solidcraft_version"
printf '%s\n' "$solidcraft_version" | grep -F "$SOLIDCRAFT_VERSION" >/dev/null

registry="$(mktemp)"
solidcraft-cli commands >"$registry"
python - "$registry" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    commands = json.load(handle)

ids = {command.get("id") for command in commands}
required = {
    "sketch.slot.center_to_center",
    "sketch.slot.overall",
    "sketch.slot.center_point",
    "sketch.slot.arc_three_point",
    "sketch.slot.arc_center",
    "sketch.draw.dimensioned",
}
missing = sorted(required - ids)
if missing:
    raise SystemExit(f"missing required SolidCraft commands: {missing}")
PY
rm -f "$registry"

slot_smoke="$(mktemp)"
cat >"$slot_smoke" <<'JSON'
{"commands":[
{"command":"parameters.add","params":{"name":"slot_w","expression":"6 mm"}},
{"command":"sketch.create","params":{"plane":"XY","name":"SlotSmoke"}},
{"command":"sketch.slot.center_to_center","params":{"p0":[0,0],"p1":[30,0],"width":"slot_w"}},
{"command":"sketch.finish","params":{}}
]}
JSON
solidcraft-cli run "$slot_smoke" --quiet
rm -f "$slot_smoke"

dimensioned_slot_smoke="$(mktemp)"
cat >"$dimensioned_slot_smoke" <<'JSON'
{"commands":[
{"command":"parameters.add","params":{"name":"slot_len","expression":"30 mm"}},
{"command":"sketch.create","params":{"plane":"XY","name":"DimensionedSlotSmoke"}},
{"command":"sketch.draw.dimensioned","params":{
  "command":"sketch.slot.center_to_center",
  "params":{"p0":[0,0],"p1":[20,0],"width":6},
  "dimensions":{"length":"slot_len"}
}},
{"command":"sketch.finish","params":{}}
]}
JSON
solidcraft-cli run "$dimensioned_slot_smoke" --quiet
rm -f "$dimensioned_slot_smoke"

plain_point_smoke="$(mktemp)"
cat >"$plain_point_smoke" <<'JSON'
{"commands":[
{"command":"parameters.add","params":{"name":"slot_x","expression":"30 mm"}},
{"command":"sketch.create","params":{"plane":"XY","name":"PlainPointBoundary"}},
{"command":"sketch.slot.center_to_center","params":{
  "p0":[0,0],
  "p1":["slot_x",0],
  "width":6
}},
{"command":"sketch.finish","params":{}}
]}
JSON
if solidcraft-cli run "$plain_point_smoke" --quiet >/dev/null 2>&1; then
    echo "unexpected expression-valued direct Slot point accepted" >&2
    rm -f "$plain_point_smoke"
    exit 1
fi
rm -f "$plain_point_smoke"

if command -v cadcraft-cli >/dev/null 2>&1; then
    echo "unexpected cadcraft-cli in SolidCraft runtime" >&2
    exit 1
fi

echo "SolidCraft runtime smoke test: PASS"
