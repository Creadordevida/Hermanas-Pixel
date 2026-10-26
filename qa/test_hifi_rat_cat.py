"""Quality gate for the actual rat/cat sheets consumed by Flutter.

These tests would have rejected the flat RC6 silhouettes. Pixel richness and
different poses are necessary evidence, NOT automatic artistic approval.
"""
import hashlib
import json
import re
import unittest
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'assets/images'
MAIN = (ROOT / 'lib/main.dart').read_text()
BOUNDS_DART = (ROOT / 'lib/creature_sheet_bounds.dart').read_text()
MANIFEST = json.loads((ROOT / 'qa/ENEMIES_HIFI_MANIFEST.json').read_text())

FRAMES = {
    'rat': [(21, 369, 395, 173), (462, 383, 410, 159),
            (884, 383, 453, 159), (1378, 298, 313, 244),
            (1749, 438, 403, 125)],
    'cat': [(36, 254, 341, 304), (419, 263, 388, 295),
            (838, 281, 396, 277), (1272, 308, 346, 251),
            (1627, 428, 434, 138)],
}


def crop(sheet, rect):
    x, y, w, h = rect
    return sheet.crop((x, y, x + w, y + h))


def palette_detail(image):
    pixels = np.asarray(image.convert('RGBA'))
    return len(np.unique(pixels[pixels[:, :, 3] >= 180][:, :3], axis=0))


def visible_rect(sheet, region):
    x0, x1 = region
    alpha = np.asarray(sheet.getchannel('A'))
    ys, xs = np.where(alpha[:, x0:x1] >= 128)
    if not len(xs):
        return None
    return (int(xs.min()) + x0, int(ys.min()),
            int(xs.max() - xs.min() + 1), int(ys.max() - ys.min() + 1))


class HighFidelityCreatureTests(unittest.TestCase):
    def test_new_sheets_are_real_distinct_transparent_assets(self):
        hashes = []
        for kind in FRAMES:
            path = ASSETS / 'enemies_hifi' / f'{kind}_sheet.png'
            self.assertTrue(path.is_file())
            with Image.open(path) as image:
                self.assertEqual('RGBA', image.mode)
                self.assertGreater(image.width, 2000)
                self.assertGreater(image.height, 700)
                self.assertEqual(0, image.getpixel((image.width//2, 5))[3])
            hashes.append(hashlib.sha256(path.read_bytes()).hexdigest())
            self.assertEqual(MANIFEST['assets'][kind]['sha256'], hashes[-1])
        self.assertEqual(2, len(set(hashes)))
        self.assertFalse(MANIFEST['android_approved'])

    def test_every_pose_fits_its_own_source_rect(self):
        for kind, rects in FRAMES.items():
            with Image.open(ASSETS / 'enemies_hifi' / f'{kind}_sheet.png') as im:
                self.assertEqual(5, len(rects))
                for i, (x, y, w, h) in enumerate(rects):
                    with self.subTest(kind=kind, pose=i):
                        self.assertGreaterEqual(x, 0)
                        self.assertGreaterEqual(y, 0)
                        self.assertLessEqual(x+w, im.width)
                        self.assertLessEqual(y+h, im.height)
                        self.assertGreater(w, 250)
                        self.assertGreater(h, 115)
                        # The render rect must match the actual opaque sprite,
                        # not the entire atlas or transparent empty canvas.
                        self.assertEqual((x, y, w, h), visible_rect(im, (x, x+w)))
                        self.assertIn(
                            f"'{kind}_{i}': Rect.fromLTWH({x}, {y}, {w}, {h})",
                            BOUNDS_DART,
                        )

    def test_richness_negative_test_rejects_old_flat_art(self):
        for kind in FRAMES:
            with Image.open(ASSETS / 'enemies_hifi' / f'{kind}_sheet.png') as im:
                good = palette_detail(crop(im, FRAMES[kind][0]))
            with Image.open(ASSETS / 'enemies' / f'{kind}_0.png') as old:
                bad = palette_detail(old)
            with self.subTest(kind=kind):
                self.assertGreater(good, 400)
                self.assertLess(bad, 50)
                self.assertGreater(good, 20*bad)

    def test_three_walk_idle_frames_are_not_identical(self):
        for kind, rects in FRAMES.items():
            with Image.open(ASSETS / 'enemies_hifi' / f'{kind}_sheet.png') as im:
                frames = [np.asarray(crop(im, r).resize((96, 96)).convert('RGBA'),
                                     dtype=np.int16) for r in rects[:3]]
            for i in (0, 1):
                difference = np.abs(frames[i] - frames[i+1])
                self.assertGreater(float(difference[:, :, 3].mean()), 25,
                                   f'{kind} poses {i}/{i+1} are almost identical')

    def test_ground_anchor_and_proportions_are_constant_in_renderer(self):
        self.assertIn("paths['enemy_${v}_sheet']", MAIN)
        self.assertIn("hiFiCreature ? 'enemy_${foe.kind}_sheet'", MAIN)
        self.assertIn('creatureFrameBounds', MAIN)
        self.assertIn('pixelScale=targetHeight/canonical.height', MAIN)
        self.assertIn('groundY-actualHeight+airborne', MAIN)
        self.assertIn('source:visible', MAIN)
        self.assertIn("'rat': 36", BOUNDS_DART)
        self.assertIn("'cat': 76", BOUNDS_DART)
        self.assertIn('assets/images/enemies_hifi/', (ROOT/'pubspec.yaml').read_text())

    def test_original_assets_and_sprite_bounds_are_preserved(self):
        for kind in FRAMES:
            for i in range(5):
                self.assertTrue((ASSETS/'enemies'/f'{kind}_{i}.png').is_file())
        self.assertTrue((ROOT/'lib/sprite_bounds.g.dart').is_file())


if __name__ == '__main__':
    unittest.main()
