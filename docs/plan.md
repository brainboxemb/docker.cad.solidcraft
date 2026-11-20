# Repository plan

## Current state

Runtime v0.3.0 is released with the lean role split proven and immutable.

`lib.py.cad.verification` 0.11.0 is now released at exact commit
`9f2802816637d944c88815352ecadb72e78027f5`. Forge #432 batch 1 requires
that released API inside the immutable runtime.

## Current goal

Complete #12 and release runtime v0.3.1.

This is a dependency-pin patch release only:

- keep the v0.3.0 role composition unchanged;
- pin CAD verification 0.11.0 at the exact released commit;
- bump RUNTIME_VERSION to 0.3.1;
- run the existing independent role smoke tests;
- publish immutable v0.3.1 from the exact green main commit.

## Required proof

- cad-solidcraft and cad-reference both contain CAD verification 0.11.0;
- the existing positive/negative role smoke tests remain green;
- SolidCraft 0.42.0 and all reference-engine pins remain unchanged;
- dependency split remains unchanged;
- main :edge build is green;
- immutable v0.3.1 build/release is green;
- only after release may Forge adopt v0.3.1.

## Execution order

1. Update versions.env and changelog only.
2. Run both role-image PR smoke tests.
3. Merge and prove main :edge.
4. Create immutable v0.3.1 release request for the exact green main commit.
5. Verify tagged role-image build.
6. Resume Forge #432 batch 1.

## Open issue assessment — 2026-11-20

| Issue | Status | Assessment |
| --- | --- | --- |
| #12 Pin CAD verification 0.11.0 and release runtime v0.3.1 | now | Required immutable dependency update for Forge #432 batch 1. |

Immediate chain:

`#12 runtime v0.3.1 -> Forge #432 batch 1`.
