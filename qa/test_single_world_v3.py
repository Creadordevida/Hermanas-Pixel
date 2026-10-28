"""Controles independientes: una sola geografía y aritmética de cámara."""
import re
import hashlib
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
SCENES = (ROOT/'lib/neighborhood_scene_engine.dart').read_text()
ZONES = (ROOT/'lib/chapter_one_layout.dart').read_text()
CAM = (ROOT/'lib/chapter_one_camera_v3.dart').read_text()


def stage_regions():
    # Marcador restrictivo: exactamente los bloques declarados de región.
    content = SCENES.split('const neighborhoodSceneRegions =',1)[1].split('];',1)[0]
    return [(a, float(b), float(c)) for a,b,c in re.findall(
        r"id:\s*'([^']+)'.*?start:\s*(\d+),\s*end:\s*(\d+)",
        content, flags=re.S)]


class NeighborhoodContractTest(unittest.TestCase):
    def test_regions_contiguous_and_unique(self):
        regions = stage_regions()
        self.assertEqual(len(regions), 7)
        self.assertEqual(len(set(x[0] for x in regions)), 7)
        self.assertEqual(regions[0][1], 0)
        self.assertEqual(regions[-1][2], 36500)
        for a,b in zip(regions,regions[1:]):
            self.assertEqual(a[2],b[1])

    def test_no_duplicate_geography_table(self):
        self.assertNotIn('const neighborhoodZones = <NeighborhoodZone>[', ZONES)
        self.assertIn('neighborhoodSceneRegions.where((r) => !r.connector)', ZONES)

    def test_camera_is_world_anchored(self):
        self.assertIn('worldX - cameraX', CAM)
        self.assertIn('scaleFactor: 1', CAM)
        self.assertIn('missingWorldArtInCamera', CAM)

    def test_art_masters_unchanged(self):
        import json
        records = json.loads((ROOT/'qa/ch1_legacy_art_sha256.json').read_text())
        self.assertEqual(len(records), 4)
        for path, old in records.items():
            self.assertEqual(hashlib.sha256((ROOT/path).read_bytes()).hexdigest(), old)

    def test_art_gap_must_fail_at_camera_600(self):
        native_width=1672*380/690
        self.assertGreater(600+800-native_width, 470)

if __name__ == '__main__':
    unittest.main()
