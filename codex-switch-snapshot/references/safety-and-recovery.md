# Safety and Recovery

## Default Rule

Use `safe` unless the user explicitly asks to preserve local auth files.

Prefer installing the shared local session pool once when the goal is long-term local continuity across account or API key switches.

## Shared Pool Boundary

The shared pool is for local continuity only.

Share:
- `session_index.jsonl`
- `sessions/`
- `archived_sessions/`
- optionally `history.jsonl`

Do not share:
- `auth.json`
- `config.toml`
- `.codex-global-state.json`
- sqlite state or log databases
- cache or temp directories

This keeps conversation storage continuous without mixing sensitive auth or volatile runtime state.

Local continuity does not remove cloud-side account boundaries. It only keeps the local conversation pool available on the same machine.

## `safe` vs `full`

`safe` is for:
- conversation and local state preservation
- account or OAuth switching
- lower-risk sharing of snapshot procedure

`full` is for:
- explicit local auth restoration needs
- API key based users who know `auth.json` and `config.toml` must come back too

`full` should be treated as sensitive because it can contain:
- API tokens
- local provider credentials
- configuration that reveals model or account routing details
- MCP credentials stored in local config

## What to Check Before Snapshot

1. Confirm whether the user wants only conversations back or also local auth state.
2. Confirm whether the user uses environment variables for API keys.
3. Remind the user that environment variables are outside this skill's scope.
4. If they want to avoid repeated snapshots for routine switching, suggest shared-pool install.

## What to Check After Snapshot

1. Confirm the snapshot directory exists.
2. Confirm `manifest.json` exists.
3. Confirm the user understands whether auth files were excluded or included.

## What to Check Before Restore

1. Confirm the user picked the right snapshot.
2. Prefer `--mode safe` when the user only wants old conversations visible again.
3. Warn before `--mode full` that local auth files may overwrite current configuration.

## What to Check After Restore

1. Confirm a `pre-restore` snapshot was created.
2. Confirm expected conversation files reappeared.
3. Confirm auth files were only changed when the restore mode required it.
4. Remind the user that cloud-side account isolation still applies.
