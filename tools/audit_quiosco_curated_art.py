#!/usr/bin/env python3
"""Audit three curated Quiosco candidate PNGs before artwork integration.

Real raster inspection. Do not classify these as Flutter captures. This check
rejects naive concatenation of the 3 short samples. It does NOT manufacture
the missing six full sector backgrounds.
"""
from __future__ import annotations
import argparse
import json
import zipfile
from io import BytesIO
from pathlib import Path
from PIL import Image

EXPECTED=("01_fachadas_entrada.png","02_quiosco_unico_referencia.png",
          "03_fachadas_salida.png")

def audit(zip_path:Path):
    with zipfile.ZipFile(zip_path) as z:
        manifest=json.loads(z.read("quiosco_arte_curado/manifest.json"))
        samples=[]
        for entry,name in zip(manifest["entries"],EXPECTED):
            if entry["file"]!=name:
                raise ValueError("Unexpected candidate sequence")
            raw=z.read("quiosco_arte_curado/"+name)
            import hashlib
            if hashlib.sha256(raw).hexdigest()!=entry["sha256"]:
                raise ValueError("Source hash mismatch: "+name)
            with Image.open(BytesIO(raw)) as im:
                if im.size!=(960,390):
                    raise ValueError("Wrong source dimensions "+name)
                samples.append(im.convert("RGB").copy())
    joins=[]
    for i in range(2):
        left=list(samples[i].crop((959,0,960,390)).getdata())
        right=list(samples[i+1].crop((0,0,1,390)).getdata())
        delta=[sum(abs(a-b) for a,b in zip(x,y))/3 for x,y in zip(left,right)]
        joins.append({"left":EXPECTED[i],"right":EXPECTED[i+1],
                      "mean_rgb_jump":round(sum(delta)/len(delta),2),
                      "rows_jump_over60":sum(x>60 for x in delta),
                      "rows_total":len(delta)})
    return {"type":"CURATED_CANDIDATE_ONLY","count":len(samples),
            "dimensions":[960,390],
            "joins":joins,"direct_join_acceptable":False,
            "notice":"These are candidate art crops, NOT StagePainter or full-length assets."}

if __name__=="__main__":
    ap=argparse.ArgumentParser()
    ap.add_argument("zip",type=Path)
    ap.add_argument("--report",type=Path)
    args=ap.parse_args()
    result=audit(args.zip)
    output=json.dumps(result,ensure_ascii=False,indent=2)
    print(output)
    if args.report:
        args.report.parent.mkdir(parents=True,exist_ok=True)
        args.report.write_text(output+"\n",encoding="utf-8")
