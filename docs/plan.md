# Repository plan

## Current released state

Runtime **v0.3.7** is the latest immutable published runtime.

Exact release identity:

- repository commit:
  `50ba1afae583c4f45c14dada8c00d88a45eab36f`;
- SolidCraft: `0.49.0`;
- Mitcad: `0.70.0`;
- annotated tag object:
  `0be191a09f1aef45143353336e8504240125dda9`;
- authoritative tag Build run:
  `45811771212` with all three runtime roles passing;
- immutable images:
  - `ghcr.io/brainboxemb/cad-solidcraft:v0.3.7`;
  - `ghcr.io/brainboxemb/cad-reference:v0.3.7`;
  - `ghcr.io/brainboxemb/cad-mitcad:v0.3.7`;
- GitHub Release `v0.3.7` published 2026-11-26 11:39:13Z.

The v0.3.7 release keeps the existing SolidCraft and reference role contents
and adds an isolated Mitcad role. Mitcad v0.70.0 uses its own pinned Ubuntu
24.04 base because the upstream AppImage requires a newer glibc/libstdc++ ABI
than the Bookworm base shared by the other roles.

Before publication, Forge `exp` PR #230 qualified the exact candidate manifest
through normal CAD-CI. `simple-box--scpf-mitcad:geometry` and
`circle-negative-extrude--scpf-mitcad:geometry` both passed; the evidence PR
was closed unmerged before the immutable tag was created.

Existing older runtime tags remain immutable evidence.

## Current role boundary

Released v0.3.7 contains:

- `cad-solidcraft`: lightweight SolidCraft role;
- `cad-reference`: PythonSCAD, pyBOSL2, CadQuery, build123d and CADCraft;
- `cad-mitcad`: pinned Mitcad AppImage plus its headless `mitcad-cli`
  wrapper;
- no role embeds `lib.py.cad.verification`.

The Mitcad role deliberately does not contain SolidCraft, CADCraft or the
reference-engine Python stack. Consumers supply their exact verification
package separately.

## Current work

There is no active runtime-composition change after v0.3.7. New runtime work
must start from a separate issue and qualify its owner and consumer boundaries
before an immutable release.

## Later

- #26 remains historical/open investigation around the older 0.48.1
  component-Cylinder render history.
- New engine/runtime changes require their own issue and immutable runtime
  release; never mutate an existing release tag.
