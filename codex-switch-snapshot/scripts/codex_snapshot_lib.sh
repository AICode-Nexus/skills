#!/usr/bin/env bash

set -euo pipefail

codex_print() {
  printf '%s\n' "$*"
}

codex_error() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

codex_validate_mode() {
  case "${1:-}" in
    safe|full) ;;
    *)
      codex_error "Mode must be safe or full. Example: ./scripts/codex_snapshot.sh safe work-oauth-before-switch"
      ;;
  esac
}

codex_validate_label() {
  local label="${1:-}"
  [[ -n "${label}" ]] || codex_error "Label cannot be empty. Use a short identifier such as work-oauth-before-switch."
  [[ "${label}" =~ ^[A-Za-z0-9._-]+$ ]] || codex_error "Label may contain only letters, numbers, dots, underscores, and hyphens."
}

codex_now_timestamp() {
  date '+%Y%m%d-%H%M%S'
}

codex_now_iso() {
  date -u '+%Y-%m-%dT%H:%M:%SZ'
}

codex_resolve_codex_root() {
  if [[ -n "${CODEX_HOME:-}" ]]; then
    printf '%s\n' "${CODEX_HOME%/}"
  else
    printf '%s\n' "${HOME%/}/.codex"
  fi
}

codex_resolve_backup_root() {
  printf '%s\n' "${HOME%/}/.codex-backups"
}

codex_local_profile_root() {
  printf '%s\n' "${HOME%/}/.codex-switch-snapshot"
}

codex_local_profile_file() {
  printf '%s\n' "$(codex_local_profile_root)/profiles/default.env"
}

codex_load_local_profile() {
  local profile_file
  profile_file="$(codex_local_profile_file)"

  if [[ -f "${profile_file}" ]]; then
    set -a
    # shellcheck source=/dev/null
    source "${profile_file}"
    set +a
  fi

  : "${CODEX_SWITCH_SNAPSHOT_DEFAULT_MODE:=safe}"
  : "${CODEX_SWITCH_SHARED_POOL_ROOT:=${HOME%/}/.codex-shared/session-pool}"
  : "${CODEX_SWITCH_SHARE_HISTORY:=1}"
}

codex_resolve_shared_pool_root() {
  codex_load_local_profile
  printf '%s\n' "${CODEX_SWITCH_SHARED_POOL_ROOT%/}"
}

codex_require_codex_root() {
  local codex_root="$1"
  [[ -d "${codex_root}" ]] || codex_error "Codex local state directory not found: ${codex_root}. Confirm that this machine already has a .codex state directory."
}

codex_json_string() {
  python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$1"
}

codex_json_array() {
  local first=1
  local item
  printf '['
  for item in "$@"; do
    if [[ "${first}" -eq 0 ]]; then
      printf ', '
    fi
    codex_json_string "${item}"
    first=0
  done
  printf ']'
}

codex_snapshot_included_paths() {
  local mode="$1"
  local safe_paths=(
    "session_index.jsonl"
    "history.jsonl"
    ".codex-global-state.json"
    "sessions"
    "archived_sessions"
    "memories"
    "rules"
    "automations"
  )
  local full_extra_paths=(
    "auth.json"
    "config.toml"
  )

  printf '%s\n' "${safe_paths[@]}"
  if [[ "${mode}" == "full" ]]; then
    printf '%s\n' "${full_extra_paths[@]}"
  fi
}

codex_snapshot_excluded_paths() {
  printf '%s\n' \
    "auth.json" \
    "config.toml" \
    "state_*.sqlite" \
    "logs_*.sqlite" \
    "*-wal" \
    "*-shm" \
    "cache/" \
    "tmp/" \
    "shell_snapshots/" \
    "environment variables (.zshrc/.bashrc/.env)"
}

codex_shared_pool_paths() {
  codex_load_local_profile

  printf '%s\n' \
    "session_index.jsonl" \
    "sessions" \
    "archived_sessions"

  if [[ "${CODEX_SWITCH_SHARE_HISTORY}" == "1" ]]; then
    printf '%s\n' "history.jsonl"
  fi
}

codex_is_directory_style_path() {
  case "$1" in
    sessions|archived_sessions|memories|rules|automations)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

