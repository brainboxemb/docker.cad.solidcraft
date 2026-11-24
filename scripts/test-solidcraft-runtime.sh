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

component_history_script="$(mktemp --suffix=.json)"
component_history_results="$(mktemp --suffix=.json)"
component_history_stage="$(mktemp --suffix=.sc)"
component_move_script="$(mktemp --suffix=.json)"
component_design="$(mktemp --suffix=.sc)"
component_cylinder_png="$(mktemp --suffix=.png)"

cat >"$component_history_script" <<'JSON'
{
  "commands": [
    {
      "command": "component.create",
      "params": {
        "name": "Hub75HistoryPanel",
        "grounded": true
      }
    },
    {
      "command": "sketch.create",
      "params": {
        "plane": "XY",
        "name": "d1_Hub75HistoryPanel__Hub75HistoryPanel footprint"
      }
    },
    {
      "command": "sketch.rectangle.two_point",
      "params": {
        "p0": [
          -79.85,
          -159.855
        ],
        "p1": [
          79.85,
          159.855
        ]
      }
    },
    {
      "command": "sketch.finish",
      "params": {}
    },
    {
      "command": "solid.extrude",
      "params": {
        "distance": 2,
        "body_name": "Hub75HistoryPanel"
      }
    },
    {
      "command": "sketch.create",
      "params": {
        "plane": "XY",
        "name": "d1_Hub75HistoryPanel__Hub75HistoryPanel rear start",
        "offset": 2
      }
    },
    {
      "command": "sketch.rectangle.two_point",
      "params": {
        "p0": [
          -79.85,
          -159.855
        ],
        "p1": [
          79.85,
          159.855
        ]
      }
    },
    {
      "command": "sketch.finish",
      "params": {}
    },
    {
      "command": "sketch.create",
      "params": {
        "plane": "XY",
        "name": "d1_Hub75HistoryPanel__Hub75HistoryPanel rear perimeter",
        "offset": 14.5
      }
    },
    {
      "command": "sketch.rectangle.two_point",
      "params": {
        "p0": [
          -78.6,
          -158.605
        ],
        "p1": [
          78.6,
          158.605
        ]
      }
    },
    {
      "command": "sketch.finish",
      "params": {}
    },
    {
      "command": "solid.loft",
      "params": {
        "sections": [
          {
            "sketch": "d1_Hub75HistoryPanel__Hub75HistoryPanel rear start"
          },
          {
            "sketch": "d1_Hub75HistoryPanel__Hub75HistoryPanel rear perimeter"
          }
        ],
        "operation": "join",
        "targets": [
          "Hub75HistoryPanel"
        ]
      }
    },
    {
      "command": "model.faces",
      "params": {
        "body": "Hub75HistoryPanel"
      }
    },
    {
      "command": "sketch.create",
      "params": {
        "plane": {
          "face": [
            18.40772842651739,
            -98.41272842651739,
            14.5
          ],
          "body": "Hub75HistoryPanel",
          "index": 8
        },
        "project_edges": false,
        "name": "d1_Hub75HistoryPanel__Rear electronics bays"
      }
    },
    {
      "command": "sketch.rectangle.two_point",
      "params": {
        "p0": [
          -67.3734375,
          -149.11474218749998
        ],
        "p1": [
          67.3734375,
          -89.91843749999998
        ]
      }
    },
    {
      "command": "sketch.rectangle.two_point",
      "params": {
        "p0": [
          -67.3734375,
          -69.9365625
        ],
        "p1": [
          67.3734375,
          -9.990937500000001
        ]
      }
    },
    {
      "command": "sketch.rectangle.two_point",
      "params": {
        "p0": [
          -67.3734375,
          9.990937500000001
        ],
        "p1": [
          67.3734375,
          69.9365625
        ]
      }
    },
    {
      "command": "sketch.rectangle.two_point",
      "params": {
        "p0": [
          -67.3734375,
          89.91843749999998
        ],
        "p1": [
          67.3734375,
          149.11474218749998
        ]
      }
    },
    {
      "command": "sketch.finish",
      "params": {}
    },
    {
      "command": "solid.extrude",
      "params": {
        "operation": "cut",
        "targets": [
          "Hub75HistoryPanel"
        ],
        "name": "Rear electronics bays",
        "distance": 12.5,
        "direction": "negative"
      }
    },
    {
      "command": "solid.hole",
      "params": {
        "position": [
          -72,
          -152,
          14.5
        ],
        "targets": [
          "Hub75HistoryPanel"
        ],
        "diameter": 10,
        "depth": 0.8,
        "direction": [
          0,
          0,
          -1
        ]
      }
    },
    {
      "command": "solid.cylinder",
      "params": {
        "height": 13,
        "diameter": 8.5,
        "base": [
          -72,
          -152,
          2
        ],
        "axis": "Z",
        "operation": "join",
        "targets": [
          "Hub75HistoryPanel"
        ]
      }
    },
    {
      "command": "solid.hole",
      "params": {
        "position": [
          -72,
          0,
          14.5
        ],
        "targets": [
          "Hub75HistoryPanel"
        ],
        "diameter": 10,
        "depth": 0.8,
        "direction": [
          0,
          0,
          -1
        ]
      }
    },
    {
      "command": "solid.cylinder",
      "params": {
        "height": 13,
        "diameter": 8.5,
        "base": [
          -72,
          0,
          2
        ],
        "axis": "Z",
        "operation": "join",
        "targets": [
          "Hub75HistoryPanel"
        ]
      }
    },
    {
      "command": "solid.hole",
      "params": {
        "position": [
          -72,
          152,
          14.5
        ],
        "targets": [
          "Hub75HistoryPanel"
        ],
        "diameter": 10,
        "depth": 0.8,
        "direction": [
          0,
          0,
          -1
        ]
      }
    },
    {
      "command": "solid.cylinder",
      "params": {
        "height": 13,
        "diameter": 8.5,
        "base": [
          -72,
          152,
          2
        ],
        "axis": "Z",
        "operation": "join",
        "targets": [
          "Hub75HistoryPanel"
        ]
      }
    },
    {
      "command": "solid.hole",
      "params": {
        "position": [
          72,
          -152,
          14.5
        ],
        "targets": [
          "Hub75HistoryPanel"
        ],
        "diameter": 10,
        "depth": 0.8,
        "direction": [
          0,
          0,
          -1
        ]
      }
    },
    {
      "command": "solid.cylinder",
      "params": {
        "height": 13,
        "diameter": 8.5,
        "base": [
          72,
          -152,
          2
        ],
        "axis": "Z",
        "operation": "join",
        "targets": [
          "Hub75HistoryPanel"
        ]
      }
    },
    {
      "command": "solid.hole",
      "params": {
        "position": [
          72,
          0,
          14.5
        ],
        "targets": [
          "Hub75HistoryPanel"
        ],
        "diameter": 10,
        "depth": 0.8,
        "direction": [
          0,
          0,
          -1
        ]
      }
    },
    {
      "command": "solid.cylinder",
      "params": {
        "height": 13,
        "diameter": 8.5,
        "base": [
          72,
          0,
          2
        ],
        "axis": "Z",
        "operation": "join",
        "targets": [
          "Hub75HistoryPanel"
        ]
      }
    },
    {
      "command": "solid.hole",
      "params": {
        "position": [
          72,
          152,
          14.5
        ],
        "targets": [
          "Hub75HistoryPanel"
        ],
        "diameter": 10,
        "depth": 0.8,
        "direction": [
          0,
          0,
          -1
        ]
      }
    },
    {
      "command": "solid.cylinder",
      "params": {
        "height": 13,
        "diameter": 8.5,
        "base": [
          72,
          152,
          2
        ],
        "axis": "Z",
        "operation": "join",
        "targets": [
          "Hub75HistoryPanel"
        ]
      }
    },
    {
      "command": "solid.cylinder",
      "params": {
        "height": 12.5,
        "diameter": 14,
        "base": [
          -72,
          -141,
          2
        ],
        "axis": "Z",
        "operation": "join",
        "targets": [
          "Hub75HistoryPanel"
        ]
      }
    },
    {
      "command": "solid.hole",
      "params": {
        "position": [
          -72,
          -141,
          14.5
        ],
        "targets": [
          "Hub75HistoryPanel"
        ],
        "diameter": 10,
        "depth": 2.5,
        "direction": [
          0,
          0,
          -1
        ]
      }
    },
    {
      "command": "solid.hole",
      "params": {
        "position": [
          -72,
          -141,
          12
        ],
        "targets": [
          "Hub75HistoryPanel"
        ],
        "diameter": 2.5,
        "depth": 10,
        "direction": [
          0,
          0,
          -1
        ]
      }
    },
    {
      "command": "solid.cylinder",
      "params": {
        "height": 12.5,
        "diameter": 14,
        "base": [
          72,
          -141,
          2
        ],
        "axis": "Z",
        "operation": "join",
        "targets": [
          "Hub75HistoryPanel"
        ]
      }
    },
    {
      "command": "solid.hole",
      "params": {
        "position": [
          72,
          -141,
          14.5
        ],
        "targets": [
          "Hub75HistoryPanel"
        ],
        "diameter": 10,
        "depth": 2.5,
        "direction": [
          0,
          0,
          -1
        ]
      }
    },
    {
      "command": "solid.hole",
      "params": {
        "position": [
          72,
          -141,
          12
        ],
        "targets": [
          "Hub75HistoryPanel"
        ],
        "diameter": 2.5,
        "depth": 10,
        "direction": [
          0,
          0,
          -1
        ]
      }
    },
    {
      "command": "solid.cylinder",
      "params": {
        "height": 12.5,
        "diameter": 14,
        "base": [
          -72,
          11,
          2
        ],
        "axis": "Z",
        "operation": "join",
        "targets": [
          "Hub75HistoryPanel"
        ]
      }
    },
    {
      "command": "solid.hole",
      "params": {
        "position": [
          -72,
          11,
          14.5
        ],
        "targets": [
          "Hub75HistoryPanel"
        ],
        "diameter": 10,
        "depth": 2.5,
        "direction": [
          0,
          0,
          -1
        ]
      }
    },
    {
      "command": "solid.hole",
      "params": {
        "position": [
          -72,
          11,
          12
        ],
        "targets": [
          "Hub75HistoryPanel"
        ],
        "diameter": 2.5,
        "depth": 10,
        "direction": [
          0,
          0,
          -1
        ]
      }
    },
    {
      "command": "solid.cylinder",
      "params": {
        "height": 12.5,
        "diameter": 14,
        "base": [
          72,
          -11,
          2
        ],
        "axis": "Z",
        "operation": "join",
        "targets": [
          "Hub75HistoryPanel"
        ]
      }
    },
    {
      "command": "solid.hole",
      "params": {
        "position": [
          72,
          -11,
          14.5
        ],
        "targets": [
          "Hub75HistoryPanel"
        ],
        "diameter": 10,
        "depth": 2.5,
        "direction": [
          0,
          0,
          -1
        ]
      }
    },
    {
      "command": "solid.hole",
      "params": {
        "position": [
          72,
          -11,
          12
        ],
        "targets": [
          "Hub75HistoryPanel"
        ],
        "diameter": 2.5,
        "depth": 10,
        "direction": [
          0,
          0,
          -1
        ]
      }
    },
    {
      "command": "solid.cylinder",
      "params": {
        "height": 12.5,
        "diameter": 14,
        "base": [
          -72,
          141,
          2
        ],
        "axis": "Z",
        "operation": "join",
        "targets": [
          "Hub75HistoryPanel"
        ]
      }
    },
    {
      "command": "solid.hole",
      "params": {
        "position": [
          -72,
          141,
          14.5
        ],
        "targets": [
          "Hub75HistoryPanel"
        ],
        "diameter": 10,
        "depth": 2.5,
        "direction": [
          0,
          0,
          -1
        ]
      }
    },
    {
      "command": "solid.hole",
      "params": {
        "position": [
          -72,
          141,
          12
        ],
        "targets": [
          "Hub75HistoryPanel"
        ],
        "diameter": 2.5,
        "depth": 10,
        "direction": [
          0,
          0,
          -1
        ]
      }
    },
    {
      "command": "solid.cylinder",
      "params": {
        "height": 12.5,
        "diameter": 14,
        "base": [
          72,
          141,
          2
        ],
        "axis": "Z",
        "operation": "join",
        "targets": [
          "Hub75HistoryPanel"
        ]
      }
    },
    {
      "command": "solid.hole",
      "params": {
        "position": [
          72,
          141,
          14.5
        ],
        "targets": [
          "Hub75HistoryPanel"
        ],
        "diameter": 10,
        "depth": 2.5,
        "direction": [
          0,
          0,
          -1
        ]
      }
    },
    {
      "command": "solid.hole",
      "params": {
        "position": [
          72,
          141,
          12
        ],
        "targets": [
          "Hub75HistoryPanel"
        ],
        "diameter": 2.5,
        "depth": 10,
        "direction": [
          0,
          0,
          -1
        ]
      }
    },
    {
      "command": "solid.cylinder",
      "params": {
        "height": 3,
        "diameter": 3,
        "base": [
          -75,
          110,
          14.5
        ],
        "axis": "Z",
        "operation": "join",
        "targets": [
          "Hub75HistoryPanel"
        ]
      }
    },
    {
      "command": "solid.cylinder",
      "params": {
        "height": 3,
        "diameter": 3,
        "base": [
          75,
          -110,
          14.5
        ],
        "axis": "Z",
        "operation": "join",
        "targets": [
          "Hub75HistoryPanel"
        ]
      }
    },
    {
      "command": "solid.hole",
      "params": {
        "position": [
          -72,
          -152,
          15
        ],
        "targets": [
          "Hub75HistoryPanel"
        ],
        "diameter": 3,
        "depth": 13,
        "direction": [
          0,
          0,
          -1
        ]
      }
    },
    {
      "command": "solid.hole",
      "params": {
        "position": [
          -72,
          0,
          15
        ],
        "targets": [
          "Hub75HistoryPanel"
        ],
        "diameter": 3,
        "depth": 13,
        "direction": [
          0,
          0,
          -1
        ]
      }
    },
    {
      "command": "solid.hole",
      "params": {
        "position": [
          -72,
          152,
          15
        ],
        "targets": [
          "Hub75HistoryPanel"
        ],
        "diameter": 3,
        "depth": 13,
        "direction": [
          0,
          0,
          -1
        ]
      }
    },
    {
      "command": "solid.hole",
      "params": {
        "position": [
          72,
          -152,
          15
        ],
        "targets": [
          "Hub75HistoryPanel"
        ],
        "diameter": 3,
        "depth": 13,
        "direction": [
          0,
          0,
          -1
        ]
      }
    },
    {
      "command": "solid.hole",
      "params": {
        "position": [
          72,
          0,
          15
        ],
        "targets": [
          "Hub75HistoryPanel"
        ],
        "diameter": 3,
        "depth": 13,
        "direction": [
          0,
          0,
          -1
        ]
      }
    },
    {
      "command": "solid.hole",
      "params": {
        "position": [
          72,
          152,
          15
        ],
        "targets": [
          "Hub75HistoryPanel"
        ],
        "diameter": 3,
        "depth": 13,
        "direction": [
          0,
          0,
          -1
        ]
      }
    },
    {
      "command": "component.activate",
      "params": {
        "component": "root"
      }
    },
    {
      "command": "occurrence.copy",
      "params": {
        "component": "Hub75HistoryPanel"
      }
    },
    {
      "command": "occurrence.copy",
      "params": {
        "component": "Hub75HistoryPanel"
      }
    },
    {
      "command": "occurrence.copy",
      "params": {
        "component": "Hub75HistoryPanel"
      }
    },
    {
      "command": "occurrence.copy",
      "params": {
        "component": "Hub75HistoryPanel"
      }
    }
  ]
}
JSON

