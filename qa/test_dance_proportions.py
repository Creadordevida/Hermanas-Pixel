#!/usr/bin/env python3
"""Dance geometry gate against approved original source pixels, not a taste test.

Run after: python3 tools/build_dance_panels_twc.py
The current GitHub dance panels must be regenerated to meet this contract.
Passing this test DOES NOT prove Flutter/Android visual correctness.
"""
import hashlib
import unittest
from pathlib import Path
from PIL import Image
import numpy as np

ROOT=Path(__file__).resolve().parents[1]
ASSETS=ROOT/'assets/images'
DANCE=ASSETS/'interiors_parallax/dance'
ORIGINALS=('dance_foyer','dance_studio','dance_stage')
# Git blob IDs of protected real original artwork.
SOURCE_BLOBS=('a0e98f69853e17f9b0734e6ae496b0cd1ff07153',
              'be8e33789444cd94f7843906dbfae7a1c4c37d2a',
              'f48659a6517e6a5c52973441cfce055de8caeae8')

def git_blob_sha(data):
    return hashlib.sha1(b'blob '+str(len(data)).encode()+b'\\0'+data).hexdigest()

class DanceSourceProportions(unittest.TestCase):
    def test_original_art_protected(self):
        for i,name in enumerate(ORIGINALS):
            source=(ASSETS/'chapter45'/f'{name}.png').read_bytes()
            self.assertEqual(git_blob_sha(source),SOURCE_BLOBS[i],name)

    def test_non_deforming_source_window(self):
        self.assertAlmostEqual(880/1200,286/390,places=10)

    def test_nine_distinct_panels_and_color_provenance(self):
        digest=set()
        for zone,name in enumerate(ORIGINALS):
            original=Image.open(ASSETS/'chapter45'/f'{name}.png').convert('RGB')
            for variant,left in enumerate((0,236,472)):
                top=175 if zone==2 else 155
                expected=original.crop((left,top,left+1200,top+390)).resize(
                    (880,286),Image.Resampling.LANCZOS)
                path=DANCE/f'z{zone}_panel_{variant}.png'
                self.assertTrue(path.is_file(),path)
                digest.add(hashlib.sha256(path.read_bytes()).digest())
                with Image.open(path) as panel:
                    self.assertEqual(panel.size,(880,286))
                    self.assertEqual(panel.mode,'RGBA')
                    for x,y in ((100,70),(290,120),(570,175),(735,240)):
                        self.assertEqual(panel.getpixel((x,y))[:3],
                                         expected.getpixel((x,y)),
                                         f'{name}/{variant} pixel {x},{y}')
                    alpha=np.asarray(panel)[:,:,3]
                    self.assertTrue(np.all(alpha[-25:,:]==255),
                                    'Floor must not become transparent')
                    self.assertGreater(float((alpha==255).mean()),.82,
                                       'Do not erase the walls for parallax')
        self.assertEqual(len(digest),9)

if __name__=='__main__':
    unittest.main()
