# Repository plan

## Current released state

Runtime **v0.3.6** is the latest immutable published runtime.

Exact release identity:

- repository commit:
  `fa323fba8146d36e2598d08cb88b3a74e8c71761`;
- SolidCraft: `0.49.0`;
- annotated tag object:
  `ab9b9b025902d838af0e24e664ad3d7d31eeb320`;
- immutable images:
  - `ghcr.io/brainboxemb/cad-solidcraft:v0.3.6`;
  - `ghcr.io/brainboxemb/cad-reference:v0.3.6`;
- GitHub Release `v0.3.6` published 2026-11-25 09:04:31Z.

The v0.3.6 release retained the two-role composition and moved SolidCraft to
0.49.0 after owner, Forge and CAD consumer checks passed. Existing older
runtime tags remain immutable evidence.

## Current role boundary

Released v0.3.6 contains:

- `cad-solidcraft`: lightweight SolidCraft role;
- `cad-reference`: PythonSCAD, pyBOSL2, CadQuery, build123d and CADCraft;
- neither role embeds `lib.py.cad.verification`.

Consumers supply their exact verification package separately.

## Current work

### #32 — add isolated Mitcad v0.70.0 runtime role

Status: **now / experimental consumer runtime extension**.

Forge `exp` has already proved an isolated native Mitcad backend and
`builder-scpf-mitcad`. The remaining owner-runtime boundary is an immutable
runtime image that exposes the exact already-tested CLI without making Forge
download an AppImage during model builds.

Prepare runtime **v0.3.7** as the candidate release:

- keep the existing `cad-solidcraft` and `cad-reference` contents unchanged;
- add a third `cad-mitcad` image;
- pin Mitcad `v0.70.0`, upstream commit
  `806a4210126ab977ba678708dd476496ddbd2968`;
- pin `Mitcad-0.70.0-x86_64.AppImage` SHA-256
  `9e1e8919a0ccd8f48bba4b3d443c70fb92f44d6104357fc00c25bf4c18379551`;
- expose `mitcad-cli` on `PATH` through the accepted headless wrapper;
- run an owner smoke that checks the exact CLI version and MCP command-reference
  resource without importing Forge;
- prove the Mitcad role does not contain SolidCraft, CADCraft,
  `cad_verification` or the reference-engine Python stack;
- after owner PR and `:edge` builds pass, run Forge `exp` against the exact
  candidate image before publishing v0.3.7.

Do not publish an immutable v0.3.7 tag until the Forge consumer check is green.

## Later

- #26 remains historical/open investigation around the older 0.48.1
  component-Cylinder render history. Do not fold that work into #32.
- New engine/runtime changes require their own issue and immutable runtime
  release; never mutate an existing release tag.
