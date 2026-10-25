"""Verificaciones ejecutables de la candidata; NO certifican arte ni Android."""
import unittest, json, hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
QA=ROOT/'qa'
BASE=ROOT/'assets/images/dog'
class Specs(unittest.TestCase):
 def test_seven_chapters_all_unique(self):
  j=json.loads((QA/'specification_090.json').read_text()); c=j['chapters']
  self.assertEqual(list(range(7)),[x['id'] for x in c]);self.assertEqual(len(set(x['name'] for x in c)),7)
  self.assertTrue(j['all_chapters_unlocked_for_testing'])
 def test_protagonists_specific(self):
  c=json.loads((QA/'specification_090.json').read_text())['chapters']
  self.assertEqual([x['character'] for x in c],['either']*4+['miren','sara','either'])
 def test_all_enemy_types_have_stats_and_chapter(self):
  j=json.loads((QA/'specification_090.json').read_text())
  self.assertEqual(len(j['enemies']),13)
  used=set(sum((x['new_enemies'] for x in j['chapters']),[]))
  self.assertEqual(set(j['enemies']),used)
  for x in j['enemies'].values():
   self.assertIn(x['hits'],(1,2,3))
   if x['hits']==3:self.assertGreaterEqual(x['attack_interval_min_sec'],3.0)
 def test_dog_variants_exact_alpha(self):
  from PIL import Image
  import numpy as np
  for pose in ['idle','walk','alert','run','bite','hit','stunned','defeated']:
   original=np.array(Image.open(BASE/(pose+'.png')).convert('RGBA'))
   for variant in ['dalmatian','doberman']:
    b=np.array(Image.open(BASE/variant/(pose+'.png')).convert('RGBA'))
    self.assertEqual(original.shape,b.shape)
    self.assertTrue(np.array_equal(original[:,:,3],b[:,:,3]),(variant,pose))
    self.assertGreater(np.count_nonzero(np.any(original[:,:,:3]!=b[:,:,:3],axis=2)),15)
 def test_all_new_enemies_have_5_frames(self):
  for role in ['rival','referee','novice','breakdancer','pigeon','cat','rat','bully','teacher','statue']:
   from PIL import Image
   for frame in range(5):
    p=ROOT/f'assets/images/enemies/{role}_{frame}.png'
    self.assertTrue(p.is_file(),str(p))
    with Image.open(p) as img:
     self.assertEqual(img.mode,'RGBA',(role,frame))
     self.assertGreater(img.getbbox()[2],6,(role,frame))
 def test_seven_backgrounds_and_school_variations(self):
  for name in ['football','ballet','school','school_classroom','school_computers']:
   self.assertTrue((ROOT/f'assets/images/scenes/{name}.png').exists())
  self.assertTrue((ROOT/'assets/images/worldmap/pamplona.png').exists())
 def test_existing_ground_protected_no_2nd_ground(self):
  dart=(ROOT/'lib/main.dart').read_text()
  self.assertIn('const double groundY = 390;',dart)
  self.assertIn('const double stageWidth = 36500;',dart)
  self.assertIn('_background(canvas);',dart)
  self.assertNotIn('void _ground(',dart)
  self.assertNotIn('canvas.drawRect(Rect.fromLTWH(0, groundY',dart)
 def test_hits_and_special_projectiles_exist(self):
  s=(ROOT/'lib/main.dart').read_text()
  for target in ["kind == 'dog_doberman' ? 2",'foe.hits++','foe.hits>=foe.hp',"'referee'=>'red_card'", "'breakdancer'=>'shoe'", "'teacher'=>'eraser'",'foe.attackCooldown=3.6']:
   self.assertIn(target,s)
 def test_sister_and_dad_walk_off(self):
  s=(ROOT/'lib/main.dart').read_text()
  self.assertIn('father.x-=65*dt;',s)
  self.assertIn('otherSister.x-=67*dt;',s)
  self.assertIn('exitTime>=0',s)
  self.assertNotIn('final followSpeed =',s)
 def test_no_release_approval_without_android(self):
  j=json.loads((QA/'acceptance_090.json').read_text())
  self.assertNotEqual(j['release_status'],'APROBADO')
if __name__=='__main__': unittest.main()
