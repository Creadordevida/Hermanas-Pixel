#!/usr/bin/env python3
"""Generate only the nine TWC dance wall PNGs without rewriting school art.

Use before visual inspection / local Flutter checks. This does not run Actions
or build Android. Generated PNGs must be inspected and committed separately.
"""
from pathlib import Path
import json, hashlib
from build_interiors_parallax_twc import make_wall,ASSETS,OUT,SRCS

def main():
    folder=OUT/'dance'
    folder.mkdir(parents=True,exist_ok=True)
    rows=[]
    for zone in range(3):
        src=ASSETS/SRCS['dance'][zone]
        for variant in range(3):
            path=folder/f'z{zone}_panel_{variant}.png'
            im=make_wall('dance',zone,variant)
            im.save(path,optimize=True)
            rows.append({
                'zone':zone, 'variant':variant, 'file':str(path),
                'size':list(im.size),
                'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),
                'source_sha256':hashlib.sha256(src.read_bytes()).hexdigest(),
                'artistic_approval':'PENDING_FLUTTER_INSPECTION'
            })
    report=OUT.parents[1]/'qa/interiors_twc_lab/DANCE_PANEL_GENERATION.json'
    report.parent.mkdir(parents=True,exist_ok=True)
    report.write_text(json.dumps({'type':'REAL_PNG_NOT_FLUTTER','panels':rows},
                                 ensure_ascii=False,indent=2),encoding='utf-8')
    print('Generated 9 source-proportional dance PNGs; not yet Flutter approved.')

if __name__=='__main__':main()
