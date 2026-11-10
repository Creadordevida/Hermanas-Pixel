"""Strict artistic QA gate for goalkeeper 4x6 atlas.

This is intentionally separate from technical PNG validation. Rejects duplicated
frames (including copies used for emergency CI recovery) and any invalid cell.
Does not modify files, integrate assets, or approve visual quality by itself.
"""
from pathlib import Path
from PIL import Image, ImageChops
import argparse, hashlib, json, sys

ROOT=Path("qa/goalkeeper_rebuild_20261109")
parser=argparse.ArgumentParser()
parser.add_argument("--atlas",type=Path,default=ROOT/"goalkeeper_atlas_4x6_candidate_temporary_rgba.png")
args=parser.parse_args()
with Image.open(args.atlas) as source:
    source.load()
    atlas=source.convert("RGBA")
assert atlas.size==(1024,1536),f"Wrong atlas size {atlas.size}"
frames=[]
for row in range(6):
    for col in range(4):
        frame=atlas.crop((col*256,row*256,(col+1)*256,(row+1)*256))
        bbox=frame.getchannel("A").getbbox()
        assert bbox, f"Empty frame {row},{col}"
        frames.append(frame)
duplicates=[]
for a in range(24):
    for b in range(a+1,24):
        if ImageChops.difference(frames[a],frames[b]).getbbox() is None:
            duplicates.append([a,b])
report={"atlas":str(args.atlas),"atlas_sha256":hashlib.sha256(args.atlas.read_bytes()).hexdigest(),
        "cells":24,"exact_duplicate_pairs":duplicates,
        "artistic_approval":"REJECTED" if duplicates else "REQUIRES_VISUAL_AND_FLUTTER_REVIEW"}
out=ROOT/"goalkeeper_art_quality_audit.json"
out.write_text(json.dumps(report,indent=2)+"\n")
print(json.dumps(report))
if duplicates:
    sys.exit("ART_QA_FAIL: duplicated animation frames; never publish this candidate")
print("ART_QA_TECHNICAL_UNIQUENESS_PASS; visual/Flutter QA still mandatory")
