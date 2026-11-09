#!/usr/bin/env python3
"""Build STAGED Quiosco RC7 art from six ORIGINAL contiguous sector PNGs.

No changes to active assets; never claims artistic validation. Requires Pillow.
Example:
 python3 tools/build_quiosco_reconstruction.py --sources qa/quiosco_art_sources --out /tmp/quiosco_candidate
Input: <sector-id>.png for every sector in qa/quiosco_rc7_art_rebuild_plan.json
Each image MUST be exactly (end-start) x 390 pixels. No stretching.
"""
from __future__ import annotations
import argparse
import collections
import hashlib
import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
PLAN = ROOT / "qa/quiosco_rc7_art_rebuild_plan.json"

def sha(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()

def seam_metric(left: Image.Image, right: Image.Image) -> float:
    """Mean absolute RGB change at one vertical seam, diagnostic only."""
    a = left.convert("RGB").crop((left.width - 1, 0, left.width, left.height))
    b = right.convert("RGB").crop((0, 0, 1, right.height))
    pixels_a, pixels_b = list(a.getdata()), list(b.getdata())
    return round(sum(abs(x-y) for p,q in zip(pixels_a,pixels_b)
                     for x,y in zip(p,q)) / (3*len(pixels_a)), 2)

def build(source_dir: Path, out: Path, plan_path: Path = PLAN) -> dict:
    plan = json.loads(plan_path.read_text(encoding="utf-8"))
    assert plan["art_status"] != "APPROVED"
    sections = plan["sectors"]
    height, width, tile_width = plan["tile_height"], plan["world_width"], plan["tile_width"]
    if not sections or sections[0]["start"] != 0 or sections[-1]["end"] != width:
        raise ValueError("Sector coverage incomplete")
    for a,b in zip(sections,sections[1:]):
        if a["end"] != b["start"]:
            raise ValueError("Sector gap or overlap")
    sources, pictures = [], []
    for part in sections:
        path = source_dir / (part["id"] + ".png")
        if not path.is_file():
            raise FileNotFoundError(f"Original sector missing: {path}")
        with Image.open(path) as im:
            if im.size != (part["end"]-part["start"], height):
                raise ValueError(f"Wrong original dimensions {path}: {im.size}")
            picture = im.convert("RGB").copy()
        sources.append({"sector": part["id"], "file": path.name,
                        "sha256": sha(path.read_bytes()), "width": picture.width})
        pictures.append(picture)
    if len(set(s["sha256"] for s in sources)) != len(sources):
        raise ValueError("Identical whole-sector source images are forbidden")
    sector_seams = [
        {"boundary": parts["end"], "left": parts["id"],
         "right": sections[i+1]["id"],
         "mean_rgb_difference": seam_metric(pictures[i],pictures[i+1])}
        for i,parts in enumerate(sections[:-1])
    ]
    # Writes only to an isolated new/staging directory, never assets/images.
    if out.resolve().is_relative_to((ROOT / "assets").resolve()):
        raise ValueError("Staging output cannot be inside active assets")
    if out.exists() and any(out.iterdir()):
        raise ValueError("Output directory must be new or empty; no overwrite")
    out.mkdir(parents=True, exist_ok=True)
    tile = Image.new("RGB",(tile_width,height))
    tiles = []
    for i in range(width // tile_width):
        begin,end = i*tile_width,(i+1)*tile_width
        for section,picture in zip(sections,pictures):
            lo=max(begin,section["start"]); hi=min(end,section["end"])
            if hi>lo:
                fragment=picture.crop((lo-section["start"],0,hi-section["start"],height))
                tile.paste(fragment,(lo-begin,0))
        dest=out/f"quiosco_{i:02d}.webp"
        tile.save(dest,format="WEBP",lossless=True,method=6)
        tiles.append({"tile":i,"world_start":begin,"filename":dest.name,
                      "sha256":sha(dest.read_bytes())})
    manifest={"status":"STAGED_NOT_INTEGRATED_NOT_APPROVED",
              "world_width":width,"tile_width":tile_width,"tile_height":height,
              "tile_count":len(tiles),"source_sectors":sources,
              "sector_seams":sector_seams,"tiles":tiles,
              "landmark":plan["landmark"],
              "notice":"quiosco_unico.webp remains protected in active asset bundle; no Flutter/Android validation"}
    (out/"rebuild_manifest.json").write_text(
        json.dumps(manifest,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    return manifest

if __name__ == "__main__":
    parser=argparse.ArgumentParser()
    parser.add_argument("--sources",required=True,type=Path)
    parser.add_argument("--out",required=True,type=Path)
    parser.add_argument("--plan",default=PLAN,type=Path)
    args=parser.parse_args()
    result=build(args.sources,args.out,args.plan)
    print(f"STAGED {result['tile_count']} panels; no live art modified")
    print("Seams are measurements, not artistic sign-off:",result["sector_seams"])
