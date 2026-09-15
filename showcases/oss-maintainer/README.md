# oss-maintainer showcase

oss-maintainer is a runnable digital-organization workspace for maintaining an
open-source project. It contains one owner and three read-only specialist
positions:

    repo-owner
    ├── issue-researcher
    ├── release-engineer
    └── community-operator

The showcase uses the canonical workspace layout consumed by the Digital
Employee CLI and RoleWeave:

    oss-maintainer/
    ├── workspace.json
    ├── organization.v1alpha1.json
    ├── context/
    └── positions/
        └── repo-owner/
            ├── employee.json
            ├── budget.json
            ├── knowledge/
            ├── schemas/
            ├── evals/
            ├── issue-researcher/
            ├── release-engineer/
            └── community-operator/

Each position is a portable employee-package.v1alpha1 package. The nested
directory structure is also the reporting structure: the three specialist
positions report to repo-owner.

## Position responsibilities

| Position | Responsibility | Boundary |
|----------|----------------|----------|
| repo-owner | Owns the roadmap, review decisions, and final release recommendations | Read-only; may recommend delegation but does not claim to execute it |
| issue-researcher | Groups issues, checks evidence, and produces research summaries | Read-only; does not make product decisions |
| release-engineer | Drafts release plans, checklists, and migration notes | Read-only; does not publish releases |
| community-operator | Turns community feedback into FAQ and announcement drafts | Read-only; does not publish content |

All positions use the conservative baseline of read_only, network deny, no MCP
tools, and no write access.

## Validate the workspace

The following checks require no credentials and do not call a model:

    npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
      digital-employee org tree showcases/oss-maintainer --json

    npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
      digital-employee org apply showcases/oss-maintainer --json

Validate and evaluate each position package:

    for package_dir in \
      showcases/oss-maintainer/positions/repo-owner \
      showcases/oss-maintainer/positions/repo-owner/issue-researcher \
      showcases/oss-maintainer/positions/repo-owner/release-engineer \
      showcases/oss-maintainer/positions/repo-owner/community-operator
    do
      npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
        digital-employee validate "$package_dir" --json
      npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
        digital-employee eval "$package_dir" --json
    done

validate checks package structure. eval checks the repository's offline
fixtures; neither proves that a model produced a correct answer. A real
one-shot run requires a separately configured, supported Agent Host and should
not be added as a mandatory CI dependency.

## Open in RoleWeave

In the desktop client, choose Open existing workspace and select the
showcases/oss-maintainer directory. Select the workspace directory itself,
not an individual employee.json file.

The desktop client owns local session history and Agent Host bindings. Those
runtime files are intentionally not part of this showcase and must not be
committed.

## Update a position

Keep each position package self-contained. When changing a position:

1. Update its SKILL.md, knowledge, schemas, and fixtures together.
2. Add or update normal, refusal, conflict, boundary, or structured-output
   fixtures as appropriate.
3. Run validate and eval for the changed position.
4. Run the workspace checks and the full showcase workflow before opening a PR.

Do not put credentials, private repository data, personal identifiers, local
absolute paths, generated indexes, or provider-specific secrets in the
showcase.

## Status

This showcase is a runnable workspace and remains intentionally limited to
read-only package validation, offline evaluation, organization inspection, and
organization apply. Interactive chat-at-position orchestration is outside this
repository's current scope.
