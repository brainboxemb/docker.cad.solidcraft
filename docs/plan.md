# Repository plan

## Current state

Runtime v0.3.1 is released with the corrected package/runtime ownership
boundary:

- neither runtime embeds `lib.py.cad.verification`;
- `cad-solidcraft` is the lightweight SolidCraft role;
- `cad-reference` contains the independent Python reference CAD stack.

Forge now uses CADCraft for verification/documentation evidence but still
downloads and manages the CADCraft binary itself. That crosses the runtime
ownership boundary: CADCraft is an independent/reference CAD engine and belongs
in the released reference image.

## Current goal

Complete #15 and release runtime v0.3.2:

- add CADCraft 0.20.1 to `cad-reference` only;
- pin its release archive SHA-256 in `versions.env`;
- expose `cadcraft-cli` on PATH and runtime metadata;
- smoke-test the exact CADCraft version;
- keep all existing engine/dependency versions unchanged;
- keep `cad-solidcraft` free of CADCraft.

## Required proof

- reference image runs `cadcraft-cli --version` and reports 0.20.1;
- reference image retains PythonSCAD, pyBOSL2, CadQuery and build123d;
- SolidCraft image still has no CADCraft executable;
- neither image contains `cad_verification`;
- both PR role-image smoke tests pass;
- main `:edge` build passes;
- immutable v0.3.2 is published from the exact green main commit.

## Execution order

1. Add the CADCraft pin/checksum and reference-image installation.
2. Extend metadata and role smoke tests.
3. Prove both role images in PR.
4. Merge and prove main `:edge`.
5. Release immutable v0.3.2.
6. Update Forge to consume CADCraft from `cad-reference:v0.3.2` and remove
   Forge-owned CADCraft download/cache logic.

## Open issue assessment — 2026-11-20

| Issue | Status | Assessment |
| --- | --- | --- |
| #15 Add CADCraft to the reference runtime | now | Restore CADCraft to the heavy reference role so Forge no longer owns its binary lifecycle. |

Immediate chain:

`#15 reference runtime -> v0.3.2 -> Forge consumes released CADCraft`.
