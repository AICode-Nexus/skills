#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./codex_snapshot_lib.sh
source "${SCRIPT_DIR}/codex_snapshot_lib.sh"

usage() {
  codex_print "Usage: ./scripts/codex_snapshot.sh <safe|full> <label>"
  codex_print "Example: ./scripts/codex_snapshot.sh safe work-oauth-before-switch"
}

[[ $# -eq 2 ]] || {
  usage
  codex_error "Expected exactly 2 arguments."
}

MODE="$1"
LABEL="$2"

codex_validate_mode "${MODE}"
codex_validate_label "${LABEL}"

CODEX_ROOT="$(codex_resolve_codex_root)"
BACKUP_ROOT="$(codex_resolve_backup_root)"
TIMESTAMP="$(codex_now_timestamp)"
CREATED_AT="$(codex_now_iso)"
SNAPSHOT_DIR="${BACKUP_ROOT}/${TIMESTAMP}-${MODE}-${LABEL}"
FILES_ROOT="${SNAPSHOT_DIR}/files"

codex_require_codex_root "${CODEX_ROOT}"
[[ ! -e "${SNAPSHOT_DIR}" ]] || codex_error "Snapshot directory already exists: ${SNAPSHOT_DIR}"

mkdir -p "${FILES_ROOT}"

REQUESTED_PATHS=()
while IFS= read -r line; do
  REQUESTED_PATHS+=("${line}")
done < <(codex_snapshot_included_paths "${MODE}")

EXCLUDED_PATHS=()
while IFS= read -r line; do
  EXCLUDED_PATHS+=("${line}")
done < <(codex_snapshot_excluded_paths)

INCLUDED_PATHS=()
MISSING_PATHS=()

for relative_path in "${REQUESTED_PATHS[@]}"; do
  if codex_copy_relative_path "${CODEX_ROOT}" "${relative_path}" "${FILES_ROOT}"; then
    INCLUDED_PATHS+=("${relative_path}")
  else
    MISSING_PATHS+=("${relative_path}")
  fi
done

MANIFEST_ARGS=(
  "${SNAPSHOT_DIR}/manifest.json"
  "${MODE}"
  "${LABEL}"
  "${CREATED_AT}"
  "${CODEX_ROOT}"
  "${SNAPSHOT_DIR}"
)

if [[ ${#INCLUDED_PATHS[@]} -gt 0 ]]; then
  MANIFEST_ARGS+=("${INCLUDED_PATHS[@]}")
fi

MANIFEST_ARGS+=(--missing)

if [[ ${#MISSING_PATHS[@]} -gt 0 ]]; then
  MANIFEST_ARGS+=("${MISSING_PATHS[@]}")
fi

MANIFEST_ARGS+=(--excluded)

if [[ ${#EXCLUDED_PATHS[@]} -gt 0 ]]; then
  MANIFEST_ARGS+=("${EXCLUDED_PATHS[@]}")
fi

codex_write_manifest "${MANIFEST_ARGS[@]}"

codex_write_checksums "${FILES_ROOT}" "${SNAPSHOT_DIR}/checksums.txt"

codex_print "Snapshot complete"
codex_print "Mode: ${MODE}"
codex_print "Label: ${LABEL}"
codex_print "Snapshot dir: ${SNAPSHOT_DIR}"
codex_print "Included paths: ${#INCLUDED_PATHS[@]}"
codex_print "Missing paths: ${#MISSING_PATHS[@]}"
if [[ "${MODE}" == "safe" ]]; then
  codex_print "Auth files included: no"
else
  codex_print "Auth files included: yes"
fi
codex_print "Environment-variable API keys were not captured"
codex_print "SNAPSHOT_DIR=${SNAPSHOT_DIR}"
