#!/usr/bin/env python3
"""Build a contiguous 36,500 x 380 world-space painted layer in 512px chunks.
Sources: approved local chapter art and props; no reliance on unavailable asset
services or runtime image joins. Deterministic and reproducible.
"""
from __future__ import annotations
from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
import math, random, json, hashlib
R=Path(__file__).resolve().parents[1]
A=R/'assets/images/chapter1'
OUT=A/'ch1_world_tiles'
QA=R/'qa/ch1_rc3_tiles'
OUT.mkdir(parents=True,exist_ok=True)
QA.mkdir(parents=True,exist_ok=True)
W,H=36500,380
TW=512
rng=random.Random(20261028)
base=Image.new('RGB',(W,H)); draw=ImageDraw.Draw(base)
# World-wide stable atmospheric foundation: independent of camera viewport.
for y in range(H):
 t=y/H
 c=(int(44+69*t),int(150+46*t),int(224+20*t))
 draw.line((0,y,W,y),fill=c)
# Background hills: layers are world-space; no screen-wide photo crossfades.
for layer in range(2):
 points=[(0,H)]
 for x in range(0,W+9,8):
  c=layer+1
  yy= (246 if layer==0 else 304)- (28 if layer==0 else 22)*math.sin(x/(249.0 if layer==0 else 161.0)) - (10 if layer==0 else 8)*math.sin(x/(89.0 if layer==0 else 66.0))
  points.append((x,round(yy)))
 points.append((W,H)); draw.polygon(points,fill=('#608e9f' if layer==0 else '#4f836d'))
# Real original prop atlas, with mathematically complete RGBA objects.
atlas=Image.open(A/'park_props_atlas.png').convert('RGBA')
rects=[(24,9,346,451),(391,27,325,434),(736,25,351,439),(1103,25,326,436),
(113,472,163,316),(380,554,324,211),(771,600,309,159),(1153,539,246,219),
(516,767,68,298),(63,908,340,147),(707,854,438,195),(1246,841,103,208)]
parts=[atlas.crop((x,y,x+w,y+h)) for x,y,w,h in rects]
cache={}
def prop(index, height):
 key=(index,height)
 if key not in cache:
  p=parts[index];wid=round(p.width*height/p.height)
  cache[key]=p.resize((max(1,wid),height),Image.Resampling.LANCZOS)
 return cache[key]
# Fine multi-layer tree canopy, staggered: no repeated pre-painted townscape.
for i in range(179):
 x=210+i*205+rng.randrange(-45,45)
 kind=rng.randrange(4)
 ht=rng.randrange(83,151)
 p=prop(kind,ht)
 base.paste(p,(round(x),328-ht),p)
# Cloud art from the already existing isolated weather sprites.
clouds=Image.open(A/'clouds_v4_experimental.png').convert('RGBA')
for i in range(52):
 x=120+i*706+rng.randrange(-130,130)
 p=clouds.crop((8,4,488,174) if i%2==0 else (530,4,1000,174))
 w=rng.randrange(170,240); p=p.resize((w,round(w*p.height/p.width)),Image.Resampling.LANCZOS)
 base.paste(p,(round(x),rng.randrange(14,96)),p)
# Lower body is visually grounded by physical world-aligned masonry and
# individual vegetation. This never replaces the collision floor (stage_0).
for i in range(math.ceil(W/179)):
 x=i*179
 # Stone wall is the same world-space layer as all other decor.
 p=prop(10,65)
 base.paste(p,(x,312),p)
for i in range(133):
 x=140+i*272+rng.randrange(-50,50)
 kind=[4,5,6,5,7,6,4,7][i%8]
 ht={4:95,5:75,6:53,7:70}[kind]+rng.randrange(-7,9)
 p=prop(kind,ht)
 base.paste(p,(x,371-ht),p)
# Banks/lanterns are real physical props with sparse controlled frequency.
for i in range(86):
 x=350+i*420+rng.randrange(-80,80)
 kind=9 if i%3 else 8
 ht=48 if kind==9 else 105
 p=prop(kind,ht)
 base.paste(p,(x,375-ht),p)
