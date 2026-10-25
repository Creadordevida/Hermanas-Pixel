"""Offline regression tests. Run: python3 -m unittest discover -s qa -p 'test_quality_gate.py'."""
import json, tempfile, unittest
from pathlib import Path
import release_gate
from sprite_scale_audit import png_size

class QualityGateTests(unittest.TestCase):
    def test_v080_assets_are_byte_identical(self):
        self.assertEqual([],release_gate.frozen_check())

    def test_090_cannot_be_approved_by_checklist_without_evidence(self):
        failures=release_gate.signoff_check()
        self.assertGreater(len(failures),100)
        self.assertTrue(any('android_device_test' in x for x in failures))

    def test_approved_reference_manifest_is_complete(self):
        data=json.loads((release_gate.QA/'baseline_080_sha256.json').read_text())
        self.assertEqual(len(data['frozen_assets']),31)
        for role in ('futbolista','bailarina','padre'):
            self.assertIn(f'assets/images/frames/{role}_walk_1.png',data['frozen_assets'])

    def test_png_dimensions_are_real(self):
        path=release_gate.ROOT/'assets/images/dog/idle.png'
        self.assertEqual((144,108),png_size(path))

    def test_no_unapproved_090_asset_is_in_reference(self):
        data=json.loads((release_gate.QA/'baseline_080_sha256.json').read_text())
        for forbidden in ('assets/images/scenes/school.png','assets/images/map_pamplona.png',
                         'assets/images/enemies/pigeon_0.png'):
            self.assertNotIn(forbidden,data['frozen_assets'])

if __name__=='__main__':unittest.main()
