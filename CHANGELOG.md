# Changelog

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
