# Repository plan

## Current state

Runtime v0.3.3 is the latest immutable published runtime and was released from
main commit `344cad2bffe7ee6133880b0941bdf131b01b7a71`.

That historical release contains SolidCraft 0.43.0. It remains immutable, but
0.43.0 is no longer an active design or qualification target for new work.

Current role boundary remains unchanged:

- neither runtime embeds `lib.py.cad.verification`;
- `cad-solidcraft` is the lightweight SolidCraft role;
- `cad-reference` contains PythonSCAD, pyBOSL2, CadQuery, build123d and
  CADCraft 0.20.1;
- consumers supply the exact verification package separately.

## Current goal

Issue #21 is **now / P1**.

Qualify the current upstream stable SolidCraft release, **0.45.0**, and publish a
new immutable runtime only after the released binary passes the owner-repository
smokes.

Pinned upstream source identity:

- release: `v0.45.0`;
- release commit: `e8ce12ef78fe76281a04b7242a9ce059ff7d5067`;
- published: 2026-11-19;
- Linux x86_64 archive SHA-256:
  `78170f546e1442db9d14637a4b8a8e6b39b543009d3d3d857cbd65f09afa37f8`.

Pinned 0.45.0 source confirms the Forge-relevant Slot contracts:

- native Slot `width` accepts a number or expression;
- straight Slot authored points remain numeric `PlainPoint` values;
- `sketch.draw.dimensioned` exposes `length` and `width` roles for the
  three straight Slot creators.

Those source facts are not sufficient on their own. The runtime PR must prove
the exact 0.45.0 binary and replay the parameter-driven native Slot-width
regression before any consumer adopts the new runtime.

## Version-selection policy

For a deliberate CAD-engine upgrade, qualify the **current stable upstream
release** unless a concrete, reproducible incompatibility requires an older
release.

Selecting the first release that contains one required fix is not by itself a
reason to remain behind current stable. Any deliberate older pin must document
and test the incompatibility that prevents current stable adoption.

## Known upstream 0.45 risk

Upstream `tangency-labs/solidcraft#18848` reports a regression introduced after
0.43.0 and still present in 0.45.0 final: one specific Autodesk Inventor STEP
import followed by a thin join extrusion fails a kernel coincident-edge check.
The reporter cannot publish the source STEP, so the owner repository cannot add
that exact case to its deterministic smoke suite.

This is **not** evidence that the Forge-required Slot contracts fail on 0.45.0:
the official 0.45.0 binary passes the exact-version, command-registry,
parameter-driven Slot-width, dimensioned straight-Slot-length and numeric
direct-point boundary smokes in PR #22.

It is nevertheless an explicit upstream limitation of the candidate runtime.
Before release, treat 0.45.0 as qualified for the contracts actually covered by
the owner smoke, not as a claim that every SolidCraft workflow is regression
free. Current Forge does not use STEP import as a model-authoring input path;
if that becomes a required runtime contract, add a reproducible public case or
hold the affected feature behind a separately qualified engine version.

## Required release invariants

The next runtime release must:

- use one exact `versions.env` source of truth;
- bump the immutable runtime SemVer; never mutate v0.3.3;
- pin SolidCraft 0.45.0;
- build and smoke-test both role images in PR;
- require `solidcraft-cli --version` to report exactly the pinned version;
- replay the parameter-driven native Slot-width smoke for upstream #15857;
- preserve all role-boundary negative checks;
- prove green main `:edge` from the exact merged commit;
- publish the immutable tag and role images from that exact green commit;
- leave `cad_verification` outside both images.

## Open issue assessment — 2026-11-21

| Issue | Status | Assessment |
| --- | --- | --- |
| #21 Qualify SolidCraft 0.45.0 as the current runtime baseline | **now / P1** | Replace the superseded 0.43 active baseline with current stable 0.45.0, prove the binary runtime and release a new immutable runtime before Forge continues version-specific qualification. |

Immediate chain:

`#21 qualify 0.45.0 -> new immutable runtime -> Forge canonical 0.45 reference -> Forge #355 qualification`.

Forge must not derive a 0.45 contract from the discarded hand-authored 0.43
reference material.
