# Repository plan

## Current state

The role-specific runtime split is released as v0.2.0 from exact green commit
`ea087a93ec02f62f35cae62ec8624486bef77926`.

Immutable v0.2.0 images:

- `ghcr.io/brainboxemb/cad-solidcraft:v0.2.0`;
- `ghcr.io/brainboxemb/cad-reference:v0.2.0`.

Forge production measurements now show that the remaining normal-PR bottleneck
is the SolidCraft runtime rather than verification work:

- clean image pull observed between 7.515 s and 13.307 s;
- container start to entry shell observed between 7.480 s and 8.079 s;
- actual in-runtime simple-box verification remains below 1 s.

The v0.2.0 Docker `common` stage still installs Pillow, trimesh, scipy and
matplotlib into both roles.

Released `lib.py.cad.verification` 0.10.1 at exact commit
`056b6075c606a3ab4a758f9438078e174f57fee9` now proves that the public
SolidCraft verification API does not eagerly import geometry or visual modules.

## Current goal

Complete #10 as runtime v0.3.0.

Make `cad-solidcraft` genuinely lightweight by keeping only:

- SolidCraft 0.42.0;
- lib.py.cad.verification 0.10.1;
- PyYAML;
- Pillow;
- required shared system libraries.

Keep trimesh/scipy/matplotlib and the independent CAD reference engines in
`cad-reference` only.

## Required proof

- both role images build and pass independent PR smoke tests;
- SolidCraft smoke proves trimesh/scipy/matplotlib are absent;
- SolidCraft public verification API imports without geometry/visual eager load;
- reference smoke retains the previous heavy/reference imports;
- main publishes and clean-pull tests both `:edge` images;
- record edge pull timing;
- release immutable v0.3.0 from the exact green main commit;
- record immutable v0.3.0 pull timing;
- only after release may Forge #484 adopt v0.3.0 and repeat the one-model
  end-to-end measurement.

## Execution order

1. Update role dependency design/requirements for #10.
2. Pin verification 0.10.1 and split Python dependencies by role.
3. Strengthen positive/negative smoke tests.
4. Merge only after both PR image builds are green.
5. Record main `:edge` clean-pull evidence.
6. Release v0.3.0 from the exact tested main commit.
7. Record immutable release clean-pull evidence.
8. Update Forge only after the runtime release is proven.

## Open issue assessment — 2026-11-20

| Issue | Status | Assessment |
| --- | --- | --- |
| #10 Remove geometry stack from the SolidCraft runtime role | now | Directly targets the measured Forge cold-path bottleneck while preserving the reference role. |

Immediate chain:

`#10 lean runtime -> v0.3.0 release timing -> Forge #484 measurement`.
