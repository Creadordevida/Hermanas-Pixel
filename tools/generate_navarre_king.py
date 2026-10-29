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
 # Rediseño de superficie: proporción escultórica, placa heráldica,
 # cincelado de la cota y capa de piedra, sin reciclar ninguna figura humana.
 d.polygon([(14,27+squat),(9,33+squat),(6,49+squat),
            (11,55+squat),(17,47+squat),(19,33+squat)],
           fill='#65727a',outline='#35444e')
 d.polygon([(39,27+squat),(44,32+squat),(49,48+squat),
            (46,54+squat),(39,48+squat),(36,33+squat)],
           fill='#74838a',outline='#35444e')
 d.line((11,34+squat,8,48+squat),fill='#a9b3ad',width=2)
 d.line((44,34+squat,47,47+squat),fill='#bcc1b8',width=1)
 # Talla de rostro, sienes, pómulos, puente nasal y barba segmentada.
 d.polygon([(22,16+squat),(34,16+squat),(34,24+squat),
            (31,28+squat),(27,31+squat),(23,26+squat)],
           fill='#aab3b1',outline='#475660')
 d.polygon([(25,24+squat),(33,24+squat),(31,32+squat),
            (27,35+squat),(23,29+squat)],fill='#6c7a80')
 d.line((24,22+squat,27,21+squat),fill='#d9d7c8',width=1)
 d.line((31,22+squat,33,22+squat),fill='#d9d7c8',width=1)
 d.polygon([(27,22+squat),(29,22+squat),(30,26+squat),
            (28,27+squat)],fill='#e0d8bd')
 d.line((25,30+squat,29,32+squat,31,29+squat),
        fill='#3f525d',width=1)
 # Bordes metálicos pétreos de la corona y las gemas fosilizadas.
 for xx in (19,26,34):
  d.line((xx,11+squat,xx+2,15+squat),fill='#e0ce92',width=1)
 d.rectangle((27,13+squat,30,15+squat),fill='#7e5952')
 d.point((28,13+squat),fill='#edc88a')
 # Peto de piedra tallada y cadenas del antiguo reino, nunca letras.
 d.polygon([(19,32+squat),(37,32+squat),(40,44+squat),
            (34,50+squat),(21,50+squat),(16,44+squat)],
           fill='#a0aba9',outline='#47545e')
 for xx in range(21,35,4):
  d.line((xx,34+squat,xx+2,47+squat),fill='#697b80',width=1)
 d.polygon([(25,34+squat),(30,34+squat),(33,39+squat),
            (30,45+squat),(25,45+squat),(23,39+squat)],
           fill='#c0ad76',outline='#6b6459')
 d.line((25,38+squat,31,38+squat),fill='#7e5a4d',width=1)
 d.line((28,35+squat,28,44+squat),fill='#76594a',width=1)
 # Trama de piedra en botas, capa y hombros.
 for xx in (16,33):
  d.line((xx,55+squat,xx+6,55+squat),fill='#bcc1b7',width=2)
  d.line((xx,59+squat,xx+8,59+squat),fill='#4c5961',width=1)
 d.line((12,35+squat,15,41+squat,13,48+squat),fill=moss,width=1)
 d.line((42,34+squat,40,40+squat,44,47+squat),fill=moss,width=1)
 # Remodelación escultórica: placas de hombrera con bisel,
 # cadena de Navarra grabada en el peto y fragmentos de piedra a cincel.
 for side in (-1,1):
  cx=28+side*18
  d.polygon([(cx-5,29+squat),(cx-3,25+squat),
             (cx+3,26+squat),(cx+6,31+squat),
             (cx+4,37+squat),(cx-4,36+squat)],
            fill='#87939a',outline='#384652')
  d.line((cx-3,28+squat,cx+2,28+squat),
         fill='#c4c8bd',width=2)
  d.line((cx-2,34+squat,cx+3,35+squat),
         fill='#51616a',width=1)
 # Stone beard curls and distinct cheek, brow and nose planes.
 d.line((22,18+squat,27,17+squat),fill='#444f59',width=2)
 d.line((30,17+squat,34,18+squat),fill='#444f59',width=2)
 for px,py in ((24,27),(26,30),(29,31),(32,27)):
  d.line((px,py+squat,px-1,py+3+squat),fill='#b3b9b1',width=1)
 d.polygon([(26,21+squat),(29,20+squat),(31,25+squat),
            (29,28+squat),(27,26+squat)],fill='#dad9c9')
 d.line((25,24+squat,25,25+squat),
        fill='#f7cc77' if active else '#4c5962',width=2)
 d.line((32,24+squat,32,25+squat),
        fill='#f7cc77' if active else '#4c5962',width=2)
 # The historic Navarre chain motif is carved as connected gold links.
 links=((28,35),(24,38),(32,38),(28,41),(24,44),(32,44))
 for px,py in links:
  d.ellipse((px-2,py-2+squat,px+2,py+2+squat),
            outline='#e1d19a',width=1)
 d.line((24,38+squat,32,38+squat),fill='#816c50',width=1)
 d.line((28,35+squat,28,44+squat),fill='#816c50',width=1)
 d.point((28,39+squat),fill='#3d755c')
 # Independent chisel marks keep the faceted stone surface from
 # becoming flat blocks; avoid opaque strokes across the silhouette.
 for px,py in ((10,42),(16,52),(38,51),(43,42),(18,58),(37,58)):
  d.line((px,py+squat,px+3,py-1+squat),
         fill='#ccd0c8',width=1)
 d.line((14,38+squat,11,45+squat),fill='#48575d',width=1)
 d.line((42,37+squat,44,45+squat),fill='#45545f',width=1)
 # Pose changes in stone joints / fists; don't merely shift a still.
 if pose=='awaken':
  d.polygon([(8,34),(5-frame,29),(9,25),(12,32)],
            fill='#c2c9c1',outline='#45535d')
 elif pose=='walk':
  offset=(-3,0,4,1)[frame]
  d.polygon([(40,38),(44+offset,41),(47+offset,47),
             (43,50),(39,46)],fill='#9ca6a4',outline='#46535e')
  d.line((18+offset,48,16+offset,56),fill='#e0d8b9',width=2)
 elif pose=='slam':
  rise=(0,8,5,0)[frame]
  d.polygon([(41,34-rise),(48,35-rise),(51,42-rise),
             (48,49-rise),(42,47-rise)],
            fill='#bdc5be',outline='#46515c')
  d.line((45,37-rise,50,40-rise),fill='#f0e0b4',width=2)
 elif pose=='hit':
  d.polygon([(14,34),(7,30),(3,36),(8,42),(14,40)],
            fill='#c3c6b8',outline='#51626b')
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
 # La estatua derrotada NO puede seguir erguida: cuerpo de piedra
 # derrumbado, con corona, capa y botas horizontales sobre el pavimento.
 # Mantener el suelo en y=68 en los cuatro fotogramas.
 if pose=='defeated':
  fragments=Image.new('RGBA',(CW,CH))
  rubble=ImageDraw.Draw(fragments)
  # Cascotes de piedra desprendidos de la corona y los hombros.
  rubble.polygon([(4,62),(9,57),(14,60),(15,67),(5,68)],
                 fill='#596872',outline='#35444e')
  rubble.polygon([(40,60),(46,55),(52,61),(50,68),(40,68)],
                 fill='#829197',outline='#35444e')
  rubble.polygon([(25,64),(28,60),(33,64),(32,69),(24,69)],
                 fill='#b6bdb5')
  fall_angles=(26,48,66,80)
  fallen=im.rotate(fall_angles[frame],
                   resample=Image.Resampling.NEAREST,expand=True)
  fallen.thumbnail((48,46-frame*4),resample=Image.Resampling.NEAREST)
  fragments.alpha_composite(fallen,((CW-fallen.width)//2,68-fallen.height))
  rubble=ImageDraw.Draw(fragments)
  for x,y in ((8,54),(45,53),(17,66),(38,67)):
   rubble.line((x,y,x+3,y-2),fill='#d1c7a7',width=1)
  im=fragments
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
