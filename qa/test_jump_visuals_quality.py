"""Source/asset regression checks for improvement #8.

No claim about real Flutter or Android captures is made by these tests.
"""
import hashlib
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CODE = (ROOT / 'lib/main.dart').read_text()
VIS = (ROOT / 'lib/jump_visuals.dart').read_text()
CAP = (ROOT / 'test/qa_jump_render_test.dart').read_text()
PIPE = (ROOT / '.github/workflows/build.yml').read_text()
MANIFEST = json.loads((ROOT / 'qa/JUMP_QA_MANIFEST.json').read_text())


class JumpQuality(unittest.TestCase):
    def test_all_eighteen_approved_hero_images_are_bit_identical(self):
        for relative, expected in MANIFEST['original_art_preserved_sha256'].items():
            with self.subTest(sprite=relative):
                asset = ROOT / 'assets/images' / relative
                self.assertTrue(asset.is_file())
                self.assertEqual(expected, hashlib.sha256(asset.read_bytes()).hexdigest())

    def test_both_shadow_ovals_are_projected_to_floor_not_foot_y(self):
        self.assertIn('final floorAtX=shadowSurfaceY(', CODE)
        self.assertIn('center:Offset(x,floorAtX+3)', CODE)
        self.assertIn('center:Offset(x,floorAtX+4)', CODE)
        self.assertNotIn('center:Offset(x,c.y+3)', CODE)
        self.assertNotIn('center:Offset(x,c.y+4)', CODE)
        self.assertIn('footY:c.y', CODE)
        self.assertIn('surface.top < footY - 1', VIS)
        self.assertIn('jumpShadowScale(altitude)', CODE)
        self.assertIn('jumpShadowAlpha(altitude)', CODE)

    def test_landings_are_detected_from_actual_physics_not_clock_cycle(self):
        self.assertIn('final wasGrounded=hero.grounded;', CODE)
        self.assertIn('final speedBeforeLanding=hero.vy;', CODE)
        self.assertIn('if(!wasGrounded && hero.grounded && speedBeforeLanding > 65)', CODE)
        self.assertIn('hero.landedAt=time;', CODE)
        self.assertIn('hero.jumpedAt=time;', CODE)
        self.assertIn('JumpVisualPhase.falling', CODE)
        self.assertIn('JumpVisualPhase.impact', CODE)
        self.assertIn('JumpVisualPhase.recovery', CODE)

    def test_real_engine_captures_are_mandatory_in_ci(self):
        self.assertIn('flutter test test/qa_render_capture_test.dart', PIPE)
        self.assertIn('test/qa_jump_render_test.dart', PIPE)
        self.assertIn('test/jump_visuals_test.dart', PIPE)
        self.assertIn('await boundary.toImage(pixelRatio:1.0)', CAP)
        self.assertIn("['idle','takeoff','rising','apex','falling','impact','recovery']", CAP)
        self.assertIn('sombra_plataforma', CAP)
        self.assertNotIn('continue-on-error', PIPE)


if __name__ == '__main__':
    unittest.main()
