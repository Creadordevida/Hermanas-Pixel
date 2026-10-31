#!/usr/bin/env python3
"""Evidence of camera-aligned wall and moving exterior through real dance windows.

Image source: genuine Flutter StagePainter 1000x450 saved by widget test.
"""
from pathlib import Path
from PIL import Image

ROOT=Path(__file__).resolve().parents[1]/'qa/dance_hifi_flutter'
BASE=Image.open(ROOT/'04_estudio.png').convert('RGB')
MOVED=Image.open(ROOT/'09_estudio_camara_60.png').convert('RGB')
assert BASE.size==MOVED.size==(1000,450)

def difference(bounds):
    x0,y0,x1,y1=bounds
    a=BASE.load()
    b=MOVED.load()
    count=0
    total=0
    for y in range(y0,y1):
        for x in range(x0,x1):
            p=a[x,y]
            q=b[x-60,y]
            total+=sum(abs(p[i]-q[i]) for i in range(3))
            count+=3
    return total/count

# Every x coordinate below refers to screenshot 04. The camera moved +60
# world pixels in screenshot 09, hence its aligned physical x is x-60.
wall=difference((520,115,560,185))
glass=difference((705,95,760,175))
print('DANCE_REAL_WINDOW_PARALLAX: wall=',round(wall,3),
      'glass=',round(glass,3))
# Strict movement threshold will be set after inspecting the actual samples.
assert wall < 2.0, 'Physical wall is not stable at 1.00 world speed'
assert glass > wall + 0.05, 'No detected exterior motion inside dance window'
