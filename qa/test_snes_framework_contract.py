#!/usr/bin/env python3
"""Pruebas de REGRESIÓN del conocimiento de TWC SNES, con stdlib.

Verifica que la implementación de producción sigue respetando el método
documentado del capítulo 1 y el estándar de escala de protagonistas.
NO ejecuta Flutter, Android ni GitHub Actions. NO aprueba estética.
Se ejecuta desde el checkout: python3 -m unittest qa.test_snes_framework_contract
"""
from __future__ import annotations
import re
import struct
import unittest
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]

def get_numeric(path: str, name: str) -> float:
    source=(ROOT/path).read_text(encoding="utf-8")
    match=re.search(
        r"\bconst\s+(?:double|int)\s+"+re.escape(name)+r"\s*=\s*(\d+(?:\.\d+)?)\s*;",
        source)
    if not match:
        raise AssertionError(f"Missing or changed contract {path}:{name}")
    return float(match.group(1))

def png_dimensions(path: str) -> tuple[int,int]:
    target=ROOT/path
    with target.open("rb") as file:
        header=file.read(26)
    if len(header)<26 or header[:8]!=b"\x89PNG\r\n\x1a\n":
        raise AssertionError(f"Not a real PNG: {path}")
    return struct.unpack(">II",header[16:24])

class SnesFrameworkContractTest(unittest.TestCase):
    def test_chapter_one_world_geometry_is_unchanged(self):
        path="lib/chapter_one_world_tiles.dart"
        width=int(get_numeric(path,"ch1PhysicalWidth"))
        tiles=int(get_numeric(path,"ch1PhysicalTileCount"))
        nominal=int(get_numeric(path,"ch1PhysicalTileWidth"))
        height=int(get_numeric(path,"ch1PhysicalHeight"))
        self.assertEqual((width,tiles,nominal,height),(36500,72,512,380))
        self.assertEqual(width-(tiles-1)*nominal,148)
        for n in (0,1,35,70,71):
            file=f"assets/images/chapter1/ch1_world_tiles/world_{n:03d}.png"
            self.assertTrue((ROOT/file).is_file(),file)

    def test_parallax_depth_contract_not_reset(self):
        contracts=[
            ("lib/chapter_one_world_tiles.dart","ch1FarSpeed","ch1MidSpeed",
             "ch1FarCycleWidth","ch1MidCycleWidth"),
            ("lib/football_parallax_twc.dart","footballFarSpeedTWC",
             "footballMidSpeedTWC","footballFarCycleWidthTWC",
             "footballMidCycleWidthTWC"),
            ("lib/interiors_parallax_twc.dart","interiorFarSpeedTWC",
             "interiorMidSpeedTWC","interiorFarCycleWidthTWC",
             "interiorMidCycleWidthTWC"),
        ]
        for path,far,mid,fw,mw in contracts:
            with self.subTest(path=path):
                self.assertEqual(get_numeric(path,far),.30)
                self.assertEqual(get_numeric(path,mid),.56)
                self.assertEqual(get_numeric(path,fw),2200)
                self.assertEqual(get_numeric(path,mw),2020)
        # Exact repeat period is a consequence of cycle width and velocity.
        self.assertAlmostEqual(2200/.30,7333.333333,places=3)
        self.assertAlmostEqual(2020/.56,3607.142857,places=3)

    def test_production_renders_real_world_tiles_and_approved_sprites(self):
        main=(ROOT/"lib/main.dart").read_text(encoding="utf-8")
        camera=(ROOT/"lib/chapter_one_camera_v3.dart").read_text(encoding="utf-8")
        self.assertIn("_neighborhoodPhysicalWorld(canvas);",main)
        self.assertIn("ch1PhysicalVisibleTiles(cameraX",main)
        self.assertIn("ch1PhysicalTileActualWidth(index)",main)
        self.assertIn("groundY = 390",main)
        self.assertIn("final scale=standardHeight/(base?.height ?? img.height)",main)
        self.assertIn("worldObjectScreenX(double worldX, double cameraX) => worldX - cameraX",camera)
        self.assertIn("FilterQuality.none",main)

    def test_real_hero_source_frames_are_not_synthetic_placeholders(self):
        expected={
            "assets/images/futbolista.png":(230,617),
            "assets/images/bailarina.png":(170,543),
            "assets/images/frames/futbolista_idle_0.png":(191,321),
            "assets/images/frames/futbolista_walk_0.png":(219,320),
            "assets/images/frames/futbolista_run_0.png":(56,87),
            "assets/images/frames/futbolista_jump_0.png":(251,284),
            "assets/images/frames/bailarina_idle_0.png":(165,259),
            "assets/images/frames/bailarina_walk_0.png":(202,262),
            "assets/images/frames/bailarina_run_0.png":(52,87),
            "assets/images/frames/bailarina_jump_0.png":(217,249),
        }
        for path,size in expected.items():
            with self.subTest(asset=path):
                self.assertEqual(png_dimensions(path),size,
                    "Approved sprite changed. Requires visual review, not silent overwrite.")

    def test_reusable_knowledge_is_stored_in_repository(self):
        for name in ("README.md","PROTOCOLO_ACEPTACION_VISUAL.md",
                     "ERRORES_Y_SOLUCIONES.md",
                     "01_MOTOR_ESCENARIOS_PARALLAX.md",
                     "02_PERSONAJES_ESTANDAR_MIREN_SARA.md"):
            file=ROOT/"docs/FRAMEWORK_SNES_TWC"/name
            self.assertTrue(file.exists(),name)

if __name__=="__main__":
    unittest.main()
