"""Contrato estático de conexión de trajes: un código que cargue otros assets falla.
No sustituye flutter test ni el resultado en Android.
"""
import unittest
from pathlib import Path
import json,hashlib

ROOT=Path(__file__).resolve().parents[1]
SRC=(ROOT/'lib/main.dart').read_text()

class CostumeIntegration(unittest.TestCase):
    def test_poses_loaded_by_real_flutter_asset_loader(self):
        self.assertIn("paths['costume_${role}_attack_0']",SRC)
        self.assertIn("assets/images/outfits/${role}_attack_0.png",SRC)
        self.assertIn("paths['costume_${role}_$pose']",SRC)

    def test_costumes_only_in_corresponding_chapters(self):
        self.assertIn("(stage==4 && role=='futbolista')||(stage==5 && role=='bailarina')",SRC)

    def test_attack_frame_triggered_by_actual_button(self):
        self.assertIn("lastAttackTime=time;",SRC)
        self.assertIn("isCostumeAttack=active && costume",SRC)
        self.assertIn("time-lastAttackTime<.23",SRC)
        self.assertIn("final pose=isCostumeAttack?'attack_0'",SRC)

    def test_manifest_holds_10_distinct_real_png_paths(self):
        manifest=json.loads((ROOT/'qa/uniformes/MANIFIESTO_ORIGEN_Y_POSES.json').read_text())
        paths=[ROOT/i['path'] for records in manifest.values() for i in records]
        self.assertEqual(len(paths),10)
        self.assertEqual(len(set(paths)),10)
        for p in paths:self.assertTrue(p.exists())

if __name__=='__main__':unittest.main()
