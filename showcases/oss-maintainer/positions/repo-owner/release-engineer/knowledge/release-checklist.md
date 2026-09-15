# Release checklist

The standard **acme-toolkit** release checklist (draft template).

1. Verify changelog covers all merged changes since the last release.
2. List breaking changes; write migration notes for each.
3. Run the full test suite; confirm zero known release-blocking regressions.
4. Confirm version number follows the versioning rules.
5. Draft the release tag and release notes (text only; do not push tags or publish).
6. Identify risk items from release history; flag anything recurring.

## Risk items to check every release

- JSON output schema stability across the minor boundary.
- Install path regressions (Windows PATH, native dependency downloads).
- Deprecated flags removed in this release confusing existing users.
