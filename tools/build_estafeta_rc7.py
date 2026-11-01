#!/usr/bin/env python3
"""Estafeta RC7: rebuild continuous candidate facades from four masters.
Source masters are external to repo until artwork can be committed. This
reuses facade motifs; the output is NOT historically or artistically approved.
"""
from PIL import Image
from pathlib import Path
from collections import Counter
import hashlib, json, random
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/images/estafeta_rc7'
MASTERS=ROOT/'assets/images/estafeta_masters'
OUT.mkdir(parents=True,exist_ok=True)
TILES, WIDTH, HEIGHT = 39, 960, 390
BOUNDARIES = [
 [0,300,540,800,1110,1390,1640,1910,2172],
 [0,290,545,815,1085,1335,1590,1865,2172],
 [0,275,550,815,1090,1355,1640,1910,2172],
 [0,310,565,810,1075,1330,1600,1890,2172],
]
facades=[]
for m,breaks in enumerate(BOUNDARIES):
    src=MASTERS/f'master_{m}.png'
    if not src.is_file():
        raise FileNotFoundError(f'Artwork missing: {src}')
    im=Image.open(src).convert('RGB')
    if im.size!=(2172,724):
        raise ValueError(f'Incorrect master dimensions {src}: {im.size}')
    im=im.crop((0,0,2172,660)).resize((1283,HEIGHT),Image.Resampling.NEAREST)
    xs=[round(x*1283/2172) for x in breaks]
    for j,(a,b) in enumerate(zip(xs,xs[1:])):
        facades.append((m,j,im.crop((a,0,b,HEIGHT))))
assert len(facades)==32
rng=random.Random(20261101)
counts=Counter()
world=Image.new('RGB',(TILES*WIDTH,HEIGHT))
sequence=[]
x=0
last=-1
while x<world.width:
    options=[i for i in range(32) if i!=last and
             counts[i]<=min(counts.values() or [0])+1]
    if not options: options=[i for i in range(32) if i!=last]
    i=rng.choice(options)
    m,j,art=facades[i]
    world.paste(art,(x,0))
    sequence.append({'world_x':x,'master':m,'facade':j,'width':art.width})
    x+=art.width
    counts[i]+=1
    last=i
manifest=[]
for i in range(TILES):
    image=world.crop((i*WIDTH,0,(i+1)*WIDTH,HEIGHT))
    file=OUT/f'estafeta_{i:02d}.webp'
    image.save(file,'WEBP',quality=90,method=6)
    manifest.append({'tile':i,'filename':file.name,
                     'sha256':hashlib.sha256(file.read_bytes()).hexdigest()})
(OUT/'manifest.json').write_text(json.dumps(
    {'tiles':manifest,'sequence':sequence,'world_width':world.width,
     'tile_width':WIDTH,'height':HEIGHT,
     'approval':'candidate only; architectural authenticity and seams unverified'},
    indent=2),encoding='utf-8')
print(f'Wrote {len(manifest)} candidates; NOT approved art')
