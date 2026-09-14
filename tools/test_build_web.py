import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
from build_web import export_project, validate_export

class WebBuildTests(unittest.TestCase):
    def test_export_bundles_reader_assets_from_committed_source(self):
        from build_web import install_guide_reader
        with tempfile.TemporaryDirectory() as folder:
            stage=Path(folder)/'source'; web=Path(folder)/'web'
            (stage/'web').mkdir(parents=True); web.mkdir()
            for name in ('guide-reader.js','guide-reader.css'):
                (stage/'web'/name).write_text('committed '+name)
            install_guide_reader(stage,web)
            for name in ('guide-reader.js','guide-reader.css'):
                self.assertEqual((web/name).read_text(),'committed '+name)
            (stage/'web/guide-reader.js').unlink()
            with self.assertRaises(FileNotFoundError):install_guide_reader(stage,web)

    def test_existing_output_is_never_overwritten(self):
        with tempfile.TemporaryDirectory() as folder:
            output=Path(folder); marker=output/'player-save';marker.write_text('keep')
            with patch('build_web.prepare_tree') as stage:
                with self.assertRaises(FileExistsError):export_project('HEAD',output,'unused')
                stage.assert_not_called()
            self.assertEqual(marker.read_text(),'keep')

    def test_incomplete_or_invalid_runtime_is_not_deliverable(self):
        with tempfile.TemporaryDirectory() as folder:
            web=Path(folder)
            for name in ['index.html','index.js','index.pck']: (web/name).write_bytes(b'content')
            with self.assertRaises(ValueError):validate_export(web)
            (web/'index.wasm').write_bytes(b'not a wasm program')
            with self.assertRaises(ValueError):validate_export(web)
            (web/'index.wasm').write_bytes(b'\x00asm\x01\x00\x00\x00')
            validate_export(web)
            (web/'index.pck').write_bytes(b'')
            with self.assertRaises(ValueError):validate_export(web)

if __name__=='__main__':unittest.main()
