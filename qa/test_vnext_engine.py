import unittest
from pathlib import Path
from scene_metrics_vnext import ROOT,MAIN,BASE,mirror_detect,stretch_detect
from PIL import Image

class RenderContract(unittest.TestCase):
 def test_no_mirror_even_when_asset_edges_differ(self):
  self.assertFalse(mirror_detect(MAIN))
  self.assertTrue(mirror_detect(MAIN.replace('void _background(Canvas canvas) {','void _background(Canvas canvas) {\nif(n.isOdd)canvas.scale(-1,1);',1)))
 def test_no_arbitrary_world_stretch(self):
  self.assertFalse(stretch_detect(MAIN))
  self.assertTrue(stretch_detect(MAIN.replace('void _background(Canvas canvas) {','void _background(Canvas canvas) {\nconst tileWorldWidth=1570;',1)))
 def test_ground_alignment_declared_in_renderer(self):
  self.assertIn('static const List<double> _floorArtTop',MAIN)
  self.assertIn("final tile=images['ground_$stage'];",MAIN)
  self.assertIn('final tileW=tile.width.toDouble();',MAIN)
 def test_map_uses_exact_asset_and_no_duplicate_labels(self):
  section=MAIN.split('Widget _map() =>',1)[1].split('Widget _chooseScreen()',1)[0]
  self.assertIn('pamplona_aprobado.png',section)
  self.assertIn('mapHitboxesOriginal',section)
  self.assertNotIn("Text(chapterNames[i]",section)
 def test_all_seven_targets_in_image_bounds(self):
  import re
  area=MAIN.split('mapHitboxesOriginal = [',1)[1].split('];',1)[0]
  coords=[tuple(map(int,m)) for m in re.findall(r'Rect.fromLTWH\((\d+),(\d+),(\d+),(\d+)\)',area)]
  self.assertEqual(7,len(coords))
  for x,y,w,h in coords:
   self.assertLess(x+w,1673);self.assertLess(y+h,942)
 def test_enemy_scale_based_on_idle_sprite_not_current_pose(self):
  self.assertIn("final canonical=enemyVisibleBounds['${foe.kind}_0'];",MAIN)
  self.assertIn('final pixelScale=targetHeight/canonical.height;',MAIN)
  self.assertNotIn('final scale=math.min(hh/img.height',MAIN)
 def test_protagonist_scale_based_on_identity(self):
  self.assertIn('final standardHeight=',MAIN)
  self.assertIn('final scale=standardHeight/(base?.height ?? img.height);',MAIN)
 def test_floor_assets_remain_original(self):
  with Image.open(BASE/'level_pixel.png') as im:self.assertEqual((1320,480),im.size)
 def test_exact_user_approved_map_stored(self):
  with Image.open(BASE/'worldmap/pamplona_aprobado.png') as im:self.assertEqual((1672,941),im.size)

if __name__=='__main__':unittest.main()
