import { join } from 'node:path';
import { tmpdir } from 'node:os';

export const DEFAULT_NPM_CACHE = join(tmpdir(), 'aicode-nexus-skills-npm-cache');
const VALID_RELEASE_TYPES = ['patch', 'minor', 'major'];

export function formatHelp() {
  return `Usage:
  npm run release:patch
  npm run release:minor
  npm run release:major
  node scripts/release.mjs <patch|minor|major> [--dry-run]

What it does:
  1. Verifies the git worktree is clean
  2. Runs npm test
  3. Runs npm run publish:dry-run
  4. Bumps the version with npm version
  5. Publishes to npm
  6. Pushes the current branch and tags to origin

Install target examples:
  npx @aicode-nexus/skills install react-monorepo-init --dest ~/.claude/skills
  npx @aicode-nexus/skills install react-monorepo-init --dest ./.claude/skills
  npx @aicode-nexus/skills install react-monorepo-init --dest ./tools/agent-skills
`;
}

export function parseArgs(args) {
  const [releaseType, ...rest] = args;

  if (!releaseType || releaseType === '--help' || releaseType === '-h' || releaseType === 'help') {
    return { help: true };
  }

  if (!VALID_RELEASE_TYPES.includes(releaseType)) {
    throw new Error(`Release type must be one of: ${VALID_RELEASE_TYPES.join(', ')}.`);
  }

  let dryRun = false;

  for (const arg of rest) {
    if (arg === '--dry-run') {
      dryRun = true;
      continue;
    }
    throw new Error(`Unknown option: ${arg}`);
  }

  return { dryRun, releaseType };
}

export function buildReleasePlan({ branch, releaseType }) {
  if (!VALID_RELEASE_TYPES.includes(releaseType)) {
    throw new Error(`Release type must be one of: ${VALID_RELEASE_TYPES.join(', ')}.`);
  }

  if (!branch || branch === 'HEAD') {
    throw new Error('Cannot create a release from a detached HEAD.');
  }

  const npmEnv = {
    npm_config_cache: DEFAULT_NPM_CACHE,
  };

  return [
    {
      label: 'Run test suite',
      command: 'npm',
      args: ['test'],
      env: npmEnv,
    },
    {
      label: 'Run publish dry-run',
      command: 'npm',
      args: ['run', 'publish:dry-run'],
      env: npmEnv,
    },
    {
      label: `Bump version (${releaseType})`,
      command: 'npm',
      args: ['version', releaseType],
      env: npmEnv,
    },
    {
      label: 'Publish package',
      command: 'npm',
      args: ['publish'],
      env: npmEnv,
    },
    {
      label: 'Push branch and tags',
      command: 'git',
      args: ['push', 'origin', branch, '--follow-tags'],
    },
  ];
}
