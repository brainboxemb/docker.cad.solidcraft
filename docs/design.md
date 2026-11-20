# SolidCraft CAD runtime design

## Repository boundary

```text
docker.cad.solidcraft
  versions.env
  Dockerfile
  runtime smoke tests
  build/release workflows
  -> ghcr.io/brainboxemb/cad-solidcraft:vX.Y.Z

consumer repository
  -> selects one immutable vX.Y.Z image
  -> supplies its own source/model verification inputs
```

The runtime repository owns packaging. Consumers own project behavior.

## Version and release flow

```text
versions.env
  RUNTIME_VERSION=0.1.0
       |
       v
branch / PR
  build image locally
  smoke test
       |
       v
main
  publish/test :edge
       |
       v
release.yml
  validate requested v0.1.0 + exact verified commit
  create annotated v0.1.0 tag
  dispatch build.yml on v0.1.0
       |
       v
build.yml
  publish/test ghcr.io/brainboxemb/cad-solidcraft:v0.1.0
  create GitHub Release
```

The release version is explicit human-readable state. It is not derived from a
content hash or timestamp.

## Runtime composition

The initial image follows the proven Forge runtime composition:

```text
SolidCraft CAD runtime
  SolidCraft
  CADCraft
  released CAD verification library
  PythonSCAD
  pyBOSL2
  CadQuery
  build123d
  trimesh / matplotlib / Pillow / scipy / PyYAML
  required system libraries
```

Preinstallation is an execution-efficiency choice; library code ownership stays
with each library repository.

## Image tags

`:edge` is mutable and development-only.

`vX.Y.Z` is immutable and is the normal consumer contract.

Consumers should never derive a runtime tag from a Dockerfile hash or Git
commit automatically.

## CI architecture

```text
pull request
  -> build image locally
  -> smoke test
  -> no publish

main
  -> build image
  -> publish :edge
  -> smoke test

vX.Y.Z
  -> build image
  -> publish :vX.Y.Z
  -> smoke test
  -> create GitHub Release
```

No GitHub Actions cache transport is used.
