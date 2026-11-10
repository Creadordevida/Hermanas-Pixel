#!/usr/bin/env python3
"""Ayuntamiento RC7: verify and import ONLY the singular landmark candidate.

This source is not accepted as final scenery and must not enable the stage.
Adapted from the proven school/Estafeta ZIP ingestion pattern.
"""
from pathlib import Path
from PIL import Image
from hashlib import sha256
import zipfile, io, json, sys

EXPECTED_ZIP_SHA256 = "82434a749f91c6da34ebe86b0c2e6f97c6f801f65b1fa32da0a8e88d4932176c"
NAME = "assets/images/ayuntamiento_rc7/consistorial_unico.webp"
MANIFEST = "qa/manifest.json"

def load(root: Path, archive: Path):
    if not archive.is_file():
        raise FileNotFoundError(archive)
    if sha256(archive.read_bytes()).hexdigest() != EXPECTED_ZIP_SHA256:
        raise ValueError("The supplied Ayuntamiento candidate ZIP differs from the verified source.")
    with zipfile.ZipFile(archive) as z:
        if z.testzip():
            raise ValueError("ZIP CRC validation failed")
        item = json.loads(z.read(MANIFEST))
        data = z.read(NAME)
        expected_size = (item.get("width"), item.get("height"))
        if expected_size != (1170,390) or item.get("status") != "candidate, not verified real render":
            raise ValueError("Wrong candidate manifest or artwork dimensions")
        if sha256(data).hexdigest() != item["sha256"]:
            raise ValueError("Town hall image bytes do not match approved transfer manifest")
        with Image.open(io.BytesIO(data)) as im:
            im.verify()
        with Image.open(io.BytesIO(data)) as im:
            if im.size != (1170,390):
                raise ValueError("Image dimensions do not match source")
    dst = root / NAME
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_bytes(data)
    (root/"qa/ayuntamiento_rc7").mkdir(parents=True, exist_ok=True)
    (root/"qa/ayuntamiento_rc7"/"landmark_candidate_manifest.json").write_text(
        json.dumps(item,indent=2,ensure_ascii=False),encoding="utf-8")
    print("AYUNTAMIENTO_RC7_SINGLE_UNIQUE_LANDMARK_IMPORTED; NOT THE COMPLETE SCENERY")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit("Usage: import_ayuntamiento_rc7.py REPO_ROOT ZIP_FILE")
    load(Path(sys.argv[1]), Path(sys.argv[2]))
