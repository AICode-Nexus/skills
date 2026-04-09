#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path

REQUIRED_PATHS = [
    "AGENTS.md",
    "CHANGELOG.md",
    "DESIGN.md",
    "README.md",
    "package.json",
    "pnpm-workspace.yaml",
    "turbo.json",
    ".changeset/config.json",
    "apps/web/package.json",
    "apps/web/src/main.tsx",
    "apps/web/src/test/setup.ts",
    "apps/web/e2e/home.spec.ts",
    "packages/api-client/src/index.ts",
    "packages/ui/src/index.ts",
    "packages/config-eslint/index.mjs",
    "packages/config-typescript/base.json",
    "packages/config-tailwind/src/index.css",
    "packages/config-vitest/index.mjs",
]
DEFAULT_COMMANDS = [
    ["pnpm", "lint"],
    ["pnpm", "typecheck"],
    ["pnpm", "test"],
]


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Verify that a generated starter contains the required files and optionally run workspace checks.")
    parser.add_argument("--target-dir", required=True, help="Generated repository root.")
    parser.add_argument("--skip-commands", action="store_true", help="Only run structural checks.")
    return parser


def verify_structure(target_dir: Path) -> list[str]:
    errors = []
    for relative_path in REQUIRED_PATHS:
        if not (target_dir / relative_path).exists():
            errors.append(f"missing required path: {relative_path}")
    package_json = target_dir / "package.json"
    if package_json.exists():
        root_package = json.loads(package_json.read_text(encoding="utf-8"))
        if not root_package.get("name") or "{{" in root_package.get("name", ""):
            errors.append("root package name still contains placeholders")
    changelog_text = (target_dir / "CHANGELOG.md").read_text(encoding="utf-8") if (target_dir / "CHANGELOG.md").exists() else ""
    if "Keep a Changelog" not in changelog_text:
        errors.append("CHANGELOG.md does not explain the changelog format")
    return errors


def run_commands(target_dir: Path) -> list[str]:
    errors = []
    for command in DEFAULT_COMMANDS:
        result = subprocess.run(command, cwd=target_dir, text=True, capture_output=True, check=False)
        if result.returncode != 0:
            errors.append(
                f"command failed: {' '.join(command)}\nstdout:\n{result.stdout}\nstderr:\n{result.stderr}"
            )
    return errors


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    target_dir = Path(args.target_dir).resolve()
    if not target_dir.exists():
        parser.error(f"target directory does not exist: {target_dir}")

    errors = verify_structure(target_dir)
    if not args.skip_commands:
        errors.extend(run_commands(target_dir))

    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1

    print(f"Scaffold verified in {target_dir}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
