# docker.cad.solidcraft

Reusable released Docker runtimes for CAD verification.

Starting with v0.3.7, one repository release publishes three immutable role
images:

```text
ghcr.io/brainboxemb/cad-solidcraft:<version>
ghcr.io/brainboxemb/cad-reference:<version>
ghcr.io/brainboxemb/cad-mitcad:<version>
```

`cad-solidcraft` is the lightweight SolidCraft model/visual verification
runtime. It deliberately excludes the trimesh/scipy/matplotlib geometry stack.
`cad-reference` contains that geometry stack together with the independent
PythonSCAD, pyBOSL2, CadQuery, build123d and CADCraft reference engines.
`cad-mitcad` is an isolated native Mitcad runtime for explicitly selected
experimental consumers; it does not contain SolidCraft or the reference-engine
stack.

All images in one release use the same SemVer tag. Current `main` may publish
`:edge` for pre-release validation.

v0.2.0 through v0.3.6 remain immutable two-role releases. The legacy monolithic
`cad-solidcraft:v0.1.0` also remains immutable and usable.

Version pins live in `versions.env`. See `docs/requirements.md`,
`docs/design.md` and `docs/plan.md`.
