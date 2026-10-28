from PIL import Image,ImageDraw
from pathlib import Path
import re,unittest,hashlib
base=Path(__file__).resolve().parents[1]
main=(base/'lib/main.dart').read_text(); bounds=(base/'lib/sprite_bounds.g.dart').read_text()
class Quality(unittest.TestCase):
 def test_goalkeeper_only_in_football(self):
  self.assertIn("4 => ['rival','goalkeeper','referee']",main)
  for i in (0,1,2,3,5,6):
   self.assertNotRegex(main,rf"{i} => \[[^\]]*goalkeeper")
 def test_sprite_alpha_and_bounds(self):
  for i in range(5):
   im=Image.open(base/f'assets/images/enemies/goalkeeper_{i}.png').convert('RGBA')
   self.assertGreaterEqual(im.width,55); self.assertIsNotNone(im.getchannel('A').getbbox())
   self.assertIn(f"'goalkeeper_{i}'",bounds)
 def test_frames_differ(self):
  sha=[hashlib.sha256((base/f'assets/images/enemies/goalkeeper_{i}.png').read_bytes()).hexdigest() for i in range(5)]
  self.assertEqual(len(set(sha)),5)
 def test_difficulty_between_rival_referee(self):
  self.assertIn("kind == 'goalkeeper') ? 2",main)
  self.assertIn("'goalkeeper' => 80",main)
  self.assertIn("foe.t >= .34",main)
  self.assertIn("foe.attackCooldown=2.7",main)
 def test_load_assets(self):
  self.assertIn("'rival','goalkeeper','referee'",main)
 def test_landmarks_of_football(self):
  from PIL import Image
  for s in ('football_arrival','football_drills','football_stands'):
   with Image.open(base/f'assets/images/chapter45/{s}.png') as im:self.assertGreaterEqual(im.width,1200)
 def test_no_city_shared_background(self):
  assert 'footballActivityZones' in (base/'lib/activity_chapters.dart').read_text()
  self.assertIn("paths['activity_${zone.asset}']",main)
 def test_art_sheet_anatomy(self):
  im=Image.open(base/'assets/images/enemies/goalkeeper_0.png').convert('RGBA')
  self.assertGreater(im.getchannel('A').getbbox()[2],35)
if __name__=='__main__':unittest.main()
