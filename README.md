# docker.cad.solidcraft

Reusable released Docker runtimes for CAD verification.

Starting with v0.2.0, one repository release publishes two immutable role
images:

```text
ghcr.io/brainboxemb/cad-solidcraft:<version>
ghcr.io/brainboxemb/cad-reference:<version>
```

`cad-solidcraft` is the lightweight SolidCraft model/visual verification
runtime. It deliberately excludes the trimesh/scipy/matplotlib geometry stack.
`cad-reference` contains that geometry stack together with the independent
PythonSCAD, pyBOSL2, CadQuery and build123d reference engines.

Both images use the same SemVer release tag. Current `main` may publish
`:edge` for pre-release validation.

The legacy monolithic `cad-solidcraft:v0.1.0` remains immutable and usable
while consumers migrate.

Version pins live in `versions.env`. See `docs/requirements.md`,
`docs/design.md` and `docs/plan.md`.
