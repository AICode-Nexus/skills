import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, existsSync, readFileSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { spawnSync } from 'node:child_process';

const repoRoot = resolve(import.meta.dirname, '..');
const cliPath = join(repoRoot, 'bin', 'skills.js');

function runCli(args) {
  return spawnSync(process.execPath, [cliPath, ...args], {
    cwd: repoRoot,
    encoding: 'utf8',
  });
}

test('list prints available skills', () => {
  const result = runCli(['list']);

  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /react-monorepo-init/);
  assert.match(result.stdout, /codex-switch-snapshot/);
  assert.match(result.stdout, /producing-animated-icons/);
});

test('install copies a requested skill into the target directory', () => {
  const targetRoot = mkdtempSync(join(tmpdir(), 'skills-install-'));
  const result = runCli(['install', 'react-monorepo-init', '--dest', targetRoot]);

  assert.equal(result.status, 0, result.stderr);
  assert.equal(existsSync(join(targetRoot, 'react-monorepo-init', 'SKILL.md')), true);
  const skillText = readFileSync(join(targetRoot, 'react-monorepo-init', 'SKILL.md'), 'utf8');
  assert.match(skillText, /name: react-monorepo-init/);
  assert.match(result.stdout, /Restart your AI coding tool to pick up new skills\./);
});

test('install fails if the destination already exists without --force', () => {
  const targetRoot = mkdtempSync(join(tmpdir(), 'skills-force-'));
  const existingDir = join(targetRoot, 'react-monorepo-init');
  const firstInstall = runCli(['install', 'react-monorepo-init', '--dest', targetRoot]);

  assert.equal(firstInstall.status, 0, firstInstall.stderr);
  writeFileSync(join(existingDir, 'LOCAL_ONLY.txt'), 'keep me');

  const secondInstall = runCli(['install', 'react-monorepo-init', '--dest', targetRoot]);

  assert.notEqual(secondInstall.status, 0);
  assert.match(secondInstall.stderr, /already exists/i);
});

test('install --force overwrites an existing destination', () => {
  const targetRoot = mkdtempSync(join(tmpdir(), 'skills-overwrite-'));
  const existingDir = join(targetRoot, 'react-monorepo-init');
  const firstInstall = runCli(['install', 'react-monorepo-init', '--dest', targetRoot]);

  assert.equal(firstInstall.status, 0, firstInstall.stderr);
  writeFileSync(join(existingDir, 'LOCAL_ONLY.txt'), 'remove me');

  const forcedInstall = runCli(['install', 'react-monorepo-init', '--dest', targetRoot, '--force']);

  assert.equal(forcedInstall.status, 0, forcedInstall.stderr);
  assert.equal(existsSync(join(existingDir, 'LOCAL_ONLY.txt')), false);
  assert.equal(existsSync(join(existingDir, 'SKILL.md')), true);
});

test('install --all copies every skill', () => {
  const targetRoot = mkdtempSync(join(tmpdir(), 'skills-all-'));
  const result = runCli(['install', '--all', '--dest', targetRoot]);

  assert.equal(result.status, 0, result.stderr);
  assert.equal(existsSync(join(targetRoot, 'react-monorepo-init', 'SKILL.md')), true);
  assert.equal(existsSync(join(targetRoot, 'codex-switch-snapshot', 'SKILL.md')), true);
  assert.equal(existsSync(join(targetRoot, 'producing-animated-icons', 'SKILL.md')), true);
});

test('install --dry-run reports actions without writing files', () => {
  const targetRoot = mkdtempSync(join(tmpdir(), 'skills-dry-run-'));
  const result = runCli(['install', 'react-monorepo-init', '--dest', targetRoot, '--dry-run']);

  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /dry-run/i);
  assert.match(result.stdout, /Restart your AI coding tool to pick up new skills\./);
  assert.equal(existsSync(join(targetRoot, 'react-monorepo-init')), false);
});

test('install fails for an unknown skill name', () => {
  const targetRoot = mkdtempSync(join(tmpdir(), 'skills-unknown-'));
  const result = runCli(['install', 'does-not-exist', '--dest', targetRoot]);

  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /unknown skill/i);
});

test('install fails when --dest is missing a path value', () => {
  const result = runCli(['install', 'react-monorepo-init', '--dest']);

  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /requires a path/i);
});
