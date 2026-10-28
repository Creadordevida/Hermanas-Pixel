"""Evita perder por accidente el patrón de cámara y paralaje aprobado.

El contrato NO aprueba imágenes artísticamente ni impide cambios intencionados:
para rediseños deliberados, actualizar documento, contrato, pruebas y vídeos.
"""
import json
import re
import unittest
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / 'docs/TWC_PARALLAX_2D_METODO_APROBADO_RC3_FIX2.md'
META = ROOT / 'docs/twc_parallax_rc3_fix2_contrato.json'


def dart_const(code, name):
    match = re.search(r'\bconst\s+(?:double|int)\s+' + re.escape(name) +
                      r'\s*=\s*([0-9]+(?:\.[0-9]+)?)\s*;', code)
    if match is None:
        raise AssertionError(f'Constante Dart desaparecida: {name}')
    return float(match.group(1))


class ApprovedParallaxContract(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.data = json.loads(META.read_text(encoding='utf-8'))
        cls.engine = (ROOT / 'lib/main.dart').read_text(encoding='utf-8')
        cls.model = (ROOT / 'lib/chapter_one_world_tiles.dart').read_text(encoding='utf-8')
        cls.generator = (ROOT / 'tools/build_ch1_parallax.py').read_text(encoding='utf-8')

    def test_source_and_document_are_present(self):
        self.assertTrue(DOC.is_file())
        self.assertIn('Método de movimiento 2D aprobado', DOC.read_text(encoding='utf-8'))
        self.assertIn('las siete', DOC.read_text(encoding='utf-8').lower())

    def test_physical_world_anchors_camera_1_to_1(self):
        d = self.data['world']
        for constant, expected in [
            ('ch1PhysicalWidth', d['length']),
            ('ch1PhysicalHeight', d['backdrop_height']),
            ('ch1PhysicalTileCount', d['near_tile_count']),
            ('ch1PhysicalTileWidth', d['near_tile_width']),
        ]:
            self.assertEqual(dart_const(self.model, constant), expected)
        self.assertEqual(d['near_tile_width'] * (d['near_tile_count'] - 1) +
                         d['last_tile_width'], d['length'])
        self.assertIn('ch1PhysicalTileX(index)-cameraX', self.engine)
        self.assertIn('ch1PhysicalVisibleTiles(cameraX', self.engine)

    def test_cycle_constants_and_equations(self):
        f, m = self.data['far'], self.data['mid']
        for name, expected in [('ch1FarSpeed', f['speed']),
                               ('ch1MidSpeed', m['speed']),
                               ('ch1FarCycleWidth', f['width']),
                               ('ch1MidCycleWidth', m['width'])]:
            self.assertAlmostEqual(dart_const(self.model, name), expected)
        self.assertIn('(cameraX*speed)%width', self.engine)
        self.assertAlmostEqual(f['width']/f['speed'], f['world_repeat_distance'])
        self.assertAlmostEqual(m['width']/m['speed'], m['world_repeat_distance'])
        dist = self.data['reference_camera_advance']
        self.assertAlmostEqual(dist*f['speed'], self.data['expected_layer_displacement']['far'])
        self.assertAlmostEqual(dist*m['speed'], self.data['expected_layer_displacement']['mid'])
        self.assertEqual(dist, self.data['expected_layer_displacement']['near'])

    def test_layer_render_order_and_theme_assets(self):
        for expression in [
            "_drawCh1Loop(canvas,images['ch1_far_city_loop'],ch1FarSpeed)",
            "_drawCh1Loop(canvas,images['ch1_mid_woodland_loop'],ch1MidSpeed)",
            "for (final index in ch1PhysicalVisibleTiles(cameraX",
        ]:
            self.assertIn(expression, self.engine)
        a = self.engine.index("_drawCh1Loop(canvas,images['ch1_far_city_loop'],ch1FarSpeed)")
        b = self.engine.index("_drawCh1Loop(canvas,images['ch1_mid_woodland_loop'],ch1MidSpeed)")
        c = self.engine.index('for (final index in ch1PhysicalVisibleTiles(cameraX')
        self.assertLess(a,b)
        self.assertLess(b,c)
        for plane in ('far','mid'):
            p = self.data[plane]
            with Image.open(ROOT/p['asset']) as im:
                self.assertEqual(im.size,(p['width'],p['height']))
                self.assertEqual(im.mode,p['format'])
        self.assertIn("SEED=20261028", self.generator)
        self.assertIn("W,H,TW=36500,380,512", self.generator)

    def test_approved_technique_distinguishes_known_art_faults(self):
        self.assertIn('ghost buildings', self.data['explicitly_not_approved'])
        self.assertIn('multilayer scrolling', self.data['approved'])


if __name__ == '__main__':
    unittest.main()