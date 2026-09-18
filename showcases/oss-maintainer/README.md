# oss-maintainer showcase

[简体中文](README.zh-CN.md)

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

`validate` checks package structure. `eval` checks the repository's offline
fixtures; neither proves that a model produced a correct answer. A real
one-shot run requires a separately configured, supported Agent Host and should
not be added as a mandatory CI dependency.

## Open in RoleWeave Desktop

### 1. Workspace isolation (Recommended)

RoleWeave Desktop treats opened workspaces as live, mutable state. In the UI,
recruiting positions adds directories, moving positions changes reporting lines,
and dismissing positions deletes directories. Furthermore, running sessions
creates `.digital-employee/` runtime audit and history records.

To prevent accidental modification or dismissal of files in your Git tracking,
copy the showcase out of the repository before opening it:

```bash
mkdir -p "$HOME/roleweave-workspaces"
cp -R showcases/oss-maintainer "$HOME/roleweave-workspaces/oss-maintainer"
```

### 2. Launching RoleWeave

Point RoleWeave to your copied workspace directory:

- **Desktop App**: Choose **Open existing workspace** and select the
  `$HOME/roleweave-workspaces/oss-maintainer` directory (select the workspace root,
  not an individual `employee.json`).
- **Development Shell**:
  ```bash
  ROLEWEAVE_DEFAULT_WORKSPACE=$HOME/roleweave-workspaces/oss-maintainer npm run dev:desktop
  ```

### 3. What you will see

- **Organization tree on the left**: `oss-maintainer` root with `repo-owner`,
  and under it `community-operator`, `issue-researcher`, `release-engineer`.
- **Position budget inspector**:
  - `repo-owner`: 40,000 tokens / 12 iterations per task; 400,000 tokens / 96 iterations per day.
  - Direct reports: 20,000 tokens / 8 iterations per task; 200,000 tokens / 64 iterations per day.
- **Permissions**: Read / Grep / Glob allowed; filesystem write denied.
- **Context sources**: Position knowledge base connected in read-only mode.

### 4. Running interactive chat (`@position`)

- Interactive chats with positions require a supported local Agent Host (such
  as Qoder CLI 1.1.x or Claude Code).
- The Qoder host requires `QODER_PERSONAL_ACCESS_TOKEN` set in your environment.
- Machine-specific engine and model choices are saved in local
  `.workbench/agent-binding.v1.json` files; these are gitignored and should
  not be committed across machines.
- Unified storage: Set `MEM_URL` or `ORG_WORKBENCH_MEM_URL` pointing to `memd`
  if connecting shared drive storage.

### 5. Control plane rules

1. **File tree is organization structure**: Adding a directory equals recruiting
   (requires `budget.json`). Moving a directory updates reporting lines (`reportTo`).
   Deleting a directory dismisses the position (backups recorded in `.digital-employee/backup/`).
2. **Digest reconciliation**: `organization.v1alpha1.json` stores the package
   digest for each position. If package files are modified, reconcile via:
   ```bash
   npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
     digital-employee org apply <workspace-dir> --json
   ```
3. **Restoring pristine showcase state**: If testing accidentally mutates
   the showcase inside this repository, restore it using:
   ```bash
   bash scripts/restore-showcase.sh
   ```

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
