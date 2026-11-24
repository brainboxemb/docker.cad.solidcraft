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

component_create_script="$(mktemp --suffix=.json)"
component_create_results="$(mktemp --suffix=.json)"
component_copy_script="$(mktemp --suffix=.json)"
component_copy_results="$(mktemp --suffix=.json)"
component_move_script="$(mktemp --suffix=.json)"
component_stage1="$(mktemp --suffix=.sc)"
component_stage2="$(mktemp --suffix=.sc)"
component_design="$(mktemp --suffix=.sc)"
component_cylinder_png="$(mktemp --suffix=.png)"

cat >"$component_create_script" <<'JSON'
{"commands":[
  {"command":"component.create","params":{"name":"BossedPanel","grounded":true}},
  {"command":"solid.box","params":{
    "length":20,"width":10,"height":4,"operation":"new",
    "center":[0,0,0],"body_name":"BossedPanel"
  }},
  {"command":"solid.cylinder","params":{
    "height":4,"diameter":4,"base":[6,0,1.5],"axis":"Z",
    "operation":"join","targets":["BossedPanel"]
  }},
  {"command":"component.activate","params":{"component":"root"}}
]}
JSON

solidcraft-cli run "$component_create_script" \
    --save "$component_stage1" \
    --results \
    --json-out "$component_create_results" \
    --quiet

first_occurrence="$(
python - "$component_create_results" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    result = json.load(handle)
print(result["results"][0]["occurrence"])
PY
)"

cat >"$component_copy_script" <<'JSON'
{"commands":[
  {"command":"occurrence.copy","params":{"component":"BossedPanel"}}
]}
JSON

solidcraft-cli run "$component_copy_script" \
    --in "$component_stage1" \
    --save "$component_stage2" \
    --results \
    --json-out "$component_copy_results" \
    --quiet

second_occurrence="$(
python - "$component_copy_results" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    result = json.load(handle)
print(result["results"][0]["occurrence"])
PY
)"

cat >"$component_move_script" <<JSON
{"commands":[
  {"command":"occurrence.move","params":{
    "occurrence":${first_occurrence},
    "translate":[-30,0,0],
    "axis":[1,0,0],
    "angle":"90 deg",
    "move_grounded":true
  }},
  {"command":"occurrence.move","params":{
    "occurrence":${second_occurrence},
    "translate":[30,0,0],
    "axis":[1,0,0],
    "angle":"90 deg"
  }}
]}
JSON

solidcraft-cli run "$component_move_script" \
    --in "$component_stage2" \
    --save "$component_design" \
    --quiet

solidcraft-cli snapshot "$component_design" \
    --out "$component_cylinder_png" \
    --width 720 \
    --height 540 \
    --camera '{"target":[0,-1.75,0],"yaw":-0.7853981633974483,"pitch":0.5585053606381855,"roll":0,"distance":132,"fov":0}' \
    --no-grid \
    --no-axes \
    --transparent

python - "$component_cylinder_png" <<'PY'
from collections import deque
from pathlib import Path
import sys

from PIL import Image


path = Path(sys.argv[1])
with Image.open(path) as source:
    image = source.convert("RGBA")
    width, height = image.size
    alpha = image.getchannel("A")
    occupied = {
        (x, y)
        for y in range(height)
        for x in range(width)
        if alpha.getpixel((x, y)) >= 32
    }

components = []
while occupied:
    seed = occupied.pop()
    queue = deque([seed])
    size = 1
    while queue:
        x, y = queue.popleft()
        for dx, dy in (
            (-1, -1), (0, -1), (1, -1),
            (-1, 0),            (1, 0),
            (-1, 1),  (0, 1),  (1, 1),
        ):
            point = (x + dx, y + dy)
            if point in occupied:
                occupied.remove(point)
                queue.append(point)
                size += 1
    if size >= 50:
        components.append(size)

components.sort(reverse=True)
print(f"component Cylinder render islands: {components}")
if len(components) != 2:
    raise SystemExit(
        "expected exactly two substantial visible occurrence islands; "
        f"got {len(components)} ({components})"
    )
PY

rm -f \
    "$component_create_script" \
    "$component_create_results" \
    "$component_copy_script" \
    "$component_copy_results" \
    "$component_move_script" \
    "$component_stage1" \
    "$component_stage2" \
    "$component_design" \
    "$component_cylinder_png"

if command -v cadcraft-cli >/dev/null 2>&1; then
    echo "unexpected cadcraft-cli in SolidCraft runtime" >&2
    exit 1
fi

echo "SolidCraft runtime smoke test: PASS"
