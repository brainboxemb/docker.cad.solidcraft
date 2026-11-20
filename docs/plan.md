# Repository plan

## Current state

The role-specific runtime split is released as v0.2.0 from exact green commit
`ea087a93ec02f62f35cae62ec8624486bef77926`.

Immutable images:

- `ghcr.io/brainboxemb/cad-solidcraft:v0.2.0`;
- `ghcr.io/brainboxemb/cad-reference:v0.2.0`.

Both role images passed independent release smoke tests.

Hosted-runner clean-pull evidence:

- SolidCraft role: 13.386 s on immutable v0.2.0; 9.974 s on the preceding
  `:edge` proof;
- reference role: 46.679 s on immutable v0.2.0; 23.073 s on the preceding
  `:edge` proof.

The lightweight SolidCraft role is therefore well below the previous
monolithic ~40-45 s pull and below the approximate <=20 s engineering target.
Reference-image pull variance no longer affects normal model verification.

Legacy `cad-solidcraft:v0.1.0` remains immutable and available.

## Current goal

Runtime repository work for #4 is complete.

The next proof belongs in `lib.py.solidcraft.forge`:

1. pin both immutable v0.2.0 role images explicitly;
2. return model verification scope to one active model: `simple-box`;
3. run one cold `simple-box` proof;
4. separate image acquisition, container/start and model verification timing;
5. only after that timing is understood may broader model migration resume.

## Open issue assessment — 2026-11-20

| Issue | Status | Assessment |
| --- | --- | --- |
| #6 Update runtime plan after v0.2.0 role-image release | effectively complete but still open | Close after this plan-only PR merges. |
| #4 Split the lightweight SolidCraft runtime from the heavy reference toolchain | effectively complete but still open | v0.2.0 is released and independently smoke-tested; close after post-release plan update. |
| #1 Establish released SolidCraft CAD runtime | effectively complete | v0.1.0 remains the immutable legacy release. |

## Next runtime work

No runtime implementation change is active.

A future runtime change starts with a new issue and must preserve role
separation unless measured consumer evidence justifies a deliberate boundary
change.
