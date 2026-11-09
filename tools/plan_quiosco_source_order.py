#!/usr/bin/env python3
"""Rank orderings of distinct authored Quiosco candidate panoramas.

Only an image-border diagnostic. Structural continuity and StagePainter QA
remain mandatory; it cannot manufacture or approve a connector.
"""
from __future__ import annotations

import argparse
import itertools
import json
from pathlib import Path

from PIL import Image


def audit(paths: list[Path]) -> dict:
    if len(paths) < 2 or len(paths) > 8:
        raise ValueError("Supply between 2 and 8 candidate sources")
    ends = []
    for p in paths:
        with Image.open(p) as im:
            if im.height != 390:
                raise ValueError(f"Non-native candidate height: {p}")
            rgb = im.convert("RGB")
            ends.append((list(rgb.crop((0,0,1,390)).getdata()),
                         list(rgb.crop((rgb.width-1,0,rgb.width,390)).getdata())))
    def delta(i, j):
        return sum(abs(x-y) for a,b in zip(ends[i][1],ends[j][0]) for x,y in zip(a,b)) / (390*3)
    best=[]
    for order in itertools.permutations(range(len(paths))):
        scores=[delta(a,b) for a,b in zip(order,order[1:])]
        best.append({"order":[paths[i].name for i in order],
                     "join_deltas":[round(s,2) for s in scores],
                     "worst_join":round(max(scores),2),
                     "total_delta":round(sum(scores),2)})
    return {"candidate_count":len(paths),"orderings_checked":len(best),
            "lowest_total_delta":sorted(best,key=lambda x:(x["total_delta"],x["worst_join"]))[:3],
            "status":"PLANNING_ONLY_DO_NOT_ACTIVATE"}


if __name__ == "__main__":
    parser=argparse.ArgumentParser()
    parser.add_argument("sources",type=Path,nargs="+")
    args=parser.parse_args()
    print(json.dumps(audit(args.sources),indent=2,ensure_ascii=False))
