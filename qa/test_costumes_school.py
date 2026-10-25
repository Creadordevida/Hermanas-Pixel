"""Comprueba que los sprites de vestuario provienen del arte aprobado.

Ya NO se exige que el traje redibujado tenga la silueta/rostro idéntico
píxel a píxel al personaje cotidiano: eso impediría la ropa nueva. La hoja
que el usuario aprobó expresamente es la referencia de esta versión.
El código conserva los archivos cotidianos intactos (verify_resources.py).
"""
import unittest
from pathlib import Path
from PIL import Image
import hashlib
import json
import numpy as np

ROOT=Path(__file__).resolve().parents[1]
P=ROOT/'assets/images'

class WardrobeIntegrity(unittest.TestCase):
    def test_sources_are_exactly_the_images_explicitly_approved(self):
        expected={
            'MIREN_FUTBOL_OJOS_MARRONES_APROBADO.png':'52e17c17c0c487a4386f81785aa849574338d713bdd1af7a38065bcf4346f93d',
            'SARA_DANZA_APROBADO.png':'c77379cc2126e153b4ff999499cdb3281c7608d4312cf8febb57cd8da8febd3a',
        }
        for fname,digest in expected.items():
            with self.subTest(file=fname):
                path=ROOT/'reference'/fname
                self.assertTrue(path.exists())
                self.assertEqual(hashlib.sha256(path.read_bytes()).hexdigest(),digest)

    def test_five_real_transparent_poses_match_the_approved_source_manifest(self):
        manifest=json.loads((ROOT/'qa/uniformes/MANIFIESTO_ORIGEN_Y_POSES.json').read_text())
        for role in ('futbolista','bailarina'):
            self.assertEqual({p['name'] for p in manifest[role]},
                {'idle_0','walk_0','walk_1','jump_0','attack_0'})
            for item in manifest[role]:
                with self.subTest(role=role,pose=item['name']):
                    img=Image.open(ROOT/item['path']).convert('RGBA')
                    pixels=np.asarray(img)
                    self.assertEqual(list(img.size),item['size'])
                    self.assertEqual(hashlib.sha256((ROOT/item['path']).read_bytes()).hexdigest(),item['sha256'])
                    # No backgrounds de carteles / póster dentro del juego.
                    self.assertEqual(int(pixels[0,0,3]),0)
                    self.assertEqual(int(pixels[-1,-1,3]),0)
                    self.assertGreater(int((pixels[:,:,3]>240).sum()),20000)
                    self.assertGreater(int((pixels[:,:,3]==0).sum()),4000)
                    self.assertGreater(img.height,200)

    def test_outfits_are_actually_redrawn_not_old_hoodie_recolored(self):
        # No silhouette-preservation test: a proper football kit/leotard MUST
        # differ in silhouette from the everyday black hoodie / trousers.
        for role in ('futbolista','bailarina'):
            casual=np.asarray(Image.open(P/f'frames/{role}_idle_0.png').convert('RGBA'))
            new=np.asarray(Image.open(P/f'outfits/{role}_idle_0.png').convert('RGBA'))
            self.assertNotEqual(casual.shape,new.shape)
            self.assertGreater(int((new[:,:,3]>240).sum()),20000)
            visible=new[new[:,:,3]>240]
            if role=='futbolista':
                yellow=((visible[:,0]>170)&(visible[:,1]>110)&(visible[:,0]>visible[:,2]*1.4)).sum()
                self.assertGreater(int(yellow),5000,'La camiseta amarilla debe ser reconocible')
            else:
                mint=((visible[:,1]>visible[:,0]*1.10)&(visible[:,1]>visible[:,2]*1.15)).sum()
                self.assertGreater(int(mint),3000,'Maillot verde menta no reconocible')

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
