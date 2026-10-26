"""Offline regression guardrails for expensive GitHub Flutter capture jobs.

These checks cannot replace `flutter analyze` or `flutter test`. Their purpose
is to prevent the avoidable 2026-10-26 regressions from returning when the
authoring environment has no installed Flutter SDK.
"""

from pathlib import Path
import unittest


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

    def test_apk_is_available_before_visual_checks(self):
        workflow = (ROOT / '.github/workflows/build.yml').read_text()
        apk_build = workflow.index('flutter build apk --release')
        upload = workflow.index('name: Miren-y-Sara-')
        test_analysis = workflow.index('flutter analyze --no-pub test')
        render_capture = workflow.index('test/qa_outfits_capture_test.dart')
        self.assertLess(apk_build, upload)
        self.assertLess(upload, test_analysis)
        self.assertLess(test_analysis, render_capture)

    def test_heavy_render_tests_do_not_compete_for_resources(self):
        workflow = (ROOT / '.github/workflows/build.yml').read_text()
        self.assertIn('flutter test --concurrency=1 ', workflow)
        self.assertIn('timeout-minutes: 30', workflow)
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
                self.assertIn('return file.length().timeout(', source)
                self.assertIn('Duration(seconds:20)', source.replace(' ', ''))


if __name__ == '__main__':
    unittest.main()
