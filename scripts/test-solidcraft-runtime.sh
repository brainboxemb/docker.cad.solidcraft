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

component_phase1_script="$(mktemp --suffix=.json)"
component_phase2_script="$(mktemp --suffix=.json)"

cat >"$component_phase1_script" <<'JSON'
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
    }
  ]
}
JSON

cat >"$component_phase2_script" <<'JSON'
{
  "commands": [
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
    },
    {
      "command": "occurrence.move",
      "params": {
        "occurrence": 2,
        "translate": [
          0,
          0,
          160
        ],
        "axis": [
          1,
          0,
          0
        ],
        "angle": "90 deg",
        "move_grounded": true
      }
    }
  ]
}
JSON

python - "$component_phase1_script" "$component_phase2_script" <<'PY'
from collections import deque
import json
from pathlib import Path
import subprocess
import sys
import tempfile

from PIL import Image


phase1_path = Path(sys.argv[1])
phase2_path = Path(sys.argv[2])
phase2_source = json.loads(phase2_path.read_text(encoding="utf-8"))
phase2_commands = phase2_source["commands"]

CAMERA = (
    '{"target":[0,0,160],"yaw":-0.7853981633974483,'
    '"pitch":0.5585053606381855,"roll":0,"distance":1319.505,"fov":0}'
)


def command_category(command, index):
    kind = command["command"]
    params = command.get("params", {})
    if index <= 6:
        return "rear_cut"
    if kind == "solid.cylinder":
        diameter = params.get("diameter")
        height = params.get("height")
        if diameter == 8.5 and height == 13:
            return "mounting_cylinder"
        if diameter == 14 and height == 12.5:
            return "reinforcement_cylinder"
        if diameter == 3 and height == 3:
            return "locator_pin"
    if kind == "solid.hole":
        diameter = params.get("diameter")
        depth = params.get("depth")
        position = params.get("position", [None, None, None])
        if diameter == 10 and depth == 0.8:
            return "mounting_relief"
        if (
            (diameter == 10 and depth == 2.5)
            or (diameter == 2.5 and depth == 10)
        ):
            return "reinforcement_hole"
        if diameter == 3 and depth == 13 and position[2] == 15:
            return "final_bore"
    return "assembly"


def is_first_mounting(command):
    params = command.get("params", {})
    point = params.get("base") or params.get("position")
    return isinstance(point, list) and point[:2] == [-72, -152]


VARIANTS = (
    ("baseline", set(), False, False),
    ("no_final_bores", {"final_bore"}, False, False),
    (
        "no_locators_or_final_bores",
        {"locator_pin", "final_bore"},
        False,
        False,
    ),
    (
        "no_reinforcement_holes_locators_final",
        {"reinforcement_hole", "locator_pin", "final_bore"},
        False,
        False,
    ),
    (
        "mounting_only",
        {
            "reinforcement_hole",
            "reinforcement_cylinder",
            "locator_pin",
            "final_bore",
        },
        False,
        False,
    ),
    (
        "one_mounting_pair",
        {
            "reinforcement_hole",
            "reinforcement_cylinder",
            "locator_pin",
            "final_bore",
        },
        True,
        False,
    ),
    (
        "one_cylinder_no_relief",
        {
            "reinforcement_hole",
            "reinforcement_cylinder",
            "locator_pin",
            "final_bore",
            "mounting_relief",
        },
        True,
        False,
    ),
    (
        "taper_one_cylinder_no_rear_cut",
        {
            "reinforcement_hole",
            "reinforcement_cylinder",
            "locator_pin",
            "final_bore",
            "mounting_relief",
            "rear_cut",
        },
        True,
        True,
    ),
)


def filtered_phase2(remove_categories, first_mounting_only):
    rows = []
    for index, command in enumerate(phase2_commands):
        category = command_category(command, index)
        if category in remove_categories:
            continue
        if (
            first_mounting_only
            and category == "mounting_cylinder"
            and not is_first_mounting(command)
        ):
            continue
        if (
            first_mounting_only
            and category == "mounting_relief"
            and not is_first_mounting(command)
        ):
            continue
        rows.append(command)
    return {"commands": rows}


