# Repository plan

## Current state

Runtime v0.3.0 is released but still embeds `lib.py.cad.verification`.
That couples verification-library changes to Docker releases and is the wrong
ownership boundary.

Forge already source-mounts model-local verification definitions. Its CAD-CI
dependency graph can likewise supply a separately built verification wheel.

## Current goal

Complete #12 and release runtime v0.3.1 with the corrected boundary:

- remove `cad_verification` from both runtime images;
- remove verification version/commit metadata from `versions.env`;
- keep all CAD engine versions and the v0.3.0 role split unchanged;
- smoke-test that `cad_verification` is absent;
- publish immutable v0.3.1.

## Required proof

- neither role contains the verification distribution/module;
- SolidCraft 0.42.0 and all reference-engine pins remain unchanged;
- SolidCraft keeps PyYAML/Pillow and excludes heavy geometry/reference modules;
- reference keeps the existing engine/geometry stack;
- both PR role-image smoke tests pass;
- main `:edge` build passes;
- immutable v0.3.1 is published from the exact green main commit;
- consumer integration is proven separately with a mounted released
  verification wheel.

## Execution order

1. Remove verification package/pins from runtime images and docs.
2. Prove both role boundaries in PR smoke tests.
3. Merge and prove main `:edge`.
4. Release immutable v0.3.1.
5. Update Forge to supply the verification wheel as a CAD-CI dependency.
6. Resume Forge #537 batch 1.

## Open issue assessment — 2026-11-20

| Issue | Status | Assessment |
| --- | --- | --- |
| #12 Remove verification library from runtime images and release v0.3.1 | now | Correct the package/runtime ownership boundary before Forge batch 1. |

Immediate chain:

`#12 runtime boundary -> Forge verification-wheel dependency -> #537 batch 1`.
