"""Checks for the concrete defects seen in the user-supplied Android screenshots.
These tests are mechanical; visual artistic approval still needs actual device.
"""
import unittest,hashlib,zipfile,re
from pathlib import Path
from PIL import Image
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
EN=ROOT/'assets/images/enemies'
CODE=(ROOT/'lib/main.dart').read_text()
BASE=ROOT/'qa/enemy_originals_rc5'

class RC6EnemyCorrections(unittest.TestCase):
 def test_every_required_enemy_frame_is_loaded_and_not_empty(self):
  for kind in ['rival','referee','novice','breakdancer','pigeon','cat','rat','bully','teacher','statue']:
   for idx in range(5):
    with self.subTest(kind=kind,frame=idx):
     f=EN/f'{kind}_{idx}.png'
     self.assertTrue(f.is_file())
     with Image.open(f) as im:
      self.assertEqual('RGBA',im.mode)
      self.assertIsNotNone(im.getchannel('A').getbbox())

 def test_referee_card_attack_keeps_the_full_face_and_arms(self):
  with Image.open(EN/'referee_2.png') as im:
   rgba=np.array(im.convert('RGBA'))
   red=(rgba[:,:,0].astype(int)>rgba[:,:,1].astype(int)*1.45)&(rgba[:,:,0]>155)&(rgba[:,:,3]>100)
   self.assertGreater(int(red.sum()),45,'The red card vanished')
  self.assertNotEqual((EN/'referee_2.png').read_bytes(),(BASE/'referee_2.png').read_bytes(),
                      'Old solid black rectangle has returned')

 def test_running_player_no_longer_has_the_original_cropped_canvas(self):
  for frame in (1,2,3):
   before=Image.open(BASE/f'rival_{frame}.png').convert('RGBA')
   after=Image.open(EN/f'rival_{frame}.png').convert('RGBA')
   self.assertGreater(after.width,before.width)
   self.assertTrue(after.getchannel('A').getbbox())

 def test_professor_has_both_feet_in_idle_animation(self):
  for frame in range(4):
   im=Image.open(EN/f'teacher_{frame}.png').convert('RGBA')
   a=np.array(im.getchannel('A'))
   self.assertGreater(im.height,213,'Shoes were cropped from the original sprite')
   # Count visibly distinct foot zones near floor, not their absolute pixels.
   foot=a[-27:]>45
   occupied=np.where(foot.any(axis=0))[0]
   self.assertGreater(occupied[-1]-occupied[0],65)

 def test_defeat_poses_are_derived_from_complete_standing_figures(self):
  for name in ('teacher','referee'):
   original=Image.open(EN/f'{name}_4.png').convert('RGBA')
   rect=original.getchannel('A').getbbox()
   self.assertGreater(rect[2]-rect[0],rect[3]-rect[1],f'{name} does not lie sideways')

 def test_pose_anchors_use_same_pixel_scale_and_floor(self):
  self.assertIn('pixelScale=targetHeight/canonical.height',CODE)
  self.assertIn('groundY-actualHeight+airborne',CODE)
  self.assertIn('source:visible',CODE)
  self.assertIn('final lean=foe.launched',CODE)

 def test_defensive_enemy_attacks_are_spaced_not_machineguns(self):
  self.assertIn('foe.attackCooldown=3.6',CODE)
  self.assertIn('foe.kind==\'referee\' ? 2',CODE)

class RC6SceneryCorrections(unittest.TestCase):
 def test_panorama_never_mirrored_stretched_or_repeated(self):
  area=CODE.split('void _backLayer(',1)[1].split('void _actor(',1)[0]
  self.assertNotIn('canvas.scale(-1,1)',area)
  self.assertIn('math.min(math.max(0, cameraX-zoneOrigin)*parallax,limit)',area)
  self.assertIn('Rect.fromLTWH(0,0,viewW,bottom)',area)

 def test_dugout_no_longer_appears_every_640_pixels(self):
  self.assertIn("paths['mid_4_plain']",CODE)
  self.assertIn('stage==4 && n%9!=0',CODE)
  p=ROOT/'assets/images/mid/stage_4_plain.png'
  with Image.open(p) as im:
   left=np.array(im.convert('RGBA'))[:,0]
   right=np.array(im.convert('RGBA'))[:,-1]
   self.assertTrue(np.array_equal(left,right),'Plain tile seam is not continuous')
  self.assertNotEqual(p.read_bytes(),(ROOT/'assets/images/mid/stage_4.png').read_bytes())

 def test_school_has_three_real_zones_with_local_camera(self):
  self.assertIn('zoneOrigin:part*zone',CODE)
  self.assertIn('zoneOrigin:next*zone',CODE)
  for scene in ('school','school_classroom','school_computers'):
   self.assertTrue((ROOT/f'assets/images/scenes/{scene}.png').is_file())

 def test_approved_miren_sara_uniforms_have_not_been_modified(self):
  archive=Path('/mnt/data/Las_aventuras_de_Miren_y_Sara_0.9.0_RC5_UNIFORMES_INTEGRADOS_GITHUB.zip')
  # Unit test can run on GitHub without prior ZIP: use versioned checksums
  # of the 10 immutable RC5 costume pixels, captured below.
  approved={
  'futbolista_idle_0':'44e0e09af92902ce252c941f1884ae53931bc59393164406e16d7fd6d776c662','futbolista_walk_0':'49f88f49507fc0afcac90b299e04fa39342d7c4f73f084ec1f1b06288705f40f',
  'futbolista_walk_1':'538a2df9c79f2ff6d03800f9ecb14967b34904d8f0b67340d49ffb547c8e228a','futbolista_jump_0':'a76e861a60af1a5e0d3a97f4f967be36533584a06cfce0ff2050941acb61ce46',
  'futbolista_attack_0':'acc38dafaa3f3433f3f2344f36badd90501b1ae74bda94ab37add61a6e1ec2de','bailarina_idle_0':'6e181909e69ca4d4e8ad448041efc2594c4bc0540506ec18b67da03971f64618',
  'bailarina_walk_0':'d153e1bf7dc99b1a15a4e966a68d9d5f12de7430b6ef5673f952c0265bc2e4f2','bailarina_walk_1':'2fdc3094d6616b0d65606250b448c230f8ed77fd318d6f959e79eb532760edfd',
  'bailarina_jump_0':'155c77d2a1be21a181f2aa475efcf1ee860b011f9886f710d839ea95bc465f8e','bailarina_attack_0':'84751782cc4fdf0c1e0926eb12143821edd87456f12ab26ba8af8f2868dbe644'
  }
  for name,expected in approved.items():
   f=ROOT/f'assets/images/outfits/{name}.png'
   self.assertEqual(expected,hashlib.sha256(f.read_bytes()).hexdigest(),name)

if __name__=='__main__':unittest.main()
