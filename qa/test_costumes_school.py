"""Redundant art-sanity controls for the actual PNG assets shipped in the APK.
Passing does NOT certify artistic excellence: review/Android screenshot still required.
"""
import unittest
from pathlib import Path
from PIL import Image
import numpy as np

ROOT=Path(__file__).resolve().parents[1]
P=ROOT/'assets/images'

class WardrobeIntegrity(unittest.TestCase):
    def test_facial_pixels_are_identical_for_each_of_eight_costume_poses(self):
        for role in ('futbolista','bailarina'):
            for pose in ('idle_0','walk_0','walk_1','jump_0'):
                with self.subTest(role=role,pose=pose):
                    original=np.array(Image.open(P/f'frames/{role}_{pose}.png').convert('RGBA'))
                    costumed=np.array(Image.open(P/f'outfits/{role}_{pose}.png').convert('RGBA'))
                    h,w=original.shape[:2]
                    # Full original face/eye/nose/mouth for both characters.
                    region=(slice(int(h*.12),int(h*.34)),slice(int(w*.58),int(w*.95)))
                    self.assertTrue(np.array_equal(original[region],costumed[region]),'Original face altered')
                    self.assertTrue(np.array_equal(original[:,:,3],costumed[:,:,3]),'Sprite outline/anchor altered')
                    self.assertGreater(np.count_nonzero(np.any(original[:,:,:3]!=costumed[:,:,:3],axis=2)),6000)

    def test_outfits_have_yellow_jersey_and_mint_leotard_not_old_black_hoodie(self):
        for role in ('futbolista','bailarina'):
            im=np.array(Image.open(P/f'outfits/{role}_idle_0.png').convert('RGBA'))
            hh,ww=im.shape[:2];torso=im[int(hh*.36):int(hh*.55),int(ww*.43):int(ww*.72)]
            visible=torso[torso[:,:,3]>60]
            if role=='futbolista':
                yellow=np.count_nonzero((visible[:,0]>135)&(visible[:,1]>94)&(visible[:,0]>visible[:,2]*1.6))
                self.assertGreater(yellow,150,'Football jersey not recognisably yellow')
            else:
                mint=np.count_nonzero((visible[:,1]>visible[:,0]*1.17)&(visible[:,1]>visible[:,2]))
                self.assertGreater(mint,130,'Ballet leotard not recognisably mint')

class SchoolArtIntegrity(unittest.TestCase):
    def test_three_distinct_art_assets_have_the_same_floor(self):
        images=[np.array(Image.open(P/f'scenes/{name}.png').convert('RGB')) for name in ('school','school_classroom','school_computers')]
        for im in images:self.assertEqual(im.shape,(480,1320,3))
        # All rooms have exact same world floor / collision contact at groundY=390.
        self.assertTrue(np.array_equal(images[0][395:],images[1][395:]))
        self.assertTrue(np.array_equal(images[0][395:],images[2][395:]))
        for b in images[1:]:
            self.assertGreater(float(np.mean(np.any(images[0][:280]!=b[:280],axis=2))),.05)
        self.assertGreater(float(np.mean(np.any(images[1][:280]!=images[2][:280],axis=2))),.05)

    def test_school_floor_not_flat_or_vertical_stretched_wood(self):
        im=np.array(Image.open(P/'scenes/school.png').convert('RGB'),dtype=np.float32)
        region=im[320:450]
        self.assertGreater(float(region.std()),12)
        # Both horizontal and vertical detail exists in the floor, not a stretched 1D stripe.
        vertical=float(np.abs(np.diff(region,axis=0)).mean())
        horizontal=float(np.abs(np.diff(region,axis=1)).mean())
        self.assertGreater(vertical,2.0)
        self.assertGreater(horizontal,2.0)

if __name__=='__main__':unittest.main()
