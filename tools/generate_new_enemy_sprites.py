#!/usr/bin/env python3
"""Pixel sprites reproducibles. Genera atlas 6 poses x 4 fotogramas con pivote fijo.
Arte de prototipo: REQUIERE aprobación visual antes de publicar el juego.
"""
from pathlib import Path
from PIL import Image, ImageDraw
import hashlib, json, math
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/images/enemies_new';OUT.mkdir(parents=True,exist_ok=True)
POSES=('idle','patrol','alert','attack','hit','defeated')
S=3; W=48; H=64
COLORS={'robot':('#304f65','#55b5bb','#e4be52'),
        'supporter':('#ad365a','#f2d3a6','#f4cc4e'),
        'tourist':('#639b6c','#f0c5a2','#c4a85a')}
def box(d,xy,c):d.rectangle(tuple(int(z) for z in xy),fill=c)
def ellipse(d,xy,c):d.ellipse(tuple(int(z) for z in xy),fill=c)
def frame(kind,pose,n):
 im=Image.new('RGBA',(W,H));d=ImageDraw.Draw(im)
 body,skin,accent=COLORS[kind]
 oscill=((-1,0,1,0)[n] if pose=='patrol' else 0)
 tilt=((-2,1,3,-1)[n] if kind=='tourist' and pose=='patrol' else 0)
 y=oscill
 shadow='#27323d'
 if kind=='robot':
  box(d,(9,40+y,40,54+y),shadow);box(d,(11,38+y,38,50+y),body)
  box(d,(14,33+y,35,45+y),accent);box(d,(17,30+y,32,36+y),body)
  ellipse(d,(17,42+y,24,49+y),'#c6e7f3');ellipse(d,(29,42+y,36,49+y),'#c6e7f3')
  box(d,(22,25+y,25,31+y),'#e6ebeb');ellipse(d,(21,22+y,26,27+y),'#e86368')
  for x in (14,32):ellipse(d,(x,50+y,x+7,58+y),shadow);ellipse(d,(x+2,52+y,x+5,55+y),'#81949e')
  if pose=='attack':box(d,(37,35,46,39),'#e6ebeb')
 elif kind=='supporter':
  # Feet at 59 all states; shirt, scarf, legs, arms, short hair.
  box(d,(16,43+y,23,56+y),'#293e55');box(d,(27,43+y,34,56+y),'#293e55')
  box(d,(13,55,24,59),'#222635');box(d,(26,55,37,59),'#222635')
  box(d,(12,23+y,38,44+y),body)
  for xx in (18,28):box(d,(xx,24+y,xx+3,42+y),'#f4edf0')
  box(d,(19,19+y,32,26+y),accent);box(d,(29,23+y,34,39+y),accent)
  ellipse(d,(18,8+y,33,23+y),skin);box(d,(17,8+y,34,12+y),'#513933')
  box(d,(6,26+y,13,41+y),skin);box(d,(38,25+y,44,40+y),skin)
  if pose in ('alert','attack'):box(d,(38,15,44,33),accent)
 elif kind=='tourist':
  box(d,(16+tilt,43,23+tilt,56),'#465578');box(d,(27+tilt,43,34+tilt,56),'#465578')
  box(d,(13+tilt,55,24+tilt,59),'#30313e');box(d,(27+tilt,55,37+tilt,59),'#30313e')
  box(d,(13+tilt,23,36+tilt,45),body)
  ellipse(d,(17+tilt,8,34+tilt,25),skin)
  box(d,(14+tilt,7,37+tilt,12),accent);box(d,(31+tilt,11,40+tilt,14),accent)
  # Camera neck strap, body and lens.
  d.line((19+tilt,23,25+tilt,33,32+tilt,23),fill='#282b35',width=2)
  box(d,(20+tilt,31,33+tilt,39),'#272933');ellipse(d,(25+tilt,32,31+tilt,38),'#8eacb5')
  box(d,(5+tilt,26,13+tilt,43),skin);box(d,(38+tilt,26,44+tilt,40),skin)
  box(d,(40+tilt,35,45+tilt,49),'#597848');box(d,(41+tilt,32,44+tilt,36),'#b6cab3')
  if pose=='attack':box(d,(36+tilt,20,42+tilt,38),'#597848')
 if pose=='hit':box(d,(6,13,10,17),'#ffffcd')
 if pose=='defeated':
  # crouch/drop sprite while keeping the same cell and floor.
  im=im.crop((0,10,W,H)).resize((W,44),Image.Resampling.NEAREST)
  down=Image.new('RGBA',(W,H));down.alpha_composite(im,(0,15));im=down
 if pose=='alert':box(ImageDraw.Draw(im),(1,4,4,10),'#f4cc4e')
 return im.resize((W*S,H*S),Image.Resampling.NEAREST)
manifest={'cell':[W*S,H*S],'poses':list(POSES),'frames_per_pose':4,'pose_rows':6,'frame_columns':4,'art_status':'candidate_requires_user_review','enemies':{}}
for kind in COLORS:
 sheet=Image.new('RGBA',(W*S*4,H*S*6))
 for row,pose in enumerate(POSES):
  for col in range(4):
   sheet.alpha_composite(frame(kind,pose,col),(col*W*S,row*H*S))
 p=OUT/f'{kind}_atlas.png';sheet.save(p,optimize=True)
 manifest['enemies'][kind]={'file':str(p.relative_to(ROOT)),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
(OUT/'MANIFEST.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
print(json.dumps(manifest))
