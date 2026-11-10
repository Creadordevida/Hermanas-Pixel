#!/usr/bin/env python3
"""Validate the approved Quiosco rebuild geometry without claiming artistic QA.

Run: python3 tools/check_quiosco_rebuild_plan.py
The current old art must NOT be promoted by passing this structural test.
"""
from __future__ import annotations
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PLAN = ROOT / "qa/quiosco_rc7_art_rebuild_plan.json"
MANIFEST = ROOT / "assets/images/quiosco_rc7/manifest.json"

def check(plan: dict, current: dict) -> None:
    assert plan["art_status"] != "APPROVED", "Art cannot be auto-approved"
    assert plan["world_width"] == current["world_width"]
    assert plan["tile_width"] == current["tile_width"]
    assert plan["tile_height"] == current["tile_height"]
    assert len(current["tiles"]) == current["tile_count"] == 39
    assert current["tile_count"] * current["tile_width"] == plan["world_width"]
    landmark = plan["landmark"]
    old_landmark = current["landmark"]
    for key in ("world_x", "width", "count"):
        assert landmark[key] == old_landmark[key], f"landmark {key} changed"
    assert landmark["count"] == 1
    sectors = plan["sectors"]
    assert sectors and sectors[0]["start"] == 0
    assert sectors[-1]["end"] == plan["world_width"]
    for previous, following in zip(sectors, sectors[1:]):
        assert previous["end"] == following["start"], (
            f"gap/overlap at {previous['id']} -> {following['id']}"
        )
    for sector in sectors:
        assert 0 <= sector["start"] < sector["end"] <= plan["world_width"]
    middle = next(s for s in sectors if s["id"] == "quiosco_central")
    assert middle["start"] <= landmark["world_x"]
    assert landmark["world_x"] + landmark["width"] <= middle["end"]
    speeds = {layer["id"]: layer["parallax"] for layer in plan["layers"]}
    assert speeds["far"] < speeds["middle"] < speeds["near"] == 1.0
    assert all(plan["requirements"].values()), "Acceptance requirements missing"
    for idx, tile in enumerate(current["tiles"]):
        assert tile["tile"] == idx
        assert tile["world_start"] == idx * plan["tile_width"]
    print("QUIOSCO_REBUILD_PLAN_GEOMETRY_PASS; art not yet approved")

if __name__ == "__main__":
    check(json.loads(PLAN.read_text(encoding="utf-8")),
          json.loads(MANIFEST.read_text(encoding="utf-8")))
