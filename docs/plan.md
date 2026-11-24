# Repository plan

## Current released state

Runtime **v0.3.5** is the latest immutable published runtime.

Exact release identity:

- repository commit:
  `cb4295271173ac88deed92627c74456300c0393f`;
- SolidCraft: `0.48.1`;
- upstream SolidCraft release commit:
  `e5bc9288aab2f6f1d8661afc6d9702d75a6e171e`;
- immutable images:
  - `ghcr.io/brainboxemb/cad-solidcraft:v0.3.5`;
  - `ghcr.io/brainboxemb/cad-reference:v0.3.5`;
- authoritative tag build `45366783017`: success;
- GitHub Release `v0.3.5` published and immutable.

Historical v0.3.4 / SolidCraft 0.45.0 and v0.3.3 / SolidCraft 0.43.0 remain
immutable evidence but are not the active runtime baseline.

## Role boundary

The accepted role boundary remains unchanged:

- neither runtime embeds `lib.py.cad.verification`;
- `cad-solidcraft` is the lightweight SolidCraft role;
- `cad-reference` contains PythonSCAD, pyBOSL2, CadQuery, build123d and
  CADCraft 0.20.1;
- consumers supply the exact verification package separately.

Ordinary verification-library changes must not require rebuilding either runtime
image.

## Qualified SolidCraft 0.45 contracts

Owner-repository qualification proves the exact released binary for the
contracts this runtime owns, including:

- exact `solidcraft-cli 0.45.0`;
- complete command-registry access;
- parameter-driven native Slot width;
- dimensioned straight-Slot length;
- numeric direct-point boundary;
- both runtime-role smoke suites and negative role-boundary checks.

Forge may use this immutable release as runtime evidence but still owns its own
compiler/API/model qualification.

## Version-selection policy

For a deliberate CAD-engine upgrade, qualify the **current stable upstream
release** unless a concrete, reproducible incompatibility requires an older
release.

Selecting the first release containing one required fix is not by itself a
reason to remain behind current stable. Any deliberate older pin must document
and test the incompatibility that prevents current stable adoption.

## Known upstream 0.45 limitation

Upstream `tangency-labs/solidcraft#18848` reports a regression affecting one
specific Autodesk Inventor STEP import followed by a thin join extrusion. The
source STEP is not publicly reproducible, so this repository cannot make that
case part of its deterministic qualification.

This does not invalidate the runtime contracts above. It does mean v0.3.4 is a
qualified baseline for the behavior actually covered by the owner smoke, not a
claim that every SolidCraft workflow is regression-free.

If STEP-import authoring becomes a required consumer contract, add a reproducible
public case or qualify an appropriate engine release for that feature.

## Current work

### #26 — component-Cylinder render qualification

Status: **reopened / primary runtime blocker**.

The original v0.3.5 acceptance used a Box + one joined Cylinder and two
occurrences. That smoke passed on SolidCraft 0.48.1, but it was not equivalent
to the downstream HUB75 history.

Downstream consumer acceptance has now disproved the release claim:

- product CAD dev-cad source
  `5fcfe6836973e13b1d3372a151735af195f22a4d`;
- durable CAD run `45389479040`: success;
- exact generated build
  `d78a2d666eb7d7b1abfd2171e59fe8b309e51c6f`;
- Forge v0.14.0 + runtime v0.3.5 / SolidCraft 0.48.1;
- source-matched product render still contains detached joined-Cylinder tools.

Forge #753 now owns a larger retained reproducer with the relevant history:
taper/rear cut, 14 Cylinder joins, 24 Hole features and five copied/rotated
occurrences. PR #832 merged that fixture to Forge dev-cad as
`89e04abd40930aef48d6519e69e2672f6bc4d88f`; durable run
`45391583228` succeeded, and build `0acc9b15beb9e54b9f665917c6017c00123e627f`
publishes preview blob `140ae01a4397f751273bde4010d0084e7aaf4131`
showing the same detached cylinders.

Runtime work now is:

- replace the insufficient two-island smoke with the proven multi-feature
  replay shape while keeping runtime independent of Forge;
- render transparently and make detached render islands a hard failing owner
  contract;
- minimize the feature sequence after the failure is reproduced;
- determine whether current SolidCraft 0.48.1 can be fixed/configured or a
  newer upstream build is required;
- publish a new immutable runtime only after the expanded owner regression and
  external Forge/product acceptance are green.

Do not mutate v0.3.5 and do not introduce a Forge/product geometry workaround.

A new runtime release starts only for one of these reasons:

1. a consumer exposes a reproducible engine/runtime defect;
2. a new upstream stable release is deliberately selected;
3. runtime composition or dependency ownership must change.

For such work:
- update this plan first;
- qualify in this owner repository;
- prove the exact merged main commit;
- publish a new immutable SemVer tag/image pair;
- never mutate v0.3.4;
- only then update consumers.

## Open issue assessment — 2026-11-24

| Issue | Status | Next action |
| --- | --- | --- |
| #26 SolidCraft 0.48.1 / Forge component-Cylinder blocker | **reopened / now** | Replace the insufficient minimal render smoke with the proven HUB75-history reproducer, then minimize and fix the owner-layer defect. |

Immediate consumer chain:

`runtime v0.3.5 / SolidCraft 0.48.1 -> expanded #753 owner render regression -> minimal failing sequence -> owner fix/new immutable runtime -> Forge/product requalification`.
