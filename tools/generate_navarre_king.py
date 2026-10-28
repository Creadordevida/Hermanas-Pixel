#!/usr/bin/env python3
"""Estatua viviente del antiguo rey de Navarra: atlas independiente 6x4.
Arte original reproducible, sin reutilizar el padre ni la antigua estatua.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import json,hashlib,math
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/images/enemies_new';OUT.mkdir(parents=True,exist_ok=True)
CW,CH,S=56,72,3
POSES=('stone','awaken','walk','slam','hit','defeated')
def draw(pose,frame):
 im=Image.new('RGBA',(CW,CH)); d=ImageDraw.Draw(im)
 stone='#89919b';light='#c3c8c5';dark='#4b5962';gold='#b9a06b';moss='#577b66'
 active=pose not in ('stone','defeated')
 sway=(frame%2)*2 if pose=='walk' else 0
 squat=6 if pose=='slam' else 0
 # Base plinth: only attached while still inert.
 if pose=='stone':
  d.polygon([(5,62),(49,62),(53,68),(3,68)],fill=dark)
  d.rectangle((8,58,47,63),fill=stone)
 # Legs / boots
 for x in (15+sway,32-sway):
  d.polygon([(x,42+squat),(x+9,42+squat),(x+10,61),(x-1,61)],fill=stone)
  d.rectangle((x-2,58,x+11,63),fill=dark)
 # Royal mantle, tunic, visible stone scale texture
 d.polygon([(17,27+squat),(39,27+squat),(46,52+squat),(12,52+squat)],fill=dark)
 d.polygon([(19,25+squat),(37,25+squat),(40,49+squat),(16,49+squat)],fill=stone)
 for k in range(4):
  d.line((19,33+squat+k*4,36,33+squat+k*4),fill=light if k%2 else dark,width=1)
 # Medieval royal arms / shield
 d.polygon([(14,27+squat),(6,29+squat),(6,47+squat),(13,48+squat)],fill=stone)
 d.polygon([(41,27+squat),(49,30+squat),(50,47+squat),(42,46+squat)],fill=stone)
 # Head and beard, explicitly NOT human/father portrait
 d.rectangle((20,12+squat,35,28+squat),fill=stone)
 d.polygon([(20,22+squat),(35,22+squat),(32,33+squat),(24,33+squat)],fill=dark)
 for x in (23,33):
  d.rectangle((x,18+squat,x+2,20+squat),fill='#f0ca6b' if active else dark)
 # Crown stone with old gold relief
 d.polygon([(18,14+squat),(18,7+squat),(22,10+squat),(26,4+squat),(30,10+squat),(35,6+squat),(38,14+squat)],fill=gold)
 d.rectangle((18,12+squat,38,16+squat),fill=dark)
 d.rectangle((26,12+squat,30,14+squat),fill=light)
 # Inscribed archaic chest emblem (not a modern mark)
 d.line((25,34+squat,31,34+squat),fill=gold,width=2)
 d.line((28,31+squat,28,39+squat),fill=gold,width=2)
 # Moss and cracks
 d.line((10,35+squat,13,40+squat,10,44+squat),fill=moss,width=2)
 d.line((34,17+squat,31,24+squat,35,29+squat),fill=dark,width=1)
 if pose=='awaken':
  d.line((3,24,11,20),fill=light,width=2)
  d.line((46,20,53,16),fill=light,width=2)
 if pose=='slam':
  # Stone fist lowered; shockwave drawn separately in world, never coins.
  d.rectangle((40,46,53,55),fill=light)
 if pose=='hit':
  d.line((8,15,15,10),fill='#e5d6a1',width=2)
 if pose=='defeated':
  d.line((9,32,46,62),fill=dark,width=3)
  d.line((42,35,14,59),fill=dark,width=2)
 # Fotogramas únicos según fase: grietas progresivas, paso y golpe al suelo.
 if pose=='awaken':
  cracks=((23,17,25,25),(22,16,26,27),(21,15,28,31),(18,14,30,36))
  xx,yy,x2,y2=cracks[frame]
  d.line((xx,yy,x2,y2),fill='#d5c6a2',width=1)
  d.point((28,19),fill='#f7d17d')
 elif pose=='walk':
  # Piedras de las grebas oscilan sin modificar el pivote del suelo.
  foot=frame%4
  d.line((13+foot,57,19+foot,61),fill=light,width=2)
  d.line((35-foot,57,42-foot,61),fill=dark,width=2)
  d.line((9,37,13+foot,43),fill=gold,width=1)
 elif pose=='slam':
  d.line((39,47-frame,51,53+frame%2),fill=light,width=3)
  d.arc((6,56,49,69),0,180,fill='#d5c6a2',width=1+frame//2)
 elif pose=='hit':
  d.line((11+frame,23,17+frame,28),fill=light,width=2)
  d.line((41-frame,40,45-frame,44),fill=gold,width=1)
 elif pose=='defeated':
  d.line((16,41+frame,42,58),fill=dark,width=2)
  d.line((22,14,31,18+frame),fill=light,width=1)
 # Acabado pixel: borde tallado oscuro; jamás reaprovechar el padre.
 alpha=im.getchannel('A')
 outer=alpha.filter(ImageFilter.MaxFilter(3))
 rim=Image.new('RGBA',im.size,(39,47,57,0))
 rim.putalpha(Image.frombytes('L',im.size,
   bytes(max(0,a-b) for a,b in zip(outer.tobytes(),alpha.tobytes()))))
 rim.alpha_composite(im)
 return rim.resize((CW*S,CH*S),Image.Resampling.NEAREST)
atlas=Image.new('RGBA',(CW*S*4,CH*S*len(POSES)))
for row,pose in enumerate(POSES):
 for col in range(4):atlas.alpha_composite(draw(pose,col),(col*CW*S,row*CH*S))
out=OUT/'navarre_king_atlas.png';atlas.save(out,optimize=True)
(OUT/'navarre_king_manifest.json').write_text(json.dumps({
 'id':'navarre_king','concept':'Antiguo rey de Navarra, estatua viviente original',
 'art_status':'candidate_pending_visual_review','poses':list(POSES),
 'columns':4,'rows':6,'cell':[CW*S,CH*S],
 'sha256':hashlib.sha256(out.read_bytes()).hexdigest()},indent=2))
print(out)
