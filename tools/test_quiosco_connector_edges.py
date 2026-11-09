#!/usr/bin/env python3
"""Regression: connector/core joins must flag obvious artificial vertical cuts."""
from __future__ import annotations
import json
import tempfile
from pathlib import Path
from PIL import Image
from audit_quiosco_connector_edges import audit

def main():
    with tempfile.TemporaryDirectory(prefix="quiosco_edges_") as temp:
        root=Path(temp)
        cores=root/"cores"
        cons=root/"connectors"
        cores.mkdir()
        cons.mkdir()
        sectors=[{"id":"left","start":0,"end":10},
                 {"id":"right","start":10,"end":20}]
        plan={"tile_height":8,"sectors":sectors,
              "connector_system":{"overlap_px":4,"boundary_connector_types":["A"]}}
        pp=root/"plan.json"
        pp.write_text(json.dumps(plan),encoding="utf-8")
        for name,width in [("left",6),("right",10)]:
            Image.new("RGB",(width,8),(95,100,110)).save(cores/(name+".png"))
        con=cons/"A.png"
        Image.new("RGB",(4,8),(95,100,110)).save(con)
        good=audit(cores,cons,pp)
        assert good["edge_count"]==2
        assert good["status"]=="PIXEL_EDGE_GATE_PASS_HUMAN_REVIEW_STILL_REQUIRED"
        Image.new("RGB",(4,8),(245,240,235)).save(con)
        bad=audit(cores,cons,pp)
        assert bad["status"]=="VISUAL_REVIEW_REQUIRED"
        assert all(item["review_required"] for item in bad["edges"])
    print("QUIOSCO_CONNECTOR_EDGES_TEST_PASS; synthetic QA only")

if __name__=="__main__":
    main()
