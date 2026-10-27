"""Non-artistic invariants of chapter-one composition after RC1 gameplay review.

DO NOT encode a 'green quality' claim when joins still fail the pixels test.
"""
from pathlib import Path
from PIL import Image
from collections import Counter
import json, hashlib, unittest
from audit_rc2_scene_composition import audit, authored_panels, SCENE_HEIGHT, ASSETS

ROOT=Path(__file__).resolve().parents[1]
MAIN=(ROOT/'lib/main.dart').read_text()
ENGINE=(ROOT/'lib/neighborhood_scene_engine.dart').read_text()
BASELINE={
'residential_curve':'8486df5a23d069e659014d8cfc35aef70a6b39eb20e67d56e1183ca2c0b61699',
'green_promenade':'56dc3f61a5f948685d863cf9e1484f70ba552b0f9750f127bc07e93d017d043f',
'white_canopy':'7bef4349c693fda57ee571b2ff5aef6bbfbe510e668bf84a217bcb00901c0494',
'rocket_park':'a4d0cdfe9d72d3bf5be76b9cc5eb139ef6a6ffe3ba048bec9688bb93aaff788e',
}
class Rc2CompositionGate(unittest.TestCase):
 def test_four_masters_untouched(self):
  for name,expected in BASELINE.items():
   self.assertEqual(hashlib.sha256((ASSETS/(name+'.png')).read_bytes()).hexdigest(),expected)
 def test_neighborhood_is_distant_world_pan_with_single_physical_floor(self):
  self.assertIn('neighborhoodSourceHeight(panel.asset)',MAIN)
  self.assertIn('neighborhoodPanFraction(panel, cameraX)',MAIN)
  self.assertIn('neighborhoodTreeAllowedAt(worldX)',MAIN)
  self.assertIn('neighborhoodLandmarkInCamera(cameraX, viewW)',MAIN)
  self.assertIn('neighborhoodViewSourceWidth(panel.asset)',MAIN)
  self.assertNotIn('if(stage==0) _neighborhoodTrees(canvas,foreground:true);',MAIN)
  self.assertIn("_floorArtTop = [380,390,390,390",MAIN)
 def test_seven_unique_and_non_distorting_crops(self):
  panels=authored_panels()
  self.assertEqual(len(panels),7)
  self.assertEqual(len({asset for asset,_,_,_ in panels}),7)
  for asset,x,y,_ in panels:
   with Image.open(ASSETS/(asset+'.png')) as im:
    self.assertGreaterEqual(im.width,800*SCENE_HEIGHT[asset]/380)
    self.assertLess(SCENE_HEIGHT[asset],im.height-100)
  for a,b in zip(panels,panels[1:]): self.assertEqual(a[2],b[1])
 def test_audit_is_not_artistic_approval(self):
  data=audit()
  self.assertEqual(data['authored_regions'],7)
  self.assertEqual(data['unique_region_artworks'],7)
  self.assertEqual(len(data['seams']),6)
  self.assertTrue(all(n==1 for n in data['connector_repetitions'].values()))
  self.assertIn('PENDING Flutter',data['quality_status'])
 def test_only_local_spatial_seam_not_time_based_whole_scene_fade(self):
  self.assertIn('neighborhoodSeamHalfWidth = 48.0',ENGINE)
  area=MAIN.split('void _neighborhoodJoin(',1)[1].split('void _neighborhoodBackground(',1)[0]
  self.assertIn('BlendMode.dstIn',area)
  self.assertIn('ui.Gradient.linear',area)
  self.assertNotIn('foe.t',area)

if __name__=='__main__': unittest.main()
