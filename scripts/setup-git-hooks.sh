#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
hooks_dir="${repo_root}/.githooks"

echo "Setting Git hooks path to: ${hooks_dir}"
git config core.hooksPath "${hooks_dir}"

echo "Making hooks executable..."
chmod +x "${hooks_dir}"/* || true

cat <<'EOF'
Git hooks configured.

Hooks installed:
- pre-commit: Runs Semgrep on staged files and blocks on findings.
- pre-push:   Runs TruffleHog on the push range and blocks on findings.

Skip temporarily by prefixing commands with SKIP_SECURITY_HOOKS=1 (not recommended).
EOF

