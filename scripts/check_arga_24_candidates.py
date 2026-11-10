#!/usr/bin/env python3
"""Read-only QA for the 24 approved-concept Río Arga pose candidates.

Run from repository root. Requires Pillow; does not regenerate or rewrite art.
The report measures opaque bounds and pivot variation, not artistic approval.
"""
from pathlib import Path
import json
import sys

try:
    from PIL import Image
except ImportError:
    sys.exit("Pillow required: python -m pip install Pillow")

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "assets/images/arga_rc7/enemies_candidates"
POSES = {
    "cangrejo": ("reposo", "caminar", "alerta", "ataque", "impacto", "derrota"),
    "pescador": ("reposo", "caminar", "alerta", "lanzamiento", "impacto", "derrota"),
    "gamberro": ("reposo", "correr", "alerta", "lanzamiento", "impacto", "derrota"),
    "trucha": ("nado", "acelerar", "alerta", "salto", "impacto", "derrota"),
}


def inspect(path):
    with Image.open(path) as image:
        if image.format != "WEBP" or image.size != (1254, 1254):
            raise ValueError(f"invalid format/size: {image.format} {image.size}")
        if "A" not in image.getbands():
            raise ValueError("alpha channel missing")
        alpha = image.getchannel("A")
        bounds = alpha.point(lambda v: 255 if v >= 64 else 0).getbbox()
        if bounds is None:
            raise ValueError("empty opaque silhouette")
        if min(bounds[0], bounds[1], 1254 - bounds[2], 1254 - bounds[3]) < 8:
            raise ValueError(f"opaque pixels too close to canvas edge: {bounds}")
        if alpha.getextrema()[0] != 0:
            raise ValueError("no fully transparent background")
        return bounds


def main():
    report = {}
    errors = []
    for enemy, poses in POSES.items():
        report[enemy] = {}
        for pose in poses:
            path = BASE / f"{enemy}_{pose}_aislado_candidate.webp"
            try:
                bounds = inspect(path)
                report[enemy][pose] = {"bbox": bounds, "bottom": bounds[3], "width": bounds[2]-bounds[0], "height": bounds[3]-bounds[1]}
            except (OSError, ValueError) as exc:
                errors.append(f"{path.relative_to(ROOT)}: {exc}")
        if len(report[enemy]) == 6:
            # Defeat, leap, casting and airborne poses intentionally change
            # their bottom edge. Report variation for visual review, no false
            # automatic claim that every frame must use the same foot pivot.
            report[enemy]["bottom_span_review"] = max(x["bottom"] for x in report[enemy].values()) - min(x["bottom"] for x in report[enemy].values())
    print(json.dumps({"poses_checked": sum(len(v)-int("bottom_span_review" in v) for v in report.values()), "measurements": report, "errors": errors}, indent=2))
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