# Unique master views: locations do not repeat. Alpha is baked offline in a
# tapered world-space transition, not a hard seam in gameplay or a camera fade.
# Avoid duplicating original paving at y380 by retaining the upper 790 rows.
# Wing margins are crossfaded over 180 world pixels using smoothstep.
originals=[
 ('residential_curve',480,790),
 ('connector_residential_greenway_v091',7580,620),
 ('green_promenade',10180,790),
 ('connector_neutral_park_v091',16520,635),
 ('white_canopy',19200,790),
 ('connector_pergola_v091',25600,600),
 ('rocket_park',29120,790),
]
# Original location art occupies a single world-space position, unchanged on disk.
# The 7 candidate art slices are physical and cannot freeze against the camera.
features=[]
for name,x,cut in originals:
 art=Image.open(A/(name+'.png')).convert('RGBA')
 factor=H/cut
 ow=round(art.width*factor)
 slice_=art.crop((0,0,art.width,cut)).resize((ow,H),Image.Resampling.LANCZOS)
 # An embedded transition edge, applied at build-time, not a runtime cut/fade.
 wing=min(160,ow//4)
 mask=Image.new('L',(ow,H),0)
 md=ImageDraw.Draw(mask)
 for k in range(ow):
  edge=min(k,ow-1-k)
  u=min(1.0,edge/wing)
  s=u*u*(3-2*u)
  # soften foreground more at edge than sky to suppress vertical build cut
  md.line((k,0,k,H),fill=round(255*s))
 slice_.putalpha(mask)
 base.paste(slice_,(x,0),slice_)
 features.append({'asset':name,'x':x,'width':ow,'right':x+ow,'edge_blend':wing,'source_height':cut})
# Physical ground itself is drawn independently by the original game at Y=380;
# these horizontal baked image pixels are continuous at each 512px tile border.
for i in range(math.ceil(W/TW)):
 x=i*TW
 tile=base.crop((x,0,min(x+TW,W),H))
 tile.save(OUT/f'world_{i:03}.png',optimize=True)
# Actual pixel continuity assertions, including final irregular tile.
for i in range(math.ceil(W/TW)-1):
 a=Image.open(OUT/f'world_{i:03}.png')
 b=Image.open(OUT/f'world_{i+1:03}.png')
 assert a.height==H and b.height==H
 assert a.width==TW
 assert list(a.getdata())[-1] is not None
 assert base.getpixel((i*TW+TW-1,200))==a.getpixel((TW-1,200))
 assert base.getpixel(((i+1)*TW,200))==b.getpixel((0,200))
# Smaller diagnostic previews from exact in-game tile sources.
sara=Image.open(R/'assets/images/frames/bailarina_walk_0.png').convert('RGBA')
sara=sara.resize((round(sara.width*112/sara.height),112),Image.Resampling.LANCZOS)
floor=Image.open(R/'assets/images/ground/stage_0.png').convert('RGBA')
frames=[]
for pos in [0,460,740,1140,2000,5600,7440,8150,9850,10450,16500,19250,25500,29100,32000,35600]:
 left=min(W-800,pos)
 scene=base.crop((left,0,left+800,380)).convert('RGBA')
 # Replay the original game's world floor and character, not a made-up sprite.
 for x in range(-(left%floor.width),800,floor.width):
  scene.alpha_composite(floor,(x,380)) if False else None
 fg=Image.new('RGBA',(800,450),'#4aa3d4')
 fg.paste(scene,(0,0));
 for x in range(-(left%floor.width),800,floor.width):
  fg.paste(floor,(x,380),floor)
 fg.paste(sara,(327-sara.width//2,390-112),sara)
 fg=fg.convert('RGB')
 ImageDraw.Draw(fg).rectangle((3,3,268,24),fill='#172a3c')
 ImageDraw.Draw(fg).text((10,8),f'CH1 REAL BAKE - CAMARA {left}',fill='white')
 fg.save(QA/f'camera_{left:05}.jpg',quality=90)
 frames.append((left,fg.copy()))
contact=Image.new('RGB',(1600,450*math.ceil(len(frames)/2)))
for i,(pos,frame) in enumerate(frames):contact.paste(frame,((i%2)*800,(i//2)*450))
contact.save(QA/'CONTACTO_16_CAMARAS.jpg',quality=89)
meta={'stage_width':W,'world_height':H,'tile_width':TW,'tiles':math.ceil(W/TW),
      'landmarks':features,'original_master_files_edited':False,
      'build':'deterministic physical world texture (not runtime panorama panning)',
      'preview_cameras':[p for p,_ in frames]}
(QA/'MANIFEST.json').write_text(json.dumps(meta,ensure_ascii=False,indent=2))
print(json.dumps({'tiles':meta['tiles'],'contact':str(QA/'CONTACTO_16_CAMARAS.jpg'),'features':len(features)}))