solidcraft-cli run "$component_history_script" \
    --save "$component_history_stage" \
    --results \
    --json-out "$component_history_results" \
    --quiet

occurrences="$(
python - "$component_history_results" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    result = json.load(handle)
rows = result.get("results", result) if isinstance(result, dict) else result
occurrences = [
    row["occurrence"]
    for row in rows
    if isinstance(row, dict)
    and "component" in row
    and "occurrence" in row
]
if len(occurrences) != 5:
    raise SystemExit(
        "expected exactly five HUB75-history occurrences; "
        f"got {occurrences}"
    )
print(" ".join(str(value) for value in occurrences))
PY
)"

read -r occurrence_1 occurrence_2 occurrence_3 occurrence_4 occurrence_5 \
    <<<"$occurrences"

cat >"$component_move_script" <<JSON
{"commands":[
  {"command":"occurrence.move","params":{
    "occurrence":${occurrence_1},
    "translate":[0,0,160],
    "axis":[1,0,0],
    "angle":"90 deg",
    "move_grounded":true
  }},
  {"command":"occurrence.move","params":{
    "occurrence":${occurrence_2},
    "translate":[-320,0,160],
    "axis":[1,0,0],
    "angle":"90 deg"
  }},
  {"command":"occurrence.move","params":{
    "occurrence":${occurrence_3},
    "translate":[-160,0,160],
    "axis":[0,1,-1],
    "angle":"180 deg"
  }},
  {"command":"occurrence.move","params":{
    "occurrence":${occurrence_4},
    "translate":[160,0,160],
    "axis":[0,1,-1],
    "angle":"180 deg"
  }},
  {"command":"occurrence.move","params":{
    "occurrence":${occurrence_5},
    "translate":[320,0,160],
    "axis":[1,0,0],
    "angle":"90 deg"
  }}
]}
JSON

