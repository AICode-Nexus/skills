#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./codex_snapshot_lib.sh
source "${SCRIPT_DIR}/codex_snapshot_lib.sh"

codex_load_local_profile

CODEX_ROOT="$(codex_resolve_codex_root)"
SHARED_ROOT="$(codex_resolve_shared_pool_root)"
codex_require_codex_root "${CODEX_ROOT}"

mkdir -p "${SHARED_ROOT}"

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

if [[ "${ALL_LINKED}" == "1" ]]; then
  codex_print "Shared pool already installed"
  codex_print "Shared root: ${SHARED_ROOT}"
  exit 0
fi

PRE_LABEL="pre-shared-pool-install-$(codex_now_timestamp)"
"${SCRIPT_DIR}/codex_snapshot.sh" safe "${PRE_LABEL}" >/dev/null

CONFLICT_ROOT="$(codex_shared_conflict_backup_root "${SHARED_ROOT}")"
LINKED_COUNT=0
MERGED_COUNT=0
BACKED_UP_COUNT=0

for relative_path in "${SHARED_PATHS[@]}"; do
  source_path="${CODEX_ROOT}/${relative_path}"
  target_path="${SHARED_ROOT}/${relative_path}"

  mkdir -p "$(dirname "${target_path}")"

  if codex_is_symlink_to "${source_path}" "${target_path}"; then
    continue
  fi

  if [[ ! -e "${target_path}" && ! -L "${target_path}" ]]; then
    if [[ -e "${source_path}" && ! -L "${source_path}" ]]; then
      mv "${source_path}" "${target_path}"
    else
      codex_ensure_empty_shared_target "${relative_path}" "${target_path}"
    fi
  else
    if [[ -d "${source_path}" && ! -L "${source_path}" ]]; then
      codex_copy_path_contents "${source_path}" "${target_path}"
      ((MERGED_COUNT+=1))
    elif [[ -f "${source_path}" && ! -L "${source_path}" ]]; then
      if ! cmp -s "${source_path}" "${target_path}"; then
        backup_path="${CONFLICT_ROOT}/${relative_path}"
        mkdir -p "$(dirname "${backup_path}")"
        cp -p "${source_path}" "${backup_path}"
        ((BACKED_UP_COUNT+=1))
      fi
    fi
  fi

  codex_remove_path "${source_path}"
  mkdir -p "$(dirname "${source_path}")"
  ln -s "${target_path}" "${source_path}"
  ((LINKED_COUNT+=1))
done

codex_print "Shared pool install complete"
codex_print "Shared root: ${SHARED_ROOT}"
codex_print "Linked paths: ${LINKED_COUNT}"
codex_print "Merged directories: ${MERGED_COUNT}"
codex_print "Backed up file conflicts: ${BACKED_UP_COUNT}"
if [[ "${BACKED_UP_COUNT}" -gt 0 ]]; then
  codex_print "Conflict backup root: ${CONFLICT_ROOT}"
fi
