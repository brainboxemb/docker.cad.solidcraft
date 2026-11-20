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

One SemVer release publishes both role images.

```text
versions.env
  RUNTIME_VERSION=0.2.0
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
release v0.2.0
  validate one exact green commit
  create immutable repository tag
  build/publish/test:
    cad-solidcraft:v0.2.0
    cad-reference:v0.2.0
  create one GitHub Release listing both images
```

## Docker stage model

```text
python base
   |
   v
common
  system libraries common to verification
  released cad-verification
  PyYAML/Pillow/trimesh/scipy/matplotlib
   |
   +-----------------------+
   |                       |
   v                       v
solidcraft              reference
SolidCraft              PythonSCAD
                        pyBOSL2
                        CadQuery
                        build123d venv
```

The `solidcraft` target must never inherit the heavy reference engines.
The `reference` target must never inherit SolidCraft.

CADCraft is omitted from the v0.2.0 stage graph because no current consumer
dependency has been demonstrated.

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

The tests verify both presence and deliberate absence of role-inappropriate
tools. This prevents future Dockerfile refactors from silently re-bloating the
SolidCraft image.

## CI architecture

A two-entry build matrix is used:

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
each role package, then pull/run that exact published tag for smoke testing.

The workflow does not use GitHub Actions cache transport.

## Consumer migration

Forge first moves only the one-model `simple-box` proof:

- model verification -> `cad-solidcraft:v0.2.0`;
- independent reference verification -> `cad-reference:v0.2.0`.

Only after clean-pull and one-model timing are understood may the broader model
set resume.
