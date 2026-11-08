"""Read-only QA for 4x6 Arga enemy atlas candidates.

This is a geometry and diversity gate, NOT visual approval or Flutter proof.
Usage: python qa/check_arga_candidate_atlas.py file1.png [file2.webp ...]
"""

import json
import sys
from pathlib import Path

from PIL import Image, ImageChops


def inspect(path: Path) -> dict:
    image = Image.open(path).convert("RGBA")
    width, height = image.size
    report = {"file": str(path), "size": [width, height], "status": "PASS", "warnings": []}
    if width % 4 or height % 6:
        report["status"] = "FAIL"
        report["warnings"].append("Atlas dimensions do not divide into 4x6 cells")
        return report

    cell_width, cell_height = width // 4, height // 6
    frames = []
    for row in range(6):
        row_frames = []
        for col in range(4):
            cell = image.crop((col * cell_width, row * cell_height,
                               (col + 1) * cell_width, (row + 1) * cell_height))
            alpha = cell.getchannel("A")
            visible = alpha.point(lambda value: 255 if value >= 128 else 0)
            bounds = visible.getbbox()
            if bounds is None:
                report["status"] = "FAIL"
                report["warnings"].append(f"Empty frame {row}:{col}")
            else:
                margins = (bounds[0], bounds[1], cell_width - bounds[2], cell_height - bounds[3])
                if min(margins) < 12:
                    report["status"] = "FAIL"
                    report["warnings"].append(f"Frame {row}:{col} has <12px margin: {margins}")
            row_frames.append(cell)
        frames.append(row_frames)

    # Two identical source frames can never produce meaningful animation.
    for row, row_frames in enumerate(frames):
        differences = []
        for col in range(3):
            diff = ImageChops.difference(row_frames[col], row_frames[col + 1])
            differences.append(diff.getbbox() is not None)
        if not all(differences):
            report["status"] = "FAIL"
            report["warnings"].append(f"Duplicate adjacent frame in row {row}")

    report["nonempty_cells"] = 24 - sum("Empty frame" in w for w in report["warnings"])
    report["notes"] = "Does not verify clean alpha, same character, aligned feet or gameplay"
    return report


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit("Supply one or more atlas image paths")
    results = [inspect(Path(arg)) for arg in sys.argv[1:]]
    print(json.dumps(results, ensure_ascii=False, indent=2))
    sys.exit(1 if any(item["status"] == "FAIL" for item in results) else 0)
