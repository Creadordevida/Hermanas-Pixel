"""Build a *candidate* 4x6 goalkeeper atlas from the 24 preserved RGBA masters.

Run from repository root: python3 tools/build_goalkeeper_atlas.py
Requires Pillow. Does not alter the five classic goalkeeper sprites or Flutter.
The resulting atlas requires visual QA before release.
"""
from pathlib import Path
from PIL import Image
import hashlib
import json

ROOT = Path("qa/goalkeeper_rebuild_20261109")
OUT = ROOT / "goalkeeper_atlas_4x6_candidate_rgba.png"
MANIFEST = ROOT / "goalkeeper_atlas_4x6_candidate_manifest.json"
ROWS = (
    ("ready", "idle_shift_a", "idle_shift_b", "idle_shift_c"),
    ("shuffle", "shuffle_step_a", "shuffle_step_b", "shuffle_step_c"),
    ("warning", "warning_crouch", "warning_reach", "warning_extend"),
    ("dive", "dive_extension", "dive_launch", "dive_full"),
    ("hurt", "hurt_recoil", "hurt_side", "hurt_recover"),
    ("defeat_knee", "defeat_hands", "defeat_side", "defeated"),
)
CELL = 256
MARGIN = 12
# Shared pixel scale for ALL frames; never independently fit each pose.
# Large source poses are normalized against the tallest upright pose; a dive
# may require review for horizontal reach and the chosen common scale.
TARGET_UPRIGHT_HEIGHT = 120


def silhouette(im):
    alpha = im.getchannel("A")
    return alpha.point(lambda a: 255 if a >= 128 else 0).getbbox()


def main():
    masters = {}
    for row in ROWS:
        for name in row:
            path = ROOT / f"pose_{name}_rgba.png"
            try:
                with Image.open(path) as src:
                    im = src.convert("RGBA")
                    im.load()
            except OSError:
                recovery = ROOT / "diagnostic_recovery" / path.name
                if not recovery.exists():
                    raise
                with Image.open(recovery) as src:
                    im = src.convert("RGBA")
                    im.load()
            box = silhouette(im)
            if box is None:
                raise ValueError(f"Empty pose: {name}")
            if not (box[0] > 0 and box[1] > 0 and box[2] < im.width and box[3] < im.height):
                raise ValueError(f"Clipped source: {name}")
            masters[name] = (im, box, hashlib.sha256(path.read_bytes()).hexdigest())

    upright = [masters[n][1][3] - masters[n][1][1]
               for row in ROWS[:3] for n in row]
    scale = TARGET_UPRIGHT_HEIGHT / max(upright)
    atlas = Image.new("RGBA", (CELL * 4, CELL * 6), (0, 0, 0, 0))
    records = []
    for r, row in enumerate(ROWS):
        for c, name in enumerate(row):
            im, bounds, digest = masters[name]
            cropped = im.crop(bounds)
            w = max(1, round(cropped.width * scale))
            h = max(1, round(cropped.height * scale))
            if w > CELL - 2 * MARGIN or h > CELL - 2 * MARGIN:
                raise ValueError(
                    f"{name}: {w}x{h} exceeds cell interior. "
                    "Do NOT crop limbs or rescale this pose independently; "
                    "revise shared scale/cell size and rerun."
                )
            # Bottom-centred is a review pivot, NOT final feet alignment for
            # horizontal dive or defeated poses.
            x = c * CELL + (CELL - w) // 2
            y = r * CELL + CELL - MARGIN - h
            sprite = cropped.resize((w, h), Image.Resampling.NEAREST)
            atlas.alpha_composite(sprite, (x, y))
            records.append({"name": name, "row": r, "column": c,
                            "source_sha256": digest, "size": [w, h],
                            "cell_pivot": "bottom-centre; needs visual review"})
    if len(records) != 24:
        raise AssertionError("Expected exactly 24 poses")
    OUT.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(OUT, optimize=True)
    manifest = {"status": "CANDIDATE_NOT_APPROVED", "cell": CELL,
                "size": list(atlas.size), "scale": scale,
                "atlas_sha256": hashlib.sha256(OUT.read_bytes()).hexdigest(),
                "poses": records,
                "warning": "Inspect transparency, halos, animation and dive/defeat pivots before Flutter integration"}
    MANIFEST.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"GOALKEEPER_CANDIDATE_BUILT {OUT} sha256={manifest['atlas_sha256']}")


if __name__ == "__main__":
    main()
