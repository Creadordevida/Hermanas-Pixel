#!/usr/bin/env python3
"""Finds dangerous enemies-appear-huge scaling changes in the rejected v0.9.0 assets.
    Uses dimensions and the previous renderer rule (height normalized to 90).
    This is a *rejection* test, not an automatic visual approval.
"""
from pathlib import Path
import struct,sys,json

def png_size(path):
    with open(path,'rb') as f: data=f.read(24)
    if data[:8]!=b'\x89PNG\r\n\x1a\n': raise ValueError(f'Bad PNG: {path}')
    return struct.unpack('>II',data[16:24])

def scale_audit(candidate:Path):
    ret=[]
    for name in ('rival','referee','novice','breakdancer','bully','teacher','pigeon','rat','cat','statue'):
        frames=[candidate/f'assets/images/enemies/{name}_{i}.png' for i in range(5)]
        if not all(f.exists() for f in frames):continue
        dims=[png_size(f) for f in frames]
        # v0.9.0 draw algorithm: draw height=90 for ALL frames
        lengths=[90.0*w/h for w,h in dims]
        stand=lengths[0]
        # A normal standing->lying sprite does grow in width, but >2.4 means reject for human QA.
        ratio=max(lengths)/stand
        ret.append({'enemy':name,'source_dimensions':dims,'rendered_widths':[round(x,1) for x in lengths],
                    'ratio':round(ratio,2),'warning':ratio>2.4})
    return ret
if __name__=='__main__':
    if len(sys.argv)!=2:raise SystemExit('Usage: python qa/sprite_scale_audit.py PATH_TO_REJECTED_090')
    rows=scale_audit(Path(sys.argv[1]));print(json.dumps(rows,indent=2,ensure_ascii=False))
    if any(r['warning'] for r in rows):raise SystemExit(1)
