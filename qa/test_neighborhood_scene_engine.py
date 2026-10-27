"""QA de la arquitectura 0.9.1; incluye pruebas NEGATIVAS deliberadas.

Esto certifica invariantes y recursos, no que el juego parezca bonito ni que
Flutter compile. Las capturas de transición siguen siendo obligatorias.
"""
import hashlib
import re
import unittest
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets/images/chapter1"
ENGINE = (ROOT / "lib/neighborhood_scene_engine.dart").read_text()
MAIN = (ROOT / "lib/main.dart").read_text()
REGION_RE = re.compile(
    r"id: '([^']+)', asset: '([^']+)', start: (\d+), end: (\d+)"
    r"|id: '([^']+)', asset: '([^']+)',\s*start: (\d+), end: (\d+)"
)
LANDMARKS = (
    "residential_curve", "green_promenade", "white_canopy", "rocket_park"
)
CONNECTORS = (
    "connector_residential_greenway_v091", "connector_neutral_park_v091"
)


def regions(source=ENGINE):
    result = []
    for match in REGION_RE.finditer(source):
        parts = match.groups()
        values = parts[:4] if parts[0] else parts[4:]
        name, asset, start, end = values
        result.append((name, asset, int(start), int(end)))
    return result


def valid_regions(items):
    return (len(items) >= 7 and items[0][2] == 0
            and items[-1][3] == 36500
            and all(end > start for _, _, start, end in items)
            and all(left[3] == right[2] for left, right in zip(items, items[1:]))
            and all(sum(row[1] == landmark for row in items) == 1
                    for landmark in LANDMARKS))


def clean_tree_cell_borders(image, tolerance=4, margin=8):
    """True iff no visible pixel crosses/crowds any equal-cell boundary."""
    if image.mode != "RGBA":
        return False
    w, h = image.size
    if w % 2 or h % 2:
        return False
    alpha = image.getchannel("A")
    guards = (
        (0, 0, margin, h),
        (w-margin, 0, w, h),
        (0, 0, w, margin),
        (0, h-margin, w, h),
        (w//2-margin, 0, w//2+margin, h),
        (0, h//2-margin, w, h//2+margin),
    )
    return all(alpha.crop(area).getextrema()[1] <= tolerance for area in guards)


class NeighborhoodEngineQA(unittest.TestCase):
    def test_regions_are_continuous_and_landmarks_unique(self):
        found = regions()
        self.assertTrue(valid_regions(found), found)
        self.assertEqual(7, len(found))
        self.assertEqual(
            [r[1] for r in found if r[1] in LANDMARKS],
            list(LANDMARKS),
        )

    def test_negative_gap_duplicate_and_overlap_are_rejected(self):
        original = regions()
        gap = original.copy()
        name, asset, start, end = gap[2]
        gap[2] = (name, asset, start + 3, end)
        self.assertFalse(valid_regions(gap))
        overlap = original.copy()
        name, asset, start, end = overlap[1]
        overlap[1] = (name, asset, start - 3, end)
        self.assertFalse(valid_regions(overlap))
        duplicate = original.copy()
        name, _, start, end = duplicate[5]
        duplicate[5] = (name, LANDMARKS[0], start, end)
        self.assertFalse(valid_regions(duplicate))

    def test_all_visual_regions_are_real_high_quality_assets(self):
        content_hashes = {}
        for _, asset, _, _ in regions():
            path = ASSETS / f"{asset}.png"
            self.assertTrue(path.is_file(), path)
            self.assertGreater(path.stat().st_size, 300_000)
            with Image.open(path) as image:
                self.assertGreaterEqual(image.width, 1600)
                self.assertGreaterEqual(image.height, 700)
            digest = hashlib.sha256(path.read_bytes()).hexdigest()
            if asset in LANDMARKS:
                self.assertNotIn(digest, content_hashes.values())
            content_hashes[asset] = digest
        self.assertEqual(7, len(content_hashes))

    def test_world_boundary_is_localised_without_opaque_jump(self):
        segment = MAIN.split("void _neighborhoodJoin(", 1)[1].split(
            'void _neighborhoodBackground(', 1)[0]
        self.assertIn('BlendMode.dstIn', segment)
        self.assertIn('neighborhoodSeamHalfWidth', segment)
        self.assertIn('canvas.clipRect(area)', segment)
        self.assertIn('ui.Gradient.linear',segment)
        self.assertNotIn('withValues(alpha:fade)', segment)
        self.assertNotIn('canvas.scale(-1,1)', segment)

    def test_new_separated_trees_are_real_and_non_overlapping(self):
        path = ASSETS / "trees_separated_v091.png"
        with Image.open(path) as image:
            self.assertTrue(clean_tree_cell_borders(image), image.size)
            self.assertEqual(image.getchannel("A").getextrema()[0], 0)
            cell_width, cell_height = image.width//2, image.height//2
            for row in (0, 1):
                for col in (0, 1):
                    box = (col*cell_width, row*cell_height,
                           (col+1)*cell_width, (row+1)*cell_height)
                    self.assertIsNotNone(image.crop(box).getchannel("A").getbbox())

    def test_negative_corrupted_alpha_atlas_is_rejected(self):
        with Image.open(ASSETS / "trees_separated_v091.png") as loaded:
            image = loaded.copy()
        image.putpixel((image.width//2, image.height//4), (255, 20, 20, 255))
        self.assertFalse(clean_tree_cell_borders(image))


if __name__ == "__main__":
    unittest.main()
