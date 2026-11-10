#!/usr/bin/env python3
"""Measure actual authored coverage of the uploaded Quiosco prototype.

This is a diagnostic, never evidence of StagePainter rendering or art approval.
It deliberately does not create pixels, resample art, or modify active assets.
"""
from __future__ import annotations

import argparse
import hashlib
import io
import json
import zipfile
from pathlib import Path

from PIL import Image

WORLD_WIDTH = 37440
HEIGHT = 390
WINDOW = 256


def audit(archive: Path) -> dict:
    with zipfile.ZipFile(archive) as z:
        if z.testzip() is not None:
            raise ValueError("Corrupt prototype archive")
        with Image.open(io.BytesIO(z.read("panorama_prototipo_6_sectores.png"))) as im:
            im.load()
            if im.height != HEIGHT:
                raise ValueError(f"Unexpected panorama height: {im.height}")
            image = im.convert("RGB")
        manifest = json.loads(z.read("manifest.json"))

    windows = []
    for left in range(0, image.width - WINDOW + 1, WINDOW):
        raw = image.crop((left, 0, left + WINDOW, HEIGHT)).tobytes()
        windows.append((left, hashlib.sha256(raw).hexdigest()))
    seen = {}
    exact_repeats = []
    for left, sha in windows:
        if sha in seen:
            exact_repeats.append({"first_x": seen[sha], "repeated_x": left, "width": WINDOW})
        else:
            seen[sha] = left
    return {
        "prototype_width": image.width,
        "world_width": WORLD_WIDTH,
        "height": HEIGHT,
        "coverage_ratio": round(image.width / WORLD_WIDTH, 5),
        "remaining_px": WORLD_WIDTH - image.width,
        "reported_compositions": manifest.get("source_count"),
        "full_windows_checked": len(windows),
        "exact_repeated_windows": exact_repeats,
        "status": "INCOMPLETE_CANDIDATE_NOT_ACTIVE" if image.width != WORLD_WIDTH else "FULL_WIDTH_REQUIRES_ART_AND_FLUTTER_QA",
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("archive", type=Path)
    args = parser.parse_args()
    print(json.dumps(audit(args.archive), indent=2, ensure_ascii=False))
