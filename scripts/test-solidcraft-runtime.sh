#!/usr/bin/env sh
set -eu

cad-solidcraft-info

python - <<'PY'
import importlib.metadata as metadata
import importlib.util
import os
from pathlib import Path
import sys

import PIL
import yaml
from cad_verification import (
    SolidCraftVerification,
    run_solidcraft_verification,
)

actual = metadata.version("brainboxemb-cad-verification-lib")
expected = os.environ["CAD_VERIFICATION_VERSION"]
if actual != expected:
    raise SystemExit(f"cad-verification: expected {expected}, got {actual}")

if "cad_verification.geometry" in sys.modules:
    raise SystemExit("SolidCraft API eagerly loaded geometry verification")
if "cad_verification.visual" in sys.modules:
    raise SystemExit("SolidCraft API eagerly loaded visual verification")

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
assert SolidCraftVerification
assert callable(run_solidcraft_verification)
PY

solidcraft-cli --version >/dev/null

if command -v cadcraft-cli >/dev/null 2>&1; then
    echo "unexpected cadcraft-cli in SolidCraft runtime" >&2
    exit 1
fi

echo "SolidCraft runtime smoke test: PASS"
