"""Offline regression guardrails for expensive GitHub Flutter capture jobs.

These checks cannot replace `flutter analyze` or `flutter test`. Their purpose
is to prevent the avoidable 2026-10-26 regressions from returning when the
authoring environment has no installed Flutter SDK.
"""

from pathlib import Path
import unittest
import yaml


ROOT = Path(__file__).resolve().parents[1]


class FlutterCaptureGuardrails(unittest.TestCase):
    def test_outfits_load_once_for_both_chapters(self):
        source = (ROOT / 'test/qa_outfits_capture_test.dart').read_text()
        self.assertEqual(source.count('testWidgets('), 1)
        self.assertIn('final gameKey = GlobalKey()', source)
        self.assertIn('key: gameKey', source)
        self.assertIn('if (index == 0)', source)
        self.assertIn('stage: 4', source)
        self.assertIn('stage: 5', source)

    def test_outfits_have_realistic_timeout_and_async_capture(self):
        source = (ROOT / 'test/qa_outfits_capture_test.dart').read_text()
        self.assertIn('attempt < 225', source)
        self.assertIn('Duration(milliseconds: 400)', source)
        self.assertIn('tester.runAsync<int>', source)
        self.assertIn('boundary.toImage', source)
        self.assertIn('Duration(seconds: 20)', source)

    def test_fast_flutter_checks_precede_costly_apk_and_visual_checks(self):
        workflow = (ROOT / '.github/workflows/build.yml').read_text()
        game_analysis = workflow.index('flutter analyze --no-pub lib')
        test_analysis = workflow.index('flutter analyze --no-pub test')
        unit_tests = workflow.index('flutter test test/asset_integrity_test.dart')
        apk_build = workflow.index('flutter build apk --release')
        upload = workflow.index('name: Miren-y-Sara-')
        render_capture = workflow.index('test/qa_outfits_capture_test.dart')
        self.assertLess(game_analysis, test_analysis)
        self.assertLess(test_analysis, unit_tests)
        self.assertLess(unit_tests, apk_build)
        self.assertLess(apk_build, upload)
        self.assertLess(upload, render_capture)

    def test_heavy_render_tests_do_not_compete_for_resources(self):
        workflow = (ROOT / '.github/workflows/build.yml').read_text()
        self.assertIn('flutter test --concurrency=1 ', workflow)
        config = yaml.safe_load(workflow)
        qa_timeout = int(config['jobs']['qa-graficos-flutter']['timeout-minutes'])
        self.assertGreaterEqual(qa_timeout, 18)
        self.assertLessEqual(qa_timeout, 25)
        self.assertNotIn('timeout-minutes: 30', workflow)
        self.assertIn('qa-graficos-flutter:', workflow)
        self.assertIn('needs: android-apk-candidato', workflow)

    def test_wildlife_and_jump_screenshots_use_real_async_for_disk_io(self):
        # Both tests once rendered inside runAsync but wrote their PNG files
        # outside it, leaving Flutter Test's FakeAsync stuck for ten minutes.
        for relative in (
            'test/qa_wildlife_render_test.dart',
            'test/qa_jump_render_test.dart',
        ):
            with self.subTest(test=relative):
                source = (ROOT / relative).read_text()
                self.assertIn('tester.runAsync<int>', source)
                self.assertIn('await file.writeAsBytes(', source)
                self.assertIn('return await file.length().timeout(', source)
                self.assertIn('Duration(seconds:20)', source.replace(' ', ''))

    def test_no_unawaited_file_length_return_inside_capture_try_blocks(self):
        # Flutter's analyzer raises unawaited_return_in_try_block if a Future
        # escapes a try/finally without `await`. This blocked RC8 REV2 after
        # the APK had already been built.
        for relative in (
            'test/qa_wildlife_render_test.dart',
            'test/qa_jump_render_test.dart',
            'test/qa_outfits_capture_test.dart',
        ):
            with self.subTest(test=relative):
                source = (ROOT / relative).read_text()
                self.assertNotIn('return file.length().timeout(', source)
                self.assertNotIn('return out.length().timeout(', source)
                self.assertTrue(
                    'return await file.length().timeout(' in source or
                    'return await out.length().timeout(' in source
                )


if __name__ == '__main__':
    unittest.main()
