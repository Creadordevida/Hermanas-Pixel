#!/usr/bin/env python3
"""Fail-closed check of the five approved, unaltered dance scene PNG files.

No rendering, no replacement of approved artwork and no Android builds.
"""
from pathlib import Path
import hashlib
import json
import sys

ROOT = Path(__file__).resolve().parents[1]
FOLDER = ROOT / "assets/images/dance_hifi"
EXPECTED = {
    "01_recepcion.png": ((693, 338), "0376b7999defb2c1e615867f0537ccd971b18fe645f30f7f05e7e79d9de20817"),
    "02_estudio.png": ((701, 338), "0b59f11e8c4a6efc8e85663bd6991ac0941dd0997bcb2b99641608f7cee92534"),
    "03_escenario.png": ((756, 338), "de16a6d8d3cc8c47badf61a01ca8f51db1d14bdb72d2d1a2fbf5895a96c96bb6"),
    "04_pasillo.png": ((1168, 374), "52529e61963d07c1f547da9e88178b8fa0692ff44e212a36db7f2f8f3369469e"),
    "05_vestuario.png": ((992, 374), "22f4984b96187bb65b430ef61448ceb6ff9f784bf2affce58f63d6064f8c9e46"),
}

def png_dimensions(raw):
    if raw[:8] != b"\x89PNG\r\n\x1a\n" or raw[12:16] != b"IHDR":
        raise ValueError("Invalid PNG header")
    return (int.from_bytes(raw[16:20], "big"), int.from_bytes(raw[20:24], "big"))

def main():
    failures = []
    for name, (dimensions, digest) in EXPECTED.items():
        path = FOLDER / name
        if not path.is_file():
            failures.append(f"MISSING {path.relative_to(ROOT)}")
            continue
        raw = path.read_bytes()
        if png_dimensions(raw) != dimensions:
            failures.append(f"WRONG DIMENSIONS {name}: {png_dimensions(raw)}")
        if hashlib.sha256(raw).hexdigest() != digest:
            failures.append(f"WRONG SHA256 {name}")
    if failures:
        for issue in failures:
            print(issue, file=sys.stderr)
        raise SystemExit(1)
    print("DANCE APPROVED ART: 5/5 binary SHA256 and dimensions verified")

if __name__ == "__main__":
    main()
