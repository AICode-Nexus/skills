#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./codex_snapshot_lib.sh
source "${SCRIPT_DIR}/codex_snapshot_lib.sh"

codex_load_local_profile

CODEX_ROOT="$(codex_resolve_codex_root)"
SHARED_ROOT="$(codex_resolve_shared_pool_root)"

SHARED_PATHS=()
while IFS= read -r line; do
  SHARED_PATHS+=("${line}")
done < <(codex_shared_pool_paths)

ALL_LINKED=1
for relative_path in "${SHARED_PATHS[@]}"; do
  source_path="${CODEX_ROOT}/${relative_path}"
  target_path="${SHARED_ROOT}/${relative_path}"
  if ! codex_is_symlink_to "${source_path}" "${target_path}"; then
    ALL_LINKED=0
    break
  fi
done

codex_print "Shared pool installed: $([[ "${ALL_LINKED}" == "1" ]] && printf 'yes' || printf 'no')"
codex_print "Codex root: ${CODEX_ROOT}"
codex_print "Shared root: ${SHARED_ROOT}"
codex_print "Local profile: $(codex_local_profile_file)"
codex_print "History sharing: $([[ "${CODEX_SWITCH_SHARE_HISTORY}" == "1" ]] && printf 'enabled' || printf 'disabled')"

for relative_path in "${SHARED_PATHS[@]}"; do
  source_path="${CODEX_ROOT}/${relative_path}"
  target_path="${SHARED_ROOT}/${relative_path}"

  if codex_is_symlink_to "${source_path}" "${target_path}"; then
    codex_print "${relative_path}: linked -> ${target_path}"
  elif [[ -e "${source_path}" ]]; then
    codex_print "${relative_path}: local-only"
  else
    codex_print "${relative_path}: missing"
  fi
done
