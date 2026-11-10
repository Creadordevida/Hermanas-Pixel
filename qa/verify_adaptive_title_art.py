#!/usr/bin/env python3
"""Hard gate for a genuine, approved 20:9 title extension.

A panoramic asset is NOT acceptable merely because dimensions are correct.
The ENTIRE original 16:9 title is required to remain pixel-for-pixel intact.
Side art must have real local detail and should not be mirrored/repeated.
A technical PASS is NOT human artistic approval.

Call this BEFORE any manual Android build. No GitHub Actions auto trigger.
"""
from pathlib import Path
from PIL import Image
import numpy as np
import json,sys,hashlib

ROOT=Path(__file__).resolve().parents[1]
ORIGINAL=ROOT/"assets/images/title_cars_fixed_091.png"
PANORAMA=ROOT/"assets/images/title_wide_20x9.png"
LOGO=ROOT/"assets/images/twc_title_mark_clean.png"
OUTPUT=ROOT/"qa/title_art_audit.json"

def fail(message):
    raise SystemExit("TITLE ART BLOCKED: "+message)

def main():
    if not ORIGINAL.exists(): fail("approved original title missing")
    if not PANORAMA.exists():
        fail("20:9 panoramic side artwork missing. Do NOT fake it with "
             "mirrored panels, blur or a copied strip. The original 16:9 "
             "image is preserved until coherent real side artwork exists.")
    original=np.asarray(Image.open(ORIGINAL).convert("RGBA"))
    wide=np.asarray(Image.open(PANORAMA).convert("RGBA"))
    h,w=original.shape[:2]
    wh,ww=wide.shape[:2]
    if h!=wh:fail(f"height changed: {h} -> {wh}")
    target=round(h*20/9)
    if abs(ww-target)>1:fail(f"expected 20:9 width {target}, got {ww}")
    if ww<=w:fail("panorama is not wider than the original")
    left=(ww-w)//2;right=ww-w-left
    if not np.array_equal(wide[:,left:left+w,:],original):
        fail("approved central composition was changed or stretched")
    border_left=wide[:,left-1,:3].astype("float32")
    border_right=wide[:,left+w,:3].astype("float32")
    orig_left=original[:,0,:3].astype("float32")
    orig_right=original[:,-1,:3].astype("float32")
    seam_l=float(np.mean(np.abs(border_left-orig_left)))
    seam_r=float(np.mean(np.abs(border_right-orig_right)))
    if seam_l>24 or seam_r>24:
        fail(f"visible seam risk L={seam_l:.1f} R={seam_r:.1f}")
    # A blurred/solid filler is rejected based on mid-to-bottom image detail;
    # skies may naturally be flat, so never rely solely on sky variance.
    complexity=[]
    for side in (wide[:,0:left,:3],wide[:,ww-right:ww,:3]):
        part=side[int(h*.25):int(h*.90)].astype("float32")
        if part.shape[1]<10:fail("side continuation too narrow to review")
        detail=(np.abs(np.diff(part,axis=1)).mean()
                +np.abs(np.diff(part,axis=0)).mean())/2
        complexity.append(float(detail))
    if min(complexity)<2.5:
        fail(f"low-detail/blurry side extension suspected: {complexity}")
    # Detect exact mirror strips. This is a real-asset check, not aesthetics.
    for side,edge in (
        (wide[:,:left,:3],original[:,:left,:3][:,::-1]),
        (wide[:,-right:,:3],original[:,-right:,:3][:,::-1]),
    ):
        if side.shape==edge.shape:
            exact=(side==edge).all(axis=2).mean()
            if exact>.75:fail("mirrored/repeated source strip detected")
    if not LOGO.is_file():fail("transparent TWC logo not generated")
    clean=Image.open(LOGO).convert("RGBA")
    alpha=np.asarray(clean)[:,:,3]
    if not np.any(alpha>=180):fail("logo was erased")
    if alpha[0,0]>8 or alpha[-1,0]>8 or alpha[0,-1]>8 or alpha[-1,-1]>8:
        fail("logo still has opaque rectangle at corners")
    metadata={
        "source_size":[w,h],"wide_size":[ww,wh],
        "central_unmodified":True,
        "border_seam_mean_rgb":[round(seam_l,2),round(seam_r,2)],
        "side_detail":[round(v,2) for v in complexity],
        "logo_size":list(clean.size),
        "png_sha256":hashlib.sha256(PANORAMA.read_bytes()).hexdigest(),
        "artistic_approval":"PENDING human review on real Flutter screenshots",
    }
    OUTPUT.parent.mkdir(parents=True,exist_ok=True)
    OUTPUT.write_text(json.dumps(metadata,indent=2),encoding="utf-8")
    print("PASS technical title compositing. NOT an aesthetic sign-off.")

if __name__=="__main__":main()
