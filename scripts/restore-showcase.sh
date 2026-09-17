#!/usr/bin/env bash
# Reset the showcases/oss-maintainer workspace positions and config to canonical state.
# Useful when RoleWeave Desktop or live agent testing modifies or dismisses positions.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "1. Cleaning local runtime artifacts from showcase..."
rm -rf showcases/oss-maintainer/.digital-employee \
       showcases/oss-maintainer/**/.workbench \
       showcases/oss-maintainer/.workbench

echo "2. Restoring git-tracked positions and configs in showcases/oss-maintainer..."
git checkout -- showcases/oss-maintainer/positions/ \
                showcases/oss-maintainer/organization.v1alpha1.json \
                showcases/oss-maintainer/workspace.json \
                showcases/oss-maintainer/context/

echo "3. Re-applying workspace organization..."
npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
  digital-employee org apply showcases/oss-maintainer --json

echo "4. Verifying workspace organization tree..."
npx --yes --package @fullstack-ai-infra/digital-employee@0.6.0 -- \
  digital-employee org tree showcases/oss-maintainer --json

echo "Showcase restored and verified successfully."
