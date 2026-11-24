# Repository plan

## Current released state

Runtime **v0.3.4** is the latest immutable published runtime.

Exact release identity:

- repository commit:
  `89acce00bd760c523251c6c84d291d758c2a4dc5`;
- SolidCraft: `0.45.0`;
- upstream SolidCraft release commit:
  `e8ce12ef78fe76281a04b7242a9ce059ff7d5067`;
- immutable images:
  - `ghcr.io/brainboxemb/cad-solidcraft:v0.3.4`;
  - `ghcr.io/brainboxemb/cad-reference:v0.3.4`;
- tag Build run #37 / `44952726885`: success;
- GitHub Release `v0.3.4` published 2026-11-21 21:44:48Z.

Historical v0.3.3 / SolidCraft 0.43.0 remains immutable evidence but is not the
active runtime baseline.

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

### #26 — qualify SolidCraft 0.48.1 for Forge #753 / CAD #388

Status: **now / runtime blocker qualification**.

The current stable upstream release is SolidCraft **0.48.1**, exact release
commit `e5bc9288aab2f6f1d8661afc6d9702d75a6e171e`. Forge #753 now owns a
minimal retained reproducer for the HUB75 five-panel blocker: a reusable
component containing a native joined Cylinder, copied and rotated into two
occurrences.

Prepare runtime **v0.3.5** as the candidate immutable upgrade:

- pin exact SolidCraft 0.48.1;
- keep the existing two-role composition unchanged;
- retain all existing 0.45 owner-smoke contracts unless 0.48.1 proves a
  documented incompatibility;
- add a narrow owner smoke for the primitive/component-frame behavior that
  triggered the migration where it can be asserted without importing Forge;
- build and smoke both candidate role images in PR;
- externally run Forge #753 against the candidate SolidCraft image before
  release.

Upstream SolidCraft #21098 / PR #21145 is a strong related lead but is still
open and is **not** part of stable 0.48.1. Therefore a green 0.48.1 owner smoke
alone is not proof that CAD #388 is fixed. If the Forge reproducer remains
wrong on 0.48.1, record the exact runtime blocker instead of adding a consumer
workaround.

No v0.3.5 tag/image may be published until the owner smoke and external Forge
qualification are both accepted.

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
| #26 SolidCraft 0.48.1 / Forge component-Cylinder blocker | **now** | Build v0.3.5 candidate, run owner smoke, then qualify Forge #753 against the candidate image before release. |

Immediate consumer chain:

`runtime v0.3.4 / SolidCraft 0.45.0 -> v0.3.5 candidate / SolidCraft 0.48.1 -> Forge #753 external qualification -> immutable runtime release -> Forge adoption/release decision`.
