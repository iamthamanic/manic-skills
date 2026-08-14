#!/usr/bin/env python3
from __future__ import annotations

import importlib.util
import json
import sys
import tempfile
import unittest
import zipfile
from pathlib import Path

MODULE_PATH = Path(__file__).with_name("chatgpt-provider.py")
spec = importlib.util.spec_from_file_location("chatgpt_provider", MODULE_PATH)
assert spec and spec.loader
provider = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = provider
spec.loader.exec_module(provider)


class ChatGPTProviderTests(unittest.TestCase):
    def make_repo(self, root: Path, skill_md: str, name: str = "api-design") -> Path:
        skill_dir = root / "skills" / name
        skill_dir.mkdir(parents=True)
        (skill_dir / "SKILL.md").write_text(skill_md, encoding="utf-8")
        (skill_dir / "references").mkdir()
        (skill_dir / "references" / "example.md").write_text("reference\n", encoding="utf-8")
        return skill_dir

    def test_export_strips_provider_specific_frontmatter_and_generates_metadata(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            self.make_repo(
                root,
                """---
name: api-design
description: REST API design patterns for production APIs.
disable-model-invocation: true
argument-hint: endpoint
---

# API Design

Body.
""",
            )
            output = root / "dist" / "chatgpt"
            records = provider.export_skills(root, output)
            self.assertEqual(len(records), 1)

            archive = output / "api-design" / "skill.zip"
            self.assertTrue(archive.is_file())
            with zipfile.ZipFile(archive) as zip_file:
                names = set(zip_file.namelist())
                self.assertIn("api-design/SKILL.md", names)
                self.assertIn("api-design/agents/openai.yaml", names)
                self.assertIn("api-design/references/example.md", names)
                exported_skill = zip_file.read("api-design/SKILL.md").decode("utf-8")
                self.assertNotIn("disable-model-invocation", exported_skill)
                self.assertNotIn("argument-hint", exported_skill)
                self.assertIn('name: "api-design"', exported_skill)
                self.assertIn("# API Design", exported_skill)

            manifest = json.loads((output / "manifest.json").read_text(encoding="utf-8"))
            self.assertEqual(manifest["provider"], "chatgpt")
            self.assertEqual(manifest["count"], 1)
            self.assertTrue(manifest["packages"][0]["generated_openai_yaml"])

    def test_existing_openai_yaml_is_preserved(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            skill_dir = self.make_repo(
                root,
                """---
name: api-design
description: REST API design patterns.
---
# API Design
""",
            )
            agents = skill_dir / "agents"
            agents.mkdir()
            original = 'interface:\n  display_name: "Custom API"\n  short_description: "Custom"\n'
            (agents / "openai.yaml").write_text(original, encoding="utf-8")

            output = root / "dist" / "chatgpt"
            records = provider.export_skills(root, output)
            self.assertFalse(records[0]["generated_openai_yaml"])
            with zipfile.ZipFile(output / "api-design" / "skill.zip") as zip_file:
                actual = zip_file.read("api-design/agents/openai.yaml").decode("utf-8")
            self.assertEqual(actual, original)

    def test_frontmatter_name_must_match_directory(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            self.make_repo(
                root,
                """---
name: wrong-name
description: REST API design patterns.
---
# API Design
""",
            )
            with self.assertRaises(provider.ProviderError):
                provider.verify_skills(root)

    def test_folded_description_is_supported(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            skill_dir = self.make_repo(
                root,
                """---
name: api-design
description: >-
  REST API design patterns including pagination,
  filtering, and versioning.
---
# API Design
""",
            )
            metadata = provider.validate_source_skill(skill_dir)
            self.assertEqual(
                metadata.description,
                "REST API design patterns including pagination, filtering, and versioning.",
            )


if __name__ == "__main__":
    unittest.main()
