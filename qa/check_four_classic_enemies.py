#!/usr/bin/env python3
"""Technical QA of 20 genuine polished character frames; not an art approval."""
from pathlib import Path
from PIL import Image
import hashlib, json, sys

ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/"assets/images/enemies"
REVIEW=ROOT/"qa/art_review"
manifest=REVIEW/"four_existing_enemy_polish_state.json"
errors=[]
if not manifest.exists():
    raise SystemExit("Run tools/refine_four_classic_enemies.py first")
data=json.loads(manifest.read_text(encoding="utf-8"))
required={"breakdancer":(2,6),"bully":(1,5),"referee":(2,6),"rival":(2,5)}

for kind,(scale,count) in required.items():
    visible=[]
    for idx in range(count):
        name=f"{kind}_{idx}"
        p=SRC/f"{name}.png"
        info=data.get(name,{})
        if not p.exists() or not info:
            errors.append(name+": source/manifest missing")
            continue
        sha=hashlib.sha256(p.read_bytes()).hexdigest()
        if sha!=info.get("after"):
            errors.append(name+": generated PNG doesn't match verified SHA")
        im=Image.open(p).convert("RGBA")
        w,h=info["old_size"]
        if im.size != (w*scale,h*scale):
            errors.append(name+f": expected {(w*scale,h*scale)}, got {im.size}")
        box=im.getchannel("A").getbbox()
        if not box:
            errors.append(name+": no visible pixels")
            continue
        visible.append(box)
        if box[2]-box[0]<im.width*.2:
            errors.append(name+": unnaturally thin silhouette")
        if box[3]-box[1]<im.height*.18:
            errors.append(name+": visible figure is truncated")
    sheet=REVIEW/f"{kind}_original_vs_polished.png"
    if not sheet.is_file():
        errors.append(kind+": contact sheet missing")
    else:
        with Image.open(sheet) as im:
            if im.width<1000 or im.height<500:
                errors.append(kind+": contact sheet truncated")
    print(f"{kind}: {len(visible)} of {count} original-illustration poses inspected (geometry)")
if errors:
    for err in errors:print("ERROR:",err,file=sys.stderr)
    raise SystemExit(1)
print("PASS: source checksums, pixel geometry and contact sheets.")
print("NOT APPROVED: visual comparison and gameplay captures still required.")
