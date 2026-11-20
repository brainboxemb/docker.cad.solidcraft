#!/usr/bin/env sh
set -eu

cad-reference-info

python - <<'PY'
import importlib.metadata as metadata
import importlib.util
import os
from pathlib import Path

import cadquery
import matplotlib
import PIL
import pybosl2
import pythonscad
import scipy
import trimesh
import yaml

if importlib.util.find_spec("cad_verification") is not None:
    raise SystemExit("unexpected cad_verification package in reference runtime")

expected = {
    "cadquery": os.environ["CADQUERY_VERSION"],
}

for distribution, version in expected.items():
    actual = metadata.version(distribution)
    if actual != version:
        raise SystemExit(f"{distribution}: expected {version}, got {actual}")

if Path("/opt/solidcraft").exists():
    raise SystemExit("unexpected SolidCraft installation in reference runtime")

assert cadquery
assert matplotlib
assert PIL
assert pybosl2
assert pythonscad
assert scipy
assert trimesh
assert yaml
PY

/opt/build123d/bin/python - <<'PY'
import build123d
assert build123d
PY

if command -v solidcraft-cli >/dev/null 2>&1; then
    echo "unexpected solidcraft-cli in reference runtime" >&2
    exit 1
fi

if command -v cadcraft-cli >/dev/null 2>&1; then
    echo "unexpected cadcraft-cli in reference runtime" >&2
    exit 1
fi

echo "Reference runtime smoke test: PASS"
