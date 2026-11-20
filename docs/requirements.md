# SolidCraft CAD runtime requirements

## Ownership

`docker.cad.solidcraft` owns reusable CAD engine/runtime packages only.

Consumer repositories select released immutable images. They do not own the
Dockerfile, engine pins, runtime package composition or publication flow.

Verification policy and verification-library versions are consumer/CI
dependencies and are deliberately not baked into these runtime images.

## Versioning

One repository release version governs all role images.

- `versions.env::RUNTIME_VERSION` is the release source of truth.
- Repository release tags use `vX.Y.Z`.
- Every role image published by that release uses the same immutable `vX.Y.Z`.
- `:edge` represents current `main`.
- Existing release/image tags are never overwritten.

## SolidCraft role

`ghcr.io/brainboxemb/cad-solidcraft:vX.Y.Z` contains:

- SolidCraft;
- PyYAML;
- Pillow;
- SolidCraft system dependencies.

It must not contain:

- `lib.py.cad.verification` / `cad_verification`;
- trimesh, scipy or matplotlib;
- PythonSCAD, pyBOSL2, CadQuery or build123d.

The consumer supplies the exact released verification package at execution
time, for example as a mounted wheel on `PYTHONPATH`.

## Reference role

`ghcr.io/brainboxemb/cad-reference:vX.Y.Z` contains:

- PythonSCAD;
- pyBOSL2;
- CadQuery;
- build123d;
- Pillow;
- trimesh;
- scipy;
- matplotlib;
- PyYAML;
- required system dependencies.

It must not contain:

- SolidCraft;
- `lib.py.cad.verification` / `cad_verification`.

The consumer supplies the exact released verification package at execution
time.

## Dependency boundary

A verification-library release must not require a Docker runtime release.

Likewise, a model-local `verification/verify.py` change must never require a
runtime rebuild.

A runtime release is required only when CAD engine versions, system/stable
runtime dependencies or image composition change.

## Build and publication

- pull requests build and smoke-test both images without publishing;
- `main` publishes and smoke-tests both `:edge` images;
- immutable `vX.Y.Z` tags publish and smoke-test both images;
- the release workflow validates exact version and commit;
- no GitHub Actions cache transport is used for Docker layers.

## Smoke tests

SolidCraft smoke proves:

- `solidcraft-cli` starts;
- PyYAML and Pillow are present;
- `cad_verification` is absent;
- heavy geometry/reference modules are absent.

Reference smoke proves:

- PythonSCAD, pyBOSL2, CadQuery and build123d work;
- Pillow, trimesh, scipy and matplotlib are present;
- `cad_verification` is absent;
- SolidCraft is absent.

## Consumer migration

Runtime releases and verification-library releases are independent.

Consumers update an immutable runtime image only when runtime contents change.
Consumers update their verification dependency pin independently when a
verification-library release is required.
