import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SKILL_DIR = Path(__file__).resolve().parents[2]
SCRIPTS_DIR = SKILL_DIR / "scripts"
BOOTSTRAP = SCRIPTS_DIR / "bootstrap_project.py"
SYNC = SCRIPTS_DIR / "sync_metadata.py"
VERIFY = SCRIPTS_DIR / "verify_scaffold.py"


def run_python(script: Path, *args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, str(script), *args],
        text=True,
        capture_output=True,
        check=False,
    )


class SkillScriptsTest(unittest.TestCase):
    def test_bootstrap_creates_expected_monorepo_structure(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            target = Path(temp_dir) / "demo-app"
            result = run_python(
                BOOTSTRAP,
                "--project-name",
                "demo-app",
                "--target-dir",
                str(target),
                "--scope",
                "@acme",
                "--base-strategy",
                "asset-only",
            )
            self.assertEqual(result.returncode, 0, msg=result.stderr or result.stdout)
            required_paths = [
                target / "package.json",
                target / "turbo.json",
                target / "CHANGELOG.md",
                target / "AGENTS.md",
                target / "DESIGN.md",
                target / "apps/web/package.json",
                target / "apps/web/src/main.tsx",
                target / "packages/ui/src/index.ts",
                target / "packages/api-client/src/index.ts",
                target / "packages/config-eslint/index.mjs",
                target / ".changeset/config.json",
            ]
            for path in required_paths:
                self.assertTrue(path.exists(), msg=f"missing expected path: {path}")
            root_package = json.loads((target / "package.json").read_text())
            self.assertEqual(root_package["name"], "demo-app")
            app_package = json.loads((target / "apps/web/package.json").read_text())
            self.assertEqual(app_package["name"], "@acme/web")
            changelog_text = (target / "CHANGELOG.md").read_text()
            self.assertIn("Keep a Changelog", changelog_text)
            self.assertIn("project-level summary", changelog_text)
            self.assertIn(".changeset/", changelog_text)
            readme_text = (target / "README.md").read_text()
            self.assertIn("Changelog Policy", readme_text)
            self.assertIn("会影响版本或发布说明的改动，先写 `.changeset/`。", readme_text)

    def test_bootstrap_rejects_non_empty_directory(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            target = Path(temp_dir) / "occupied"
            target.mkdir()
            (target / "keep.txt").write_text("do not overwrite")
            result = run_python(
                BOOTSTRAP,
                "--project-name",
                "demo-app",
                "--target-dir",
                str(target),
                "--scope",
                "@acme",
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("not empty", result.stderr.lower())

    def test_sync_metadata_replaces_placeholders(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            readme = root / "README.md"
            readme.write_text("# {{PROJECT_NAME}}\nScope: {{SCOPE}}\n")
            package_json = root / "package.json"
            package_json.write_text('{"name": "{{PROJECT_NAME}}"}\n')
            result = run_python(
                SYNC,
                "--target-dir",
                str(root),
                "--project-name",
                "demo-app",
                "--scope",
                "@acme",
            )
            self.assertEqual(result.returncode, 0, msg=result.stderr or result.stdout)
            self.assertEqual(readme.read_text(), "# demo-app\nScope: @acme\n")
            self.assertEqual(json.loads(package_json.read_text())["name"], "demo-app")

    def test_verify_scaffold_requires_core_files(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            target = Path(temp_dir) / "demo-app"
            bootstrap = run_python(
                BOOTSTRAP,
                "--project-name",
                "demo-app",
                "--target-dir",
                str(target),
                "--scope",
                "@acme",
                "--base-strategy",
                "asset-only",
            )
            self.assertEqual(bootstrap.returncode, 0, msg=bootstrap.stderr or bootstrap.stdout)
            result = run_python(VERIFY, "--target-dir", str(target), "--skip-commands")
            self.assertEqual(result.returncode, 0, msg=result.stderr or result.stdout)
            self.assertIn("verified", result.stdout.lower())


if __name__ == "__main__":
    unittest.main()
