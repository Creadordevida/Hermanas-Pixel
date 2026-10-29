#!/usr/bin/env python3
"""Contactos auténticos de las 27 composiciones del colegio.

Sólo usa PNG generados por el proyecto y el render local Python existente.
NO simula una captura Android ni del StagePainter/Flutter.
No ejecuta GitHub Actions y no construye ningún APK.
"""
from pathlib import Path
import runpy

ROOT=Path(__file__).resolve().parents[1]
SCRIPT=ROOT/"tools/preview_interiors_twc.py"
QA=ROOT/"qa/interiors_twc_lab"

def main():
    preview=runpy.run_path(str(SCRIPT))
    contact=preview["contact"]
    render=preview["render"]
    edges=(0,10500,25500,36500)
    labels=("PASILLO","AULAS","INFORMATICA")
    QA.mkdir(parents=True,exist_ok=True)
    for zone in range(3):
        start,end=edges[zone:zone+2]
        # Center each camera over one distinct REAL module of the zone.
        cameras=[min(end-800,start+i*880+40) for i in range(9)]
        contact("school",cameras,
          f"CONTACTO_COLEGIO_{labels[zone]}_9_MODULOS_PYTHON.jpg",
          columns=3)
    # Hold the furniture/walls camera frozen and advance ONLY the landscape:
    # any movement outside a transparent pane is a rendering defect.
    cam=1320
    for shift,name in ((0,"quieto"),(540,"cielo_en_movimiento")):
        render("school",cam,exterior_cam=cam+shift).save(
            QA/f"VENTANA_CIELO_{name}_PYTHON.png")
    print("27 panel views and sky-only A/B checks written from REAL game assets.")
    print("These are Python renders, NOT Flutter screenshots or art approval.")

if __name__=="__main__":
    main()
