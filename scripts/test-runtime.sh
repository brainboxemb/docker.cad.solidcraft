#!/usr/bin/env sh
set -eu

cad-solidcraft-info

python - <<'PY'
import importlib.metadata as metadata

import cad_verification
import cadquery
import matplotlib
import PIL
import scipy
import trimesh
import yaml

expected = {
    "brainboxemb-cad-verification-lib": __import__("os").environ[
        "CAD_VERIFICATION_VERSION"
    ],
    "cadquery": __import__("os").environ["CADQUERY_VERSION"],
}

for distribution, version in expected.items():
    actual = metadata.version(distribution)
    if actual != version:
        raise SystemExit(
            f"{distribution}: expected {version}, got {actual}"
        )

assert cad_verification
assert cadquery
assert matplotlib
assert PIL
assert scipy
assert trimesh
assert yaml
PY

/opt/build123d/bin/python - <<'PY'
import build123d
assert build123d
PY

solidcraft-cli --version >/dev/null
cadcraft-cli --version >/dev/null

echo "SolidCraft CAD runtime smoke test: PASS"