def analyze(path):
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
    return components, orphans


def run_quiet(args):
    subprocess.run(
        args,
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


results = {}
with tempfile.TemporaryDirectory(prefix="hub75-history-") as directory:
    root = Path(directory)
    stage1 = root / "stage1.sc"
    run_quiet([
        "solidcraft-cli", "run", str(phase1_path),
        "--save", str(stage1),
        "--quiet",
    ])

    for label, remove, first_only, _no_rear in VARIANTS:
        variant_dir = root / label
        variant_dir.mkdir()
        p2 = variant_dir / "phase2.json"
        p2_results = variant_dir / "phase2-results.json"
        stage2 = variant_dir / "stage2.sc"
        p3 = variant_dir / "phase3.json"
        design = variant_dir / "design.sc"
        png = variant_dir / "preview.png"

        p2.write_text(
            json.dumps(
                filtered_phase2(remove, first_only),
                indent=2,
            ) + "\n",
            encoding="utf-8",
        )

        try:
            subprocess.run(
                [
                    "solidcraft-cli", "run", str(p2),
                    "--in", str(stage1),
                    "--save", str(stage2),
                    "--results",
                    "--json-out", str(p2_results),
                    "--quiet",
                ],
                check=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            raw = json.loads(p2_results.read_text(encoding="utf-8"))
            rows = raw.get("results", raw) if isinstance(raw, dict) else raw
            copies = [
                row["occurrence"]
                for row in rows
                if isinstance(row, dict)
                and "component" in row
                and "occurrence" in row
            ]
            if len(copies) != 4:
                raise RuntimeError(
                    f"expected four copied occurrences, got {copies}"
                )

            transforms = (
                ([-320, 0, 160], [1, 0, 0], "90 deg"),
                ([-160, 0, 160], [0, 1, -1], "180 deg"),
                ([160, 0, 160], [0, 1, -1], "180 deg"),
                ([320, 0, 160], [1, 0, 0], "90 deg"),
            )
            p3.write_text(
                json.dumps(
                    {
                        "commands": [
                            {
                                "command": "occurrence.move",
                                "params": {
                                    "occurrence": occurrence,
                                    "translate": translate,
                                    "axis": axis,
                                    "angle": angle,
                                },
                            }
                            for occurrence, (translate, axis, angle)
                            in zip(copies, transforms)
                        ]
                    },
                    indent=2,
                ) + "\n",
                encoding="utf-8",
            )
            run_quiet([
                "solidcraft-cli", "run", str(p3),
                "--in", str(stage2),
                "--save", str(design),
                "--quiet",
            ])
            run_quiet([
                "solidcraft-cli", "snapshot", str(design),
                "--out", str(png),
                "--width", "720",
                "--height", "540",
                "--camera", CAMERA,
                "--no-grid",
                "--no-axes",
                "--transparent",
            ])
            components, orphans = analyze(png)
            results[label] = {
                "commands": len(json.loads(p2.read_text())["commands"]),
                "components": components,
                "orphans": orphans,
            }
            print(
                f"HUB75 reduction {label}: "
                f"commands={results[label]['commands']} "
                f"orphans={len(orphans)} "
                f"components={components}"
            )
        except Exception as exc:
            results[label] = {"error": str(exc)}
            print(f"HUB75 reduction {label}: ERROR {exc}")

baseline = results.get("baseline", {})
orphans = baseline.get("orphans", [])
if not orphans:
    raise SystemExit(
        "expanded HUB75 baseline unexpectedly has no detached render islands"
    )

print(
    "HUB75 baseline detached islands remain a hard failure: "
    f"{orphans}"
)
raise SystemExit(1)
PY

rm -f "$component_phase1_script" "$component_phase2_script"

if command -v cadcraft-cli >/dev/null 2>&1; then
    echo "unexpected cadcraft-cli in SolidCraft runtime" >&2
    exit 1
fi

echo "SolidCraft runtime smoke test: PASS"
