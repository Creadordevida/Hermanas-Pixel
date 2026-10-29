#!/usr/bin/env python3
"""Clean the actual TIKU TWC monogram onto transparency.

The source is copied byte-for-byte from the connected TIKU GitHub project.\nOnly a uniform rectangular
background is turned transparent; no invented logo or new lettering.
This script MUST be run before a Flutter build (only with user authorization).
"""
from __future__ import annotations

from pathlib import Path
import hashlib
import json

import numpy as np
from PIL import Image

ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/"assets/images/twc_mark_from_tiku.png"
TARGET=ROOT/"assets/images/twc_title_mark_clean.png"
REPORT=ROOT/"qa/title_logo_alpha_report.json"


def extract(source: Image.Image) -> tuple[Image.Image,dict]:
    image=np.array(source.convert("RGBA"),dtype=np.uint8)
    h,w=image.shape[:2]
    rgb=image[:,:,:3].astype(np.float32)
    original_alpha=image[:,:,3].astype(np.float32)
    # Estimate the backing from the OUTER picture edges, not the wolf/seal.
    border=max(2,min(h,w)//48)
    edge=np.concatenate([
        rgb[:border].reshape(-1,3),
        rgb[-border:].reshape(-1,3),
        rgb[border:-border,:border].reshape(-1,3),
        rgb[border:-border,-border:].reshape(-1,3),
    ],axis=0)
    matte=np.median(edge,axis=0)
    spread=np.percentile(np.max(abs(edge-matte),axis=1),90)
    # Remove only the fairly uniform outer backing. A wildly varying border
    # cannot be safely keyed without deleting real TWC artwork.
    if spread>42:
        raise ValueError(
            f"Corporate logo background is not uniform (p90 {spread:.1f}). "
            "Needs manual alpha-mask inspection; refusing to damage the logo."
        )
    distance=np.max(abs(rgb-matte),axis=2)
    # Preserve non-key art and its original alpha with a short 8px
    # antialias ramp; NOT a translucent rectangular backdrop.
    keyed=np.clip((distance-12.0)/21.0,0.0,1.0)
    new_alpha=np.rint(original_alpha*keyed).astype(np.uint8)
    if np.count_nonzero(new_alpha>24)<max(150,int(h*w*.0004)):
        raise ValueError("TIKU TWC mark contains no recoverable artwork")
    image[:,:,3]=new_alpha
    box=Image.fromarray(new_alpha,"L").getbbox()
    if box is None: raise ValueError("Corporate artwork completely removed")
    l,t,r,b=box
    margin=max(5,int(h*.009))
    box=(max(0,l-margin),max(0,t-margin),
         min(w,r+margin),min(h,b+margin))
    clean=Image.fromarray(image,"RGBA").crop(box)
    a=np.asarray(clean)[:,:,3]
    if np.count_nonzero(a[0])>0 or np.count_nonzero(a[-1])>0:
        raise ValueError("Monogram touches top/bottom; need manual review")
    return clean,{
        "source_size":[w,h],"crop":list(box),
        "clean_size":list(clean.size),
        "matte_rgb":list(map(lambda x:round(float(x),2),matte)),
        "matte_p90_deviation":round(float(spread),2),
        "transparent_corner":int(clean.getpixel((0,0))[3])==0,
        "opaque_pixel_count":int(np.count_nonzero(a>=128)),
    }


def main():
    if not SOURCE.exists():raise FileNotFoundError(SOURCE)
    original=Image.open(SOURCE).convert("RGBA")
    final,info=extract(original)
    TARGET.parent.mkdir(parents=True,exist_ok=True)
    final.save(TARGET,optimize=True)
    info.update({
        "source_sha256":hashlib.sha256(SOURCE.read_bytes()).hexdigest(),
        "out_sha256":hashlib.sha256(TARGET.read_bytes()).hexdigest(),
        "review":"technical transparency only; human review required",
    })
    REPORT.parent.mkdir(parents=True,exist_ok=True)
    REPORT.write_text(json.dumps(info,indent=2),encoding="utf-8")
    print(f"Actual corporate seal extracted (not regenerated): {TARGET}")
    print(f"Removed rectangular backing; {info['clean_size']} with alpha")


if __name__=="__main__":
    main()