codex_copy_relative_path() {
  local source_root="$1"
  local relative_path="$2"
  local files_root="$3"
  local source_path="${source_root%/}/${relative_path}"
  local target_path="${files_root%/}/${relative_path}"

  if [[ -d "${source_path}" ]]; then
    mkdir -p "$(dirname "${target_path}")"
    cp -R "${source_path}" "$(dirname "${target_path}")"
    return 0
  fi

  if [[ -f "${source_path}" ]]; then
    mkdir -p "$(dirname "${target_path}")"
    cp -p "${source_path}" "${target_path}"
    return 0
  fi

  return 1
}

codex_write_checksums() {
  local files_root="$1"
  local output_file="$2"

  python3 - "$files_root" "$output_file" <<'PY'
import hashlib
import pathlib
import sys

files_root = pathlib.Path(sys.argv[1])
output_file = pathlib.Path(sys.argv[2])

rows = []
if files_root.exists():
    for path in sorted(p for p in files_root.rglob("*") if p.is_file()):
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        rows.append(f"{digest}  {path.relative_to(files_root)}")

output_file.write_text("\n".join(rows) + ("\n" if rows else ""), encoding="utf-8")
PY
}

codex_write_manifest() {
  local manifest_file="$1"
  local mode="$2"
  local label="$3"
  local created_at="$4"
  local codex_root="$5"
  local snapshot_dir="$6"
  shift 6
  local included=()
  local missing=()
  local excluded=()
  local section="included"
  local item
  local included_json="[]"
  local missing_json="[]"
  local excluded_json="[]"

  for item in "$@"; do
    case "${item}" in
      --missing)
        section="missing"
        continue
        ;;
      --excluded)
        section="excluded"
        continue
        ;;
    esac

    case "${section}" in
      included) included+=("${item}") ;;
      missing) missing+=("${item}") ;;
      excluded) excluded+=("${item}") ;;
    esac
  done

  if [[ ${#included[@]} -gt 0 ]]; then
    included_json="$(codex_json_array "${included[@]}")"
  fi

  if [[ ${#missing[@]} -gt 0 ]]; then
    missing_json="$(codex_json_array "${missing[@]}")"
  fi

  if [[ ${#excluded[@]} -gt 0 ]]; then
    excluded_json="$(codex_json_array "${excluded[@]}")"
  fi

  cat > "${manifest_file}" <<EOF
{
  "mode": $(codex_json_string "${mode}"),
  "label": $(codex_json_string "${label}"),
  "created_at": $(codex_json_string "${created_at}"),
  "codex_root": $(codex_json_string "${codex_root}"),
  "snapshot_dir": $(codex_json_string "${snapshot_dir}"),
  "included_paths": ${included_json},
  "missing_paths": ${missing_json},
  "excluded_paths": ${excluded_json}
}
EOF
}

codex_manifest_value() {
  local manifest_file="$1"
  local key="$2"
  python3 -c 'import json,sys; print(json.load(open(sys.argv[1], encoding="utf-8"))[sys.argv[2]])' "${manifest_file}" "${key}"
}

codex_readlink_target() {
  python3 -c 'import os,sys; print(os.readlink(sys.argv[1]))' "$1"
}

codex_is_symlink_to() {
  local path="$1"
  local expected_target="$2"
  [[ -L "${path}" ]] || return 1
  [[ "$(codex_readlink_target "${path}")" == "${expected_target}" ]]
}

codex_remove_path() {
  local path="$1"
  if [[ -L "${path}" || -f "${path}" ]]; then
    rm -f "${path}"
  elif [[ -d "${path}" ]]; then
    rm -rf "${path}"
  fi
}

codex_copy_path_contents() {
  local source_path="$1"
  local target_path="$2"

  mkdir -p "$(dirname "${target_path}")"

  if [[ -d "${source_path}" ]]; then
    mkdir -p "${target_path}"
    cp -R "${source_path}/." "${target_path}/"
  else
    cp -p "${source_path}" "${target_path}"
  fi
}

codex_ensure_empty_shared_target() {
  local relative_path="$1"
  local target_path="$2"

  mkdir -p "$(dirname "${target_path}")"

  if codex_is_directory_style_path "${relative_path}"; then
    mkdir -p "${target_path}"
  else
    : > "${target_path}"
  fi
}

codex_shared_conflict_backup_root() {
  local shared_root="$1"
  printf '%s\n' "${shared_root%/}/_relinked-conflicts/$(codex_now_timestamp)"
}
