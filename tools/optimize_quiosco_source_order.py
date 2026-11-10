#!/usr/bin/env python3
"""Find a non-repeating order for 18 candidate Quiosco art panoramas.

Minimize both severe raw-border differences and total joins. This only chooses
source order: it does NOT certify façade geometry or touch active game assets.
"""
from __future__ import annotations

import argparse
import json
import random
from pathlib import Path
from PIL import Image

from assemble_quiosco_18_art_candidate import NAMES, source


def main():
    p=argparse.ArgumentParser()
    p.add_argument('--work', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    args=p.parse_args()
    borders=[]
    for name in NAMES:
        with Image.open(source(name,args.work)) as opened:
            im=opened.convert('RGB')
            borders.append((list(im.crop((0,0,1,390)).getdata()),
                            list(im.crop((im.width-1,0,im.width,390)).getdata())))
    n=len(NAMES)
    score=[[0.0]*n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            if i==j: continue
            score[i][j]=sum(abs(a-b) for l,r in zip(borders[i][1],borders[j][0])
                             for a,b in zip(l,r))/(390*3)
    def cost(route):
        vals=[score[a][b] for a,b in zip(route,route[1:])]
        return (round(max(vals),2),round(sum(x*x for x in vals),2),round(sum(vals),2))
    baseline=list(range(n))
    best=baseline[:]
    random.seed(20261109)
    # Two-opt path refinement with random restarts; objective first minimizes
    # the worst individual join to avoid one unacceptable hard cut.
    for trial in range(120):
        route=baseline[:] if trial==0 else random.sample(range(n),n)
        improved=True
        while improved:
            improved=False
            candidate_cost=cost(route)
            for a in range(n-1):
                for b in range(a+1,n):
                    candidate=route[:a]+list(reversed(route[a:b+1]))+route[b+1:]
                    c=cost(candidate)
                    if c<candidate_cost:
                        route=candidate
                        candidate_cost=c
                        improved=True
        if cost(route)<cost(best): best=route
    result={'baseline_order':NAMES,'baseline_cost':cost(baseline),
            'optimized_order':[NAMES[i] for i in best],
            'optimized_cost':cost(best),
            'join_differences':[round(score[a][b],2) for a,b in zip(best,best[1:])],
            'status':'COLOR_ONLY_VISUAL_ARCHITECTURE_REVIEW_REQUIRED'}
    args.out.parent.mkdir(parents=True,exist_ok=True)
    args.out.write_text(json.dumps(result,indent=2,ensure_ascii=False)+'\n')
    print(json.dumps(result,indent=2,ensure_ascii=False))


if __name__=='__main__': main()
