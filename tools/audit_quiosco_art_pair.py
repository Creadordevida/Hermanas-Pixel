#!/usr/bin/env python3
"""Diagnose a proposed join of TWO real candidate facade rasters (not Flutter).

Reports differences by vertical bands to distinguish sky/roofline/arcade/ground
breaks. This never edits or approves art and is not a StagePainter screenshot.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from PIL import Image, ImageChops, ImageStat

BANDS = (("sky", 0, 140), ("roofs", 140, 220),
         ("facades", 220, 290), ("pavement", 290, 390))


def audit(left: Path, right: Path) -> dict:
    with Image.open(left) as a, Image.open(right) as b:
        if a.height != 390 or b.height != 390:
            raise ValueError("Both sources must be native 390px high")
        x = a.convert("RGB").crop((a.width - 1, 0, a.width, 390))
        y = b.convert("RGB").crop((0, 0, 1, 390))
    delta = ImageChops.difference(x, y)
    bands = {name: round(sum(ImageStat.Stat(delta.crop((0, lo, 1, hi))).mean) / 3, 2)
             for name, lo, hi in BANDS}
    return {"left": left.name, "right": right.name,
            "mean_rgb_border_difference": round(sum(ImageStat.Stat(delta).mean) / 3, 2),
            "bands": bands,
            "status": "RAW_JOIN_REQUIRES_ARCHITECTURAL_CONNECTOR_AND_VISUAL_REVIEW"}


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("left", type=Path)
    p.add_argument("right", type=Path)
    a = p.parse_args()
    print(json.dumps(audit(a.left, a.right), indent=2, ensure_ascii=False))
