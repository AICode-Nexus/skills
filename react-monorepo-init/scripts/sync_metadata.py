#!/usr/bin/env python3
from __future__ import annotations

import argparse
import sys
from pathlib import Path

TEXT_SUFFIXES = {
    ".cjs",
    ".css",
    ".html",
    ".js",
    ".json",
    ".md",
    ".mjs",
    ".ts",
    ".tsx",
    ".txt",
    ".yaml",
    ".yml",
}
TEXT_FILENAMES = {
    ".editorconfig",
    ".gitattributes",
    ".gitignore",
    ".npmrc",
    ".nvmrc",
}
SKIP_DIRS = {".git", ".turbo", "coverage", "dist", "node_modules", "playwright-report", "test-results"}


def title_case(name: str) -> str:
    return " ".join(segment.capitalize() for segment in name.replace("_", "-").split("-") if segment)


def replacements_for(project_name: str, scope: str) -> dict[str, str]:
    scope_slug = scope.lstrip("@").replace("/", "-")
    return {
        "{{PROJECT_NAME}}": project_name,
        "{{PROJECT_TITLE}}": title_case(project_name),
        "{{SCOPE}}": scope,
        "{{SCOPE_SLUG}}": scope_slug,
        "{{PACKAGE_SCOPE}}": scope.lstrip("@"),
    }


def is_text_file(path: Path) -> bool:
    if path.name in TEXT_FILENAMES or path.suffix in TEXT_SUFFIXES:
        return True
    try:
        path.read_text(encoding="utf-8")
        return True
    except (UnicodeDecodeError, OSError):
        return False


def apply_replacements(target_dir: Path, replacements: dict[str, str]) -> int:
    changed = 0
    for path in sorted(target_dir.rglob("*")):
        if path.is_dir():
            continue
        if any(part in SKIP_DIRS for part in path.parts):
            continue
        if not is_text_file(path):
            continue
        original = path.read_text(encoding="utf-8")
        updated = original
        for placeholder, value in replacements.items():
            updated = updated.replace(placeholder, value)
        if updated != original:
            path.write_text(updated, encoding="utf-8")
            changed += 1
    return changed


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Replace scaffold placeholders inside a generated repository.")
    parser.add_argument("--target-dir", required=True, help="Repository root that contains scaffold templates.")
    parser.add_argument("--project-name", required=True, help="Project folder and package name.")
    parser.add_argument("--scope", required=True, help="Workspace package scope, for example @acme.")
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    target_dir = Path(args.target_dir).resolve()
    if not target_dir.exists() or not target_dir.is_dir():
        parser.error(f"target directory does not exist: {target_dir}")

    changed = apply_replacements(target_dir, replacements_for(args.project_name, args.scope))
    print(f"Updated {changed} files in {target_dir}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
