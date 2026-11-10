#!/usr/bin/env python3
"""Create/check a reproducible knowledge inventory for TWC SNES Game Creator.

This captures exact bytes and native dimensions of *original* references.
It never modifies art or app code, builds Android, or invokes GitHub Actions.

Run in a complete repository checkout:
  python3 tools/export_twc_snes_knowledge.py --write
  python3 tools/export_twc_snes_knowledge.py --check

Snapshots are only proof of source identity; NOT proof of artistic quality.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import struct
import sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
REPORT=ROOT/"docs/FRAMEWORK_SNES_TWC/SOURCE_REFERENCE_MANIFEST.generated.json"
SOURCE_FILES=(
    "lib/main.dart",
    "lib/chapter_one_world_tiles.dart",
    "lib/chapter_one_camera_v3.dart",
    "lib/chapter_one_layout.dart",
    "lib/neighborhood_scene_engine.dart",
    "lib/football_parallax_twc.dart",
    "lib/interiors_parallax_twc.dart",
    "tools/build_ch1_world_tiles.py",
    "tools/build_interiors_parallax_twc.py",
    "tools/build_football_parallax_twc.py",
    "tools/export_sprite_bounds.py",
    "test/qa_render_capture_test.dart",
)
ART_FILES=(
    "assets/images/futbolista.png",
    "assets/images/bailarina.png",
    "assets/images/frames/futbolista_idle_0.png",
    "assets/images/frames/futbolista_walk_0.png",
    "assets/images/frames/futbolista_run_0.png",
    "assets/images/frames/futbolista_jump_0.png",
    "assets/images/frames/bailarina_idle_0.png",
    "assets/images/frames/bailarina_walk_0.png",
    "assets/images/frames/bailarina_run_0.png",
    "assets/images/frames/bailarina_jump_0.png",
    "assets/images/chapter1/ch1_parallax/montanas_ciudad_ciclo.png",
    "assets/images/chapter1/ch1_parallax/arbolado_medio_ciclo.png",
    "assets/images/chapter1/ch1_world_tiles/world_000.png",
    "assets/images/chapter1/ch1_world_tiles/world_071.png",
    "assets/images/scenes/school.png",
    "assets/images/scenes/school_classroom.png",
    "assets/images/scenes/school_computers.png",
)

def image_shape(data: bytes) -> list[int]:
    if len(data)<26 or data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError("Expected real PNG")
    return list(struct.unpack(">II",data[16:24]))

def make_manifest():
    entries={}
    for kind,paths in (("code",SOURCE_FILES),("art",ART_FILES)):
        for path in paths:
            target=ROOT/path
            if not target.is_file():
                raise FileNotFoundError(
                    f"Reference missing in checkout: {path}. "
                    "Never invent a substitute screenshot or sprite.")
            data=target.read_bytes()
            info={"type":kind,"bytes":len(data),
                  "sha256":hashlib.sha256(data).hexdigest()}
            if kind=="art":
                info["original_png_dimensions"]=image_shape(data)
            entries[path]=info
    # Only canonical source values; never infer from generated PNG guesses.
    ch1=(ROOT/"lib/chapter_one_world_tiles.dart").read_text(encoding="utf-8")
    def const(name):
        pattern=r"\bconst\s+(?:double|int)\s+"+re.escape(name)+r"\s*=\s*(\d+(?:\.\d+)?)\s*;"
        match=re.search(pattern,ch1)
        if not match:raise ValueError(f"Cannot find canonical {name}")
        return float(match.group(1))
    settings={
      "ch1_world_width":const("ch1PhysicalWidth"),
      "ch1_world_height":const("ch1PhysicalHeight"),
      "ch1_tile_width":const("ch1PhysicalTileWidth"),
      "ch1_tile_count":int(const("ch1PhysicalTileCount")),
      "ch1_far_factor":const("ch1FarSpeed"),
      "ch1_mid_factor":const("ch1MidSpeed"),
      "ch1_far_cycle_px":int(const("ch1FarCycleWidth")),
      "ch1_mid_cycle_px":int(const("ch1MidCycleWidth")),
    }
    return {
      "schema":"TWC_SNES_REFERENCE_MANIFEST_V1",
      "evidence_type":"Actual repository bytes and canonical Dart declarations",
      "artistic_approval":"NOT IMPLIED",
      "android_verification":"NOT IMPLIED",
      "sources":entries,
      "world_contract":settings,
    }

def main():
    parser=argparse.ArgumentParser()
    action=parser.add_mutually_exclusive_group(required=True)
    action.add_argument("--write",action="store_true")
    action.add_argument("--check",action="store_true")
    args=parser.parse_args()
    found=make_manifest()
    if args.write:
        REPORT.parent.mkdir(parents=True,exist_ok=True)
        REPORT.write_text(json.dumps(found,indent=2,ensure_ascii=False)+"\n",
                          encoding="utf-8")
        print("Wrote authentic SHA256 references:",REPORT)
        print("Files indexed:",len(found["sources"]))
        print("CAUTION: source identity does not mean artistic approval.")
        return 0
    if not REPORT.is_file():
        print("Manifest missing. First run --write in a REAL checkout.",
              file=sys.stderr)
        return 2
    previous=json.loads(REPORT.read_text(encoding="utf-8"))
    if previous != found:
        modified=[
            name for name in set(previous.get("sources",{}))|set(found["sources"])
            if previous.get("sources",{}).get(name)!=found["sources"].get(name)
        ]
        print("REFERENCE DRIFT: sources or constants changed.",file=sys.stderr)
        for name in sorted(modified):print("CHANGED:",name,file=sys.stderr)
        if previous.get("world_contract")!=found["world_contract"]:
            print("CHANGED: parallax/world geometry",file=sys.stderr)
        print("Request visual reapproval before updating manifest.",
              file=sys.stderr)
        return 1
    print("PASS: canonical source bytes and parallax geometry unchanged.")
    print("This check does NOT substitute visual quality review.")
    return 0

if __name__=="__main__":
    sys.exit(main())
