# Repository plan

## Current goal

Complete #1: establish the first released SolidCraft CAD runtime and migrate
runtime ownership out of `lib.py.solidcraft.forge`.

## Execution order

1. Establish release/version sources:
   - `versions.env` with `RUNTIME_VERSION=0.1.0`;
   - immutable image name `ghcr.io/brainboxemb/cad-solidcraft:v0.1.0`.
2. Move the currently proven Forge runtime Docker content into this repository.
3. Add runtime diagnostics and smoke tests.
4. Add build workflow:
   - PR: local build + smoke test;
   - main: publish/test `:edge`;
   - tag: publish/test immutable `vX.Y.Z`;
   - no GitHub Actions cache.
5. Add permanent release workflow matching `docker.scad-toolchain` release
   discipline.
6. Prove the PR build.
7. Merge to main and prove `:edge`.
8. Create/publish `v0.1.0`.
9. Update Forge to consume `ghcr.io/brainboxemb/cad-solidcraft:v0.1.0` and
   remove Forge-owned runtime packaging/build files.

## Open issue assessment — 2026-11-20

| Issue | Status | Assessment |
| --- | --- | --- |
| #1 Establish released SolidCraft CAD runtime | now | Initial repository/runtime/release setup and Forge ownership migration. |
