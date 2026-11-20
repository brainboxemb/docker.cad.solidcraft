# docker.cad.solidcraft

Reusable released Docker runtime for SolidCraft-based CAD verification.

The runtime is published as:

```text
ghcr.io/brainboxemb/cad-solidcraft:<version>
```

Normal consumers use immutable SemVer tags such as `v0.1.0`. Current
`main` may publish `:edge` for pre-release validation.

Version pins live in `versions.env`. Release management follows the same
permanent tag/build separation used by `docker.scad-toolchain`.

See `docs/requirements.md`, `docs/design.md` and `docs/plan.md`.
