import unittest,sys,json,hashlib,re
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
BOUNDS=json.loads((ROOT/'qa/ENEMY_VISIBLE_BOUNDS.json').read_text())
GENERATED=(ROOT/'lib/sprite_bounds.g.dart').read_text()
SOURCE=(ROOT/'lib/main.dart').read_text()
class SpritePoseAnchorTests(unittest.TestCase):
 def test_all_visible_pixel_bounds_match_png_and_hash(self):
  self.assertEqual(50,len(BOUNDS))
  for key,record in BOUNDS.items():
   f=ROOT/f'assets/images/enemies/{key}.png'
   with self.subTest(sprite=key), Image.open(f) as im:
    im=im.convert('RGBA'); bbox=im.getchannel('A').getbbox()
    self.assertIsNotNone(bbox)
    l,t,r,b=bbox
    self.assertEqual([l,t,r-l,b-t],record['bounds'])
    self.assertEqual(hashlib.sha256(f.read_bytes()).hexdigest(),record['sha256'])
    self.assertIn("'"+key+"': Rect.fromLTWH(",GENERATED)
 def test_render_uses_visible_canonical_alpha_for_baseline(self):
  self.assertIn("final visible=hiFiCreature ? creatureFrameBounds",SOURCE)
  self.assertIn(": enemyVisibleBounds['${foe.kind}_$frame'];",SOURCE)
  self.assertIn("final canonical=hiFiCreature ? creatureFrameBounds",SOURCE)
  self.assertIn(": enemyVisibleBounds['${foe.kind}_0'];",SOURCE)
  self.assertIn('pixelScale=targetHeight/canonical.height',SOURCE)
  self.assertIn('source:visible',SOURCE)
 def test_detects_known_cropped_canvas_risk_not_art_signoff(self):
  count=sum(1 for p in BOUNDS.values() if p['canvas_edge_touch'])
  self.assertGreater(count,0)
  # A list of flags is never artistic approval; subject to explicit review.
 def test_negative_modified_metadata_would_fail(self):
  key='novice_4';bb=BOUNDS[key]['bounds'];invalid=[bb[0],bb[1],bb[2],bb[3]+20]
  self.assertNotEqual(bb,invalid)
if __name__=='__main__':unittest.main()
