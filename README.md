# @aicode-nexus/skills

Reusable agent skills for Codex, Claude Code, and project-local workflows.

适用于 Codex、Claude Code，以及项目内本地工作流的可复用 skills 仓库与安装 CLI。

## Overview / 简介

This repository follows a simple convention: one skill per directory, with each skill containing at least one `SKILL.md`.

这个仓库采用很直接的约定：一个 skill 对应一个目录，每个 skill 至少包含一个 `SKILL.md`。

The npm package ships a small CLI that can:

- list the published skills
- install one or more skills
- install into a host-specific user directory
- install into a project-local directory for sharing, vendoring, or bootstrapping

npm 包自带一个很轻量的 CLI，可以：

- 列出当前可安装的 skills
- 安装一个或多个 skill
- 安装到宿主工具自己的用户目录
- 安装到项目目录中，方便团队共享、仓库内置或二次分发

## Quick Start / 快速开始

List available skills:

```bash
npx @aicode-nexus/skills list
```

Install one skill:

```bash
npx @aicode-nexus/skills install react-monorepo-init
```

Install multiple skills:

```bash
npx @aicode-nexus/skills install react-monorepo-init codex-switch-snapshot
```

Install all published skills:

```bash
npx @aicode-nexus/skills install --all
```

Skip the `npx` confirmation prompt:

```bash
npx -y @aicode-nexus/skills list
```

安装完成后，重启或重新打开你的 agent 工具会话，以便加载新 skill。

## Install Targets / 安装目标

The CLI supports any destination folder through `--dest`.

CLI 通过 `--dest` 支持任意目标目录。

| Use Case | Recommended Path | Example |
| --- | --- | --- |
| Codex user-level install | `~/.codex/skills` | `npx @aicode-nexus/skills install react-monorepo-init` |
| Claude Code user-level install | `~/.claude/skills` | `npx @aicode-nexus/skills install react-monorepo-init --dest ~/.claude/skills` |
| Claude Code project-local install | `./.claude/skills` | `npx @aicode-nexus/skills install react-monorepo-init --dest ./.claude/skills` |
| Generic repo-local install | `./tools/agent-skills` | `npx @aicode-nexus/skills install react-monorepo-init --dest ./tools/agent-skills` |

Notes:

- If you omit `--dest`, the current default is `~/.codex/skills`.
- Host tools differ in how they discover project-local directories.
- A repo-local directory is a good choice when you want to keep the skill files in the repository, then copy or symlink them into the host tool if needed.

说明：

- 如果不传 `--dest`，当前默认目标目录是 `~/.codex/skills`
- 不同宿主工具对项目目录的自动发现方式并不完全相同
- 如果你想把 skills 跟项目一起版本管理，仓库内目录是一个很好用的中间层，后续再复制或软链接到具体宿主目录即可

## CLI Usage / CLI 用法

```bash
skills list
skills install <skill...> [--dest <path>] [--force] [--dry-run]
skills install --all [--dest <path>] [--force] [--dry-run]
```

### Options / 参数

| Option | Meaning |
| --- | --- |
| `--dest <path>` | Install into a specific directory |
| `--force` | Overwrite an existing destination |
| `--dry-run` | Print planned actions without writing files |
| `--all` | Install every skill in `manifest/skills.json` |

### Examples / 示例

```bash
# Codex default target
npx @aicode-nexus/skills install react-monorepo-init

# Claude Code user-level target
npx @aicode-nexus/skills install react-monorepo-init --dest ~/.claude/skills

# Claude Code project-local target
npx @aicode-nexus/skills install react-monorepo-init --dest ./.claude/skills

# Generic repo-local target
npx @aicode-nexus/skills install react-monorepo-init --dest ./tools/agent-skills

# Overwrite an existing install
npx @aicode-nexus/skills install react-monorepo-init --force

# Preview without writing files
npx @aicode-nexus/skills install react-monorepo-init --dry-run
```

## Available Skills / 已收录 Skills

### `codex-switch-snapshot`

Keep local Codex continuity across account switches, OAuth changes, API key swaps, and snapshot recovery.

用于在 Codex 账号切换、OAuth 变化、API key 更换和本地快照恢复之间保持连续性。

- Host fit: Codex-specific
- 安装：

```bash
npx @aicode-nexus/skills install codex-switch-snapshot
```

### `producing-animated-icons`

Create animated icon assets and collect references from curated motion-icon sources.

用于生产动态图标素材，并整理动效图标参考来源。

- Host fit: general workflow skill
- 安装：

```bash
npx @aicode-nexus/skills install producing-animated-icons
```

### `react-monorepo-init`

Bootstrap a React 19 + TypeScript monorepo starter with Vite, Router, Query, Zustand, Tailwind v4, and testing defaults.

用于初始化 React 19 + TypeScript monorepo 基线，内置 Vite、Router、Query、Zustand、Tailwind v4 和测试默认配置。

- Optional add-ons: `ci`, `storybook`, `pwa`, `i18n`
- Host fit: general workflow skill
- 安装：

```bash
npx @aicode-nexus/skills install react-monorepo-init
```

## Common Workflows / 常见用法

### Install into a host user directory / 安装到宿主用户目录

