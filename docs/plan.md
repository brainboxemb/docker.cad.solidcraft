# Repository plan

## Current state

Runtime v0.3.3 is released from main commit
`344cad2bffe7ee6133880b0941bdf131b01b7a71`.

Current role boundary:

- neither runtime embeds `lib.py.cad.verification`;
- `cad-solidcraft` is the lightweight SolidCraft role and contains
  SolidCraft 0.43.0;
- `cad-reference` contains PythonSCAD, pyBOSL2, CadQuery, build123d and
  CADCraft 0.20.1;
- consumers supply the exact verification package separately.

#17 is complete. The v0.3.3 SolidCraft-role smoke proves the exact 0.43.0 CLI
and replays a native Slot whose width is driven by a model parameter, covering
upstream SolidCraft issue #15857. Both role builds passed again on the exact
main commit before the immutable release was published.

## Current goal

There is no unfinished runtime implementation issue after v0.3.3.

The active dependency has moved to the consumer repository:

1. Forge #612 adopts
   `ghcr.io/brainboxemb/cad-solidcraft:v0.3.3` and
   `ghcr.io/brainboxemb/cad-reference:v0.3.3`;
2. Forge updates its tested SolidCraft target to 0.43.0;
3. Forge #355 reruns the native parametric Slot qualification against that
   immutable runtime.

Any new runtime work must start with a new owner-repository issue and must not
be inferred from consumer implementation changes.

## Required release invariants

Future runtime releases continue to require:

- one exact `versions.env` source of truth;
- both role images built and smoke-tested on PR;
- green main `:edge` from the exact release commit;
- immutable `vX.Y.Z` tag and matching role images;
- no `cad_verification` embedded in either role;
- no GitHub Actions cache transport for Docker layers;
- downstream consumers move to a new immutable release explicitly.

## Open issue assessment — 2026-11-21

No runtime implementation issues are open after #17.

Immediate external handoff:

`runtime v0.3.3 complete -> Forge #612 -> Forge #355 qualification`.
