# Repository plan

## Current state

The initial monolithic runtime release remains available and immutable:

- `ghcr.io/brainboxemb/cad-solidcraft:v0.1.0`;
- Forge currently consumes that release;
- clean hosted-runner pulls are about 40-45 seconds because the image also
  carries independent reference engines that normal SolidCraft model
  verification does not use.

## Current goal

Complete #4 by releasing role-specific v0.2.0 runtime images:

- `ghcr.io/brainboxemb/cad-solidcraft:v0.2.0` — lightweight SolidCraft
  model/visual verification runtime;
- `ghcr.io/brainboxemb/cad-reference:v0.2.0` — independent reference engines
  for PythonSCAD, pyBOSL2, CadQuery and build123d.

Both images come from one repository release and one `RUNTIME_VERSION`.

CADCraft is not included in either v0.2.0 role unless a concrete consumer
dependency is demonstrated. No current Forge or CAD-verification code path
references it.

## Required proof

1. shared base contains only dependencies genuinely common to both roles;
2. SolidCraft image contains SolidCraft plus released CAD verification support,
   but no PythonSCAD, pyBOSL2, CadQuery or build123d;
3. reference image contains the four independent reference engines and does not
   contain SolidCraft;
4. each role has its own smoke test;
5. PR builds test both roles without publishing;
6. main publishes and tests both `:edge` images;
7. one immutable v0.2.0 release publishes and tests both role images;
8. clean hosted-runner pull timing is recorded for each released role;
9. no GitHub Actions cache transport is introduced;
10. v0.1.0 remains unchanged and usable during consumer migration.

## Execution order

1. Update requirements/design for the two-role image contract.
2. Implement multi-stage Dockerfile and role-specific smoke tests.
3. Update build/release workflow for both packages.
4. Bump `RUNTIME_VERSION` to 0.2.0.
5. Prove both roles on a PR.
6. Merge and prove both `:edge` images on main.
7. Release immutable v0.2.0 from the exact green main commit.
8. Measure clean pulls.
9. Only then update Forge to the two immutable images and rerun one-model
   `simple-box` timing.

## Open issue assessment — 2026-11-20

| Issue | Status | Assessment |
| --- | --- | --- |
| #4 Split the lightweight SolidCraft runtime from the heavy reference toolchain | now | Required before further Forge model expansion; current monolithic image dominates cold one-model CI time. |
| #1 Establish released SolidCraft CAD runtime | effectively complete | v0.1.0 remains the immutable legacy release. |
