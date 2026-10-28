"""Mechanical QA of two genuine activity-chapter scenery rebuilds.

Does NOT certify Android composition or artist approval.
"""
import hashlib
import json
import re
import unittest
from pathlib import Path

import numpy as np
from PIL import Image

ROOT=Path(__file__).resolve().parents[1]
ART=ROOT/'assets/images/chapter45'
MANIFEST=json.loads((ROOT/'qa/ACTIVITY_SCENES_MANIFEST.json').read_text())
LAYOUT=(ROOT/'lib/activity_chapters.dart').read_text()
CODE=(ROOT/'lib/main.dart').read_text()
PUBSPEC=(ROOT/'pubspec.yaml').read_text()


class ActivitySceneryQuality(unittest.TestCase):
    def test_six_panorama_files_are_unique_nonempty_authentic_resources(self):
        checks=[]
        for name, expected in MANIFEST['source_asset_sha256'].items():
            with self.subTest(file=name):
                file=ART/name
                self.assertTrue(file.is_file())
                sha=hashlib.sha256(file.read_bytes()).hexdigest()
                self.assertEqual(sha,expected)
                with Image.open(file) as im:
                    expected_size=(1536,1024) if 'atlas' in name else (1672,941)
                    self.assertEqual(im.size,expected_size)
                    if 'atlas' not in name:
                        self.assertEqual(im.mode,'RGB')
                        sample=np.asarray(im)[::8,::8]
                        quant=(sample//16).reshape(-1,3)
                        # The third dance room is deliberately a dark
                        # rehearsal stage, not an outdoor sunlit panorama.
                        self.assertGreater(len(np.unique(quant,axis=0)),300)
                        checks.append(sha)
                    else:
                        self.assertEqual(im.mode,'RGBA')
        self.assertEqual(len(set(checks)),6,'Duplicate panoramic assets')

    def test_originals_and_approved_floor_tiles_have_not_been_replaced(self):
        for name,expected in MANIFEST['preserved_legacy_assets_sha256'].items():
            with self.subTest(original=name):
                self.assertEqual(hashlib.sha256((ROOT/'assets/images'/name).read_bytes()).hexdigest(),expected)
        self.assertIn("'ground_$i'",CODE)
        self.assertIn("_sprite(canvas,tile,Rect.fromLTWH(x,_floorArtTop[stage]",CODE)

    def test_three_contiguous_zones_for_each_chapter_without_periodic_landmarks(self):
        for prefix in ('football','dance'):
            for asset in MANIFEST['chapters']['4' if prefix=='football' else '5']['zone_assets']:
                self.assertIn(f"ActivityZone('{asset}'",LAYOUT)
                self.assertIn(f'activity_${{zone.asset}}',CODE)
        self.assertEqual(MANIFEST['zone_ranges'],[[0,10500],[10500,25500],[25500,36500]])
        self.assertIn('stage == 4 || stage == 5',CODE)
        self.assertNotIn('void _activityBackground(Canvas canvas)',CODE)
        self.assertIn('stage == 5 || stage == 6',CODE)
        self.assertIn('_interiorBackgroundTWC(canvas);',CODE)
        self.assertNotIn('if(fade>0) _activityBackdrop(canvas,zones[index+1],fade);',CODE)
        self.assertIn('interiorModuleXWorldTWC(zone,index)-cameraX',CODE)
        self.assertNotIn('canvas.scale(-1,1)',CODE.split('void _interiorBackgroundTWC(',1)[1].split('void _background(',1)[0])

    def test_six_props_per_atlas_cropped_to_real_solid_alpha(self):
        for basename in ('football','dance'):
            im=np.array(Image.open(ART/f'{basename}_props_atlas.png').convert('RGBA'))
            # Bounds in asset code are deliberately padded 4px beyond the
            # high-opacity silhouette, to keep outlines without colored halos.
            entry=LAYOUT.split(f'const List<Rect> {basename}ActivityProps = [',1)[1].split('];',1)[0]
            rects=[tuple(map(int,m)) for m in re.findall(r'Rect.fromLTRB\((\d+), (\d+), (\d+), (\d+)\)',entry)]
            self.assertEqual(len(rects),6)
            masks=[]
            for frame,(x0,y0,x1,y1) in enumerate(rects):
                crop=im[y0:y1,x0:x1,3]
                self.assertGreater(int((crop>160).sum()),1500,frame)
                self.assertGreater(x0,0)
                self.assertLess(x1,1536)
                self.assertLess(y1,1024)
                solid=np.where(crop>180)
                self.assertGreater(int(solid[0].min()),1,frame)
                self.assertGreater(int(solid[1].min()),1,frame)
                self.assertLess(int(solid[0].max()),crop.shape[0]-2,frame)
                self.assertLess(int(solid[1].max()),crop.shape[1]-2,frame)
                masks.append((x0,y0,x1,y1))
            for i,a in enumerate(masks):
                for b in masks[i+1:]:
                    overlap=max(a[0],b[0])<min(a[2],b[2]) and max(a[1],b[1])<min(a[3],b[3])
                    self.assertFalse(overlap,basename)

    def test_motifs_move_at_world_speed_without_repeating_big_bench_panels(self):
        self.assertIn('worldX=250+n*389.0+(seed%131)-65;',CODE)
        self.assertIn('final zoneIndex=activityZoneIndex(activityZones(stage),worldX);',CODE)
        self.assertIn('groundY-h,w,h',CODE)
        self.assertIn('if(stage == 4 || stage == 5) _activityProps(canvas);',CODE)
        self.assertIn('assets/images/chapter45/',PUBSPEC)
        self.assertIn('paths[\'activity_${kind}_props\']',CODE)


if __name__=='__main__':unittest.main()
