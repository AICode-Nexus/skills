---
name: codex-switch-snapshot
description: Use when Codex users want local continuity across account switches, OAuth changes, API key swaps, or mixed authentication setups. Use this skill to keep `~/.codex` conversations in a shared local pool, create or restore local snapshots, inspect whether shared links are installed, or initialize a private local profile without trying to merge cloud history.
---

# Codex Switch Snapshot

## Overview

Use this skill to keep local Codex conversations continuous across account or API key changes by sharing only the local conversation pool, while leaving auth and runtime state local.

Prefer installing the shared local session pool once, then use snapshots as the safety net before risky local changes or before restoring local state.

## Quick Start

1. Initialize the local-only profile once.
```bash
./scripts/codex_init_local_profile.sh
```
2. Install the shared local session pool once.
```bash
./scripts/codex_install_shared_pool.sh
```
3. Check status any time you suspect the links were replaced.
```bash
./scripts/codex_shared_pool_status.sh
```
4. Use snapshots before risky local changes or before restore operations.
```bash
./scripts/codex_snapshot.sh safe work-oauth-before-switch
```

## Workflow

### 1. Install Once for Local Continuity

Run `codex_init_local_profile.sh` to create a private config at:
`~/.codex-switch-snapshot/profiles/default.env`

This file is local-only and should not be shared or committed. It can hold:
- default snapshot mode
- shared pool root
- whether `history.jsonl` should join the shared pool

Then run:
```bash
./scripts/codex_install_shared_pool.sh
```

This installs a shared pool rooted at:
`~/.codex-shared/session-pool`

By default it links:
- `session_index.jsonl`
- `sessions/`
- `archived_sessions/`
- `history.jsonl`

It does not link:
- `auth.json`
- `config.toml`
- `.codex-global-state.json`
- sqlite databases
- cache or temp directories

### 2. Pick the Right Snapshot Mode

Use `safe` when:
- the user is switching Codex accounts
- the user is switching OAuth sessions
- the user mainly wants to preserve local conversation and workspace state

Use `full` only when:
- the user explicitly asks to preserve local auth configuration
- the user is switching API key based setups and wants local auth files restorable
- the user understands the snapshot will include sensitive local auth material

### 3. Explain the Scope Before Running

`safe` includes:
- `session_index.jsonl`
- `history.jsonl`
- `.codex-global-state.json`
- `sessions/`
- `archived_sessions/`
- `memories/`
- `rules/`
- `automations/`

`safe` excludes:
- `auth.json`
- `config.toml`
- sqlite databases
- wal/shm files
- cache/tmp directories
- shell environment variables such as `.zshrc`, `.bashrc`, `.env`

`full` adds:
- `auth.json`
- `config.toml`

### 4. Run the Snapshot

Run from the skill directory:
```bash
./scripts/codex_snapshot.sh safe <label>
./scripts/codex_snapshot.sh full <label>
```

The script resolves the Codex data root like this:
- use `CODEX_HOME` when it is set
- otherwise use `~/.codex`

Snapshots are written to:
`~/.codex-backups/<timestamp>-<mode>-<label>/`

Each snapshot contains:
- `files/`
- `manifest.json`
- `checksums.txt`

### 5. Check or Repair Shared Pool Links

Run:
```bash
./scripts/codex_shared_pool_status.sh
```

Use this when:
- the user wants to confirm the shared pool is still active
- a switch may have replaced local symlinks with plain files
- you want to confirm whether history sharing is enabled

If local links were lost, re-run:
```bash
./scripts/codex_install_shared_pool.sh
```

### 6. Advanced: Restore Carefully

Before restoring:
- remind the user that restore affects local state, not cloud history
- recommend restoring `safe` first when the goal is to get conversations back

Run:
```bash
./scripts/codex_restore.sh <snapshot-dir> --mode safe
./scripts/codex_restore.sh <snapshot-dir> --mode full
```

Restore behavior:
- always creates a `pre-restore` protective snapshot first
- restores only the requested scope
- refuses `--mode full` when the snapshot itself is only `safe`

### 7. Advanced: Unlink Shared Pool If Needed

Run:
```bash
./scripts/codex_unlink_shared_pool.sh
```

This converts shared symlinks back into plain local files and directories under `~/.codex`, while leaving the shared pool copy intact.

## What This Skill Does Not Do

- It does not migrate cloud conversations between OpenAI accounts.
- It does not merge different account histories.
- It does not manage environment-variable API keys.
- It does not watch the GUI and auto-snapshot during sign-out or sign-in.
- It does not rewrite sqlite databases to force hidden sessions back.

## Output Requirements

After running shared-pool install or status, always tell the user:
- whether the shared pool is installed
- the shared pool root
- which paths are shared
- that auth and runtime state remain local

After running a snapshot, always tell the user:
- snapshot mode
- snapshot directory
- whether auth files were included
- that environment-variable API keys were not captured

After running a restore, always tell the user:
- restore mode
- which snapshot was used
- that a `pre-restore` protective snapshot was created
- whether auth files remained untouched

## Resources

### scripts/

- `codex_snapshot.sh`: create `safe` or `full` snapshots
- `codex_restore.sh`: restore from a prior snapshot
- `codex_init_local_profile.sh`: create the private profile under `~/.codex-switch-snapshot/`
- `codex_install_shared_pool.sh`: install or repair the shared local session pool
- `codex_shared_pool_status.sh`: report whether shared links are active
- `codex_unlink_shared_pool.sh`: revert shared links back to plain local paths
- `codex_snapshot_lib.sh`: shared validation, copy, checksum, and manifest helpers

### references/

- `safety-and-recovery.md`: detailed safety boundaries, recovery guidance, and operator reminders
- `public-contribution-notes.md`: public-core vs local-only boundaries for contributors
