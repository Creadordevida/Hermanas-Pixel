#!/usr/bin/env python3
"""Measure ACTUAL visual discontinuities at Quiosco connector/core boundaries.

Unlike checking shared connector equality, this checks both boundaries where a
connector meets newly authored architecture. No synthetic claims of art quality.
Thresholds are deliberately conservative; each flagged cut needs human review.
Usage:
 python3 tools/audit_quiosco_connector_edges.py --cores /path/cores --connectors /path/connectors --out /tmp/edges.json
"""
from __future__ import annotations
import argparse
import json
from pathlib import Path
from PIL import Image

ROOT=Path(__file__).resolve().parents[1]
PLAN=ROOT/"qa/quiosco_rc7_art_rebuild_plan.json"

def edge_difference(left:Image.Image,right:Image.Image):
    """Compare adjacent vertical pixel columns, not duplicate image strips."""
    if left.height!=right.height:
        raise ValueError("Mismatched heights")
    a=left.convert("RGB").crop((left.width-1,0,left.width,left.height))
    b=right.convert("RGB").crop((0,0,1,right.height))
    vals=[]
    for pa,pb in zip(a.getdata(),b.getdata()):
        vals.append(sum(abs(x-y) for x,y in zip(pa,pb))/3)
    vals.sort()
    return {
       "mean":round(sum(vals)/len(vals),3),
       "p95":round(vals[min(len(vals)-1,int(.95*len(vals)))],3),
       "pixel_rows_above_60":sum(v>60 for v in vals)
    }

def audit(cores:Path,connectors:Path,plan_path:Path=PLAN):
    plan=json.loads(plan_path.read_text(encoding="utf-8"))
    sectors=plan["sectors"]
    cfg=plan["connector_system"]
    overlap,height=cfg["overlap_px"],plan["tile_height"]
    types=cfg["boundary_connector_types"]
    if len(types)!=len(sectors)-1:
        raise ValueError("Missing connector definitions")
    unique={}
    for typ in set(types):
        with Image.open(connectors/(typ+".png")) as im:
            if im.size!=(overlap,height):
                raise ValueError("Connector dimensions wrong: "+typ)
            unique[typ]=im.convert("RGB").copy()
    cores_rgb=[]
    for i,s in enumerate(sectors):
        expected=s["end"]-s["start"]-(overlap if i<len(sectors)-1 else 0)
        with Image.open(cores/(s["id"]+".png")) as im:
            if im.size!=(expected,height):
                raise ValueError("Core dimensions wrong: "+s["id"])
            cores_rgb.append(im.convert("RGB").copy())
    readings=[]
    for i,typ in enumerate(types):
        conn=unique[typ]
        for side,a,b in (
            ("entry",cores_rgb[i],conn),
            ("exit",conn,cores_rgb[i+1])
        ):
            reading=edge_difference(a,b)
            readings.append({
                "boundary_world_x":sectors[i]["end"]-overlap if side=="entry" else sectors[i]["end"],
                "connector_type":typ,
                "side":side,
                "left":sectors[i]["id"] if side=="entry" else typ,
                "right":typ if side=="entry" else sectors[i+1]["id"],
                **reading,
                # diagnostic-only threshold, chosen to flag dramatic hard cuts
                "review_required":reading["mean"]>22 or reading["p95"]>75
            })
    return {
       "status":"VISUAL_REVIEW_REQUIRED" if any(x["review_required"] for x in readings)
                else "PIXEL_EDGE_GATE_PASS_HUMAN_REVIEW_STILL_REQUIRED",
       "edge_count":len(readings),
       "edges":readings,
       "notice":"Only boundary RGB discontinuities measured. Architecture and real gameplay still require visual inspection."
    }

if __name__=="__main__":
    parser=argparse.ArgumentParser()
    parser.add_argument("--cores",type=Path,required=True)
    parser.add_argument("--connectors",type=Path,required=True)
    parser.add_argument("--out",type=Path,required=True)
    parser.add_argument("--plan",type=Path,default=PLAN)
    parser.add_argument("--strict",action="store_true")
    a=parser.parse_args()
    result=audit(a.cores,a.connectors,a.plan)
    a.out.parent.mkdir(parents=True,exist_ok=True)
    a.out.write_text(json.dumps(result,indent=2,ensure_ascii=False)+"\n",encoding="utf-8")
    print(result["status"],"edges:",result["edge_count"])
    if a.strict and result["status"]=="VISUAL_REVIEW_REQUIRED":
        raise SystemExit(1)
