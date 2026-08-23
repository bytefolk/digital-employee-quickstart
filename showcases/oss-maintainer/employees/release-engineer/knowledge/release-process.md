# Release process

Fictional release process for **acme-toolkit**.

- Monthly minor releases; quarterly major releases.
- Next minor: `v2.4.0` (in development): stable JSON output, Windows install
  improvements, deprecation of `--no-color`.
- Planned major: `v3.0.0` (next quarter): breaking CLI migration, plugin extension
  point, migration guide.

## Checkpoints before any release

1. Changelog reviewed and complete.
2. Breaking changes listed and covered by migration notes.
3. Release checklist fully verified.
4. No open release-blocking regression.

## Version suggestion rules

- Bugfix-only changes on a stable branch bump the patch.
- New backward-compatible features bump the minor.
- Breaking CLI or schema changes bump the major and require a migration guide.
