# SolidCraft CAD runtime requirements

## Ownership

`docker.cad.solidcraft` owns the reusable runtime packages used by SolidCraft
model verification and independent reference verification.

Consumer repositories select released immutable images. They do not own the
Dockerfile, dependency pins, runtime package composition or publication flow.

## Versioning

One repository release version governs all role images.

- `versions.env::RUNTIME_VERSION` is the release source of truth.
- Repository release tags use `vX.Y.Z`.
- Every role image published by that release uses the same immutable `vX.Y.Z`.
- `:edge` represents current `main` for each role.
- Existing release tags and image tags are never overwritten.

## Runtime roles

### SolidCraft role

Published as:

```text
ghcr.io/brainboxemb/cad-solidcraft:vX.Y.Z
```

It contains only what normal SolidCraft-backed model/visual verification needs:

- SolidCraft;
- released `lib.py.cad.verification`;
- PyYAML;
- Pillow;
- shared system dependencies required by SolidCraft.

It must not contain:

- trimesh;
- scipy;
- matplotlib;
- PythonSCAD;
- pyBOSL2;
- CadQuery;
- build123d.

The verification distribution may declare optional geometry/visual dependencies
for its complete library surface. The SolidCraft image installs that
distribution with dependency resolution disabled and installs only the runtime
dependencies owned by this role.

### Reference role

Published as:

```text
ghcr.io/brainboxemb/cad-reference:vX.Y.Z
```

It contains the independent reference engines used by Forge:

- PythonSCAD;
- pyBOSL2;
- CadQuery;
- build123d;
- released `lib.py.cad.verification`;
- Pillow;
- trimesh;
- scipy;
- matplotlib;
- shared Python/system dependencies required by reference validation/export.

It must not contain SolidCraft merely for packaging convenience.

### CADCraft

CADCraft is not part of either v0.2.0 role unless a concrete current consumer
requires it. Historical inclusion in v0.1.0 is not sufficient justification.
If a future role needs CADCraft, that dependency must be designed and tested
explicitly.

## Shared layers

The Dockerfile may share build stages/layers between roles only where the
dependencies are genuinely common. Shared stages must not pull heavy
reference-only dependencies into the SolidCraft image.

## Build and publication

- pull requests build and smoke-test both role images locally without publish;
- `main` publishes and smoke-tests both `:edge` images;
- immutable `vX.Y.Z` tags publish and smoke-test both matching role images;
- the release workflow validates one requested version and exact commit;
- the normal build workflow remains authoritative for both image packages;
- release-tag builds create one GitHub Release describing both immutable images.

## Cache policy

GitHub Actions cache transport is not used for Docker layer reuse.

The build workflow must not use `actions/cache` or Buildx `type=gha`
cache import/export.

## Verification

Each role has an independent smoke test.

SolidCraft smoke testing proves:

- `solidcraft-cli` starts and reports a version;
- the configured CAD-verification distribution is installed at the exact pin;
- the public SolidCraft verification API imports without eagerly loading
  geometry or visual implementation modules;
- PyYAML and Pillow are present;
- trimesh, scipy and matplotlib are absent;
- reference engines are absent.

Reference smoke testing proves:

- PythonSCAD imports;
- pyBOSL2 imports;
- CadQuery imports at the exact pin;
- build123d imports from its isolated environment;
- the configured CAD-verification distribution is installed at the exact pin;
- SolidCraft is absent.

## Performance acceptance

Clean pull timing is measured on GitHub-hosted runners after immutable release.

For the SolidCraft role, the engineering target is approximately <=20 seconds
under comparable external registry conditions. The measurement is evidence, not
a correctness gate against registry/network variance.

## Consumer migration

Every runtime-content change is released under a new immutable SemVer tag.
Consumers move from one released role version to the next explicitly after both
role images have been independently smoke-tested and the relevant clean-pull
evidence has been recorded.
