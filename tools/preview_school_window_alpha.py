#!/usr/bin/env python3
"""Non-destructive QA experiment for the approved school's moving windows.

Run only inside the disposable Flutter QA checkout. The accepted master and
the original 27 files in Git remain unchanged; only preview screenshots are
published, so they can be reviewed before accepting any alpha adjustment.
"""
from pathlib import Path
import hashlib
import json
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
DIR = ROOT / "assets/images/interiors_parallax/school"
MANIFEST = ROOT / "qa/school_hifi_lab/SCHOOL_HIFI_MANIFEST.json"
MASTER = ROOT / "assets/images/school_hifi/school_five_scenes_master.png"
APPROVED_MASTER_SHA = "4370a461007d4e96bef60da32e827995301f41f7d1662fec9749da739d72bc9b"

def main():
    if hashlib.sha256(MASTER.read_bytes()).hexdigest() != APPROVED_MASTER_SHA:
        raise AssertionError("Approved five-scene master replaced")
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    if manifest["master_sha256"] != APPROVED_MASTER_SHA:
        raise AssertionError("Manifest does not identify the user's exact master")
    entries = {(e["zone"], e["variant"]): e for e in manifest["panels"]}
    if len(entries) != 27:
        raise AssertionError("Expected all 27 approved school crops")
    total = 0
    for zone in range(3):
        for variant in range(9):
            path = DIR / f"z{zone}_panel_{variant}.png"
            entry = entries[(zone, variant)]
            base_sha = hashlib.sha256(path.read_bytes()).hexdigest()
            if "approved_source_sha256" not in entry:
                if base_sha != entry["sha256"]:
                    raise AssertionError("Unverified source crop: " + str(path))
                entry["approved_source_sha256"] = base_sha
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
            with Image.open(path) as output:
                saved = np.array(output.convert("RGBA"))
            if not np.array_equal(saved[:, :, :3], original[:, :, :3]):
                raise AssertionError("Lossless colour/source preservation failed")
            entry["sha256"] = hashlib.sha256(path.read_bytes()).hexdigest()
            entry["transparent_pixels"] = int(np.count_nonzero(saved[:, :, 3] < 240))
            total += int(np.count_nonzero(holes))
    manifest["glass_alpha_threshold"] = 240
    manifest["glass_alpha_method"] = "original-RGB restored to alpha166; dark muntins opaque"
    manifest["glass_alpha_source"] = "unchanged user-approved 5-room master and 27 ZIP originals"
    MANIFEST.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
                        encoding="utf-8")
    print("SCHOOL_WINDOW_PREVIEW: 27 existing panels, alpha only, ",
          total, "glass pixels; master untouched")

if __name__ == "__main__":
    main()
