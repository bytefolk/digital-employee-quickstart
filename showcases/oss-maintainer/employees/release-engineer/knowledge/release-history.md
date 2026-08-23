# Release history

Fictional release history for **acme-toolkit**.

- `v2.2.0` — added configuration file reload.
- `v2.3.0` (current stable) — stable core CLI behavior; removed the deprecated
  `--no-color` flag (breaking for users still passing it); started JSON output
  stabilization work.
- `v2.4.0` (planned) — stable JSON output, Windows install improvements,
  deprecation of `--no-color` completed.
- `v3.0.0` (planned major) — breaking CLI migration, plugin extension point,
  migration guide.

## Known recurring risk

- Flag removals between minor versions caused user confusion in the `v2.2.x` to
  `v2.3.x` migration; migration notes must call these out.
