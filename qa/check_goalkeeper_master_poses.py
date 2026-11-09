"""Read-only alpha/geometry diagnostics for the goalkeeper art masters.

Does not modify images or approve visual quality. Run from repository root.
"""

from pathlib import Path

from PIL import Image


ROOT = Path("qa/goalkeeper_rebuild_20261109")
NAMES = ("ready", "shuffle", "shuffle_step_a", "shuffle_step_b",
         "warning", "dive", "hurt", "hurt_recoil", "defeat_knee",
         "defeat_hands", "defeated")


def inspect(path: Path) -> dict:
    with Image.open(path) as source:
        im = source.convert("RGBA")
        alpha = im.getchannel("A")
        bbox = alpha.point(lambda value: 255 if value >= 128 else 0).getbbox()
        if bbox is None:
            raise ValueError(f"empty silhouette: {path}")
        opaque = sum(1 for a in alpha.get_flattened_data() if a >= 250)
        semi = sum(1 for a in alpha.get_flattened_data() if 0 < a < 250)
        corner_alpha = [im.getpixel(pt)[3] for pt in
            ((0, 0), (im.width - 1, 0), (0, im.height - 1),
             (im.width - 1, im.height - 1))]
        return {"size": im.size, "bbox": bbox, "opaque": opaque,
                "semi": semi, "corners": corner_alpha}


def main() -> None:
    for name in NAMES:
        path = ROOT / f"pose_{name}_rgba.png"
        result = inspect(path)
        if max(result["corners"]) > 2:
            raise AssertionError(f"corner background present: {name}")
        width, height = result["size"]
        x0, y0, x1, y1 = result["bbox"]
        if not (0 < x0 < x1 < width and 0 < y0 < y1 < height):
            raise AssertionError(f"silhouette touches canvas border: {name}")
        print(f"{name}: {width}x{height}, bbox={result['bbox']}, "
              f"opaque={result['opaque']}, semi={result['semi']}, "
              f"corners={result['corners']}")
    print("GOALKEEPER_MASTER_ALPHA_PASS (geometry only, not art sign-off)")


if __name__ == "__main__":
    main()
