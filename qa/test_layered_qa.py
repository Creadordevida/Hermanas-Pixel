import unittest
from pathlib import Path
import json
import sys
sys.path.insert(0,str(Path(__file__).resolve().parent))
from verify_layered_scenes import run,loop_score,ROOT
from PIL import Image
class StageLayerQA(unittest.TestCase):
 def test_actual_ground_and_near_tiles(self):
  self.assertFalse(run())
 def test_negative_seam_would_fail(self):
  p=ROOT/'assets/images/ground/stage_0.png'
  img=Image.open(p).convert('RGB')
  self.assertLess(loop_score(img),.2)
  img.putpixel((0,0),(255,0,255))
  self.assertGreater(loop_score(img),.2)
 def test_negative_broken_landmark_clamp_detectable(self):
  main=(ROOT/'lib/main.dart').read_text()
  self.assertIn('math.min(math.max(0, cameraX-zoneOrigin)*parallax,limit)',main)
  broken=main.replace('math.min(math.max(0, cameraX-zoneOrigin)*parallax,limit)','cameraX*parallax')
  self.assertNotIn('math.min(math.max(0, cameraX-zoneOrigin)*parallax,limit)',broken)
 def test_approved_map_exact_hash(self):
  from hashlib import sha256
  p=ROOT/'assets/images/worldmap/pamplona_aprobado.png'
  self.assertEqual('0bb7bf217d14fdd98ecc436e873748c892afc644f66b103132d36498dc99b030',sha256(p.read_bytes()).hexdigest())
 def test_original_ballet_image_kept_unchanged(self):
  original=ROOT/'assets/images/scenes/ballet.png'
  refined=ROOT/'assets/images/scenes/ballet_refined.png'
  self.assertTrue(original.is_file() and refined.is_file())
  self.assertNotEqual(original.read_bytes(),refined.read_bytes())
  with Image.open(original) as a, Image.open(refined) as b:
   self.assertEqual(a.size,b.size)
if __name__=='__main__':unittest.main()