solidcraft-cli run "$component_move_script" \
    --in "$component_history_stage" \
    --save "$component_design" \
    --quiet

solidcraft-cli snapshot "$component_design" \
    --out "$component_cylinder_png" \
    --width 720 \
    --height 540 \
    --camera '{"target":[0,0,160],"yaw":-0.7853981633974483,"pitch":0.5585053606381855,"roll":0,"distance":1319.505,"fov":0}' \
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
    pixels = [seed]
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
                pixels.append(point)
    if len(pixels) < 20:
        continue
    xs = [point[0] for point in pixels]
    ys = [point[1] for point in pixels]
    components.append(
        {
            "pixels": len(pixels),
            "width": max(xs) - min(xs) + 1,
            "height": max(ys) - min(ys) + 1,
        }
    )

components.sort(key=lambda row: row["pixels"], reverse=True)
orphans = [
    row
    for row in components
    if row["width"] < 80 and row["height"] < 80
]
print(f"HUB75 component render islands: {components}")
print(f"HUB75 detached small islands: {orphans}")
if orphans:
    raise SystemExit(
        "detached component-local render geometry remains visible: "
        f"{orphans}"
    )
PY

rm -f \
    "$component_history_script" \
    "$component_history_results" \
    "$component_history_stage" \
    "$component_move_script" \
    "$component_design" \
    "$component_cylinder_png"

if command -v cadcraft-cli >/dev/null 2>&1; then
    echo "unexpected cadcraft-cli in SolidCraft runtime" >&2
    exit 1
fi

echo "SolidCraft runtime smoke test: PASS"
