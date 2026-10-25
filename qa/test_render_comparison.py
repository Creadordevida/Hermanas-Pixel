"""Prueba sobre falsos positivos y negativos de la comparación visual (SIN afirmar APK)."""
from pathlib import Path
import tempfile,unittest
from PIL import Image,ImageDraw
from compare_flutter_renders import compare,check,NAMES

class CompareTests(unittest.TestCase):
    def test_identical_engine_frames_pass(self):
        with tempfile.TemporaryDirectory() as folder:
            d=Path(folder)
            im=Image.new('RGB',(800,450),'navy')
            im.save(d/'one.png')
            self.assertTrue(compare(d/'one.png',d/'one.png')['exact_match'])
    def test_one_pixel_difference_is_detected(self):
        with tempfile.TemporaryDirectory() as folder:
            d=Path(folder)
            im=Image.new('RGB',(800,450),'navy');im.save(d/'original.png')
            im.putpixel((201,114),(255,255,255));im.save(d/'changed.png')
            result=compare(d/'original.png',d/'changed.png')
            self.assertFalse(result['exact_match'])
            self.assertGreater(result['pixels_changed_pct'],0)
    def test_missing_original_capture_must_fail(self):
        with tempfile.TemporaryDirectory() as folder:
            d=Path(folder)
            result=check(d/'not_existent',d/'another')
            self.assertFalse(result['passed'])
            self.assertEqual(len(result['errors']),len(NAMES))
    def test_resolution_mismatch_is_rejected(self):
        with tempfile.TemporaryDirectory() as folder:
            d=Path(folder)
            Image.new('RGB',(800,450)).save(d/'a.png')
            Image.new('RGB',(640,360)).save(d/'b.png')
            with self.assertRaises(ValueError):compare(d/'a.png',d/'b.png')

if __name__=='__main__':unittest.main()
