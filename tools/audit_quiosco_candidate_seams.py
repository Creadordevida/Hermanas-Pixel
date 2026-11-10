#!/usr/bin/env python3
"""Check visual candidate ZIP WITHOUT modifying the game.

Outputs panel-edge seam scores and per-sector source provenance. Passing means
raster contract only; human review and authentic StagePainter scrolling required.
"""
from __future__ import annotations
import argparse
import io
import json
import statistics
import zipfile
from pathlib import Path
from PIL import Image, ImageChops, ImageStat

PREFIX = "assets/images/quiosco_rc7/"
def mean_delta(left: Image.Image, right: Image.Image) -> float:
    a = left.convert("RGB"); b = right.convert("RGB")
    return float(statistics.mean(ImageStat.Stat(ImageChops.difference(a, b)).mean))

def audit(path: Path) -> dict:
    with zipfile.ZipFile(path) as z:
        manifest = json.loads(z.read(PREFIX + "manifest.json"))
        assert manifest["tile_count"] == 39
        assert manifest["world_width"] == 37440
        sources = manifest.get("source_details", [])
        if len(sources) != 6 or len({s["sha256"] for s in sources}) != 6:
            raise ValueError("Required: six original, distinct sector panoramas")
        assert all(s.get("part") == "facade_authored_sector" for s in sources)
        panels=[]
        for i, item in enumerate(manifest["tiles"]):
            name=f"quiosco_{i:02d}.webp"
            assert (item["tile"],item["filename"],item["world_start"]) == (i,name,i*960)
            with Image.open(io.BytesIO(z.read(PREFIX+name))) as img:
                assert img.size == (960,390)
                panels.append(img.convert("RGB"))
        seams=[]
        for i in range(38):
            # Local neighbors should generally be similar at a genuinely
            # continuous slice; contrast can still vary across real edges.
            edge1=panels[i].crop((959,0,960,390))
            edge2=panels[i+1].crop((0,0,1,390))
            seams.append({"join":i,"world_x":(i+1)*960,
                          "mean_rgb_difference":round(mean_delta(edge1,edge2),2)})
        return {
            "status":"CANDIDATE_REQUIRES_ART_REVIEW",
            "panel_count":len(panels),
            "authored_unique_sector_count":len(sources),
            "seams":seams,
            "worst_seams":sorted(seams,key=lambda s:s["mean_rgb_difference"],reverse=True)[:10],
            "warning":"Seam score does not detect internal cut facades, repetition or bad camera motion."
        }

if __name__ == "__main__":
    p=argparse.ArgumentParser()
    p.add_argument("candidate",type=Path)
    p.add_argument("--report",type=Path)
    args=p.parse_args()
    result=audit(args.candidate)
    raw=json.dumps(result,ensure_ascii=False,indent=2)
    if args.report:
        args.report.parent.mkdir(parents=True,exist_ok=True)
        args.report.write_text(raw+"\n",encoding="utf-8")
    print(raw)
