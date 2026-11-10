"""Create reversible placeholder candidates for six damaged goalkeeper frames.

Uses only neighboring, strictly decodable approved-source PNGs. These are NOT
newly drawn frames, nor production-ready; their purpose is to test animation
pipeline while awaiting faithful replacement art.
"""
from pathlib import Path
from PIL import Image
import json

ROOT=Path("qa/goalkeeper_rebuild_20261109")
OUT=ROOT/"replacement_candidates"
OUT.mkdir(exist_ok=True)
# Neighboring poses with valid full-body sources; preserve original files.
SUBSTITUTES={
    "shuffle_step_b":"shuffle_step_a",
    "dive":"dive_launch",
    "dive_extension":"dive_full",
    "hurt":"hurt_recoil",
    "defeat_side":"defeat_hands",
    "defeated":"defeat_knee",
}
manifest=[]
for missing,source in SUBSTITUTES.items():
    src=ROOT/f"pose_{source}_rgba.png"
    dst=OUT/f"pose_{missing}_rgba.png"
    with Image.open(src) as im:
        im.load()
        rgba=im.convert("RGBA")
        rgba.save(dst,optimize=True)
    with Image.open(dst) as check:
        check.load()
        if check.mode!="RGBA": raise RuntimeError(f"Not RGBA: {dst}")
    manifest.append(dict(missing=missing,temporary_source=source,output=str(dst),
                         status="TEMPORARY_DUPLICATE_NOT_FINAL_ART"))
(OUT/"manifest.json").write_text(json.dumps(manifest,indent=2)+"\n")
print("SIX_VALID_CANDIDATES_CREATED; replacements are duplicate poses, NOT final animation art")
