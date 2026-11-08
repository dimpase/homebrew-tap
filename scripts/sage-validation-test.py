"""Test failure reporting without installing packages or running Sage."""

import contextlib
import importlib.util
import io
import json
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch
import xml.etree.ElementTree as ET

spec = importlib.util.spec_from_file_location(
    "sage_validation", Path(__file__).with_name("sage-validation.py"))
validation = importlib.util.module_from_spec(spec)
spec.loader.exec_module(validation)


class TestCommandResults(unittest.TestCase):
    def exercise(self, failures):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            artifacts = root / "artifacts"
            artifacts.mkdir()
            commands = []

            def run(command, **kwargs):
                if command[:3] == ["uv", "pip", "install"]:
                    self.assertIn("--no-deps", command)
                    return SimpleNamespace(returncode=0)
                commands.append(command)
                kwargs["stdout"].write("Test output\n")
                return SimpleNamespace(returncode=failures.get(len(commands), 0))

            versions = dict(package.split("==") for package in validation.TEST_PACKAGES)

            def distribution(name):
                return SimpleNamespace(version=versions[name], locate_file=lambda _: root / "venv")

            with patch.object(validation.subprocess, "run", side_effect=run), \
                 patch.object(validation, "check_python"), \
                 patch.object(validation.importlib.metadata, "distribution", side_effect=distribution), \
                 patch.object(validation.sys, "prefix", str(root / "venv")), \
                 contextlib.redirect_stdout(io.StringIO()):
                status = validation.run_tests(root, artifacts)

            self.assertEqual(len(commands), 6)
            results = json.loads((artifacts / "test-status.json").read_text())
            self.assertEqual([row["exit_code"] for row in results],
                             [failures.get(index, 0) for index in range(1, 7)])
            suite = ET.parse(artifacts / "command-results.xml").getroot()
            self.assertEqual(suite.get("tests"), "6")
            self.assertEqual(suite.get("failures"), str(len(failures)))
            return status

    def test_all_commands_pass(self):
        self.assertEqual(self.exercise({}), 0)

    def test_failures_are_preserved_and_later_groups_still_run(self):
        self.assertEqual(self.exercise({1: 5, 3: -9}), 1)


if __name__ == "__main__":
    unittest.main()
