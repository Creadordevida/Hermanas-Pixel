#!/usr/bin/env python3
"""Inspect six-sector image prototype uploaded by owner (QA only; never activate).

This prototype is 5782 x 390 and is *not* a replacement for the 37440px game.
"""
from __future__ import annotations
import io,json,hashlib,sys,zipfile
from pathlib import Path
from PIL import Image

EXPECTED_SHA="8e783ce1fbac6c46871925d9efc54fc82c5039f597d91e073a77cc9e48014be7"

def main(archive:Path,out:Path)->None:
    if hashlib.sha256(archive.read_bytes()).hexdigest()!=EXPECTED_SHA:
        raise ValueError("Wrong upload: exact ZIP SHA256 required")
    with zipfile.ZipFile(archive) as z:
        assert z.testzip() is None
        data=json.loads(z.read("manifest.json"))
        assert (data["width"],data["height"],data["source_count"])==(5782,390,6)
        with Image.open(io.BytesIO(z.read("panorama_prototipo_6_sectores.png"))) as im:
            assert im.size==(5782,390)
            out.mkdir(parents=True,exist_ok=True)
            im.save(out/"panorama_prototipo_6_sectores.png")
        with Image.open(io.BytesIO(z.read("contacto_4_recorridos.png"))) as im:
            im.verify()
            (out/"contacto_4_recorridos.png").write_bytes(z.read("contacto_4_recorridos.png"))
        (out/"manifest.json").write_text(json.dumps(data,indent=2),encoding="utf-8")
    print("PROTO_SIX_SECTORS_VERIFIED_NOT_PRODUCTION_ART")
    print("No StagePainter captures produced; active assets untouched")

if __name__=="__main__":
    main(Path(sys.argv[1]),Path(sys.argv[2]))
