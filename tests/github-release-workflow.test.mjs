import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

const workflowPath = resolve(import.meta.dirname, '..', '.github', 'workflows', 'release.yml');

test('release workflow publishes on GitHub Release and supports manual dispatch', () => {
  const workflow = readFileSync(workflowPath, 'utf8');

  assert.match(workflow, /^name:\s+Release$/m);
  assert.match(workflow, /^on:\n(?:.*\n)*\s+release:\n(?:.*\n)*\s+types:\s+\[published\]/m);
  assert.match(workflow, /^on:\n(?:.*\n)*\s+workflow_dispatch:/m);
  assert.match(workflow, /NPM_TOKEN/);
  assert.match(workflow, /npm test/);
  assert.match(workflow, /npm publish --provenance/);
  assert.match(workflow, /actions\/checkout@v4/);
  assert.match(workflow, /actions\/setup-node@v4/);
});

test('release workflow validates package version against the release tag', () => {
  const workflow = readFileSync(workflowPath, 'utf8');

  assert.match(workflow, /package\.json/);
  assert.match(workflow, /release tag/i);
  assert.match(workflow, /v\$\{packageVersion\}/);
});
