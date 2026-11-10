#!/usr/bin/env python3
"""Find the least-discontinuous 256px crop in an AUTHORED connector source.

Ranking only. Does not rewrite images, establish an artistic match or activate art.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from PIL import Image

def pixels(im, x):
    return list(im.crop((x, 0, x + 1, im.height)).getdata())

def difference(a, b):
    return sum(abs(x-y) for aa, bb in zip(a,b) for x,y in zip(aa,bb)) / (len(a)*3)

def search(left: Path, source: Path, right: Path, width=256):
    with Image.open(left) as li, Image.open(source) as si, Image.open(right) as ri:
        li, si, ri = (im.convert("RGB") for im in (li,si,ri))
    if not (li.height == si.height == ri.height == 390 and si.width >= width):
        raise ValueError("Expected matching 390px height and sufficient source width")
    a, b = pixels(li, li.width-1), pixels(ri, 0)
    ranking=[]
    for x in range(si.width-width+1):
        dl=difference(a,pixels(si,x)); dr=difference(pixels(si,x+width-1),b)
        ranking.append({"crop_x":x,"left_delta":round(dl,2),"right_delta":round(dr,2),
                        "total_delta":round(dl+dr,2)})
    return {"left":left.name,"source":source.name,"right":right.name,
            "candidates_checked":len(ranking),"best":sorted(ranking,key=lambda v:v["total_delta"])[:5],
            "status":"DIAGNOSTIC_ONLY_NOT_ART_APPROVAL"}

if __name__ == "__main__":
    p=argparse.ArgumentParser()
    p.add_argument("left",type=Path); p.add_argument("source",type=Path); p.add_argument("right",type=Path)
    a=p.parse_args()
    print(json.dumps(search(a.left,a.source,a.right),indent=2,ensure_ascii=False))
