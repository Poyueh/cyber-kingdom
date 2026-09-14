import io
import tarfile
from unittest.mock import patch
import sys
import tempfile
import unittest
from pathlib import Path
from build_desktop import ROOT, prepare_tree, run_logged

class DesktopBuildTests(unittest.TestCase):
    def test_staging_sets_playable_entry_and_apple_textures_without_touching_checkout(self):
        before = (ROOT / "project.godot").read_bytes()
        with tempfile.TemporaryDirectory() as folder:
            stage = Path(folder)
            project_bytes = b'[application]\nconfig/name="Test"\nrun/main_scene="res://scenes/training.tscn"\n[rendering]\n'
            archive_bytes = io.BytesIO()
            with tarfile.open(fileobj=archive_bytes, mode="w") as archive:
                member = tarfile.TarInfo("project.godot")
                member.size = len(project_bytes)
                archive.addfile(member, io.BytesIO(project_bytes))
            with patch("build_desktop.git", side_effect=[b"source-tree", archive_bytes.getvalue()]):
                prepare_tree("HEAD", stage)
            project = (stage / "project.godot").read_text()
            self.assertIn('run/main_scene="res://scenes/start_menu.tscn"', project)
            self.assertIn("textures/vram_compression/import_etc2_astc=true", project)
            self.assertIn('config/icon="res://art/ui/app-icon.svg"', project)
            self.assertEqual((ROOT / "project.godot").read_bytes(), before)

    def test_godot_error_with_zero_exit_code_stops_the_build(self):
        with tempfile.TemporaryDirectory() as folder:
            log = Path(folder) / "engine.log"
            with self.assertRaises(RuntimeError):
                run_logged([sys.executable, "-c", "print('SCRIPT ERROR: missing texture')"], log)
            self.assertIn("missing texture", log.read_text())

if __name__ == "__main__":
    unittest.main()
