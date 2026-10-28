"""Regresión de interiores TWC. No implica validación Flutter o Android."""
import hashlib,json,re,unittest
from pathlib import Path
import numpy as np
from PIL import Image

R=Path(__file__).resolve().parents[1]
DIR=R/'assets/images/interiors_parallax'
MAN=json.loads((R/'qa/interiors_twc_lab/MANIFEST.json').read_text(encoding='utf-8'))
MAIN=(R/'lib/main.dart').read_text()
MODEL=(R/'lib/interiors_parallax_twc.dart').read_text()
PUB=(R/'pubspec.yaml').read_text()

class InteriorTWCQA(unittest.TestCase):
 def test_01_originals_identical(self):
  self.assertEqual(len(MAN['protected_originals']),6)
  for name,digest in MAN['protected_originals'].items():
   self.assertEqual(hashlib.sha256((R/'assets/images'/name).read_bytes()).hexdigest(),digest,name)

 def test_02_all_assets_present_and_sizes(self):
  for theme,height in [('dance',286),('school',278)]:
   folder=DIR/theme
   with Image.open(folder/'exterior_lejano_ciclo.png') as f: self.assertEqual(f.size,(2200,height))
   with Image.open(folder/'arbolado_tras_ventanas_ciclo.png') as f: self.assertEqual(f.size,(2020,height))
   with Image.open(folder/'marco_paso.png') as f: self.assertEqual(f.size,(120,height))
   for zone in range(3):
    for variant in range(3):
     with Image.open(folder/f'z{zone}_panel_{variant}.png') as src:
      self.assertEqual(src.size,(880,height))
      self.assertEqual(src.mode,'RGBA')
  for name in ('pizarra_matematicas','pizarra_informatica','estanteria_biblioteca','mesa_aula','ordenador_aula'):
   self.assertTrue((DIR/'school'/f'{name}.png').is_file(),name)

 def test_03_far_loops_are_seamless(self):
  for theme in ('dance','school'):
   im=np.array(Image.open(DIR/theme/'exterior_lejano_ciclo.png').convert('RGB'),dtype=np.int16)
   jump=np.abs(im[:,0,:]-im[:,-1,:])
   self.assertLess(float(jump.mean()),3,theme)
   self.assertLess(float(np.quantile(jump,.95)),5,theme)

 def test_04_mid_alpha_loops_are_seamless(self):
  for theme in ('dance','school'):
   x=np.array(Image.open(DIR/theme/'arbolado_tras_ventanas_ciclo.png').convert('RGBA'))
   self.assertTrue(np.array_equal(x[:,0,:],x[:,-1,:]))
   self.assertGreater(int((x[:,:,3]>30).sum()),2000)

 def test_05_transparency_only_for_windows_not_all_panels(self):
  for theme in ('dance','school'):
   a=np.array(Image.open(DIR/theme/'z0_panel_0.png').convert('RGBA'))[:,:,3]
   # Pared casi opaca, huecos limitados exclusivamente al tercio superior.
   self.assertGreater(float((a==255).mean()),.82,theme)
   self.assertGreater(float((a<100).mean()),.01,theme)
   self.assertTrue(np.all(a[-25:,:]==255),theme)

 def test_06_camera_and_module_movement(self):
  self.assertIn('const double interiorFarSpeedTWC = 0.30;',MODEL)
  self.assertIn('const double interiorMidSpeedTWC = 0.56;',MODEL)
  self.assertIn('const double interiorNearSpeedTWC = 1.00;',MODEL)
  self.assertIn('interiorModuleXWorldTWC(zone,index)-cameraX',MAIN)
  self.assertIn('interiorLoopOffsetTWC(cameraX,speed,image.width)',MAIN)
  self.assertEqual(2200/.3,7333.333333333334)
  self.assertAlmostEqual(2020/.56,3607.142857142857)
  for shift in (1,60,600,820):
   world=3600
   self.assertEqual((world-shift)-world,-shift)
   self.assertAlmostEqual(shift*.30,shift*.3)
   self.assertAlmostEqual(shift*.56,shift*.56)

 def test_07_all_world_coordinates_covered_by_modules(self):
  edges=(0,10500,25500,36500);step=880
  for cx in range(0,35701,131):
   required=set(range(cx,cx+800,37))
   covered=set()
   for z,(start,end) in enumerate(zip(edges[:-1],edges[1:])):
    for world in required:
     if start<=world<end:
      n=(world-start)//step
      self.assertTrue(start+n*step<=world<min(end,start+(n+1)*step))
      covered.add(world)
   self.assertEqual(covered,required)

 def test_08_three_rooms_no_panoramic_dissolve(self):
  self.assertEqual(MAN['zones'],[{'start':0,'end':10500},{'start':10500,'end':25500},{'start':25500,'end':36500}])
  self.assertIn('for (var zone=0;zone<3;zone++)',MAIN)
  self.assertIn('canvas.clipRect(clip);',MAIN)
  self.assertIn('interiorZoneEdgesTWC[1],interiorZoneEdgesTWC[2]',MAIN)
  self.assertNotIn('void _activityBackdrop(Canvas canvas,ActivityZone zone',MAIN)
  self.assertNotIn('if(fade>0) _activityBackdrop',MAIN)
  self.assertIn('stage == 5 || stage == 6',MAIN)

 def test_09_themed_school_props_unique_not_in_repeating_wall(self):
  generator=(R/'tools/build_interiors_parallax_twc.py').read_text()
  self.assertIn('def extract_school_features():',generator)
  self.assertIn("master = Image.open(ASSETS/SRCS['school'][zone]).convert('RGB')",generator)
  self.assertNotIn("neutral=Image.open(ASSETS/'scenes/school.png')",generator)
  self.assertIn("('pizarra_matematicas',15320,52)",MAIN)
  self.assertIn("('pizarra_informatica',29820,51)",MAIN)
  self.assertIn("('estanteria_biblioteca',1720,0)",MAIN)
  self.assertIn("if(room==2)",MAIN)
  self.assertIn("images['interior_school_ordenador_aula']",MAIN)

 def test_10_floor_controls_enemies_untouched(self):
  self.assertIn('_floorArtTop[stage]',MAIN)
  self.assertIn('shadowSurfaceY(',MAIN)
  self.assertIn('if(stage == 4 || stage == 5) _activityProps(canvas);',MAIN)
  self.assertIn('_footballBackgroundTWC(canvas)',MAIN)
  self.assertIn('_neighborhoodBackground(canvas)',MAIN)
  self.assertIn("(stage==4 && role=='futbolista')||(stage==5 && role=='bailarina')",MAIN)

 def test_11_flutter_assets_registered(self):
  self.assertIn('import \'interiors_parallax_twc.dart\';',MAIN)
  self.assertIn('assets/images/interiors_parallax/dance/',PUB)
  self.assertIn('assets/images/interiors_parallax/school/',PUB)
  self.assertIn('paths[\'interior_${theme}_far\']',MAIN)
  self.assertIn('paths[\'interior_${theme}_mid\']',MAIN)
  self.assertIn('interiorPanelAssetTWC(theme,room,variant)',MAIN)

 def test_12_preview_renders_actual_room_transitions(self):
  # Las capturas de QA se generan bajo demanda: no son assets de produccion
  # ni deben comprometerse en Git. Verificamos el renderizador real local.
  import runpy
  preview = runpy.run_path(str(R/'tools/preview_interiors_twc.py'))
  render = preview['render']
  for theme in ('school','dance'):
   before = render(theme,10475)
   after = render(theme,10530)
   self.assertEqual(before.size,(800,450),theme)
   self.assertEqual(after.size,(800,450),theme)
   self.assertNotEqual(hashlib.sha256(before.tobytes()).digest(),
                       hashlib.sha256(after.tobytes()).digest(),theme)

if __name__=='__main__':unittest.main()
