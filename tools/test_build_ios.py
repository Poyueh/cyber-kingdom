import json
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch
from build_ios import configured_preset, developer_environment, export_project, preflight, validate_export, validate_identifiers
from build_desktop import run_logged

ROOT=Path(__file__).resolve().parent.parent

class IOSExportTests(unittest.TestCase):
    def test_command_line_tools_cannot_pass_as_full_xcode(self):
        with tempfile.TemporaryDirectory() as folder:
            with self.assertRaisesRegex(ValueError,'完整 Xcode'):
                developer_environment(Path(folder))

    def test_explicit_xcode_is_local_to_subprocess_environment(self):
        original=os.environ.get('DEVELOPER_DIR')
        with tempfile.TemporaryDirectory() as folder:
            app=Path(folder)/'Xcode With Spaces.app'
            developer=app/'Contents/Developer'
            (developer/'usr/bin').mkdir(parents=True)
            (developer/'usr/bin/xcodebuild').touch()
            (developer/'Platforms/iPhoneOS.platform').mkdir(parents=True)
            env=developer_environment(app)
            self.assertEqual(env['DEVELOPER_DIR'],str(developer.resolve()))
            self.assertEqual(os.environ.get('DEVELOPER_DIR'),original)
            with tempfile.TemporaryDirectory() as output:
                log=Path(output)/'env.log'
                run_logged([sys.executable,'-c','import os; print(os.environ["DEVELOPER_DIR"])'],log,env=env)
                self.assertEqual(log.read_text().strip(),str(developer.resolve()))

    def test_missing_or_injected_identifiers_are_rejected(self):
        for team,bundle in [(None,None),('Human Name','org.example.game'),('ABCDEFGHIJ','bad_id'),('ABCDEFGHIJ','org.game\napplication/export_project_only=false')]:
            with self.subTest(team=team,bundle=bundle):
                with self.assertRaises(ValueError):validate_identifiers(team,bundle)

    def test_credentials_only_enter_ios_staging_section(self):
        source=(ROOT/'export_presets.cfg').read_text()
        result=configured_preset(source,'ABCDEFGHIJ','org.example.test-game')
        before=source.split('[preset.3.options]')[0]
        self.assertEqual(result.split('[preset.3.options]')[0],before)
        self.assertIn('application/app_store_team_id="ABCDEFGHIJ"',result)
        self.assertIn('application/bundle_identifier="org.example.test-game"',result)
        self.assertIn('application/export_project_only=true',result)
        self.assertEqual((ROOT/'export_presets.cfg').read_text(),source)

    def test_existing_output_never_overwritten(self):
        with tempfile.TemporaryDirectory() as folder:
            marker=Path(folder)/'user-work';marker.write_text('keep')
            with patch('build_ios.prepare_tree') as stage:
                with self.assertRaisesRegex(ValueError,'已存在'):
                    export_project('HEAD',Path(folder),'ABCDEFGHIJ','org.example.game','unused',{})
                stage.assert_not_called()
            self.assertEqual(marker.read_text(),'keep')

    def test_xcode_shell_without_game_pack_is_not_a_complete_export(self):
        with tempfile.TemporaryDirectory() as folder:
            output=Path(folder)
            (output/'CyberKingdomDemo.xcodeproj').mkdir()
            (output/'CyberKingdomDemo.xcodeproj/project.pbxproj').write_text('fixture')
            with self.assertRaises(ValueError):validate_export(output)
            (output/'CyberKingdomDemo.pck').write_bytes(b'')
            with self.assertRaises(ValueError):validate_export(output)
            (output/'CyberKingdomDemo.pck').write_bytes(b'fixture-pck')
            self.assertEqual(validate_export(output),output/'CyberKingdomDemo.xcodeproj')

    def test_check_reports_missing_setup_without_starting_export(self):
        with patch('build_ios.probe',return_value='4.7.2.stable.official.test'),patch('build_ios.developer_environment',side_effect=ValueError('missing Xcode')),patch('build_ios.prepare_tree') as export:
            report,env=preflight('test-engine')
            self.assertFalse(report['ready_for_export'])
            self.assertFalse(report['installable'])
            self.assertIn('missing Xcode',report['issues'])
            export.assert_not_called()

    def test_error_scan_remains_strict_with_custom_developer_directory(self):
        with tempfile.TemporaryDirectory() as folder:
            with self.assertRaises(RuntimeError):
                run_logged([sys.executable,'-c',"print('ERROR: invalid signing')"],Path(folder)/'error.log',env=dict(os.environ,DEVELOPER_DIR='/test-only'))

if __name__=='__main__':unittest.main()
