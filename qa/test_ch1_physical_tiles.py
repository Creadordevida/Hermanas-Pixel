import unittest,subprocess,sys
from pathlib import Path
from PIL import Image
R=Path(__file__).resolve().parents[1]
T=R/'assets/images/chapter1/ch1_world_tiles'
class PhysicalWorldTests(unittest.TestCase):
 def test_integrity(self):
  subprocess.run([sys.executable,str(R/'qa/check_ch1_physical_tiles.py')],cwd=R,check=True,capture_output=True)
 def test_camera_crosses_world_tiles_without_missing_image(self):
  for cam in range(0,35701,109):
   first=max(0,cam//512-1)
   last=min(71,(cam+800)//512+1)
   self.assertLessEqual(first*512,cam)
   self.assertGreaterEqual(min(36500,(last+1)*512),cam+800)
 def test_master_scenes_present_once(self):
  import json
  m=json.loads((R/'qa/ch1_rc3_tiles/MANIFEST.json').read_text())
  self.assertEqual(len(m['landmarks']),7)
  self.assertEqual(len({f['asset'] for f in m['landmarks']}),7)
 def test_final_chunk_is_148(self):
  with Image.open(T/'world_071.png') as im:self.assertEqual(im.size,(148,380))
if __name__=='__main__':unittest.main()
