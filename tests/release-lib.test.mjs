import test from 'node:test';
import assert from 'node:assert/strict';

import {
  buildGitHubReleasePlan,
  buildReleasePlan,
  bumpVersion,
  formatGitHubReleaseHelp,
  formatHelp,
  parseArgs,
} from '../scripts/release-lib.mjs';

test('parseArgs parses the release type and dry-run flag', () => {
  assert.deepEqual(parseArgs(['patch']), {
    dryRun: false,
    releaseType: 'patch',
  });

  assert.deepEqual(parseArgs(['minor', '--dry-run']), {
    dryRun: true,
    releaseType: 'minor',
  });
});

test('parseArgs rejects unknown release types and flags', () => {
  assert.throws(() => parseArgs(['beta']), /Release type must be one of: patch, minor, major\./);
  assert.throws(() => parseArgs(['patch', '--nope']), /Unknown option: --nope/);
});

test('buildReleasePlan creates the expected ordered steps', () => {
  const plan = buildReleasePlan({ branch: 'main', releaseType: 'patch' });

  assert.deepEqual(
    plan.map((step) => step.label),
    [
      'Run test suite',
      'Run publish dry-run',
      'Bump version (patch)',
      'Publish package',
      'Push branch and tags',
    ],
  );

  assert.deepEqual(plan[0].args, ['test']);
  assert.deepEqual(plan[1].args, ['run', 'publish:dry-run']);
  assert.deepEqual(plan[2].args, ['version', 'patch']);
  assert.deepEqual(plan[3].args, ['publish']);
  assert.deepEqual(plan[4].args, ['push', 'origin', 'main', '--follow-tags']);
});

test('buildReleasePlan rejects detached HEAD', () => {
  assert.throws(
    () => buildReleasePlan({ branch: 'HEAD', releaseType: 'patch' }),
    /detached HEAD/i,
  );
});

test('bumpVersion calculates the next semantic version', () => {
  assert.equal(bumpVersion('0.1.1', 'patch'), '0.1.2');
  assert.equal(bumpVersion('0.1.1', 'minor'), '0.2.0');
  assert.equal(bumpVersion('0.1.1', 'major'), '1.0.0');
});

test('buildGitHubReleasePlan creates the expected ordered steps', () => {
  const plan = buildGitHubReleasePlan({
    branch: 'main',
    currentVersion: '0.1.1',
    releaseType: 'patch',
  });

  assert.deepEqual(
    plan.map((step) => step.label),
    [
      'Verify GitHub CLI auth',
      'Run test suite',
      'Run publish dry-run',
      'Bump version (patch)',
      'Push branch and tags',
      'Create GitHub Release (v0.1.2)',
    ],
  );

  assert.deepEqual(plan[0].args, ['auth', 'status']);
  assert.deepEqual(plan[1].args, ['test']);
  assert.deepEqual(plan[2].args, ['run', 'publish:dry-run']);
  assert.deepEqual(plan[3].args, ['version', 'patch']);
  assert.deepEqual(plan[4].args, ['push', 'origin', 'main', '--follow-tags']);
  assert.deepEqual(plan[5].args, ['release', 'create', 'v0.1.2', '--verify-tag', '--generate-notes', '--latest']);
});

test('formatGitHubReleaseHelp describes the GitHub release command path', () => {
  const help = formatGitHubReleaseHelp();

  assert.match(help, /npm run release:github:patch/);
  assert.match(help, /gh release create/);
  assert.match(help, /GitHub Actions publishes to npm automatically/);
});

test('formatHelp describes host and project-local release usage', () => {
  const help = formatHelp();

  assert.match(help, /npm run release:patch/);
  assert.match(help, /~\/\.claude\/skills/);
  assert.match(help, /\.\/tools\/agent-skills/);
});
