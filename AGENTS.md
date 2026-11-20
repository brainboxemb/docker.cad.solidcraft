# Repository agent guidance

Persistent guidance for automated coding agents working in
`docker.cad.solidcraft`.

## Purpose

This repository owns the reusable Docker runtime for SolidCraft-based CAD
verification in the brainboxemb ecosystem.

The runtime is a toolchain/runtime package, not a project-specific build system.
Consumer repositories decide when and how to use it.

## Sources of truth

Use:

```text
versions.env                runtime release and dependency pins
Dockerfile                  runtime implementation
scripts/                    runtime diagnostics and smoke tests
CHANGELOG.md                released history
published image tag         immutable runtime release
```

Do not duplicate changing version pins in documentation.

## Release discipline

Use the same release-management pattern as `docker.scad-toolchain`:

1. changes are reviewed and tested on a branch/PR;
2. current `main` publishes/tests `:edge`;
3. `.github/workflows/release.yml` creates an immutable `vX.Y.Z` tag for
   an exact already-verified commit;
4. `.github/workflows/build.yml` is authoritative for building/testing and
   publishing the tagged image;
5. the tagged image and GitHub Release are immutable;
6. downstream consumers move to the new release explicitly.

Never rebuild an existing release tag with changed contents.

## Runtime content

Stable libraries used on nearly every SolidCraft verification run may be
preinstalled for efficiency. Installing a released library in this runtime does
not transfer code ownership to this repository.

The initial runtime preserves the proven Forge runtime toolchain:
SolidCraft, CADCraft, released CAD verification library, PythonSCAD, pyBOSL2,
CadQuery, build123d and shared Python dependencies.

## Cache policy

Do not use GitHub Actions cache transport for Docker layer persistence:

- no `actions/cache`;
- no Buildx `type=gha` cache import/export.

The published image itself is the reusable runtime artifact.

## Consumer boundary

Consumer repositories should depend only on an immutable image tag, for example:

```text
ghcr.io/brainboxemb/cad-solidcraft:v0.1.0
```

Consumers must not copy this repository's Dockerfile, version pins or release
logic.
