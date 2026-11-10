"""Pack the reviewed teacher sources into the game atlas without redrawing."""
from hashlib import sha256
import json
from pathlib import Path

import numpy as np
from PIL import Image
from scipy.ndimage import label

QA = Path(__file__).resolve().parent
ROOT = QA.parents[1]
ASSET = ROOT / "assets/images/enemies_new/teacher_atlas.png"
CELL = 256
FOOT_X, FOOT_Y = 128, 236
ALPHA_THRESHOLD = 210

# Source hip/stance pivots measured on the original sheets. Row boundaries
# land inside the transparent gutters and keep every shoe with its own frame.
ROWS = [
    ("idle", "throw", (0, 365), 0.44, [195, 551, 908, 1267]),
    ("warning", "throw", (365, 725), 0.44, [195, 543, 893, 1252]),
    ("release", "throw", (725, 1086), 0.44, [174, 534, 886, 1244]),
    ("recovery", "recovery", (0, 724), 0.23, [277, 812, 1359, 1899]),
    ("hit", "impact_fall", (365, 730), 0.44, [181, 540, 882, 1258]),
    ("defeat", "impact_fall", (730, 1086), 0.44, [183, 528, 882, 1247]),
]


def digest(path):
    return sha256(path.read_bytes()).hexdigest()


def build():
    atlas = Image.new("RGBA", (CELL * 4, CELL * 6))
    paths = {name: QA / "sources" / f"{name}.webp" for _, name, *_ in ROWS}
    images = {name: Image.open(path).convert("RGBA") for name, path in paths.items()}
    frames = []
    silhouettes = set()

    for row, (pose, source, (top, bottom), scale, pivots) in enumerate(ROWS):
        image = images[source]
        for col, pivot_x in enumerate(pivots):
            left, right = (image.width * i // 4 for i in (col, col + 1))
            tile = np.array(image.crop((left, top, right, bottom)))
            components, _ = label(tile[:, :, 3] >= ALPHA_THRESHOLD, np.ones((3, 3)))
            areas = np.bincount(components.ravel())
            areas[0] = 0
            assert areas.max() > 10_000, (pose, col)
            solid = components == areas.argmax()
            tile[~solid] = 0
            tile[solid, 3] = 255
            cutout = Image.fromarray(tile)
            box = cutout.getbbox()
            assert box
            sprite = cutout.crop(box).resize(
                (round((box[2] - box[0]) * scale), round((box[3] - box[1]) * scale)),
                Image.Resampling.NEAREST,
            )
            x = FOOT_X + round((left + box[0] - pivot_x) * scale)
            y = FOOT_Y - sprite.height
            cell = Image.new("RGBA", (CELL, CELL))
            cell.alpha_composite(sprite, (x, y))
            mask = cell.getchannel("A")
            bounds = mask.getbbox()
            assert bounds and bounds[0] >= 12 and bounds[1] >= 12
            assert bounds[2] <= CELL - 12 and bounds[3] == FOOT_Y
            silhouette = sha256(mask.tobytes()).hexdigest()
            assert silhouette not in silhouettes, (pose, col)
            silhouettes.add(silhouette)
            atlas.alpha_composite(cell, (col * CELL, row * CELL))
            frames.append(dict(pose=pose, column=col, bounds=bounds, source=source))

    atlas.save(ASSET, optimize=True)
    manifest = {
        "approved_reference": digest(ROOT / "reference/profesora_colegio_arte_aprobado.png"),
        "atlas_sha256": digest(ASSET),
        "grid": [4, 6],
        "cell": [CELL, CELL],
        "pivot": [FOOT_X, FOOT_Y],
        "faces": "right",
        "alpha_threshold": ALPHA_THRESHOLD,
        "sources": {name: digest(path) for name, path in paths.items()},
        "frames": frames,
    }
    (QA / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    print(f"{len(silhouettes)} silhouettes, {ASSET.stat().st_size} bytes, {manifest['atlas_sha256']}")


if __name__ == "__main__":
    build()
