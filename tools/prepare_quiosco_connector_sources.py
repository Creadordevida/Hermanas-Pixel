#!/usr/bin/env python3
"""Prepare sector PNGs from distinct cores and shared architectural connectors.

Does NOT paint or invent architecture. Input files must be authored/approved PNGs.
Cores: <sector_id>.png, width=(end-start-overlap) except last=end-start.
Connectors: A.png, B.png, C.png, each overlap x tile_height.
The same connector art is inserted at BOTH sides of adjacent sector source PNGs;
the staging builder removes its duplicate so the shared building occurs once.
Usage:
 python3 tools/prepare_quiosco_connector_sources.py --cores /path/cores \
    --connectors /path/connectors --out /tmp/quiosco_sources
"""
from __future__ import annotations
import argparse
import json
from pathlib import Path
from PIL import Image

ROOT=Path(__file__).resolve().parents[1]
PLAN=ROOT/"qa/quiosco_rc7_art_rebuild_plan.json"

def prepare(cores:Path, connectors:Path, out:Path, plan_path:Path=PLAN):
    plan=json.loads(plan_path.read_text(encoding="utf-8"))
    sectors=plan["sectors"]
    cfg=plan["connector_system"]
    width=cfg["overlap_px"]
    height=plan["tile_height"]
    types=cfg["boundary_connector_types"]
    if len(types)!=len(sectors)-1 or width<=0:
        raise ValueError("Invalid connector list")
    if out.resolve().is_relative_to((ROOT/"assets").resolve()):
        raise ValueError("Cannot write to active assets")
    if out.exists() and any(out.iterdir()):
        raise ValueError("Output must be empty")
    connector_images={}
    for name in set(types):
        path=connectors/(name+".png")
        with Image.open(path) as im:
            if im.size!=(width,height):
                raise ValueError(f"Wrong connector size: {path} {im.size}")
            connector_images[name]=im.convert("RGB").copy()
    rendered=[]
    for i,sector in enumerate(sectors):
        name=sector["id"]
        segment_width=sector["end"]-sector["start"]
        core_width=segment_width-(width if i<len(sectors)-1 else 0)
        with Image.open(cores/(name+".png")) as im:
            if im.size!=(core_width,height):
                raise ValueError(f"Wrong core size {name}: {im.size}, expected {(core_width,height)}")
            middle=im.convert("RGB").copy()
        result_width=segment_width+(width if i else 0)
        result=Image.new("RGB",(result_width,height))
        offset=0
        if i:
            result.paste(connector_images[types[i-1]],(0,0))
            offset+=width
        result.paste(middle,(offset,0))
        offset+=core_width
        if i<len(sectors)-1:
            result.paste(connector_images[types[i]],(offset,0))
            offset+=width
        if offset!=result_width:
            raise ValueError(f"Unexpected sector dimensions: {name}")
        rendered.append((name,result))
    out.mkdir(parents=True,exist_ok=True)
    for name,img in rendered:
        img.save(out/(name+".png"))
    print(f"QUIOSCO_CONNECTOR_SOURCES_PREPARED: {len(rendered)} sectors")
    print("Art is NOT approved; inspect joins between each original core and connector")

if __name__=="__main__":
    parser=argparse.ArgumentParser()
    parser.add_argument("--cores",required=True,type=Path)
    parser.add_argument("--connectors",required=True,type=Path)
    parser.add_argument("--out",required=True,type=Path)
    parser.add_argument("--plan",default=PLAN,type=Path)
    args=parser.parse_args()
    prepare(args.cores,args.connectors,args.out,args.plan)
