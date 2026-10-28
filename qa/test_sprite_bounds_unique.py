"""Regression guard: a Dart const map may not repeat sprite keys.
Validate ALL generated poses against the actual PNG alpha footprints.
"""
import hashlib
import json
import re
import unittest
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
DART = ROOT / 'lib' / 'sprite_bounds.g.dart'
REPORT = ROOT / 'qa' / 'ENEMY_VISIBLE_BOUNDS.json'
ASSETS = ROOT / 'assets' / 'images' / 'enemies'
EXPECTED_KINDS = (
    'goalkeeper', 'rival', 'referee', 'novice', 'breakdancer',
    'pigeon', 'cat', 'rat', 'bully', 'teacher', 'statue',
)
PATTERN = re.compile(r"^\s*'(?P<name>[a-z]+_[0-4])': Rect\.fromLTWH\(" 
                     r"(?P<x>[\d.]+), (?P<y>[\d.]+), "
                     r"(?P<w>[\d.]+), (?P<h>[\d.]+)\),$", re.M)


def parse_bounds(text):
    """Return every entry, not a dict (a dict would silently hide duplicates)."""
    return [(m.group('name'), tuple(float(m.group(n)) for n in ('x','y','w','h')))
            for m in PATTERN.finditer(text)]


class GeneratedSpriteBoundsTests(unittest.TestCase):
    def test_no_duplicate_keys_and_exact_55_frames(self):
        entries = parse_bounds(DART.read_text())
        keys = [key for key, _ in entries]
        self.assertEqual(len(keys), len(set(keys)), 'Duplicate Dart const map keys')
        expected = {f'{name}_{i}' for name in EXPECTED_KINDS for i in range(5)}
        self.assertEqual(set(keys), expected)
        self.assertEqual(len(keys), 55)

    def test_report_and_dart_match_real_png_pixels(self):
        entries = dict(parse_bounds(DART.read_text()))
        report = json.loads(REPORT.read_text())
        self.assertEqual(set(entries), set(report))
        for key, entry in report.items():
            with self.subTest(sprite=key):
                file = ASSETS / f'{key}.png'
                self.assertTrue(file.is_file(), f'Missing source PNG: {file}')
                self.assertEqual(hashlib.sha256(file.read_bytes()).hexdigest(), entry['sha256'])
                with Image.open(file) as im:
                    im = im.convert('RGBA')
                    box = im.getchannel('A').getbbox()
                self.assertIsNotNone(box)
                l,t,r,b = box
                expected = (float(l),float(t),float(r-l),float(b-t))
                self.assertEqual(entries[key], expected)
                self.assertEqual(entry['bounds'], list(map(int, expected)))

    def test_guard_detects_repeated_key(self):
        sample = """const x = {
  'goalkeeper_0': Rect.fromLTWH(0.0, 2.0, 57.0, 99.0),
  'goalkeeper_0': Rect.fromLTWH(0.0, 2.0, 57.0, 99.0),
};"""
        keys = [key for key, _ in parse_bounds(sample)]
        self.assertNotEqual(len(keys), len(set(keys)))

if __name__ == '__main__':
    unittest.main()
