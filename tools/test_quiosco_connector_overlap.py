#!/usr/bin/env python3
"""Synthetic regression for overlapping architectural connectors.

Small fixtures only. This tests geometry, NOT the quality of Plaza del Castillo artwork.
"""
from __future__ import annotations
import json
import tempfile
from pathlib import Path
from PIL import Image
from build_quiosco_reconstruction import build

def main():
    with tempfile.TemporaryDirectory(prefix="twc_quiosco_overlap_") as root:
        root=Path(root)
        src=root/"sources"
        src.mkdir()
        sections=[{"id":k,"start":i*10,"end":(i+1)*10} for i,k in
                  enumerate(("entrada","aproximacion","salida"))]
        plan={"art_status":"RECONSTRUCTION_PENDING_NOT_APPROVED",
              "tile_width":10,"tile_height":8,"world_width":30,
              "sectors":sections,"landmark":{"world_x":12,"width":3,"count":1},
              "connector_system":{"overlap_px":4,
              "boundary_connector_types":["A","B"]}}
        pp=root/"plan.json"
        pp.write_text(json.dumps(plan),encoding="utf-8")
        # Continuous gradient is our ground truth; subsequent sector starts four
        # pixels BEFORE its world-space sector start, with the shared connector.
        original=Image.new("RGB",(30,8))
        for x in range(30):
            for y in range(8):
                original.putpixel((x,y),((x*7)%256,(x*13+y*11)%256,(y*19)%256))
        for i,part in enumerate(sections):
            source_start=part["start"]-(4 if i else 0)
            crop=original.crop((source_start,0,part["end"],8))
            crop.save(src/(part["id"]+".png"))
        manifest=build(src,root/"success",pp)
        assert len(manifest["tiles"]) == 3
        actual=Image.new("RGB",(30,8))
        for i in range(3):
            with Image.open(root/"success"/f"quiosco_{i:02d}.webp") as tile:
                actual.paste(tile.convert("RGB"),(i*10,0))
        assert actual.tobytes() == original.tobytes(), "duplicated/missing pixels"
        assert all(j["matching_pixels"] for j in manifest["sector_seams"])
        # Change one pixel in the shared architectural connector; must reject.
        path=src/"aproximacion.png"
        with Image.open(path) as im:
            faulty=im.copy()
        faulty.putpixel((1,1),(255,255,255))
        faulty.save(path)
        try:
            build(src,root/"rejected",pp)
        except ValueError as exc:
            assert "Connector mismatch" in str(exc), str(exc)
        else:
            raise AssertionError("Seam corruption was not rejected")
    print("QUIOSCO_CONNECTOR_OVERLAP_TEST_PASS; no real-art QA performed")

if __name__=="__main__":
    main()
