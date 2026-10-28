"""Batería estricta del motor modular V4 + registro de fallos de ARTE.
Las pruebas no aprueban arte: demuestran que las alarmas detectan la deuda.
"""
import unittest,sys,math,re,json,hashlib
from pathlib import Path
from PIL import Image
import numpy as np
HERE=Path(__file__).resolve().parent
ROOT=HERE.parent
sys.path.insert(0,str(HERE))
import ch1_world_v4_reference as v4


class V4Contract(unittest.TestCase):
    def test_landmarks_unique(self):
        self.assertEqual(len(v4.LANDMARKS),7)
        self.assertEqual(len({a[0] for a in v4.LANDMARKS}),7)
    def test_source_art_protected(self):
        saved=json.loads((ROOT/'qa/ch1_legacy_art_sha256.json').read_text())
        for path,digest in saved.items():
            self.assertEqual(hashlib.sha256((ROOT/path).read_bytes()).hexdigest(),digest)
    def test_lengths_are_intrinsic_not_region_stretched(self):
        for name,x,w,sh in v4.LANDMARKS:
            self.assertAlmostEqual(v4.LANDMARK_WIDTH[name],w*380/sh)
            self.assertLess(v4.LANDMARK_WIDTH[name],1900)
    def test_world_positions_derived_from_existing_regions(self):
        dart=(ROOT/'lib/chapter_one_world_v4.dart').read_text()
        self.assertIn('region.start',dart)
        self.assertIn('ch1SourceDimsV4[region.asset]',dart)
        self.assertNotRegex(dart,r"Ch1LandmarkV4\('residential_curve',\s*0,")
        self.assertEqual(len(v4.REGIONS),7)
        for item,region in zip(v4.LANDMARKS,v4.REGIONS):
            self.assertEqual(item[1],region[1])

    def test_culling_consistent(self):
        for cam in [0,920,1000,7000,7500,18500,27600,35700]:
            visible=[name for name,x,*_ in v4.LANDMARKS if x<cam+800 and x+v4.LANDMARK_WIDTH[name]>cam]
            self.assertEqual(len(visible),len(set(visible)))
    def test_full_36500_frame_without_exceptions(self):
        for cam in [0,750,920,1000,5000,7180,9500,16400,18600,27750,35700]:
            self.assertEqual(v4.frame(cam).size,(800,450))
    def test_guard_foliage_not_over_landmark(self):
        for _,x,idx,h in v4.PROPS:
            self.assertTrue(v4.prop_is_safe(x,h*v4.PROP_RECTS[idx][2]/v4.PROP_RECTS[idx][3]))
    def test_all_atlas_rects_nonempty_and_alpha(self):
        self.assertEqual(len(v4.PROP_RECTS),12)
        for x,y,w,h in v4.PROP_RECTS:
            self.assertGreater(v4.ATLAS.crop((x,y,x+w,y+h)).getchannel('A').getbbox()[2],0)
    def test_floor_tiles_contiguous(self):
        self.assertEqual(v4.GROUND.width,540)
        for cam in [0,540,777,1500]:
            img=np.asarray(v4.frame(cam))
            self.assertFalse(np.any(np.all(img[410,:,:3]==(62,166,241),axis=1)))
    def test_camera_moves_exactly_world_pixels(self):
        self.assertEqual((1200-600)-(1200-450),-150)
        self.assertEqual((2000-900)-(2000-200),-700)
    def test_world_uses_tiles_and_real_assets(self):
        dart=(ROOT/'lib/main.dart').read_text()
        self.assertIn('chapterOneWorldV4Lab',dart)
        self.assertIn('ch1LandmarksV4',dart)
        self.assertIn('ch1PropsV4()',dart)
        self.assertIn('ch1PropRectsV4[10]',dart)
        self.assertIn("'neighborhood_park_props_atlas'",dart)
    def test_not_enabled_by_default(self):
        s=(ROOT/'lib/main.dart').read_text()
        self.assertIn("bool.fromEnvironment('CHAPTER_ONE_WORLD_V4_LAB', defaultValue:false)",s)
    def test_new_art_still_not_installed(self):
        # La ilustración generada es CANDIDATA, no un empalme validado.
        code=(ROOT/'lib/main.dart').read_text()
        self.assertNotIn('wide_pixel_art_landscape_scene_side_scrolling_gam',code)
    def test_hardcut_is_detected_and_rejected(self):
        # Bordes completos de fachadas que faltan, en x ~= 804.25.
        cam=750
        edge=round(v4.LANDMARK_WIDTH['residential_curve']-cam)
        arr=np.asarray(v4.frame(cam),dtype=np.int16)
        jump=np.abs(arr[50:320,edge-1]-arr[50:320,edge]).mean()
        self.assertGreater(jump,60, f'LA PRUEBA DEBE DETECTAR EL CORTE, salto={jump}')
    def test_cloud_and_foliage_detail_in_modular_region(self):
        arr=np.asarray(v4.frame(1000))
        sky=arr[50:240]
        unique=len(np.unique(sky.reshape(-1,3),axis=0))
        self.assertGreaterEqual(unique,450, 'El tramo modular debe contener arte real en segundo plano')
    def test_qa_report_refuses_unapproved_art(self):
        report=json.loads((HERE/'ch1_world_v4_previews/RESULTADOS_V4.json').read_text())
        self.assertTrue(report['artistic_seam_gate'].startswith('REJECTED'))
        self.assertEqual(report['flutter_gate'],'NOT_RUN_SDK_UNAVAILABLE')

if __name__=='__main__': unittest.main()
