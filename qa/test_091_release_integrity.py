"""Off-device constraints for a reproducible 0.9.1 test candidate.

Passing these tests does not certify an artistic result or an Android APK.
"""
import hashlib
import unittest
from pathlib import Path
from PIL import Image
import yaml

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'assets/images'
MASTER_SHA256 = {
    'residential_curve.png': '8486df5a23d069e659014d8cfc35aef70a6b39eb20e67d56e1183ca2c0b61699',
    'green_promenade.png': '56dc3f61a5f948685d863cf9e1484f70ba552b0f9750f127bc07e93d017d043f',
    'white_canopy.png': '7bef4349c693fda57ee571b2ff5aef6bbfbe510e668bf84a217bcb00901c0494',
    'rocket_park.png': 'a4d0cdfe9d72d3bf5be76b9cc5eb139ef6a6ffe3ba048bec9688bb93aaff788e',
}

class Rc091Regression(unittest.TestCase):
    def test_four_art_masters_are_byte_identical(self):
        for file, expected_hash in MASTER_SHA256.items():
            data=(ASSETS/'chapter1'/file).read_bytes()
            self.assertEqual(hashlib.sha256(data).hexdigest(), expected_hash, file)

    def test_new_linking_assets_are_real_and_have_distinct_hashes(self):
        names = [
            'connector_residential_greenway_v091.png',
            'connector_neutral_park_v091.png',
            'connector_pergola_v091.png',
        ]
        hashes = []
        for name in names:
            path=ASSETS/'chapter1'/name
            self.assertTrue(path.is_file(),name)
            with Image.open(path) as artwork:
                self.assertGreaterEqual(artwork.width,1800)
                self.assertGreater(artwork.height,650)
            hashes.append(hashlib.sha256(path.read_bytes()).hexdigest())
        self.assertEqual(len(set(hashes)),3)
        engine=(ROOT/'lib/neighborhood_scene_engine.dart').read_text()
        self.assertIn("'connector_pergola_v091'",engine)
        main=(ROOT/'lib/main.dart').read_text()
        self.assertIn("paths['neighborhood_connector_pergola_v091']",main)

    def test_title_original_kept_and_protagonists_preserved(self):
        approved=Image.open(ASSETS/'title_approved.png').convert('RGB')
        edited=Image.open(ASSETS/'title_cars_fixed_091.png').convert('RGB')
        self.assertEqual(approved.size, edited.size)
        # Every pixel of the protagonists, father and title outside the small
        # car strip is identically preserved.
        for box in ((0,0,670,617),(670,0,1098,420),(0,544,1098,617)):
            self.assertEqual(approved.crop(box).tobytes(),edited.crop(box).tobytes())
        self.assertNotEqual(approved.tobytes(),edited.tobytes())

    def test_true_corporate_logo_contains_transparency(self):
        logo=Image.open(ASSETS/'twc_corporate_verified_091.png').convert('RGBA')
        lo,hi=logo.getchannel('A').getextrema()
        self.assertEqual(lo,0);self.assertEqual(hi,255)
        self.assertGreater(logo.width,800)

    def test_world_panels_move_with_camera_and_tree_crops_keep_roots(self):
        code=(ROOT/'lib/main.dart').read_text()
        engine=(ROOT/'lib/neighborhood_scene_engine.dart').read_text()
        self.assertIn('panel.start - cameraX',code)
        self.assertIn('panel.end - cameraX',code)
        self.assertIn('sourceHeight * panel.width / 380',code)
        self.assertIn('source: src',code)
        self.assertIn('neighborhoodBackdropPanelsValid()',engine)
        self.assertNotIn('sourceX=maxX*progress',code)

    def test_github_ci_pins_tools_and_has_fast_fail_preflight(self):
        doc=(ROOT/'.github/workflows/build.yml').read_text()
        data=yaml.safe_load(doc)
        self.assertEqual(data['jobs']['android-apk-candidato']['runs-on'],'ubuntu-24.04')
        self.assertEqual(doc.count("flutter-version: '3.47.8'"),2)
        self.assertLess(doc.index('flutter analyze --no-pub test'),doc.index('flutter build apk --release'))
        self.assertIn('timeout-minutes: 18',doc)
        self.assertNotIn('continue-on-error: true',doc)
        pubspec=(ROOT/'pubspec.yaml').read_text()
        self.assertIn('version: 0.9.1-rc.1+31',pubspec)
        self.assertIn('shared_preferences: 2.3.2',pubspec)

if __name__ == '__main__':unittest.main()
