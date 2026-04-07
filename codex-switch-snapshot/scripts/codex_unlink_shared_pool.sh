#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./codex_snapshot_lib.sh
source "${SCRIPT_DIR}/codex_snapshot_lib.sh"

codex_load_local_profile

CODEX_ROOT="$(codex_resolve_codex_root)"
SHARED_ROOT="$(codex_resolve_shared_pool_root)"
codex_require_codex_root "${CODEX_ROOT}"

SHARED_PATHS=()
while IFS= read -r line; do
  SHARED_PATHS+=("${line}")
done < <(codex_shared_pool_paths)

PRE_LABEL="pre-shared-pool-unlink-$(codex_now_timestamp)"
"${SCRIPT_DIR}/codex_snapshot.sh" safe "${PRE_LABEL}" >/dev/null

UNLINKED_COUNT=0
SKIPPED_COUNT=0

for relative_path in "${SHARED_PATHS[@]}"; do
  source_path="${CODEX_ROOT}/${relative_path}"
  target_path="${SHARED_ROOT}/${relative_path}"

  if ! codex_is_symlink_to "${source_path}" "${target_path}"; then
    ((SKIPPED_COUNT+=1))
    continue
  fi

  rm -f "${source_path}"
  mkdir -p "$(dirname "${source_path}")"

  if [[ -e "${target_path}" ]]; then
    codex_copy_path_contents "${target_path}" "${source_path}"
  else
    codex_ensure_empty_shared_target "${relative_path}" "${source_path}"
  fi

  ((UNLINKED_COUNT+=1))
done

codex_print "Shared pool unlink complete"
codex_print "Shared root kept: ${SHARED_ROOT}"
codex_print "Unlinked paths: ${UNLINKED_COUNT}"
codex_print "Skipped paths: ${SKIPPED_COUNT}"
