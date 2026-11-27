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

Issue #36 is the active runtime qualification: adopt upstream SolidCraft
**0.50.0** as the next immutable SolidCraft runtime while preserving the
released role boundaries.

Qualification target:

- candidate runtime version: **v0.3.8**;
- SolidCraft: exact stable **0.50.0**, upstream commit
  `eeb366c2ff276987a15c043d63b9072b58274703`;
- `cad-reference`: keep its current released engine/library pins unchanged;
- `cad-mitcad`: keep Mitcad **0.70.0** and its current role/base unchanged;
- retain every current runtime smoke and negative role-boundary check.

Forge #73 has already exercised the same contour-flange recess fixture on
SolidCraft 0.49.0 and 0.50.0. Both versions show the same engine behavior:
phased headless replay passes, while single-process and live replay reject the
broad-face cut until the contour-flange body is saved and reopened. Therefore
v0.50.0 must not be presented as fixing #73, and the runtime must not add a
save/reopen or model workaround for it.

Owner qualification is only the first gate. After a green v0.3.8 candidate is
on `main` / `:edge`, current normal Forge `dev` must qualify that exact
candidate, including its sheet-metal owners and the retained #73 known-behavior
evidence. Affected active CAD consumers must then qualify the candidate before
immutable publication.

Do not publish v0.3.8 or mutate v0.3.7 until those owner and consumer gates are
green.

## Later

- #26 remains historical/open investigation around the older 0.48.1
  component-Cylinder render history.
- New engine/runtime changes require their own issue and immutable runtime
  release; never mutate an existing release tag.
