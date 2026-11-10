"""Patrón de movimiento deportivo homologable a TWC RC3 FIX2, sin Flutter.

Estos tests certifican geometría, assets y no-regresión de recursos; no son
sustitutos de Flutter analyze/test ni prueba Android.
"""
import hashlib, json, unittest, re
from pathlib import Path
from PIL import Image
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
ASSETS=ROOT/'assets/images';DIR=ASSETS/'chapter45/football_parallax';M=json.loads((DIR/'MANIFEST.json').read_text())
MAIN=(ROOT/'lib/main.dart').read_text(); MODEL=(ROOT/'lib/football_parallax_twc.dart').read_text()
CH1=(ROOT/'lib/chapter_one_world_tiles.dart').read_text()

class FootballTWCContract(unittest.TestCase):
    def test_source_art_is_protected(self):
        for name,sha in M['source_sha256'].items():
            self.assertEqual(hashlib.sha256((ASSETS/'chapter45'/f'{name}.png').read_bytes()).hexdigest(),sha,name)
        self.assertFalse(M['source_master_files_edited'])

    def test_same_approved_layer_speeds(self):
        self.assertEqual(M['far']['speed'],.30)
        self.assertEqual(M['mid']['speed'],.56)
        self.assertIn('const double ch1FarSpeed = 0.30;',CH1)
        self.assertIn('const double ch1MidSpeed = 0.56;',CH1)
        self.assertIn('const double footballFarSpeedTWC = 0.30;',MODEL)
        self.assertIn('const double footballMidSpeedTWC = 0.56;',MODEL)
        self.assertAlmostEqual(M['far']['repeat_world'],7333.333,places=2)
        self.assertAlmostEqual(M['mid']['repeat_world'],3607.143,places=2)
        self.assertEqual(M['near']['speed'],1)

    def test_total_coverage_and_small_memory_footprint(self):
        self.assertEqual(M['width_world'],36500)
        self.assertEqual(M['near']['count'],6)
        self.assertEqual(M['near']['tile_width'],1100)
        self.assertEqual(M['near']['cycle_width'],6600)
        # Fencing must mix all three real sports masters, not repeated
        # copies of the same stands image under different hashes.
        seq=M['near']['source_sequence']
        self.assertEqual(len(seq),8)
        self.assertEqual(set(seq),{'football_arrival','football_drills','football_stands'})
        self.assertEqual(M['near']['source_crop'],[870,130])
        self.assertEqual(M['near']['source_resize'],[950,142])
        self.assertLess(abs((950/870)/(142/130)-1),.001)
        self.assertEqual(len({
            hashlib.sha256((DIR/'near_world_tiles'/f'near_{i}.png').read_bytes()).digest()
            for i in range(6)}),6)

        files=sorted((DIR/'near_world_tiles').glob('near_*.png'))
        self.assertEqual(len(files),6)
        for f in files:
            with Image.open(f) as im:
                self.assertEqual(im.size,(1100,386))
                self.assertEqual(im.mode,'RGBA')
                # The sky of a foreground tile must be transparent, so the
                # sports/trees at different depths can move independently.
                self.assertEqual(im.getpixel((0,0))[3],0)
        for cam in range(0,35701,97):
            first=max(0,cam//1100-1)
            last=(cam+800)//1100+1
            self.assertLessEqual(first*1100,cam)
            self.assertGreaterEqual((last+1)*1100,cam+800)

    def test_seamless_far_mid_and_near_loops(self):
        with Image.open(DIR/'montanas_ciudad_deportiva_ciclo.png') as src:
            self.assertEqual(src.size,(2200,386))
            x=np.asarray(src.convert('RGB'),np.int16)
            seam=np.abs(x[:,0,:]-x[:,-1,:])
            self.assertLess(float(np.mean(seam)),12)
            self.assertLess(float(np.quantile(seam,.95)),22)
        with Image.open(DIR/'arbolado_deportivo_ciclo.png') as src:
            self.assertEqual(src.size,(2020,386))
            self.assertEqual(src.mode,'RGBA')
            self.assertEqual(src.getchannel('A').getpixel((0,200)),0)
            self.assertEqual(src.getchannel('A').getpixel((2019,200)),0)
        parts=[np.asarray(Image.open(DIR/'near_world_tiles'/f'near_{k}.png').convert('RGBA'),np.int16) for k in range(6)]
        for i in range(6):
            # same seamless image cut at tile boundaries
            a,b=parts[i],parts[(i+1)%6]
            sample=np.abs(a[:,-1,:3]-b[:,0,:3]);
            mask=(a[:,-1,3]>160)&(b[:,0,3]>160)
            if mask.any():
                self.assertLess(np.mean(sample[mask]),32,(i,float(np.mean(sample[mask]))))

    def test_flutter_uses_correct_layer_order_and_no_legacy_crossfade(self):
        self.assertIn("import 'football_parallax_twc.dart';",MAIN)
        self.assertIn("_footballLoopTWC(canvas,images['football_far_twc'],footballFarSpeedTWC)",MAIN)
        self.assertIn("_footballLoopTWC(canvas,images['football_mid_twc'],footballMidSpeedTWC)",MAIN)
        p=MAIN.index('  void _footballBackgroundTWC(')
        q=MAIN.index('  void _background(',p)
        excerpt=MAIN[p:q]
        self.assertLess(excerpt.index('football_far_twc'),excerpt.index('football_mid_twc'))
        self.assertLess(excerpt.index('football_mid_twc'),excerpt.index('football_near_tile_'))
        self.assertIn('footballNearModuleX(n)-cameraX',excerpt)
        self.assertIn('footballNearModuleAssetIndex(n)',excerpt)
        self.assertIn('if(stage == 0)',MAIN)
        self.assertIn('} else if(stage == 4) {\n      _footballBackgroundTWC(canvas);',MAIN)
        self.assertIn('} else if(stage == 5 || stage == 6) {\n      // Sala de danza y colegio: interiores por piezas, sin fantasmas.\n      _interiorBackgroundTWC(canvas);',MAIN)
        self.assertIn('if(stage == 4 || stage == 5) _activityProps(canvas);',MAIN)
        self.assertNotIn('_activityBackdrop(canvas,zone,',excerpt)

    def test_registry_declares_all_assets_without_72_new_sprites(self):
        pub=(ROOT/'pubspec.yaml').read_text()
        self.assertIn('    - assets/images/chapter45/football_parallax/',pub)
        self.assertIn('    - assets/images/chapter45/football_parallax/near_world_tiles/',pub)
        self.assertIn('footballNearTileAssetTWC(i)',MAIN)
        self.assertIn('footballTileCountTWC = 6;',MODEL)
        self.assertTrue((ROOT/'test/football_parallax_twc_test.dart').exists())

if __name__=='__main__':unittest.main()
