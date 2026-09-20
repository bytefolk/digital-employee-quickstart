# ByteFolk open-source organization showcase

[简体中文](README.zh-CN.md)

This is a public-safe adaptation of ByteFolk's real open-source organization, not a fictional business snapshot. It demonstrates how an organization maintaining several open-source projects can be represented as addressable, inspectable, and offline-verifiable digital employees.

## Organization shape

```text
ByteFolk Owner (CEO)
├── RoleWeave team (1 lead + 6 specialists)
├── Digital Employee team (1 + 3)
├── Digital Employee Platform team (1 + 2)
├── Digital Employee Quickstart team (1 + 2)
├── Mem team (1 + 2)
├── Doc team (1 + 2)
└── Design System team (1 + 3)
```

There are 28 positions: one organization owner, seven project leads, and twenty specialist positions. Lead positions are `read_only`; specialist positions use `approval_required`, so writes and external actions still require approval.

## Public boundary

This directory contains only portable organization configuration, employee packages, role knowledge, and offline contracts:

- no credentials, personal account identifiers, or local absolute paths;
- no local Agent Host bindings such as `.workbench/agent-binding.v1.json`;
- no `.digital-employee/` audit state, conversation history, or `work/` output;
- no checked-out project repositories;
- offline `eval` verifies fixtures only and does not prove live model quality.

## Credential-free verification

Node.js 20 or newer is required. These commands pin the public `@fullstack-ai-infra/digital-employee@0.6.0` package and do not call a model:

```bash
npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
  digital-employee org tree showcases/bytefolk --json

find showcases/bytefolk/positions -name employee.json -print0 | while IFS= read -r -d '' manifest; do
  package_dir="$(dirname "$manifest")"
  npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
    digital-employee validate "$package_dir" --json
  npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
    digital-employee eval "$package_dir" --json
done
```

`org tree` should report 28 positions at depth 3. Every package should report `validate: valid` and `eval: passed`.

Because `org apply` rewrites package digests, run it only on an isolated copy:

```bash
mkdir -p "$HOME/roleweave-workspaces"
cp -R showcases/bytefolk "$HOME/roleweave-workspaces/bytefolk"
npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
  digital-employee org apply "$HOME/roleweave-workspaces/bytefolk" --json
```

## Opening in RoleWeave

Copy the showcase outside the repository first, then select `$HOME/roleweave-workspaces/bytefolk` in RoleWeave. The desktop treats a workspace as mutable state: hiring, moving or dismissing positions, and running conversations can change files. Do not operate directly on the Git-tracked source.

Live conversations additionally require a user-configured supported Agent Host. This showcase contains no credentials and deploys no messaging channel.
