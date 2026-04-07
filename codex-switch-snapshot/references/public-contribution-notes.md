# Public Contribution Notes

## Public Core vs Local-Only Data

Keep these files in the public skill:
- `SKILL.md`
- `scripts/`
- `references/`
- optional agent metadata used by the source repo

Keep these paths local-only:
- `~/.codex-switch-snapshot/`
- `~/.codex-shared/`
- `~/.codex-backups/`

The skill is designed to share local conversation storage, not personal identity, account metadata, or runtime secrets.

## Never Commit Real Local Data

Do not commit:
- real `auth.json` or `config.toml` contents
- real API keys, OAuth tokens, or MCP secrets
- real snapshot directories or checksum output from local backups
- real shared-pool data copied from `~/.codex-shared/`
- personal labels or notes from `~/.codex-switch-snapshot/profiles/default.env`

## Validation Before Publishing

Run the minimum checks before contributing:

```bash
bash tests/codex-switch-snapshot-smoke.sh
python3 /Users/admin/.codex/skills/.system/skill-creator/scripts/quick_validate.py .agents/skills/codex-switch-snapshot
rg -n -f /tmp/codex-switch-public-patterns.txt .agents/skills/codex-switch-snapshot
```

Create `/tmp/codex-switch-public-patterns.txt` with the review patterns you want to block before running the final grep.

## Publishing Boundary

When syncing this skill to a public skills repository, publish only the public core:
- `SKILL.md`
- `scripts/`
- `references/`

Do not publish local runtime data or machine-specific configuration generated under `HOME`.
