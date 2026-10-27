"""Fail-closed mechanical gates for dogs and pigeons (#9 and #11).

Artist approval and actual Flutter screenshots remain separate requirements.
"""
import hashlib
import json
import unittest
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
CODE = (ROOT / 'lib/main.dart').read_text()
BOUNDS = (ROOT / 'lib/animal_sprite_bounds.dart').read_text()
DOG = ROOT / 'assets/images/dog'
FLIGHT = ROOT / 'assets/images/enemies_hifi/pigeon_flight_sheet.png'
POSES = ('idle', 'walk', 'alert', 'run', 'bite', 'hit', 'stunned', 'defeated')


class WildlifeQuality(unittest.TestCase):
    def test_all_three_dog_coats_have_real_alpha_and_same_floor_anchors(self):
        for variant in ('', 'dalmatian/', 'doberman/'):
            with self.subTest(variant=variant):
                for pose in POSES:
                    with Image.open(DOG / variant / f'{pose}.png') as im:
                        self.assertEqual(im.size, (144, 108))
                        self.assertEqual(im.mode, 'RGBA')
                        b = im.getchannel('A').getbbox()
                        self.assertTrue(b, pose)
                        self.assertIn(f"'{pose}': Rect.fromLTRB({b[0]}, {b[1]}, {b[2]}, {b[3]})", BOUNDS)
                self.assertNotEqual(
                    (DOG / variant / 'idle.png').read_bytes(),
                    (DOG / variant / 'run.png').read_bytes())
                self.assertNotEqual(
                    (DOG / variant / 'bite.png').read_bytes(),
                    (DOG / variant / 'walk.png').read_bytes())

    def test_eight_flight_poses_are_distinct_and_not_empty(self):
        manifest = json.loads((ROOT / 'qa/WILDLIFE_QA_MANIFEST.json').read_text())
        self.assertEqual(manifest['pigeon_flight_atlas_sha256'],
                         hashlib.sha256(FLIGHT.read_bytes()).hexdigest())
        with Image.open(FLIGHT) as img:
            self.assertEqual(img.mode, 'RGBA')
            self.assertEqual(img.size, (1774, 887))
            alpha = np.asarray(img.getchannel('A'))
            signatures = set()
            for frame in range(8):
                y, x = frame // 4, frame % 4
                tile = alpha[y*443:(y+1)*443, x*443:(x+1)*443]
                self.assertGreater(int((tile > 80).sum()), 15000, frame)
                signatures.add(hashlib.sha256((tile > 80).tobytes()).hexdigest())
            self.assertEqual(len(signatures), 8, 'Wing poses repeat')

    def test_atlas_cell_gutters_cannot_bleed_neighboring_birds(self):
        alpha = np.asarray(Image.open(FLIGHT).convert('RGBA').getchannel('A'))
        for x in (443, 444, 887, 888, 1330, 1331):
            self.assertEqual(int((alpha[:, x] > 20).sum()), 0,
                             f'Frame crosses vertical divider x={x}')
        for y in (443, 444):
            self.assertEqual(int((alpha[y, :] > 20).sum()), 0,
                             f'Frame crosses horizontal divider y={y}')

    def test_flight_feet_are_measured_and_keep_scale_in_all_frames(self):
        rgba = np.asarray(Image.open(FLIGHT).convert('RGBA'))
        expected_x = (209, 277, 270, 237, 239, 250, 276, 266)
        expected_y = (368, 363, 334, 369, 325, 328, 337, 301)
        for frame in range(8):
            x0 = int((frame % 4) * 443.5)
            y0 = int((frame // 4) * 443.5)
            crop = rgba[y0:y0 + 443, x0:x0 + 443]
            red = ((crop[:, :, 0] > 125)
                   & (crop[:, :, 0] > crop[:, :, 1].astype(float) * 1.45)
                   & (crop[:, :, 0] > crop[:, :, 2].astype(float) * 1.08)
                   & (crop[:, :, 3] > 90))
            ys, xs = np.where(red)
            # Downstroke deliberately hides most of the legs behind its wing.
            self.assertGreater(len(xs), 8, frame)
            self.assertLess(abs(int(np.median(xs)) - expected_x[frame]), 14, frame)
            self.assertLess(abs(int(np.median(ys)) - expected_y[frame]), 14, frame)
        self.assertIn('pigeonAtlasWorldCell = 136;', BOUNDS)
        self.assertLess(136, 170, 'Las palomas no pueden ser gigantes')
        self.assertIn('pigeonFlightFootX[frame]*flightScale', CODE)
        self.assertIn('pigeonFlightFootY[frame]*flightScale', CODE)

    def test_ground_birds_do_not_float_and_can_fall_after_defeat(self):
        self.assertIn("animalMode = kind == 'pigeon' ? 'perch' : 'idle'", CODE)
        self.assertIn("foe.flightAltitude>1", CODE)
        self.assertIn('foe.flightAltitude-145*dt', CODE)
        self.assertIn('final airborne=0.0;', CODE)
        self.assertIn('source:pigeonFlightSource(frame)', CODE)
        self.assertIn("'pigeon_flight_sheet'", CODE)

    def test_dogs_do_not_bite_invisibly_or_slide_while_idling(self):
        self.assertIn("animalMode == 'bite'", CODE)
        self.assertIn('!biteApplied && animalTime >= .24', CODE)
        self.assertIn("_animalState('bite')", CODE)
        self.assertIn("_animalState('idle')", CODE)
        self.assertIn('groundY-h,w,h),source:source', CODE)
        self.assertIn('pixelScale=(variant==', CODE)
        self.assertNotIn('foe.t%1>.5?', CODE)


if __name__ == '__main__':
    unittest.main()
