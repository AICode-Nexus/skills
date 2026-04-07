#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./codex_snapshot_lib.sh
source "${SCRIPT_DIR}/codex_snapshot_lib.sh"

usage() {
  codex_print "Usage: ./scripts/codex_restore.sh <snapshot-dir> --mode <safe|full>"
  codex_print "Example: ./scripts/codex_restore.sh ~/.codex-backups/20260407-103500-safe-demo --mode safe"
}

[[ $# -eq 3 ]] || {
  usage
  codex_error "Expected exactly 3 arguments."
}

SNAPSHOT_DIR="$1"
MODE_FLAG="$2"
REQUESTED_MODE="$3"

[[ "${MODE_FLAG}" == "--mode" ]] || codex_error "The second argument must be --mode."
codex_validate_mode "${REQUESTED_MODE}"
[[ -d "${SNAPSHOT_DIR}" ]] || codex_error "Snapshot directory not found: ${SNAPSHOT_DIR}"
[[ -f "${SNAPSHOT_DIR}/manifest.json" ]] || codex_error "Snapshot is missing manifest.json: ${SNAPSHOT_DIR}"
[[ -d "${SNAPSHOT_DIR}/files" ]] || codex_error "Snapshot is missing files/: ${SNAPSHOT_DIR}"

SNAPSHOT_MODE="$(codex_manifest_value "${SNAPSHOT_DIR}/manifest.json" mode)"
[[ "${SNAPSHOT_MODE}" == "safe" || "${SNAPSHOT_MODE}" == "full" ]] || codex_error "Snapshot manifest has an invalid mode: ${SNAPSHOT_MODE}"

if [[ "${SNAPSHOT_MODE}" == "safe" && "${REQUESTED_MODE}" == "full" ]]; then
  codex_error "This snapshot was created in safe mode and cannot be restored with --mode full. Use --mode safe instead."
fi

CODEX_ROOT="$(codex_resolve_codex_root)"
mkdir -p "${CODEX_ROOT}"

PRE_RESTORE_LABEL="pre-restore-$(codex_now_timestamp)"
"${SCRIPT_DIR}/codex_snapshot.sh" safe "${PRE_RESTORE_LABEL}" >/dev/null

SAFE_PATHS=()
while IFS= read -r line; do
  SAFE_PATHS+=("${line}")
done < <(codex_snapshot_included_paths safe)
RESTORE_PATHS=("${SAFE_PATHS[@]}")

if [[ "${REQUESTED_MODE}" == "full" ]]; then
  RESTORE_PATHS+=("auth.json" "config.toml")
fi

RESTORED_PATHS=()
SKIPPED_PATHS=()

for relative_path in "${RESTORE_PATHS[@]}"; do
  source_path="${SNAPSHOT_DIR%/}/files/${relative_path}"
  target_path="${CODEX_ROOT%/}/${relative_path}"

  if [[ ! -e "${source_path}" ]]; then
    SKIPPED_PATHS+=("${relative_path}")
    continue
  fi

  codex_print "Restoring ${relative_path}"
  rm -rf "${target_path}"
  mkdir -p "$(dirname "${target_path}")"

  if [[ -d "${source_path}" ]]; then
    cp -R "${source_path}" "$(dirname "${target_path}")"
  else
    cp -p "${source_path}" "${target_path}"
  fi

  RESTORED_PATHS+=("${relative_path}")
done

codex_print "Restore complete"
codex_print "Requested mode: ${REQUESTED_MODE}"
codex_print "Snapshot mode: ${SNAPSHOT_MODE}"
codex_print "Snapshot dir: ${SNAPSHOT_DIR}"
codex_print "Pre-restore snapshot created: yes"
codex_print "Restored paths: ${#RESTORED_PATHS[@]}"
codex_print "Skipped paths: ${#SKIPPED_PATHS[@]}"
if [[ "${REQUESTED_MODE}" == "safe" ]]; then
  codex_print "Auth files restored: no"
else
  codex_print "Auth files restored: yes"
fi
codex_print "Environment-variable API keys were not changed"
