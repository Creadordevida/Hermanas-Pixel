#!/usr/bin/env python3
"""Conservative pixel-level restoration of FOUR EXISTING illustrated enemies.

The source is ALWAYS the real approved PNG artwork in assets/images/enemies.
This is not an AI substitute, screenshot, mock or vector replacement.
Work at the pixel level; keep every original silhouette and its transparent
background, add fine-scale material and costume detail.

Run BEFORE tools/export_sprite_bounds.py, so the runtime uses true dimensions.
Rerunning is safe: each output checksum is recorded in the accompanying state.
"""
from __future__ import annotations
from pathlib import Path
from PIL import Image, ImageDraw, ImageEnhance
import hashlib
import json

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "assets/images/enemies"
OUT = ROOT / "qa/art_review"
OUT.mkdir(parents=True, exist_ok=True)
STATE = OUT / "four_existing_enemy_polish_state.json"
KIND = ("breakdancer", "bully", "referee", "rival")
COUNT = {"breakdancer": 6, "bully": 5, "referee": 6, "rival": 5}
SCALE = {"breakdancer": 2, "bully": 1, "referee": 2, "rival": 2}


def checksum(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def guarded_detail(im: Image.Image, kind: str, frame: int) -> Image.Image:
    """All additional details must remain inside original opaque silhouette."""
    w, h = im.size
    original_mask = im.getchannel("A")
    marks = Image.new("RGBA", im.size)
    d = ImageDraw.Draw(marks)
    bbox = original_mask.getbbox()
    if bbox is None:
        raise ValueError(f"{kind}_{frame}: missing original art")
    x0, y0, x1, y1 = bbox
    bw, bh = x1 - x0, y1 - y0

    def pt(fx: float, fy: float) -> tuple[int, int]:
        return (int(x0 + bw * fx), int(y0 + bh * fy))

    def line(fracs, color: str, width: int = 1) -> None:
        xy = [pt(x, y) for x, y in fracs]
        d.line(xy, fill=color, width=width, joint="curve")

    if frame != 4:  # A collapsed body has different anatomical landmarks.
        if kind == "referee":
            # Distinct black uniform: cool facing seam, pale piping, whistle.
            line([(.36, .37), (.38, .49)], "#667582")
            line([(.41, .30), (.43, .43)], "#c0c5c2")
            d.ellipse((*pt(.44, .44), *pt(.48, .47)), fill="#d5d6c9")
            if frame in (2, 3):
                # Extra bevel on the REAL red card, if it overlaps source art.
                line([(.74, .08), (.78, .08), (.78, .19)], "#f6a8a0")
        elif kind == "breakdancer" and frame < 2:
            # Cap seam, streetwear shirt embroidery and sneaker edging.
            line([(.39, .09), (.55, .08)], "#8db3c0")
            line([(.34, .38), (.46, .40)], "#bbc6b7")
            line([(.43, .49), (.47, .56)], "#6d829d")
            line([(.18, .89), (.35, .89)], "#efdfd2")
            line([(.57, .90), (.76, .91)], "#f4e5cc")
        elif kind == "bully":
            # Original illustrated backpack remains intact: strap, zipper,
            # jacket seam and contrast piping on oversized sneakers.
            line([(.66, .26), (.76, .43)], "#ef8079", 2)
            line([(.73, .31), (.84, .32)], "#ffb7a2")
            line([(.46, .34), (.56, .43)], "#b1c5d5")
            line([(.23, .85), (.35, .89)], "#c9d7e5")
            line([(.73, .85), (.89, .87)], "#e1e7ec")
        elif kind == "rival":
            # Preserve the original hand-painted face and running legs,
            # but crispen the team shirt edges and athletic sock strips.
            line([(.33, .38), (.43, .41)], "#ffb6b7")
            line([(.48, .47), (.52, .54)], "#9c2436")
            line([(.22, .81), (.31, .83)], "#fff4e4")
            line([(.55, .87), (.68, .88)], "#f5f0df")
    # Clip drawn material to original opacity; not one drawn pixel may
    # protrude from the authentic hand-painted silhouette.
    marks.putalpha(Image.composite(
        marks.getchannel("A"), Image.new("L", im.size, 0), original_mask
    ))
    im.alpha_composite(marks)
    return im


def polish(im: Image.Image, kind: str, frame: int) -> Image.Image:
    if im.mode != "RGBA":
        im = im.convert("RGBA")
    if im.getchannel("A").getbbox() is None:
        raise ValueError(f"{kind}_{frame}: fully transparent original")
    original = im.copy()
    a = im.getchannel("A")
    # Mild local color separation, preserving existing line art.
    rgb = im.convert("RGB")
    rgb = ImageEnhance.Contrast(rgb).enhance(1.045)
    rgb = ImageEnhance.Color(rgb).enhance(1.035)
    rgb.putalpha(a)
    rgb = guarded_detail(rgb, kind, frame)
    if SCALE[kind] != 1:
        rgb = rgb.resize((im.width * SCALE[kind],
                          im.height * SCALE[kind]), Image.Resampling.NEAREST)
    # Do not invent missing limbs: any original alpha is retained.
    if not original.getchannel("A").getbbox():
        raise AssertionError("incomplete source")
    return rgb


def contact(before: list[Image.Image], after: list[Image.Image], kind: str):
    width = max(1550, len(before) * 307 + 15)
    result = Image.new("RGBA", (width, 660), "#202c3b")
    draw = ImageDraw.Draw(result)
    draw.text((10, 10), f"{kind}: originales ARRIBA / restaurados ABAJO", fill="#f8f0de")
    for i, (old, new) in enumerate(zip(before, after)):
        for row, img in enumerate((old, new)):
            tile = img.copy()
            tile.thumbnail((290, 275), Image.Resampling.NEAREST)
            x = 10 + i * 307 + (290 - tile.width)//2
            y = 42 + row * 301 + (275 - tile.height)
            result.alpha_composite(tile, (x, y))
    result.convert("RGB").save(OUT / f"{kind}_original_vs_polished.png")


def main():
    previous = json.loads(STATE.read_text()) if STATE.exists() else {}
    updated = {}
    for kind in KIND:
        originals = []
        refined = []
        for frame in range(COUNT[kind]):
            path = SRC / f"{kind}_{frame}.png"
            current = checksum(path)
            key = f"{kind}_{frame}"
            if key in previous and current == previous[key]["after"]:
                updated[key] = previous[key]
                continue
            original = Image.open(path).convert("RGBA")
            new = polish(original, kind, frame)
            # When rerun against an original file, keep the result deterministic.
            before_sha = current
            new.save(path, optimize=True)
            updated[key] = dict(before=before_sha,
                                after=checksum(path),
                                old_size=list(original.size),
                                new_size=list(new.size))
            originals.append(original)
            refined.append(new)
        if len(originals) == COUNT[kind]:
            contact(originals, refined, kind)
    STATE.write_text(json.dumps(updated, indent=2), encoding="utf-8")
    print("Refined 22 real illustrated frames; no app build or APK.")
    print("Source sha256 and pixel dimensions recorded:", STATE)


if __name__ == "__main__":
    main()
