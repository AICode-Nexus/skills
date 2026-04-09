#!/usr/bin/env node

import { cpSync, existsSync, mkdirSync, readFileSync, rmSync } from 'node:fs';
import { homedir } from 'node:os';
import { dirname, isAbsolute, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const binDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(binDir, '..');
const manifestPath = join(repoRoot, 'manifest', 'skills.json');

function readManifest() {
  const manifest = JSON.parse(readFileSync(manifestPath, 'utf8'));
  return manifest.skills;
}

function printHelp() {
  console.log(`Usage:
  skills list
  skills install <skill...> [--dest <path>] [--force] [--dry-run]
  skills install --all [--dest <path>] [--force] [--dry-run]

Examples:
  npx @aicode-nexus/skills list
  npx @aicode-nexus/skills install react-monorepo-init
  npx @aicode-nexus/skills install react-monorepo-init --dest ~/.claude/skills
  npx @aicode-nexus/skills install react-monorepo-init --dest ./.claude/skills
  npx @aicode-nexus/skills install react-monorepo-init --dest ./tools/agent-skills
  npx @aicode-nexus/skills install react-monorepo-init codex-switch-snapshot
  npx @aicode-nexus/skills install --all
`);
}

function fail(message) {
  console.error(message);
  process.exitCode = 1;
}

function expandPath(inputPath) {
  if (!inputPath) {
    return join(homedir(), '.codex', 'skills');
  }
  if (inputPath === '~') {
    return homedir();
  }
  if (inputPath.startsWith('~/')) {
    return join(homedir(), inputPath.slice(2));
  }
  return isAbsolute(inputPath) ? inputPath : resolve(process.cwd(), inputPath);
}

function parseInstallArgs(args) {
  const skillNames = [];
  let dest;
  let force = false;
  let dryRun = false;
  let installAll = false;

  for (let index = 0; index < args.length; index += 1) {
    const arg = args[index];
    if (arg === '--dest') {
      if (index + 1 >= args.length || args[index + 1].startsWith('--')) {
        throw new Error('--dest requires a path value');
      }
      dest = args[index + 1];
      index += 1;
      continue;
    }
    if (arg === '--force') {
      force = true;
      continue;
    }
    if (arg === '--dry-run') {
      dryRun = true;
      continue;
    }
    if (arg === '--all') {
      installAll = true;
      continue;
    }
    if (arg.startsWith('--')) {
      throw new Error(`Unknown option: ${arg}`);
    }
    skillNames.push(arg);
  }

  return {
    skillNames,
    dest: expandPath(dest),
    force,
    dryRun,
    installAll,
  };
}

function installSkills(skills, options) {
  const selectedSkills = options.installAll
    ? skills
    : options.skillNames.map((name) => {
        const skill = skills.find((entry) => entry.name === name);
        if (!skill) {
          throw new Error(`Unknown skill: ${name}`);
        }
        return skill;
      });

  if (selectedSkills.length === 0) {
    throw new Error('No skills selected. Pass one or more skill names, or use --all.');
  }

  if (!options.dryRun) {
    mkdirSync(options.dest, { recursive: true });
  }

  for (const skill of selectedSkills) {
    const sourceDir = join(repoRoot, skill.path);
    const targetDir = join(options.dest, skill.name);

    if (existsSync(targetDir)) {
      if (!options.force) {
        throw new Error(`Destination already exists: ${targetDir}. Use --force to overwrite.`);
      }
      if (!options.dryRun) {
        rmSync(targetDir, { recursive: true, force: true });
      }
    }

    if (options.dryRun) {
      console.log(`dry-run: would install ${skill.name} -> ${targetDir}`);
      continue;
    }

    cpSync(sourceDir, targetDir, { recursive: true });
    console.log(`installed ${skill.name} -> ${targetDir}`);
  }

  const summaryPrefix = options.dryRun ? 'Dry-run complete.' : 'Installation complete.';
  console.log(`${summaryPrefix} Restart your AI coding tool to pick up new skills.`);
}

function listSkills(skills) {
  console.log('Available skills:');
  for (const skill of skills) {
    console.log(`- ${skill.name}: ${skill.description}`);
  }
}

function main() {
  const skills = readManifest();
  const [command, ...rest] = process.argv.slice(2);

  if (!command || command === 'help' || command === '--help' || command === '-h') {
    printHelp();
    return;
  }

  if (command === 'list') {
    listSkills(skills);
    return;
  }

  if (command === 'install') {
    const options = parseInstallArgs(rest);
    installSkills(skills, options);
    return;
  }

  throw new Error(`Unknown command: ${command}`);
}

try {
  main();
} catch (error) {
  fail(error instanceof Error ? error.message : String(error));
}
