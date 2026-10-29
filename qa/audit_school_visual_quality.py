#!/usr/bin/env python3
"""Auditoría técnica REPRODUCIBLE de los 27 recursos del colegio.

No puntúa automáticamente la calidad estética: los tests de hashes/alpha
no sustituyen la inspección visual de 27 paneles y 13 capturas StagePainter.
No es una captura de Android ni genera imágenes inventadas.
"""
from pathlib import Path
from PIL import Image
import numpy as np
import hashlib,json,statistics,sys

ROOT=Path(__file__).resolve().parents[1]
SCHOOL=ROOT/"assets/images/interiors_parallax/school"
MANIFEST=ROOT/"qa/interiors_twc_lab/MANIFEST.json"
REPORT=ROOT/"qa/interiors_twc_lab/AUDITORIA_ARTISTICA_AUTOMATICA.json"
EXPECTED_W=880
EXPECTED_H=278

def visual_features(src):
    arr=np.asarray(Image.open(src).convert("RGBA"),dtype=np.uint8)
    rgb=arr[:,:,:3].astype(np.float32)
    dx=float(np.abs(np.diff(rgb,axis=1)).mean())
    dy=float(np.abs(np.diff(rgb,axis=0)).mean())
    alpha=arr[:,:,3]
    return {
        "png_sha256":hashlib.sha256(src.read_bytes()).hexdigest(),
        "native_size":list(reversed(arr.shape[:2])),
        "pixel_detail_horizontal":round(dx,3),
        "pixel_detail_vertical":round(dy,3),
        "transparent_window_fraction":round(float((alpha<100).mean()),5),
        "opaque_fraction":round(float((alpha==255).mean()),5),
    }

def main():
    if not MANIFEST.exists():raise SystemExit("Run school generator first")
    manifest=json.loads(MANIFEST.read_text(encoding="utf-8"))
    zones=manifest["stages"]["school"]["zones"]
    report={
      "identity":"Authentic school art from game PNG files",
      "render_type":"PNG resource inspection (NOT Flutter or Android)",
      "comparison_to_chapter_1":"NOT VERIFIED until real 13-camera Flutter captures",
      "artistic_approval":"BLOCKED_PENDING_VISUAL_INSPECTION",
      "zones":[],
      "failures":[],
      "warnings":[],
    }
    for z,zone in enumerate(zones):
        items=[]
        for variant in range(9):
            p=SCHOOL/f"z{z}_panel_{variant}.png"
            if not p.exists():
                report["failures"].append(f"Missing final image: {p}")
                continue
            v=visual_features(p)
            if v["native_size"] != [EXPECTED_W,EXPECTED_H]:
                report["failures"].append(f"Distorted panel size: {p}")
            items.append(v)
        hashes=[v["png_sha256"] for v in items]
        distinct=len(set(hashes))
        if distinct!=9:
            report["failures"].append(
                f"zone {z}: {distinct}/9 truly unique PNGs; old clone bug")
        if items and sum(v["transparent_window_fraction"] for v in items)<.12:
            report["warnings"].append(
                f"zone {z}: limited visible exterior; verify window masks visually")
        # Numeric visual texture is diagnostic only; a painted school interior
        # can legitimately have fewer saturated colors than a park.
        report["zones"].append({
            "id":zone["id"],"distinct_panel_hashes":distinct,
            "source_sequence":zone.get("source_sequence",[]),
            "avg_edge_horizontal":round(statistics.mean(
                v["pixel_detail_horizontal"] for v in items),3) if items else None,
            "avg_edge_vertical":round(statistics.mean(
                v["pixel_detail_vertical"] for v in items),3) if items else None,
            "transparent_window_fraction":round(statistics.mean(
                v["transparent_window_fraction"] for v in items),5) if items else None,
            "panels":items,
        })
    for name in ("mesa_aula.png","ordenador_aula.png"):
        p=SCHOOL/name
        if not p.exists():
            report["failures"].append(f"Missing real furniture: {name}")
            continue
        a=np.asarray(Image.open(p).convert("RGBA"))[:,:,3]
        fraction=float((a>100).mean())
        report.setdefault("furniture",{})[name]={
            "opaque_alpha_fraction":round(fraction,4),
            "original_geometry_sha256":hashlib.sha256(p.read_bytes()).hexdigest(),
        }
        if fraction>.60:
            report["failures"].append(
                f"{name}: probably retains a pasted rectangular background")
    REPORT.parent.mkdir(exist_ok=True,parents=True)
    REPORT.write_text(json.dumps(report,ensure_ascii=False,indent=2),
                      encoding="utf-8")
    print(f"QA art source audit written to: {REPORT}")
    for row in report["zones"]:
        print(row["id"],"distinct",row["distinct_panel_hashes"],
              "detail_x",row["avg_edge_horizontal"],
              "windows",row["transparent_window_fraction"])
    if report["failures"]:
        for failure in report["failures"]:print("FAIL:",failure,file=sys.stderr)
        raise SystemExit(1)
    print("PASS technical resource checks. HUMAN ARTISTIC REVIEW NOT PASSED.")

if __name__=="__main__":
    main()
