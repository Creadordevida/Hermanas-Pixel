"""Guards for layered physical stage: image paths, alpha and wrap geometry.
Executed in GitHub Actions, independent of Android SDK.
"""
import unittest, json, re, hashlib
from pathlib import Path
import numpy as np
from PIL import Image
R=Path(__file__).resolve().parents[1]
PAR=R/'assets/images/chapter1/ch1_parallax'
T=R/'assets/images/chapter1/ch1_world_tiles'

class ParallaxFix2(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.m=json.loads((R/'qa/ch1_rc3_parallax/MANIFEST.json').read_text())
        cls.far=np.asarray(Image.open(PAR/'montanas_ciudad_ciclo.png').convert('RGB'),dtype=np.int16)
        cls.mid=Image.open(PAR/'arbolado_medio_ciclo.png')

    def test_world_and_background_period(self):
        self.assertEqual(self.m['stage_width'],36500)
        self.assertEqual(self.m['tiles'],72)
        self.assertEqual(self.far.shape,(380,2200,3))
        self.assertAlmostEqual(self.m['far_world_repeat_interval'],7333.333,delta=1)
        self.assertEqual(self.m['far_parallax_speed'],.30)
        self.assertEqual(self.m['mid_parallax_speed'],.56)

    def test_circular_seam_without_stripes(self):
        # Adjacent true source columns at the wrap, not an invented flat line.
        gap=np.abs(self.far[:,0,:]-self.far[:,-1,:])
        self.assertLess(float(np.quantile(gap,.95)),40)
        # A heavily flattened sky/mountain band would have almost no detail.
        center=self.far[:,300,:]
        self.assertGreater(len(np.unique(center[155:370,0])),30)

    def test_mid_alpha_and_cyclic_edges(self):
        self.assertEqual(self.mid.size,(2020,380))
        self.assertEqual(self.mid.mode,'RGBA')
        self.assertLess(self.mid.getpixel((0,200))[3],60)
        self.assertEqual(self.mid.getpixel((2019,0))[3],0)

    def test_near_world_is_transparent_above_and_located_on_ground(self):
        with Image.open(T/'world_005.png') as im:
            self.assertEqual(im.mode,'RGBA')
            self.assertEqual(im.size,(512,380))
            al=np.array(im.getchannel('A'))
            self.assertEqual(int(al[10,:].max()),0)
            self.assertGreater(int((al[340,:]>0).sum()),150)

    def test_all_physical_tiles_and_last_width(self):
        pieces=sorted(T.glob('world_*.png'))
        self.assertEqual(len(pieces),72)
        widths=[]
        for p in pieces:
            with Image.open(p) as im: widths.append(im.width)
        self.assertEqual(widths[-1],148)
        self.assertEqual(sum(widths),36500)

    def test_original_art_unmodified(self):
        hashes=json.loads((R/'qa/ch1_legacy_art_sha256.json').read_text())
        for path,digest in hashes.items():
            self.assertEqual(hashlib.sha256((R/path).read_bytes()).hexdigest(),digest)

    def test_flutter_preloads_and_draws_real_layers(self):
        m=(R/'lib/main.dart').read_text()
        self.assertIn("images['ch1_far_city_loop']",m)
        self.assertIn("images['ch1_mid_woodland_loop']",m)
        self.assertIn('ch1PhysicalVisibleTiles(cameraX',m)
        self.assertIn('cameraX*speed',m)
        self.assertLess(m.index("images['ch1_far_city_loop']",m.index('void _neighborhoodPhysicalWorld')),m.index('ch1PhysicalVisibleTiles(cameraX',m.index('void _neighborhoodPhysicalWorld')))
        pub=(R/'pubspec.yaml').read_text()
        self.assertIn('assets/images/chapter1/ch1_parallax/',pub)
        self.assertIn('assets/images/chapter1/ch1_world_tiles/',pub)

    def test_runtime_only_changes_chapter_1(self):
        m=(R/'lib/main.dart').read_text()
        self.assertIn('if(stage==0) {',m) if 'if(stage==0) {' in m else self.assertIn('if (stage == 0)',m)
        self.assertIn('_neighborhoodBackground(canvas)',m)
        self.assertTrue((R/'assets/images/chapter45/football_arrival.png').is_file())

if __name__=='__main__':unittest.main()
