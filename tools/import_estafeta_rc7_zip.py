#!/usr/bin/env python3
"""Import exact Estafeta candidate ZIP; fail closed before writing any files.
No Android build. Independent from school, enemies and physics.
"""
import hashlib, io, json, sys, zipfile
from pathlib import Path
from PIL import Image

EXPECTED_ZIP_SHA256 = "88329e2d1c3ad0e54d12a4272d0eef6f47502e5a9c7464a43aec00f2b78d01ad"
PREFIX = "estafeta_rc7/"
PANEL = PREFIX + "assets/images/estafeta_rc7/"
DEST = "assets/images/estafeta_rc7/"

def sha(data):
    return hashlib.sha256(data).hexdigest()

def run(root, source):
    root, source = Path(root), Path(source)
    if not source.is_file():
        raise FileNotFoundError(source)
    if sha(source.read_bytes()) != EXPECTED_ZIP_SHA256:
        raise ValueError("ZIP differs from the reviewed candidate archive")
    payload = {}
    with zipfile.ZipFile(source) as z:
        if z.testzip():
            raise ValueError("Damaged ZIP")
        manifest = json.loads(z.read(PREFIX + "manifest.json"))
        if manifest.get("tile_width") != 960 or manifest.get("tile_height") != 390:
            raise ValueError("Wrong panel geometry")
        entries = manifest.get("tiles", [])
        if len(entries) != 39:
            raise ValueError("Expected 39 panels")
        for i, entry in enumerate(entries):
            name = f"estafeta_{i:02d}.webp"
            if (entry.get("tile") != i or entry.get("filename") != name
                    or entry.get("world_start") != i * 960):
                raise ValueError(f"Invalid panel slot {i}")
            data = z.read(PANEL + name)
            if sha(data) != entry.get("sha256"):
                raise ValueError(f"SHA256 mismatch: {name}")
            with Image.open(io.BytesIO(data)) as img:
                img.verify()
            with Image.open(io.BytesIO(data)) as img:
                if img.size != (960, 390):
                    raise ValueError(f"Invalid dimensions: {name}")
            payload[DEST + name] = data
        payload[DEST + "manifest.json"] = z.read(PREFIX + "manifest.json")
    for path, data in payload.items():
        dest = root / path
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_bytes(data)
    print("ESTAFETA_CANDIDATE_IMPORT_OK: 39 WebP + manifest; NOT artistic approval")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit("Usage: import_estafeta_rc7_zip.py ROOT ZIP")
    run(sys.argv[1], sys.argv[2])
