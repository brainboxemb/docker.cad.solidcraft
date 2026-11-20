# Repository plan

## Current state

The initial SolidCraft CAD runtime release is complete.

- `docker.cad.solidcraft` owns the runtime Dockerfile, dependency pins,
  build/smoke tests and release management.
- `v0.1.0` is published as
  `ghcr.io/brainboxemb/cad-solidcraft:v0.1.0`.
- the immutable release was pulled back from GHCR and passed the runtime smoke
  test;
- `lib.py.solidcraft.forge` consumes `v0.1.0` as an external runtime and no
  longer owns runtime packaging/publication;
- Forge's complete model/reference CAD-CI graph is green against `v0.1.0`.

## Next runtime work

There is no active runtime change.

When the runtime itself needs to change:

1. create an issue describing the required runtime capability/change;
2. update `versions.env` and bump `RUNTIME_VERSION` using SemVer;
3. implement and prove the change through a pull request;
4. prove the resulting `:edge` image on `main`;
5. create the immutable `vX.Y.Z` release through the permanent release
   workflow;
6. update consumers deliberately to the new immutable release.

## Open issue assessment — 2026-11-20

| Issue | Status | Assessment |
| --- | --- | --- |
| #1 Establish released SolidCraft CAD runtime | effectively complete | v0.1.0 is released and Forge has migrated to it; close after this plan update. |
