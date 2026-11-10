#!/usr/bin/env python3
"""Create REAL raster inspection crops from staged Quiosco source PNGs.

Only inspects supplied images; it NEVER invents gameplay captures. Generates
two contact images per connector: incoming-core -> connector, connector ->
outgoing-core, plus an assembled wide crop spanning the true world boundary.
No changes to game assets.
"""
from __future__ import annotations
import argparse
import json
from pathlib import Path
from PIL import Image, ImageDraw

ROOT=Path(__file__).resolve().parents[1]
PLAN=ROOT/"qa/quiosco_rc7_art_rebuild_plan.json"

def inspect(sources:Path,out:Path,plan_path:Path=PLAN):
    p=json.loads(plan_path.read_text(encoding="utf-8"))
    parts=p["sectors"]
    overlap=p["connector_system"]["overlap_px"]
    height=p["tile_height"]
    width=256
    if out.resolve().is_relative_to((ROOT/"assets").resolve()):
        raise ValueError("Cannot write within game assets")
    if out.exists() and any(out.iterdir()):
        raise ValueError("Output must be new or empty")
    panels=[]
    for s in parts:
        with Image.open(sources/(s["id"]+".png")) as im:
            panels.append(im.convert("RGB").copy())
    out.mkdir(parents=True,exist_ok=True)
    for i in range(len(parts)-1):
        a,b=panels[i],panels[i+1]
        if a.height!=height or b.height!=height:
            raise ValueError("Inconsistent sector height")
        if a.crop((a.width-overlap,0,a.width,height)).tobytes()!=b.crop((0,0,overlap,height)).tobytes():
            raise ValueError(f"Shared connector mismatch: {i}")
        # assembled scene: 256 px of old distinct core, 256 px of shared
        # connector and 256 px of the next distinct core, each exactly once
        half=min(width,a.width-overlap,b.width-overlap)
        img=Image.new("RGB",(half*2+overlap,height))
        img.paste(a.crop((a.width-overlap-half,0,a.width,height)),(0,0))
        img.paste(b.crop((overlap,0,overlap+half,height)),(half+overlap,0))
        img.save(out/f"boundary_{i+1:02d}_actual_source.png")
        # Flag actual cut points in a separate annotated QA copy.
        marked=img.copy()
        draw=ImageDraw.Draw(marked)
        for pos in (half,half+overlap):
            draw.line((pos,0,pos,height-1),fill=(255,0,255),width=2)
        marked.save(out/f"boundary_{i+1:02d}_qa_marks.png")
    print(f"QUIOSCO_REAL_SOURCE_SEAM_PREVIEWS: {len(parts)-1}, NOT STAGEPAINTER")

if __name__=="__main__":
    a=argparse.ArgumentParser()
    a.add_argument("--sources",type=Path,required=True)
    a.add_argument("--out",type=Path,required=True)
    a.add_argument("--plan",type=Path,default=PLAN)
    args=a.parse_args()
    inspect(args.sources,args.out,args.plan)
