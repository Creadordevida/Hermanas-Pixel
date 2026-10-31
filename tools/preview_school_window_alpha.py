#!/usr/bin/env python3
"""Non-destructive QA experiment for the approved school's moving windows.

Run only inside the disposable Flutter QA checkout. The accepted master and
the original 27 files in Git remain unchanged; only preview screenshots are
published, so they can be reviewed before accepting any alpha adjustment.
"""
from pathlib import Path
import hashlib
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
DIR = ROOT / "assets/images/interiors_parallax/school"

def main():
    total = 0
    for zone in range(3):
        for variant in range(9):
            path = DIR / f"z{zone}_panel_{variant}.png"
            with Image.open(path) as image:
                original = np.array(image.convert("RGBA"))
            revised = original.copy()
            alpha = original[:, :, 3]
            holes = alpha < 128
            # Existing 4/255-alpha hard-edged holes replaced nearly all of the
            # detailed cathedral/trees visible in the user's source artwork
            # with flat cyan patches. Recover the original glass RGB while
            # keeping 35% transparency for moving .30/.56 landscapes.
            revised[:, :, 3][holes] = 166
            # Preserve dark wooden/metal inner window bars, previously also
            # cleared by the overly broad rectangular glass mask.
            dark = (original[:, :, 0] < 90) & (original[:, :, 1] < 90) & (
                original[:, :, 2] < 100)
            revised[:, :, 3][holes & dark] = 255
            if not np.array_equal(revised[:, :, :3], original[:, :, :3]):
                raise AssertionError("Original reference RGB changed")
            if np.count_nonzero(holes) > 0:
                Image.fromarray(revised, "RGBA").save(path, optimize=True)
            total += int(np.count_nonzero(holes))
    print("SCHOOL_WINDOW_PREVIEW: 27 existing panels, alpha only, ",
          total, "glass pixels; master untouched")

if __name__ == "__main__":
    main()
