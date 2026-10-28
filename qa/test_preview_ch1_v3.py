"""QA de datos de movimiento y frames REALES del LAB Python, sin Flutter."""
from pathlib import Path
import json, sys, unittest
import numpy as np
from PIL import Image

ROOT=Path(__file__).resolve().parents[1]
MODULE_DIR=ROOT/'qa'
sys.path.insert(0,str(MODULE_DIR))
from preview_ch1_v3 import draw_frame,LANDMARK_W,GROUND

class VisualPilotTests(unittest.TestCase):
    def test_no_art_gap_in_first_120(self):
        for cam in (0,40,80,120):
            frame=draw_frame(cam,label=False)
            self.assertEqual(frame.size,(800,450))
            self.assertGreaterEqual(LANDMARK_W-cam,800)

    def test_missing_art_detected_instead_of_extending_image(self):
        with self.assertRaisesRegex(ValueError,'ARTE_INCOMPLETO'):
            draw_frame(121,label=False)
        with self.assertRaisesRegex(ValueError,'ARTE_INCOMPLETO'):
            draw_frame(600,label=False)

    def test_landmark_actual_pixels_translate_120(self):
        a=np.asarray(draw_frame(0,label=False),dtype=np.int16)
        b=np.asarray(draw_frame(120,label=False),dtype=np.int16)
        # Región arquitectónica sin personaje ni suelo: 120 px de cámara
        # desplazan exactamente 120 píxeles la imagen, no el 1.9% anterior.
        self.assertLess(np.abs(a[80:230,120:800]-b[80:230,0:680]).mean(),.001)

    def test_sprite_maintains_position_on_screen(self):
        a=np.asarray(draw_frame(0,label=False))
        b=np.asarray(draw_frame(120,label=False))
        # Azul y rosa característicos de Sara en columna x327, suelo estable.
        for im in (a,b):
            patch=im[260:390,280:370]
            pink=((patch[:,:,0]>170)&(patch[:,:,2]>60)&(patch[:,:,1]<160))
            self.assertGreater(pink.sum(),70)

    def test_floor_is_always_present(self):
        for cam in (0,40,80,120):
            im=np.asarray(draw_frame(cam,label=False))
            self.assertGreater(im[GROUND+8:GROUND+28].std(),10)

    def test_known_limitation_explicit_in_report(self):
        metrics=json.loads((MODULE_DIR/'ch1_v3_previews/metricas.json').read_text())
        self.assertGreater(metrics['uncovered_at_camera_600'],470)
        self.assertEqual(metrics['qa_status_flutter'],'NOT_TESTED')
        self.assertEqual(metrics['qa_status_seam'],'REJECTED_NOT_AUTHORED')

if __name__=='__main__':
    unittest.main()
