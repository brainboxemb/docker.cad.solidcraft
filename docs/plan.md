# Repository plan

## Current state

Runtime v0.3.2 is released from main commit
`7c0a2b38abeb2d8cb9cff45305c4299e24040267`.

Current role boundary:

- neither runtime embeds `lib.py.cad.verification`;
- `cad-solidcraft` is the lightweight SolidCraft role;
- `cad-reference` contains PythonSCAD, pyBOSL2, CadQuery, build123d and
  CADCraft 0.20.1;
- consumers supply the exact verification package separately.

The current released SolidCraft pin is 0.42.0.

Forge #355 exposed upstream SolidCraft issue #15857 against that released
runtime: a native Slot width supplied as an expression is rejected with
`width must be positive`, even though the symbolic value is positive.

Upstream SolidCraft v0.43.0 contains the #15857 fix and is the smallest stable
release inspected here that does so.

## Current goal

Complete #17 and release runtime v0.3.3:

- update only the SolidCraft engine pin from 0.42.0 to 0.43.0;
- keep all independent reference-engine pins unchanged;
- retain the existing role/image ownership boundary;
- add a smoke reproducing #15857 with a parameter-driven native Slot width;
- prove the exact SolidCraft CLI version;
- keep both role images free of `cad_verification`.

## Required proof

- `cad-solidcraft` reports SolidCraft 0.43.0;
- a script that adds `slot_w`, creates a native Slot with
  `"width":"slot_w"`, and finishes the sketch replays successfully;
- all existing SolidCraft-role negative dependency checks still pass;
- the reference role retains its existing engine versions and smoke tests;
- both PR role-image builds pass;
- main `:edge` build passes;
- immutable v0.3.3 is published from the exact green main commit.

## Execution order

1. Update plan/requirements/design for #17.
2. Bump runtime to 0.3.3 and SolidCraft to 0.43.0.
3. Add the exact-version and parameter-driven native Slot smoke.
4. Prove both role images in PR.
5. Merge and prove main `:edge`.
6. Release immutable v0.3.3.
7. Update Forge to consume the released runtime and rerun #355 qualification.

## Open issue assessment — 2026-11-21

| Issue | Status | Assessment |
| --- | --- | --- |
| #17 Upgrade cad-solidcraft runtime to SolidCraft 0.43.0 | now | Minimal owner-repository runtime update required by Forge #355; prove upstream #15857 is fixed in the released image. |

Immediate chain:

`#17 runtime 0.43.0 -> v0.3.3 -> Forge #355 consumes released runtime`.
