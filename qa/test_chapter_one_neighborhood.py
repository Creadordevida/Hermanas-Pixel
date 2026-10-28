"""Contract tests for chapter-one *real game assets*, not concept renders.

These verify geography, asset integrity and forbidden repetition. They do NOT
claim to certify the visual result or substitute for Flutter/Android captures.
"""
import hashlib
import re
import unittest
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SCENES = ROOT / 'assets/images/chapter1'
LAYOUT = (ROOT / 'lib/chapter_one_layout.dart').read_text()
MAIN = (ROOT / 'lib/main.dart').read_text()
ENGINE = (ROOT / 'lib/neighborhood_scene_engine.dart').read_text()


def zone_rows(source=ENGINE):
    """Lee la ÚNICA geografía: el renderer. Spawn zones are derived in Dart.

    Conservamos el contrato de cuatro hitos, pero no exigimos duplicar
    los números en otra tabla (que fue precisamente el error anterior).
    """
    regions = source.split('const neighborhoodSceneRegions =',1)[1].split('];',1)[0]
    rows = [
        (name, asset, int(start), int(end), 'connector: true' in rest)
        for name, asset, start, end, rest in re.findall(
            r"id:\s*'([^']+)',\s*asset:\s*'([^']+)',\s*"
            r"start:\s*(\d+),\s*end:\s*(\d+)([^)]*)\)",
            regions,
        )
    ]
    landmarks = [row for row in rows if not row[4]]
    return [
        (row[0],row[1],row[2],landmarks[i+1][2] if i+1<len(landmarks) else rows[-1][3])
        for i,row in enumerate(landmarks)
    ]


def zones_valid(rows):
    return (len(rows) == 4 and rows[0][2] == 0 and rows[-1][3] == 36500
            and len({r[0] for r in rows}) == 4
            and len({r[1] for r in rows}) == 4
            and all(row[3] > row[2] for row in rows)
            and all(a[3] == b[2] for a, b in zip(rows, rows[1:])))


class NeighborhoodChapterOneQA(unittest.TestCase):
    def test_real_photo_landmarks_each_appear_once(self):
        rows = zone_rows()
        self.assertTrue(zones_valid(rows), rows)
        self.assertEqual(
            [r[1] for r in rows],
            ['residential_curve', 'green_promenade', 'white_canopy', 'rocket_park'],
        )

    def test_negative_duplicate_landmark_is_rejected(self):
        original = zone_rows()
        duplicate = original.copy()
        duplicate[2] = (duplicate[2][0], original[0][1], duplicate[2][2], duplicate[2][3])
        self.assertFalse(zones_valid(duplicate))

    def test_scenes_are_distinct_nonblank_landscape_assets(self):
        hashes = []
        for _, asset, _, _ in zone_rows():
            path = SCENES / (asset + '.png')
            self.assertTrue(path.is_file(), path)
            self.assertGreater(path.stat().st_size, 500_000)
            with Image.open(path) as image:
                self.assertGreaterEqual(image.width, 1600)
                self.assertGreaterEqual(image.height, 900)
                self.assertIn(image.mode, ('RGB', 'RGBA'))
            hashes.append(hashlib.sha256(path.read_bytes()).hexdigest())
        self.assertEqual(4, len(set(hashes)))

    def test_separated_tree_atlas_is_not_a_fake_backdrop(self):
        # El atlas antiguo se conserva como referencia histórica, pero NO se
        # debe seguir usando: sus objetos invadían las celdas adyacentes.
        with Image.open(SCENES / 'trees_separated_v091.png') as image:
            self.assertEqual(image.mode, 'RGBA')
            self.assertEqual(image.width % 2, 0)
            self.assertEqual(image.height % 2, 0)
            alpha = image.getchannel('A')
            self.assertIsNotNone(alpha.getbbox())
            self.assertLessEqual(alpha.getpixel((image.width // 2, image.height // 4)), 4)

    def test_vistas_do_not_repeat_or_fullscreen_dissolve(self):
        area = MAIN.split('void _neighborhoodVista(', 1)[1].split(
            'void _activityProps(', 1)[0]
        self.assertIn('neighborhoodPanFraction(panel, cameraX)', area)
        self.assertIn('neighborhoodViewSourceWidth(panel.asset)', area)
        self.assertIn('canvas.clipRect(area)', area)
        self.assertNotIn('sourceX=maxX*progress', area)
        self.assertNotIn('withValues(alpha:fade)', area)
        self.assertNotIn('canvas.scale(-1,1)', area)
        self.assertIn('if(stage == 0) {\n      _neighborhoodBackground(canvas);', MAIN)

    def test_props_and_physics_use_world_coordinates(self):
        self.assertIn('worldX-cameraX', MAIN)
        self.assertIn('if (foreground) return', MAIN)
        self.assertIn('neighborhoodTreeAllowedAt(worldX)', MAIN)
        self.assertIn('neighborhoodLandmarkInCamera(cameraX, viewW)', MAIN)
        self.assertIn('375 - height', MAIN)
        self.assertIn('_layoutNeighborhood()', MAIN)
        self.assertIn('Obstacle(x,groundY-h', MAIN)
        self.assertIn('Rect.fromLTWH(x,top,132,15)', MAIN)
        self.assertIn('images[\'ground_$stage\']', MAIN)
        self.assertIn('assets/images/chapter1/', (ROOT / 'pubspec.yaml').read_text())

    def test_flutter_capture_covers_all_zones_and_both_sides_of_seams(self):
        code = (ROOT / 'test/qa_render_capture_test.dart').read_text()
        for name in ('barrio_residencial', 'barrio_paseo',
                     'barrio_cubierta', 'barrio_cohete'):
            self.assertIn(name, code)
        for seam in (1, 2, 3, 4, 5, 6):
            for side in ('antes', 'despues'):
                self.assertIn(f'barrio_union_{seam}_{side}', code)
        workflow = (ROOT / '.github/workflows/build.yml').read_text()
        self.assertNotIn('continue-on-error: true', workflow)


if __name__ == '__main__':
    unittest.main()
