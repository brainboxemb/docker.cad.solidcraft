# SolidCraft CAD runtime design

## Repository boundary

```text
docker.cad.solidcraft
  versions.env
  Dockerfile
  role-specific smoke tests
  build/release workflows
       |
       +--> ghcr.io/brainboxemb/cad-solidcraft:vX.Y.Z
       |
       +--> ghcr.io/brainboxemb/cad-reference:vX.Y.Z

consumer repositories
  -> explicitly select the immutable role image they need
```

The repository owns packaging and version pins. Consumers own project/model
behavior.

## Release model

One SemVer release publishes both role images from one exact verified commit.

```text
versions.env
  RUNTIME_VERSION=X.Y.Z
       |
       v
branch / PR
  build target solidcraft
  build target reference
  smoke-test both
       |
       v
main
  publish/test cad-solidcraft:edge
  publish/test cad-reference:edge
       |
       v
release vX.Y.Z
  validate exact green commit
  create immutable repository tag
  build/publish/test both role images
  create one GitHub Release
```

## Docker stage model

The common stage contains only dependencies genuinely shared by both roles.

```text
python base
   |
   v
common
  shared system libraries
  PyYAML
  released cad-verification --no-deps
   |
   +----------------------------+
   |                            |
   v                            v
solidcraft                   reference
Pillow                       Pillow
SolidCraft                   trimesh
                             scipy
                             matplotlib
                             PythonSCAD
                             pyBOSL2
                             CadQuery
                             build123d venv
```

The SolidCraft role intentionally does not inherit the geometry/reference
Python stack. Released `lib.py.cad.verification` keeps its complete package
metadata, while this runtime owns the explicit dependency subset appropriate to
each role.

The `solidcraft` target must never contain reference engines or the
trimesh/scipy/matplotlib geometry stack. The `reference` target must never
inherit SolidCraft.

CADCraft remains omitted unless a concrete current consumer requires it.

## Role metadata

Every role exposes:

- `CAD_RUNTIME_VERSION`;
- `CAD_RUNTIME_ROLE`;
- `CAD_VERIFICATION_VERSION`.

Role-specific version variables are exposed only in the image that owns them.

## Smoke-test model

The repository owns two executable tests:

```text
test-cad-solidcraft-runtime
test-cad-reference-runtime
```

The SolidCraft smoke test validates both the installed tools and the import
boundary:

```text
from cad_verification import SolidCraftVerification,
                             run_solidcraft_verification
  -> cad_verification.geometry not loaded
  -> cad_verification.visual not loaded
  -> trimesh/scipy/matplotlib distributions absent
```

Pillow stays in the SolidCraft role because that role also owns normal visual
verification when a consumer requests the public visual APIs.

The reference smoke test retains the complete geometry/reference import checks.
Presence and deliberate absence checks protect role boundaries from future
Dockerfile regressions.

## CI architecture

A two-entry build matrix remains authoritative:

```text
role=solidcraft
  target=solidcraft
  package=cad-solidcraft
  smoke=test-cad-solidcraft-runtime

role=reference
  target=reference
  package=cad-reference
  smoke=test-cad-reference-runtime
```

PRs load each built image locally and smoke-test it. Main and release tags push
each role package, then clean-pull/run that exact published tag.

The workflow does not use GitHub Actions cache transport.

## Performance evidence

Clean pull timing is recorded separately for each published role. Registry
variance means one measurement is evidence rather than a correctness threshold.

The normal Forge critical path uses only `cad-solidcraft`. Reference-image size
or pull variance must not affect a normal model-verification PR.
