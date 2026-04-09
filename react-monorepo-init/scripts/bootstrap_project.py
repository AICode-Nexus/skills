#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import shutil
import stat
import subprocess
import sys
from pathlib import Path

from sync_metadata import apply_replacements, replacements_for

SKILL_DIR = Path(__file__).resolve().parents[1]
BASE_ASSETS_DIR = SKILL_DIR / "assets" / "base"
ADDONS_DIR = SKILL_DIR / "assets" / "addons"
CLI_CLEANUP = [
    "apps/web/eslint.config.js",
    "apps/web/README.md",
    "apps/web/tsconfig.app.json",
    "apps/web/tsconfig.node.json",
    "apps/web/public/vite.svg",
    "apps/web/src/App.css",
    "apps/web/src/App.tsx",
    "apps/web/src/index.css",
]
ADDON_PACKAGE_UPDATES = {
    "storyboard": {
        "root_devDependencies": {
            "storybook": "^10.3.5",
            "@storybook/react-vite": "^10.3.5",
        },
        "root_scripts": {
            "storybook": "pnpm exec storybook dev -p 6006 -c .storybook",
            "storybook:build": "pnpm exec storybook build -c .storybook",
        },
    },
    "pwa": {
        "app_devDependencies": {
            "vite-plugin-pwa": "^1.2.0",
        },
    },
    "i18n": {
        "app_dependencies": {
            "i18next": "^26.0.4",
            "react-i18next": "^17.0.2",
            "i18next-browser-languagedetector": "^8.2.1",
        },
    },
}


def parse_addons(value: str | None) -> list[str]:
    if not value:
        return []
    addons = []
    for item in value.split(","):
        name = item.strip().lower()
        if name and name not in addons:
            addons.append(name)
    invalid = [name for name in addons if name not in {"ci", "storybook", "pwa", "i18n"}]
    if invalid:
        raise SystemExit(f"Unsupported addon(s): {', '.join(invalid)}")
    return addons


def ensure_safe_target(target_dir: Path) -> None:
    if target_dir.exists() and any(target_dir.iterdir()):
        raise SystemExit(f"Target directory is not empty: {target_dir}")
    target_dir.mkdir(parents=True, exist_ok=True)


def copy_tree(source_root: Path, destination_root: Path) -> None:
    for source in sorted(source_root.rglob("*")):
        relative_path = source.relative_to(source_root)
        destination = destination_root / relative_path
        if source.is_dir():
            destination.mkdir(parents=True, exist_ok=True)
            continue
        destination.parent.mkdir(parents=True, exist_ok=True)
        if source.name.endswith(".tmpl"):
            rendered_destination = destination.with_name(destination.name[:-5])
            rendered_destination.write_text(source.read_text(encoding="utf-8"), encoding="utf-8")
        else:
            shutil.copy2(source, destination)


def update_json_file(path: Path, updates: dict[str, dict[str, str]]) -> None:
    payload = json.loads(path.read_text(encoding="utf-8"))
    for section, values in updates.items():
        payload.setdefault(section, {})
        payload[section].update(values)
        payload[section] = dict(sorted(payload[section].items()))
    path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")


def apply_addon_overrides(target_dir: Path, addons: list[str]) -> None:
    root_package = target_dir / "package.json"
    app_package = target_dir / "apps" / "web" / "package.json"

    marker_replacements = {
        "/* addon:vite-imports */": "",
        "/* addon:vite-plugins */": "",
        "/* addon:main-imports */": "",
    }

    for addon in addons:
        addon_dir = ADDONS_DIR / addon
        if addon_dir.exists():
            copy_tree(addon_dir, target_dir)
        updates = ADDON_PACKAGE_UPDATES.get(addon, {})
        if root_updates := {k.removeprefix("root_"): v for k, v in updates.items() if k.startswith("root_")}:
            update_json_file(root_package, root_updates)
        if app_updates := {k.removeprefix("app_"): v for k, v in updates.items() if k.startswith("app_")}:
            update_json_file(app_package, app_updates)

        if addon == "pwa":
            marker_replacements["/* addon:vite-imports */"] += 'import { VitePWA } from "vite-plugin-pwa";\n'
            marker_replacements["/* addon:vite-plugins */"] += ',\n    VitePWA({\n      registerType: "autoUpdate",\n      manifest: {\n        name: "{{PROJECT_TITLE}}",\n        short_name: "{{PROJECT_TITLE}}",\n        theme_color: "#0f172a",\n        background_color: "#f8fafc",\n        display: "standalone",\n        start_url: "/",\n        icons: [],\n      },\n    })'
            marker_replacements["/* addon:main-imports */"] += 'import "./lib/pwa";\n'
        if addon == "i18n":
            marker_replacements["/* addon:main-imports */"] += 'import "./lib/i18n";\n'

    for relative_path in [Path("apps/web/vite.config.ts"), Path("apps/web/src/main.tsx")]:
        file_path = target_dir / relative_path
        contents = file_path.read_text(encoding="utf-8")
        for marker, value in marker_replacements.items():
            contents = contents.replace(marker, value.rstrip())
        file_path.write_text(contents, encoding="utf-8")


def apply_cli_base(target_dir: Path, strategy: str) -> str:
    if strategy == "asset-only":
        return "asset-only"

    environment = os.environ.copy()
    environment["COREPACK_ENABLE_STRICT"] = "0"
    command = ["pnpm", "dlx", "create-vite@latest", "apps/web", "--template", "react-ts"]

    try:
        subprocess.run(command, cwd=target_dir, env=environment, check=True)
        for relative_path in CLI_CLEANUP:
            path = target_dir / relative_path
            if path.is_dir():
                shutil.rmtree(path)
            elif path.exists():
                path.unlink()
        return "cli"
    except (FileNotFoundError, subprocess.CalledProcessError) as error:
        if strategy == "cli":
            raise SystemExit(f"Unable to scaffold the base Vite app with pnpm: {error}") from error
        print(f"warning: falling back to asset-only base scaffold because CLI bootstrap failed: {error}", file=sys.stderr)
        return "asset-only"


def set_executable_bits(target_dir: Path) -> None:
    for relative_path in [Path(".husky/commit-msg"), Path(".husky/pre-commit")]:
        path = target_dir / relative_path
        if path.exists():
            mode = path.stat().st_mode
            path.chmod(mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Bootstrap the standard React monorepo starter from bundled templates.")
    parser.add_argument("--project-name", required=True, help="Repository name and root package name.")
    parser.add_argument("--target-dir", required=True, help="Directory that will receive the scaffold.")
    parser.add_argument("--scope", required=True, help="Workspace package scope, for example @acme.")
    parser.add_argument("--addons", default="", help="Comma-separated addon list: ci,storybook,pwa,i18n.")
    parser.add_argument(
        "--base-strategy",
        choices=["auto", "asset-only", "cli"],
        default="auto",
        help="Choose whether to try pnpm create-vite before overlaying templates.",
    )
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    target_dir = Path(args.target_dir).resolve()
    addons = parse_addons(args.addons)

    ensure_safe_target(target_dir)
    base_strategy = apply_cli_base(target_dir, args.base_strategy)
    copy_tree(BASE_ASSETS_DIR, target_dir)
    apply_addon_overrides(target_dir, addons)
    apply_replacements(target_dir, replacements_for(args.project_name, args.scope))
    set_executable_bits(target_dir)

    print(json.dumps({
        "project": args.project_name,
        "target_dir": str(target_dir),
        "scope": args.scope,
        "addons": addons,
        "base_strategy": base_strategy,
    }, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
