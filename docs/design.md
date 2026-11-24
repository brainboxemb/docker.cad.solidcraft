# SolidCraft CAD runtime design

## Repository boundary

```text
docker.cad.solidcraft
  -> cad-solidcraft:vX.Y.Z
  -> cad-reference:vX.Y.Z

consumer CI
  -> selects one immutable runtime image
  -> supplies exact verification wheel separately
```

Docker owns CAD engines and stable runtime dependencies. It does not own the
verification-library version.

## Role layout

```text
python base
   |
   v
common
  shared system libraries
  PyYAML
   |
   +-------------------------+
   |                         |
   v                         v
solidcraft                reference
Pillow                    Pillow
SolidCraft                trimesh
                          scipy
                          matplotlib
                          PythonSCAD
                          pyBOSL2
                          CadQuery
                          build123d
                          CADCraft
```

Neither role contains `cad_verification`.

CADCraft is installed only in the reference role because it is an independent
CAD/reference renderer. Consumer repositories provide CADCraft source/command
data but do not download, pin or install the CADCraft executable themselves.

## Consumer verification injection

The verification package travels through the CI dependency graph:

```text
released lib.py.cad.verification
  -> tested wheel
  -> one CAD-CI dependency output
       |
       +--> model verification container
       |      + Forge wheel
       |
       +--> reference verification container
```

The container receives the wheel read-only and adds it to `PYTHONPATH`.

A new verification-library release therefore changes only the consumer
dependency pin. It does not invalidate/rebuild the CAD runtime image.

Model-local `verification/verify.py` stays source-mounted and can change with
the model without any package or runtime rebuild.

## Runtime metadata

Images expose:

- `CAD_RUNTIME_VERSION`;
- `CAD_RUNTIME_ROLE`;
- role-owned engine versions.

The reference role also exposes `CADCRAFT_VERSION`.

There is intentionally no `CAD_VERIFICATION_VERSION` image metadata.

## Smoke boundary

Docker smoke tests prove runtime composition plus narrow engine contracts that
justify a runtime-version upgrade. They require `cad_verification` to be
absent.

For SolidCraft upgrades, the smoke proves the exact CLI version and the narrow
native contracts that justify consumer compatibility. A runtime defect that is
visible in the SolidCraft snapshot renderer may be qualified directly in this
owner layer when it can be expressed without consumer code. Forge #753 uses
that boundary: the owner smoke replays one reusable Box + joined Cylinder,
copies/rotates two occurrences, renders with a transparent background and
requires exactly two substantial disconnected foreground islands. A stale
definition/tool Cylinder therefore fails the runtime smoke even when body
measurements remain correct.

The current Slot contract
set includes the upstream #15857 shape (one model parameter drives native Slot
width), the straight-Slot dimensioned length path, and the numeric-only direct
Slot-point boundary. These are engine/runtime smokes, not model-specific Forge
verification.

The owner repository qualifies the current stable upstream release first.
Consumer repositories may only derive version-pinned reference documentation
from that qualified immutable runtime; a hand-authored migration note is not a
runtime command snapshot.

Consumer integration tests prove that a separately supplied released
verification wheel works with the selected runtime image.

## Release model

One runtime SemVer release publishes both role images from one exact tested
commit. Runtime releases are independent from verification-library releases.
