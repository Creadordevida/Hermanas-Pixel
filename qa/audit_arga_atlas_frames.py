"""Read-only per-frame 4x6 alpha/geometry report for Arga candidate atlases.

The report is *diagnostic*, not automatic artistic approval.  Thresholded
silhouettes distinguish hidden RGB contamination from visible translucent
backdrop; every one of the 24 frames per enemy is inspected.
"""
import json
import sys
from pathlib import Path

from PIL import Image
from PIL import ImageChops


def audit(path: Path) -> dict:
    image = Image.open(path).convert("RGBA")
    width, height = image.size
    if width % 4 or height % 6:
        raise ValueError(f"Not 4x6: {path}")
    cw, ch = width // 4, height // 6
    frames = []
    row_masks = []
    for row in range(6):
        masks = []
        for col in range(4):
            alpha = image.crop((col*cw, row*ch, (col+1)*cw,
                                (row+1)*ch)).getchannel("A")
            histogram = alpha.histogram()
            counts = {f"a_ge_{t}": sum(histogram[t:])
                      for t in (1, 16, 64, 128, 240, 255)}
            bbox = alpha.point(lambda a: 255 if a >= 128 else 0).getbbox()
            if bbox is None:
                raise ValueError(f"Empty opaque silhouette: {path} {row}:{col}")
            x0, y0, x1, y1 = bbox
            masks.append(alpha.point(lambda a: 255 if a >= 128 else 0))
            # Low-alpha pixels farther than eight pixels from the solid
            # silhouette can be remnants of the AI sheet's painted backdrop.
            pixels = alpha.load()
            far_ghost = 0
            for y in range(ch):
                for x in range(cw):
                    a = pixels[x, y]
                    if 1 <= a < 64 and not (x0-8 <= x < x1+8 and
                                            y0-8 <= y < y1+8):
                        far_ghost += 1
            frames.append({"row": row, "col": col,
                           "bbox_ge_128": [x0, y0, x1, y1],
                           "bottom_margin": ch-y1,
                           "center_x": round((x0+x1)/2, 1),
                           "width": x1-x0, "height": y1-y0,
                           "low_alpha_far_from_silhouette": far_ghost,
                           **counts})
        row_masks.append(masks)
    adjacent = []
    for row, masks in enumerate(row_masks):
        for col in range(3):
            diff = ImageChops.difference(masks[col], masks[col+1])
            count = sum(diff.histogram()[1:])
            adjacent.append({"row": row, "between": [col, col+1],
                             "changed_silhouette_pixels": count})
    risks = []
    for f in frames:
        if f["a_ge_255"] == 0:
            risks.append(f"{f['row']}:{f['col']} no fully opaque pixel")
        if f["a_ge_1"] > 2*f["a_ge_128"]:
            risks.append(f"{f['row']}:{f['col']} excessive low-alpha coverage")
        if f["low_alpha_far_from_silhouette"] > 500:
            risks.append(f"{f['row']}:{f['col']} distant translucent background")
    return {"source": str(path), "size": [width, height],
            "cell_size": [cw, ch], "frames": frames,
            "adjacent_silhouette_changes": adjacent, "risks": risks}


if __name__ == "__main__":
    summary = "--summary" in sys.argv[1:]
    paths = [arg for arg in sys.argv[1:] if arg != "--summary"]
    if not paths:
        raise SystemExit("Pass one or more atlas paths")
    results = [audit(Path(p)) for p in paths]
    if summary:
        for item in results:
            frames = item["frames"]
            print(f"{Path(item['source']).name}: {len(frames)} frames, "
                  f"{sum(f['a_ge_255'] == 0 for f in frames)} with zero "
                  f"fully opaque pixels, "
                  f"{sum(f['low_alpha_far_from_silhouette'] > 500 for f in frames)} "
                  f"with distant faint-alpha pixels, "
                  f"min adjacent silhouette delta="
                  f"{min(x['changed_silhouette_pixels'] for x in item['adjacent_silhouette_changes'])}")
    else:
        print(json.dumps(results, indent=2))
