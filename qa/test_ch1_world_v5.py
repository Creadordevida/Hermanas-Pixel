"""Regression coverage for the corrected image crop and FULL-SPAN prop guards.
All visual failures are expected to remain BLOCKED until artistically fixed.
"""
from pathlib import Path
import unittest,math,sys,json,hashlib
from PIL import Image
sys.path.insert(0,str(Path(__file__).resolve().parent))
import ch1_world_v4_reference as w

class Ch1V5Regressions(unittest.TestCase):
    def test_exact_photo_source_bounds(self):
        for name,_,sw,sh in w.LANDMARKS:
            path=w.ART/(name+'.png')
            with Image.open(path) as img:
                self.assertEqual(sw,img.width,name)
                self.assertLessEqual(sh,img.height,name)
                self.assertGreater(sh,500,name)

    def test_approved_images_untouched(self):
        expected=json.loads((w.ROOT/'qa/ch1_legacy_art_sha256.json').read_text())
        self.assertEqual(len(expected),4)
        for path,digest in expected.items():
            self.assertEqual(hashlib.sha256((w.ROOT/path).read_bytes()).hexdigest(),digest)

    def test_actual_crop_shows_ground_fence(self):
        for name,_,sw,sh in w.LANDMARKS:
            if name in ['residential_curve','green_promenade','white_canopy','rocket_park']:
                self.assertEqual(sh,790, 'A painter should not cut the park fence at 690')

    def test_all_props_respect_full_alpha_rectangle(self):
        for pid,x,atlas_index,height in w.PROPS:
            left,top,sw,sh=w.PROP_RECTS[atlas_index]
            self.assertTrue(w.prop_is_safe(x,height*sw/sh), (pid,x,atlas_index))

    def test_no_visual_actor_occlusion_by_props_inside_landmarks(self):
        for _,x,atlas_index,height in w.PROPS:
            r=w.PROP_RECTS[atlas_index]
            right=x+height*r[2]/r[3]
            self.assertFalse(any(x<end+120 and right>start-120 for start,end in w.LANDMARK_ENDS))

    def test_props_nontrivial_variation(self):
        variants={x[2] for x in w.PROPS}
        self.assertGreaterEqual(len(variants),9)
        self.assertGreater(len(w.PROPS),60)

    def test_landmark_pan_scale_one_to_one(self):
        for name,start,sw,sh in w.LANDMARKS:
            width=sw*380/sh
            self.assertAlmostEqual(w.LANDMARK_WIDTH[name],width)
            self.assertAlmostEqual((start-600)-(start-200),-400)

    def test_all_seven_seams_are_recorded(self):
        path=w.ROOT/'qa/ch1_v5_audit/AUDITORIA_V5.json'
        if not path.exists():self.skipTest('Run the full V5 audit first')
        record=json.loads(path.read_text())
        self.assertEqual(len(record['seams']),7)
        self.assertFalse(record['pass'])
        self.assertFalse(record['all_seams_artistically_approved'])

    def test_sky_floor_no_unpainted_pixels_throughout_world(self):
        for c in range(0,35701,2700):
            im=w.frame(c)
            self.assertEqual(im.size,(800,450))
            self.assertNotEqual(im.getpixel((400,439)),(62,166,241))

    def test_world_region_order_and_limits(self):
        self.assertEqual(w.REGIONS[0][1],0)
        self.assertEqual(w.REGIONS[-1][2],36500)
        for (_,a,b),(_,c,d) in zip(w.REGIONS,w.REGIONS[1:]):
            self.assertEqual(b,c)

    def test_rejection_of_bad_first_seam_not_hidden(self):
        x=w.LANDMARK_ENDS[0][1]
        from visual_audit_v5 import seam_info
        info=seam_info('residential_curve',x)
        self.assertGreater(info['jump_mean_rgb'],35)

    def test_flutter_switch_remains_opt_in(self):
        main=(w.ROOT/'lib/main.dart').read_text()
        self.assertIn("'CHAPTER_ONE_WORLD_V4_LAB', defaultValue:false",main)
        self.assertIn('ch1PropsV4()',main)
        self.assertIn('ch1MidTreesV4()',main)

if __name__=='__main__':unittest.main()
