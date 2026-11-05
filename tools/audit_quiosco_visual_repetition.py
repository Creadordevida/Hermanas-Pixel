#!/usr/bin/env python3
"""Detect repeated architectural source crops in Plaza del Castillo / Quiosco.

This deliberately separates TECHNICAL raster integrity from ARTISTIC variety.
Returns exit code 1 only with --strict (final-art approval pipeline).
"""
from __future__ import annotations
import argparse, collections, json
from pathlib import Path

def audit(path: Path) -> dict:
    data=json.loads(path.read_text(encoding="utf-8"))
    chunks=[c for c in data.get("source_details",[])
            if c.get("part") == "facade_candidate"]
    if not chunks:
        raise ValueError("No sourced architectural segments documented")
    keys=[(c.get("source"),c.get("crop_x"),c.get("width")) for c in chunks]
    counts=collections.Counter(keys)
    repeated=sum(num for num in counts.values() if num>1)
    total=len(keys)
    max_repeat=max(counts.values())
    unique=len(counts)
    result={
        "chapter":"Plaza del Castillo / Quiosco",
        "total_facade_segments":total,
        "unique_source_crops":unique,
        "unique_ratio":round(unique/total,4),
        "reused_segment_count":repeated,
        "max_repetitions_of_one_crop":max_repeat,
        "bandstand_count":data.get("landmark",{}).get("count"),
        "bandstand_world_x":data.get("landmark",{}).get("world_x"),
        "status":"NEEDS_MORE_AUTHORED_ARCHITECTURE" if unique/total<0.5 else "VARIETY_GATE_MET",
    }
    return result

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument("--manifest",default="assets/images/quiosco_rc7/manifest.json")
    parser.add_argument("--strict",action="store_true")
    args=parser.parse_args()
    result=audit(Path(args.manifest))
    print(json.dumps(result,indent=2,ensure_ascii=False))
    if args.strict and result["status"]!="VARIETY_GATE_MET":
        raise SystemExit("Art NOT approved: too many repeated architectural source segments")

if __name__=="__main__":
    main()
