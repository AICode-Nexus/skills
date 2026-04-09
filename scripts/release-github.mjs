#!/usr/bin/env node

import { readFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import process from 'node:process';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

import { buildGitHubReleasePlan, formatGitHubReleaseHelp, parseArgs } from './release-lib.mjs';

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..');

function fail(message) {
  console.error(message);
  process.exit(1);
}

function runCapture(command, args, env = {}) {
  const result = spawnSync(command, args, {
    cwd: repoRoot,
    encoding: 'utf8',
    env: {
      ...process.env,
      ...env,
    },
  });

  if (result.status !== 0) {
    const errorOutput = result.stderr.trim() || result.stdout.trim() || `${command} ${args.join(' ')} failed.`;
    fail(errorOutput);
  }

  return result.stdout.trim();
}

function runStep(step, dryRun) {
  const commandLine = [step.command, ...step.args].join(' ');

  if (dryRun) {
    console.log(`- ${commandLine}`);
    return;
  }

  console.log(`\n==> ${step.label}`);
  const result = spawnSync(step.command, step.args, {
    cwd: repoRoot,
    stdio: 'inherit',
    env: {
      ...process.env,
      ...(step.env ?? {}),
    },
  });

  if (result.status !== 0) {
    process.exit(result.status ?? 1);
  }
}

function getCurrentBranch() {
  return runCapture('git', ['rev-parse', '--abbrev-ref', 'HEAD']);
}

function ensureCleanWorktree() {
  const status = runCapture('git', ['status', '--short']);
  if (status) {
    fail('Working tree is not clean. Commit or stash changes before running the GitHub release script.');
  }
}

function readCurrentVersion() {
  const packageJson = JSON.parse(readFileSync(resolve(repoRoot, 'package.json'), 'utf8'));
  return packageJson.version;
}

function main() {
  const parsed = parseArgs(process.argv.slice(2));

  if (parsed.help) {
    console.log(formatGitHubReleaseHelp());
    return;
  }

  ensureCleanWorktree();
  const branch = getCurrentBranch();
  const currentVersion = readCurrentVersion();
  const plan = buildGitHubReleasePlan({
    branch,
    currentVersion,
    releaseType: parsed.releaseType,
  });

  if (parsed.dryRun) {
    console.log(`Dry run for GitHub ${parsed.releaseType} release on branch ${branch}:`);
    console.log('');
    for (const step of plan) {
      runStep(step, true);
    }
    return;
  }

  for (const step of plan) {
    runStep(step, false);
  }
}

try {
  main();
} catch (error) {
  fail(error instanceof Error ? error.message : String(error));
}
