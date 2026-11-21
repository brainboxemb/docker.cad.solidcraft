# Changelog

## v0.3.3

### Changed

- Upgrade SolidCraft from 0.42.0 to 0.43.0 in the `cad-solidcraft` role.
- Keep all independent reference-engine pins unchanged.
- Strengthen the SolidCraft smoke to require the exact pinned CLI version.
- Add a native parameter-driven Slot-width replay smoke for upstream
  SolidCraft issue #15857.

## v0.3.2

### Changed

- Add CADCraft 0.20.1 to the heavy `cad-reference` role.
- Pin and verify the CADCraft release archive SHA-256 during image build.
- Expose `cadcraft-cli` on PATH and report its exact runtime version.
- Keep `cad-solidcraft` unchanged and free of CADCraft.
- Preserve all existing SolidCraft, PythonSCAD, pyBOSL2, CadQuery and build123d
  versions from v0.3.1.


## v0.3.1

### Changed

- Remove `lib.py.cad.verification` from both runtime images.
- Remove verification version/commit metadata from the runtime release.
- Consumers now supply the exact released verification package separately at
  execution time.
- Require both role smoke tests to prove that `cad_verification` is absent.
- Preserve all SolidCraft and independent reference-engine versions from
  v0.3.0.

## v0.3.0

### Changed

- Pin released `lib.py.cad.verification` 0.10.1 with lazy optional public
  imports.
- Install the verification distribution with `--no-deps` and make runtime
  dependencies explicit per role.
- Remove trimesh, scipy and matplotlib from `cad-solidcraft`.
- Keep PyYAML and Pillow in `cad-solidcraft` for normal model/visual
  verification.
- Keep the existing geometry/matplotlib and independent reference stack in
  `cad-reference`.
- Strengthen the SolidCraft smoke test to prove the public SolidCraft API does
  not eagerly load geometry/visual modules and that the heavy geometry stack is
  absent.


## v0.2.0

### Changed

- Split the monolithic runtime into two role-specific immutable images.
- `cad-solidcraft` now contains only SolidCraft plus shared CAD verification
  dependencies needed by normal model/visual verification.
- Added `cad-reference` for PythonSCAD, pyBOSL2, CadQuery and build123d.
- Removed CADCraft from the v0.2.0 role images because no current consumer
  dependency requires it.
- Added independent positive/negative smoke tests for both runtime roles.
- Build/release CI now builds, publishes and clean-pull measures both role
  images under one SemVer release.

## v0.1.0

### Added

- Initial released SolidCraft CAD runtime moved out of
  `lib.py.solidcraft.forge`.
- SolidCraft 0.42.0 runtime.
- CADCraft and independent CAD reference tooling.
- Released `lib.py.cad.verfication` 0.10.0.
- PythonSCAD, pyBOSL2, CadQuery and isolated build123d support.
- Internal runtime diagnostics and smoke test.
- Permanent SemVer release management matching the
  `docker.scad-toolchain` release pattern.
