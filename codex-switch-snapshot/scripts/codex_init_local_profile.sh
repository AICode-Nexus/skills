#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./codex_snapshot_lib.sh
source "${SCRIPT_DIR}/codex_snapshot_lib.sh"

PROFILE_ROOT="$(codex_local_profile_root)"
PROFILE_FILE="$(codex_local_profile_file)"

mkdir -p "${PROFILE_ROOT}/profiles"

if [[ -f "${PROFILE_FILE}" ]]; then
  codex_print "Local profile already exists"
  codex_print "Profile file: ${PROFILE_FILE}"
  exit 0
fi

cat > "${PROFILE_FILE}" <<'EOF'
# Local-only profile for codex-switch-snapshot.
# Keep this file private. It is meant for personal machine preferences.

CODEX_SWITCH_SNAPSHOT_DEFAULT_MODE=safe
CODEX_SWITCH_SHARED_POOL_ROOT="$HOME/.codex-shared/session-pool"
CODEX_SWITCH_SHARE_HISTORY=1

# Add your own local labels or notes below if useful.
# Example:
# CODEX_SWITCH_PERSONAL_LABEL=work-oauth
EOF

codex_print "Local profile created"
codex_print "Profile file: ${PROFILE_FILE}"
