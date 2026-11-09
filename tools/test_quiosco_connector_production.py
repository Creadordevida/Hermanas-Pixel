#!/usr/bin/env python3
"""QA for real connector-preparation pipeline with tiny synthetic images.

Tests mathematical pixel identity, not production artistic quality.
"""
from __future__ import annotations
import json
import tempfile
from pathlib import Path
from PIL import Image
from prepare_quiosco_connector_sources import prepare
from build_quiosco_reconstruction import build

def patterned(width,height,seed):
    im=Image.new("RGB",(width,height))
    for x in range(width):
        for y in range(height):
            im.putpixel((x,y),((seed*31+x*7)%256,(x*11+y*17+seed)%256,(y*13+seed*29)%256))
    return im

def run():
    with tempfile.TemporaryDirectory(prefix="quiosco_connector_prod_") as tmp:
        base=Path(tmp)
        for folder in ("cores","connectors"):
            (base/folder).mkdir()
        sectors=[{"id":str(i),"start":i*10,"end":(i+1)*10} for i in range(3)]
        plan={"art_status":"RECONSTRUCTION_PENDING_NOT_APPROVED","tile_width":10,
              "tile_height":8,"world_width":30,"sectors":sectors,
              "landmark":{"world_x":12,"width":3,"count":1},
              "connector_system":{"overlap_px":4,"boundary_connector_types":["A","B"]}}
        planpath=base/"plan.json"
        planpath.write_text(json.dumps(plan),encoding="utf-8")
        core_images=[]
        for i,sector in enumerate(sectors):
            width=6 if i<2 else 10
            im=patterned(width,8,i+1)
            im.save(base/"cores"/(sector["id"]+".png"))
            core_images.append(im)
        con_a=patterned(4,8,14)
        con_b=patterned(4,8,15)
        con_a.save(base/"connectors"/"A.png")
        con_b.save(base/"connectors"/"B.png")
        expected=Image.new("RGB",(30,8))
        for x,im in [(0,core_images[0]),(6,con_a),(10,core_images[1]),
                     (16,con_b),(20,core_images[2])]:
            expected.paste(im,(x,0))
        prepare(base/"cores",base/"connectors",base/"sources",planpath)
        m=build(base/"sources",base/"staging",planpath)
        actual=Image.new("RGB",(30,8))
        for i in range(3):
            with Image.open(base/"staging"/f"quiosco_{i:02d}.webp") as tile:
                actual.paste(tile.convert("RGB"),(i*10,0))
        assert actual.tobytes()==expected.tobytes(), "connector duplicated or data lost"
        assert len(m["sector_seams"])==2
        print("QUIOSCO_PREPARE_AND_BUILD_PASS: exact 30x8 px synthesis; no gameplay/art QA")

if __name__=="__main__":
    run()
