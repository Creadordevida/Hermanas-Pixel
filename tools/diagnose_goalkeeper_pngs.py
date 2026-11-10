"""Diagnose damaged goalkeeper PNG sources without changing approved originals.

This tool NEVER silently accepts recovered pixels as approved artwork.
"""
from pathlib import Path
from PIL import Image, ImageFile
import json

ROOT = Path("qa/goalkeeper_rebuild_20261109")
OUTPUT = ROOT / "diagnostic_recovery"
OUTPUT.mkdir(exist_ok=True)
report = []
for path in sorted(ROOT.glob("pose_*_rgba.png")):
    item = {"file": path.name}
    try:
        with Image.open(path) as im:
            im.load()
            item["status"] = "valid"
            item["size"] = list(im.size)
    except Exception as exc:
        item["status"] = "damaged"
        item["error"] = str(exc)
        try:
            # For diagnostics only: partial decoding may conceal missing data.
            ImageFile.LOAD_TRUNCATED_IMAGES = True
            with Image.open(path) as im:
                candidate = im.convert("RGBA")
                candidate.load()
            candidate_path = OUTPUT / path.name
            candidate.save(candidate_path)
            item["recovered_candidate"] = str(candidate_path)
            item["size"] = list(candidate.size)
            item["recovery_status"] = "UNAPPROVED_NEEDS_VISUAL_INSPECTION"
        except Exception as recovery_exc:
            item["recovery_error"] = str(recovery_exc)
        finally:
            ImageFile.LOAD_TRUNCATED_IMAGES = False
    report.append(item)
(OUTPUT / "report.json").write_text(json.dumps(report, indent=2) + "\n")
for item in report:
    print(json.dumps(item))
print("GOALKEEPER_DIAGNOSTIC_DONE; recovered images are NOT approved")
