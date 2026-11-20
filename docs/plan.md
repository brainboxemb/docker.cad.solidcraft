# Repository plan

## Current state

The runtime split is complete and released as v0.2.0.

Immutable role images:

- `ghcr.io/brainboxemb/cad-solidcraft:v0.2.0`;
- `ghcr.io/brainboxemb/cad-reference:v0.2.0`.

The legacy monolithic `cad-solidcraft:v0.1.0` remains immutable.

Validation completed on 2026-11-20:

- both role images passed PR build/smoke tests;
- both `:edge` images passed main publication/smoke tests;
- both v0.2.0 images passed immutable tag publication/smoke tests;
- clean hosted-runner pull evidence:
  - `cad-solidcraft:edge`: 9.974 s;
  - `cad-solidcraft:v0.2.0`: 13.386 s;
  - `cad-reference:edge`: 23.073 s;
  - `cad-reference:v0.2.0`: 46.679 s.

The SolidCraft role therefore meets the approximately <=20 s cold-pull
engineering target on both measured runs. Reference-image timing shows registry
variance but no longer affects normal model verification.

## Current goal

No runtime implementation change is active.

The next required proof belongs in the consumer:

1. Forge pins the two immutable v0.2.0 role images explicitly.
2. Forge returns to one-model `simple-box` staging.
3. Measure end-to-end cold and warm `simple-box` verification.
4. Only after that timing is understood may broader model migration resume.

## Open issue assessment — 2026-11-20

| Issue | Status | Assessment |
| --- | --- | --- |
| #7 Update runtime plan after v0.2.0 role-image release | effectively complete but still open | Close after this plan-only update merges. |
| #4 Split the lightweight SolidCraft runtime from the heavy reference toolchain | effectively complete | v0.2.0 is released and independently smoke-tested. |
| #1 Establish released SolidCraft CAD runtime | effectively complete | v0.1.0 remains the immutable legacy release. |
