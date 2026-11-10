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
scores=[]
for y in range(55,246,20):
    for x in range(330,871,20):
        scores.append((difference((x,y,x+20,y+20)),x,y))
scores.sort(reverse=True)
print('DANCE_PARALLAX_DIAGNOSTIC_TOP',[(round(v,3),x,y) for v,x,y in scores[:16]])
print('DANCE_PARALLAX_DIAGNOSTIC_WALL',round(wall,3))
assert wall < 2.0, 'Physical wall is not stable at 1.00 world speed'
assert scores[0][0] > wall + 0.05, 'No exterior motion anywhere in the physical mural'
