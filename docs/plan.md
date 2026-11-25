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
- GitHub Release `v0.3.5` published 2026-11-24 09:40:32Z.

Historical v0.3.4 / SolidCraft 0.45.0 remains immutable evidence but is not the
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

## Qualified SolidCraft 0.48.1 contracts

Owner-repository qualification proves the exact released binary for the
contracts this runtime owns, including:

- exact `solidcraft-cli 0.48.1`;
- complete command-registry access;
- parameter-driven native Slot width;
- dimensioned straight-Slot length;
- numeric direct-point boundary;
- reusable component / joined-Cylinder placement regression;
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

## Current work

### #29 — qualify SolidCraft 0.49.0 before the first canonical migrated Forge release

Status: **now / deliberate current-stable runtime upgrade**.

Upstream SolidCraft **0.49.0** was published on 2026-11-25. Exact release
commit: `10e6242c3a94e942c8fc11e78965ef1cd21e4856`.

The upgrade is deliberate rather than bug-minimum-only. 0.49.0 includes
performance improvements relevant to Forge/CAD consumers, including faster large
sketch solving and parameter changes, faster opening of large designs, and less
unnecessary recomputation of unaffected later features.

Prepare runtime **v0.3.6** as the candidate immutable release:

- pin exact SolidCraft 0.49.0;
- keep the existing two-role composition unchanged;
- retain every current v0.3.5 owner-smoke contract;
- verify the complete command registry expected by Forge;
- run the reusable component / joined-Cylinder regression;
- externally run Forge's retained #73 sheet regression;
- externally run Forge #74 associative Sketch-line fold qualification once that
  fixture is available;
- externally qualify the active Mounting Rail M8 / Simple MFT consumer;
- compare performance only where repeatable CI evidence exists; performance
  observations are useful evidence but not an unstable wall-clock release gate.

No new immutable runtime tag/image may be published until owner smoke and
external Forge/CAD qualification are both accepted.

A new runtime release starts only for one of these reasons:

1. a consumer exposes a reproducible engine/runtime defect;
2. a new upstream stable release is deliberately selected;
3. runtime composition or dependency ownership must change.

For such work:
- update this plan first;
- qualify in this owner repository;
- prove the exact merged main commit;
- publish a new immutable SemVer tag/image pair;
- never mutate v0.3.5;
- only then update consumers.

## Open issue assessment — 2026-11-25

| Issue | Status | Next action |
| --- | --- | --- |
| #29 SolidCraft 0.49.0 qualification | **now** | Build the next candidate runtime, retain all v0.3.5 owner smokes, then externally qualify Forge #73/#74 and the active CAD consumer before release. |

Immediate consumer chain:

`runtime v0.3.5 / SolidCraft 0.48.1 -> v0.3.6 candidate / SolidCraft 0.49.0 -> Forge #73/#74 qualification -> CAD consumer qualification -> immutable runtime release -> canonical Forge release`.
