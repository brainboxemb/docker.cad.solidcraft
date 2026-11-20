#!/usr/bin/env sh
set -eu

cad-solidcraft-info

python - <<'PY'
import importlib.metadata as metadata
import importlib.util
import os
from pathlib import Path

import cad_verification
import matplotlib
import PIL
import scipy
import trimesh
import yaml

actual = metadata.version("brainboxemb-cad-verification-lib")
expected = os.environ["CAD_VERIFICATION_VERSION"]
if actual != expected:
    raise SystemExit(f"cad-verification: expected {expected}, got {actual}")

for module in ("pythonscad", "pybosl2", "cadquery"):
    if importlib.util.find_spec(module) is not None:
        raise SystemExit(f"unexpected reference module in SolidCraft runtime: {module}")

if Path("/opt/build123d").exists():
    raise SystemExit("unexpected build123d environment in SolidCraft runtime")

assert cad_verification
assert matplotlib
assert PIL
assert scipy
assert trimesh
assert yaml
PY

solidcraft-cli --version >/dev/null

if command -v cadcraft-cli >/dev/null 2>&1; then
    echo "unexpected cadcraft-cli in SolidCraft runtime" >&2
    exit 1
fi

echo "SolidCraft runtime smoke test: PASS"