```bash
# Codex
npx @aicode-nexus/skills install react-monorepo-init --dest ~/.codex/skills

# Claude Code
npx @aicode-nexus/skills install react-monorepo-init --dest ~/.claude/skills
```

### Install into the current project / 安装到当前项目目录

```bash
# Claude Code project-local convention
npx @aicode-nexus/skills install react-monorepo-init --dest ./.claude/skills

# Generic repo-local directory
npx @aicode-nexus/skills install react-monorepo-init --dest ./tools/agent-skills
```

This is useful when:

- you want shared team setup in a repository
- you want to review or version the installed skill files
- you want a portable bootstrap directory before copying into a host-specific path

适合这些场景：

- 你想把团队共用的 skill 配置放在仓库里
- 你想把安装后的 skill 文件纳入版本控制或 code review
- 你希望先安装到一个仓库内目录，再复制到不同宿主路径

### Preview without writing / 仅预览不写入

```bash
npx @aicode-nexus/skills install react-monorepo-init --dry-run --dest ./tools/agent-skills
```

### Overwrite an existing install / 覆盖已有安装

If you see:

```text
Destination already exists: /path/to/skill. Use --force to overwrite.
```

run:

```bash
npx @aicode-nexus/skills install react-monorepo-init --force
```

### Manual copy or symlink / 手动复制或软链接

If you prefer not to use the npm CLI, you can copy or symlink skill directories yourself.

如果你不想通过 npm CLI 安装，也可以直接手动复制或软链接目录。

```bash
# Copy to Codex
mkdir -p ~/.codex/skills
cp -R react-monorepo-init ~/.codex/skills/

# Copy to Claude Code
mkdir -p ~/.claude/skills
cp -R react-monorepo-init ~/.claude/skills/

# Symlink into a repo-local directory
mkdir -p ./tools/agent-skills
ln -s /path/to/skills-repo/react-monorepo-init ./tools/agent-skills/react-monorepo-init
```

## Compatibility Notes / 兼容性说明

Not every skill is host-neutral.

并不是每个 skill 都对所有宿主完全中立。

For example:

- `codex-switch-snapshot` is intentionally Codex-specific
- `react-monorepo-init` is a more general workflow skill

在实际使用时，请以各自目录中的 `SKILL.md` 为准。

## Local Development / 本地开发

Run the local CLI from the repository root:

```bash
npx . list
npx . install react-monorepo-init --dry-run --dest /tmp/codex-skills-test
```

Run tests:

```bash
npm test
```

Run the release checks:

```bash
npm run release:check
```

This runs:

```bash
npm test
npm run pack:check
npm run publish:dry-run
```

## Publishing / 发布

This package is published to npm and can be used directly with `npx @aicode-nexus/skills ...`.

这个包已经发布到 npm，可以直接通过 `npx @aicode-nexus/skills ...` 使用。

Recommended GitHub release flow:

1. Add the repository secret `NPM_TOKEN`
2. Push your code and tag
3. Publish a GitHub Release from that tag
4. GitHub Actions runs tests and publishes to npm automatically

推荐的 GitHub 发版流程：

1. 在仓库里配置 `NPM_TOKEN` secret
2. 推送代码和 tag
3. 基于该 tag 发布 GitHub Release
4. GitHub Actions 自动跑测试并发布到 npm

This repository also includes a manual GitHub Actions fallback:

- workflow: `.github/workflows/release.yml`
- trigger: `workflow_dispatch`
- input: a tag such as `v0.1.1`

这个仓库同时保留了一个手动补发入口：

- workflow：`.github/workflows/release.yml`
- 触发方式：`workflow_dispatch`
- 输入：例如 `v0.1.1` 这样的 tag

Recommended local release shortcuts:

```bash
npm run release:patch
npm run release:minor
npm run release:major
```

Safe preview:

```bash
npm run release:patch:dry-run
```

The release script does the following:

- checks that the git worktree is clean
- runs `npm test`
- runs `npm run publish:dry-run`
- bumps the version with `npm version`
- publishes to npm
- pushes the current branch and tags to `origin`

推荐的本地发版入口：

```bash
npm run release:patch
npm run release:minor
npm run release:major
```

安全预演：

```bash
npm run release:patch:dry-run
```

这个发布脚本会依次执行：

- 检查 git 工作区是否干净
- 运行 `npm test`
- 运行 `npm run publish:dry-run`
- 用 `npm version` 升级版本
- 发布到 npm
- 把当前分支和 tags 一起推到 `origin`

For follow-up releases without the shortcut, the manual flow is:

```bash
npm run release:check
npm version patch
npm publish
```

如果你不用快捷脚本，手动流程仍然是：

```bash
npm run release:check
npm version patch
npm publish
```

For the full release checklist, registry notes, scope troubleshooting, and post-publish validation, see [RELEASING.md](./RELEASING.md).

完整的发布清单、registry 说明、scope 权限排障和发布后验证，请看 [RELEASING.md](./RELEASING.md)。

## Maintainers / 维护建议

- Prefer `npx @aicode-nexus/skills ...` in user-facing docs
- Use directory names as canonical skill names
- Update `manifest/skills.json` when adding installable skills
- Keep README install examples aligned with real CLI behavior
