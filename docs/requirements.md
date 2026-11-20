# SolidCraft CAD runtime requirements

## Ownership

`docker.cad.solidcraft` is the single owner of the reusable SolidCraft CAD
runtime image.

Consumer repositories:

- select a released runtime image;
- run their own project/model verification inside it;
- do not own the runtime Dockerfile, dependency pins or publication workflow.

## Versioning

Runtime releases use SemVer.

- `versions.env::RUNTIME_VERSION` is the release version source of truth.
- Repository release tags use `vX.Y.Z`.
- Container release tags use the same immutable `vX.Y.Z`.
- `:edge` represents current `main` only.
- Existing release tags must never be overwritten with changed contents.

## Runtime capabilities

The initial runtime must preserve the currently proven SolidCraft Forge runtime
capabilities:

- SolidCraft 0.42.0;
- CADCraft;
- released `lib.py.cad.verfication`;
- PythonSCAD;
- pyBOSL2;
- CadQuery;
- build123d;
- shared Python/runtime dependencies needed by those tools.

Frequently reused libraries may remain preinstalled for efficiency.

## Build and publication

- pull requests build and smoke-test locally but do not publish;
- `main` publishes and smoke-tests `:edge`;
- immutable `vX.Y.Z` tags publish and smoke-test the matching image;
- the release workflow validates the requested version against
  `versions.env` and an exact commit SHA;
- the release workflow creates the immutable Git tag;
- the normal build workflow remains authoritative for image publication;
- release-tag builds create the corresponding GitHub Release.

## Cache policy

GitHub Actions cache storage is not used for Docker layer reuse.

The build workflow must not use:

- `actions/cache`;
- Buildx `cache-from: type=gha`;
- Buildx `cache-to: type=gha`.

## Verification

A successful image build is insufficient.

The build workflow must run a real container smoke test that checks:

- public CAD commands start and report usable versions;
- required Python packages import;
- the released CAD verification package version matches the configured pin;
- the image can perform a minimal SolidCraft CLI operation/version check.

## Consumer migration

A consumer may move to a new immutable runtime tag only after that release image
has been built and smoke-tested successfully.
