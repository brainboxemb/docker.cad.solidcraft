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

No runtime migration is active.

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

## Open issue assessment — 2026-11-21

There is no active runtime implementation issue after completed #21.

Immediate consumer chain:

`runtime v0.3.4 -> Forge canonical 0.45 reference -> Forge version-sensitive qualification`.
