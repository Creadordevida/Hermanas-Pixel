#!/usr/bin/env python3
"""Read-only QA for approved Río Arga enemy pose sheets.

Run: python3 scripts/check_arga_enemy_atlases.py
Requires Pillow; does not edit images, run Flutter or use GitHub Actions.
"""
from pathlib import Path
from PIL import Image

root = Path(__file__).resolve().parents[1]
folder = root / "docs/continuidad/referencias/arga_enemigos_aprobados_20261108"
names = ("cangrejo", "pescador", "gamberro", "trucha")
failures = 0
for name in names:
    path = folder / f"{name}_seis_poses_aprobadas.webp"
    if not path.is_file():
        print("MISSING", path)
        failures += 1
        continue
    image = Image.open(path).convert("RGBA")
    w, h = image.size
    assert w % 6 == 0, f"{name}: width must be divisible by six"
    cell = w // 6
    alpha = image.getchannel("A")
    print(f"{name}: {w}x{h}; six cells, {cell}px each")
    for i in range(6):
        sub = alpha.crop((i * cell, 0, (i + 1) * cell, h))
        # Visible pixels: ignore nearly invisible alpha contamination.
        binary = sub.point(lambda v: 255 if v >= 64 else 0)
        bbox = binary.getbbox()
        if bbox is None:
            print(f"  POSE {i+1}: EMPTY")
            failures += 1
            continue
        edge = bbox[0] < 8 or bbox[2] > cell - 8
        print(f"  POSE {i+1}: bbox={bbox}; " +
              ("REVIEW EDGE / POSSIBLE CROPPING" if edge else "interior silhouette"))
        if edge:
            failures += 1
print("Issues requiring manual silhouette review:", failures)
raise SystemExit(1 if failures else 0)
