#!/usr/bin/env python3
"""Pixel sprites reproducibles. Genera atlas 6 poses x 4 fotogramas con pivote fijo.
Arte de prototipo: REQUIERE aprobación visual antes de publicar el juego.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
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
def finish_pixel_art(im):
 # Contorno exterior a un píxel lógico, preservando el alfa real, sin
 # añadir rectángulos de fondo ni suavizados que rompan el pixel art.
 mask=im.getchannel('A')
 grown=mask.filter(ImageFilter.MaxFilter(3))
 outline=Image.new('RGBA',im.size,(28,35,48,0))
 outline.putalpha(Image.frombytes('L',im.size,
    bytes(max(0,g-o) for g,o in zip(grown.tobytes(),mask.tobytes()))))
 outline.alpha_composite(im)
 return outline

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
 # Siluetas orgánicas y materiales: mejoras estructurales a resolución nativa.
 # Se dibujan SOBRE el borrador; ninguna forma es una ilustración fingida.
 if kind=='supporter':
  # Hombros caídos, mangas, coderas y antebrazos con proporción humana.
  d.polygon([(12,24+y),(8,27+y),(6,35+y),(11,38+y),(16,31+y)],
            fill='#8c2e4f',outline='#352d44')
  d.polygon([(38,24+y),(42,27+y),(44,34+y),(40,37+y),(34,31+y)],
            fill='#8c2e4f',outline='#352d44')
  d.polygon([(8,35+y),(11,37+y),(15,43+y),(12,46+y),(6,40+y)],
            fill='#d79f7d',outline='#684c4b')
  d.polygon([(40,36+y),(44,34+y),(46,41+y),(42,46+y),(37,43+y)],
            fill='#d79f7d',outline='#684c4b')
  # Rostro lateral construido por nariz, oreja, mandíbula y cabello.
  d.polygon([(19,12+y),(23,7+y),(31,8+y),(35,12+y),
             (34,19+y),(29,24+y),(22,22+y),(18,18+y)],
            fill='#efc19c',outline='#755043')
  d.polygon([(17,13+y),(18,7+y),(24,5+y),(32,6+y),
             (35,11+y),(29,10+y),(25,12+y),(21,11+y)],
            fill='#493038')
  d.polygon([(33,16+y),(37,18+y),(33,20+y)],fill='#db9c79')
  d.point((30,15+y),fill='#342f3a')
  d.line((29,21+y,33,21+y),fill='#845b54',width=1)
  d.polygon([(15,42+y),(25,43+y),(24,49+y),(18,53+y),(15,49+y)],
            fill='#28354e')
  d.polygon([(26,43+y),(36,42+y),(36,49+y),(31,54+y),(26,50+y)],
            fill='#2c3c56')
  d.line((18,53,16,57),fill='#7787a2',width=2)
  d.line((30,53,31,57),fill='#7787a2',width=2)
 elif kind=='tourist':
  # Camisa abierta, cuello, manga y barriga sin bloque cúbico.
  d.polygon([(15+tilt,24),(11+tilt,31),(13+tilt,42),
             (21+tilt,47),(33+tilt,44),(39+tilt,33),
             (35+tilt,23)],fill='#65977d',outline='#284c50')
  d.polygon([(20+tilt,24),(26+tilt,30),(24+tilt,40),
             (19+tilt,36)],fill='#e4bc92')
  d.polygon([(26+tilt,30),(32+tilt,24),(33+tilt,38),
             (25+tilt,40)],fill='#85b39a')
  d.polygon([(18+tilt,11),(22+tilt,8),(32+tilt,11),
             (35+tilt,18),(31+tilt,25),(23+tilt,24),
             (17+tilt,18)],fill='#eac4a1',outline='#785c58')
  d.polygon([(15+tilt,11),(19+tilt,7),(34+tilt,7),
             (37+tilt,12),(29+tilt,14),(17+tilt,14)],
            fill='#baa16f',outline='#5d634c')
  d.line((32+tilt,18,37+tilt,20),fill='#bb987d',width=2)
  d.point((27+tilt,17),fill='#38363b')
  d.line((26+tilt,23,31+tilt,23),fill='#8b635e',width=1)
  d.polygon([(13+tilt,27),(9+tilt,31),(7+tilt,40),
             (12+tilt,43),(17+tilt,35)],fill='#e9c3a0',outline='#80635b')
  # Cámara con óptica, reflejos y correa.
  d.line((21+tilt,25,24+tilt,34,32+tilt,25),fill='#303746',width=2)
  d.rounded_rectangle((19+tilt,31,33+tilt,39),radius=2,
                      fill='#303c48',outline='#172631')
  ellipse(d,(25+tilt,32,32+tilt,38),'#d9d9b6')
  ellipse(d,(27+tilt,33,30+tilt,36),'#6e93a9')
 elif kind=='robot':
  # Chasis curvo de dos alturas, carcasa pintada y reflejos especulares.
  d.polygon([(9,39+y),(11,34+y),(17,30+y),(34,30+y),
             (40,35+y),(41,43+y),(38,51+y),(12,51+y),(8,45+y)],
            fill='#426f87',outline='#1b354e')
  d.polygon([(14,33+y),(20,28+y),(32,28+y),(37,33+y),
             (34,42+y),(17,42+y)],fill='#62a9bc',outline='#20495e')
  d.polygon([(17,33+y),(21,30+y),(30,30+y),(34,33+y)],
            fill='#9fd1db')
  d.line((14,44+y,37,44+y),fill='#d5e5db',width=2)
  for xx in (17,33):
   ellipse(d,(xx,49+y,xx+7,58+y),'#213749')
   ellipse(d,(xx+2,51+y,xx+5,55+y),'#8cabb6')
  # Sensor óptico con reflejo propio.
  ellipse(d,(21,34+y,30,40+y),'#142d46')
  ellipse(d,(23,35+y,28,38+y),'#e8c66c')
  d.point((24,35+y),fill='#fff5bb')
 # Second-pass material art: clustered native pixels, curved borders,
 # non-symmetric highlights and articulated gestures. Never smear by resize.
 if kind=='robot':
  # Metal panels, visible cleaning roller, revolving brushes and venting.
  d.polygon([(12,39+y),(16,36+y),(33,36+y),(38,40+y),
             (36,44+y),(15,44+y)],fill='#376a7c')
  d.line((14,38+y,32,38+y),fill='#8cd2d4',width=2)
  d.line((15,40+y,19,42+y,32,42+y),fill='#182e43',width=1)
  for px in (16,20,24,28,32):
   d.line((px,46+y,px+1,47+y),fill='#d3d1a2',width=2)
  for px in (19,32):
   d.arc((px-5,49+y,px+6,60+y),50,170,fill='#a6c1c7',width=1)
   d.point((px-1,54+y),fill='#0e2536')
  d.polygon([(18,30+y),(21,27+y),(31,27+y),
             (34,31+y),(28,33+y),(21,33+y)],fill='#86c0c4')
  d.line((20,30+y,30,30+y),fill='#dcecea',width=1)
  # Small rotating lidar turret and amber on-board status display.
  d.ellipse((22,22+y,27,27+y),fill='#26374a',outline='#79bbc4')
  d.line((24,24+y,25+(n-1),21+y),fill='#ffb75b',width=1)
  d.rectangle((29,35+y,33,37+y),fill='#182b41')
  d.point((31,36+y),fill='#85ffa8' if pose!='hit' else '#e64e55')
  if pose=='patrol':
   for px in (10,35):
    d.line((px,55,px+(n-2)*2,60),fill='#c6c4a6',width=1)
  elif pose=='alert':
   d.arc((13,17,38,34),195,335,fill='#f7d67c',width=2)
  elif pose=='attack':
   # Articulated brush arm extends, with two-frame sweep.
   d.polygon([(38,39),(42,35-n%2),(46,36-n%2),
              (47,40),(42,44),(38,43)],fill='#5fa5b2',outline='#233e56')
   d.line((43,38,47,39+n%2),fill='#e5f0ef',width=2)
 elif kind=='supporter':
  # Hair highlights, face expression, shirt shoulder seams, fabric shadows.
  d.line((19,9+y,24,7+y,29,8+y),fill='#8c6250',width=2)
  d.line((20,11+y,23,9+y),fill='#c88e61',width=1)
  d.line((29,14+y,32,14+y),fill='#553c3c',width=1)
  d.point((31,16+y),fill='#253340')
  d.line((30,20+y,33,21+y),fill='#a15e53',width=1)
  d.line((16,27+y,19,30+y),fill='#e88397',width=2)
  d.line((34,29+y,34,40+y),fill='#6d233c',width=2)
  for row in (32,36,40):
   d.line((21,row+y,24,row+y),fill='#f5a7af',width=1)
  d.polygon([(20,26+y),(24,25+y),(27,28+y),
             (24,31+y),(20,30+y)],fill='#f4d889',outline='#9d614d')
  d.line((17,48,20,53),fill='#425c79',width=2)
  d.line((32,49,30,54),fill='#59657c',width=2)
  for sx in (15,28):
   d.line((sx,57,sx+7,57),fill='#e1d5c0',width=1)
  if pose=='patrol':
   kick=(-2,1,3,-1)[n]
   d.polygon([(30,45),(36,45),(36+kick,54),
              (31+kick,57),(27,53)],fill='#263d59')
   d.line((30+kick,57,39+kick,58),fill='#dce2e5',width=2)
  elif pose=='alert':
   d.polygon([(10,36),(7,31),(4,32),(7,41),(12,42)],
             fill='#f4c9a9',outline='#6d4948')
   d.line((7,31,5,28),fill='#e8b899',width=2)
  elif pose=='attack':
   d.polygon([(40,34),(43,24-n%3),(46,19-n%3),
              (45,15-n%3),(40,17),(38,27)],
             fill='#edbf9a',outline='#724b45')
   d.line((40,19,43,20),fill='#f9d3aa',width=2)
 elif kind=='tourist':
  # Actual separated collar, checked cloth and sunhat rim.
  d.polygon([(18+tilt,25),(23+tilt,30),(26+tilt,26),
             (23+tilt,23)],fill='#f9dfb6')
  d.polygon([(28+tilt,25),(30+tilt,30),(34+tilt,24)],
            fill='#d3e8d1')
  for row in (31,35,39):
   d.line((18+tilt,row,22+tilt,row),fill='#b3d4ae',width=1)
   d.line((30+tilt,row,34+tilt,row),fill='#315b54',width=1)
  for px in (21,27,33):
   d.line((px+tilt,30,px+tilt,41),fill='#4d856f',width=1)
  d.line((16+tilt,10,35+tilt,10),fill='#e8d6a9',width=2)
  d.polygon([(19+tilt,8),(23+tilt,5),(31+tilt,5),
             (35+tilt,9)],fill='#d3b984')
  d.line((20+tilt,15,25+tilt,14),fill='#8a6657',width=1)
  d.point((25+tilt,18),fill='#2e3338')
  d.point((32+tilt,18),fill='#2e3338')
  d.line((27+tilt,23,33+tilt,22),fill='#9b6757',width=1)
  d.line((20+tilt,47,24+tilt,52),fill='#778dab',width=2)
  d.line((31+tilt,46,32+tilt,53),fill='#293d64',width=2)
  # Camera is an actual device with shutter, grip and shiny glass.
  d.rectangle((20+tilt,32,23+tilt,35),fill='#667581')
  d.ellipse((25+tilt,32,33+tilt,40),fill='#273441',
            outline='#e5d9b6',width=1)
  d.ellipse((28+tilt,34,31+tilt,37),fill='#73aac0')
  d.point((29+tilt,34),fill='#e8f6e8')
  if pose=='patrol':
   d.line((10+tilt,33,8+tilt+(-2,1,2,-1)[n],43),
          fill='#f3c9a4',width=2)
  elif pose=='alert':
   d.line((39+tilt,29,44+tilt,22),fill='#f5c9a1',width=3)
  elif pose=='attack':
   d.polygon([(36+tilt,27),(40+tilt,23),(44+tilt,21),
              (46+tilt,24),(40+tilt,30)],fill='#dfb18e')
   d.line((41+tilt,20,43+tilt,16),fill='#a1c5a0',width=2)
 # Detalles locales, modulados por cada estado, en la imagen real del atlas.
 if kind=='supporter':
  d.line((13,27+y,16,42+y),fill='#52283d',width=2)
  d.line((35,27+y,38,42+y),fill='#f1a2ac',width=2)
  d.rectangle((20,29+y,23,31+y),fill='#f5d589')
  d.rectangle((29,35+y,32,37+y),fill='#60283c')
  d.point((22,19+y),fill='#493a35')
  d.point((29,19+y),fill='#493a35')
  if pose=='patrol':
   d.line((15,49,17+n%2,56),fill='#93a1bc',width=2)
 elif kind=='tourist':
  d.line((17+tilt,27,18+tilt,42),fill='#9ec4a0',width=2)
  d.line((33+tilt,27,34+tilt,42),fill='#315f4f',width=2)
  d.point((23+tilt,19),fill='#4b3e38')
  d.point((30+tilt,19),fill='#4b3e38')
  d.line((20+tilt,24,31+tilt,24),fill='#8c6856',width=1)
 elif kind=='robot':
  d.line((12,39+y,37,39+y),fill='#99e2df',width=1)
  d.rectangle((15,45+y,18,47+y),fill='#d9f5ef')
  d.rectangle((35,45+y,37,47+y),fill='#163849')
  d.arc((11,32+y,40,53+y),0,165,fill='#234452',width=1)
 # Diferencias materiales entre fotogramas: animaciones, no copias estáticas.
 # Todas las piezas usan coordenadas nativas con el suelo en y=59.
 if kind=='robot':
  # Giro de ruedas y luces de estado; barrido lateral al atacar.
  for cx in (18,36):
   box(d,(cx-1,52+y,cx+1,54+y),'#d4eef4' if n%2==0 else '#37677b')
  box(d,(23,23+y,24,24+y),'#ffcc75' if n%2 else '#e85c64')
  if pose=='attack':
   d.line((38,37+n%2,47,33+n%3),fill='#a7e8ef',width=2)
  if pose=='alert':
   d.arc((10,18,38,40),200,340,fill='#ffe390',width=2)
 elif kind=='supporter':
  # Bufanda dinámica y cambios de zancada observables.
  dx=(-2,0,2,0)[n] if pose=='patrol' else (0,1,0,-1)[n]
  d.polygon([(32,23+y),(38+dx,22+y),(43+dx,25+y),(38+dx,28+y),(31,27+y)],
            fill='#f4cc4e',outline='#4a3848')
  d.line((34,26+y,42+dx,26+y),fill='#ac365a',width=1)
  if pose=='attack':
   d.polygon([(38,23),(43+n%2,14),(46,16),(44,29)],fill=skin)
  if pose=='hit':
   d.line((16,12,10,9),fill='#f1d8bd',width=2)
 elif kind=='tourist':
  # Mareo visible: balanceo de sombrero, botella y cambio de pies.
  if pose in ('idle','patrol','alert'):
   d.line((14+tilt,8,34+tilt,8),fill='#e8d8a2',width=2)
  if pose=='attack':
   d.polygon([(39+tilt,29),(44+tilt,24+n),(46+tilt,26+n),(42+tilt,40)],
             fill='#5b794b')
  if pose=='hit':
   d.line((17+tilt,15,12+tilt,12),fill='#ffe0c4',width=2)
 if pose=='hit':box(d,(6,13,10,17),'#ffffcd')
 if pose=='defeated':
  # Distinct defeat poses. Do not merely squash every enemy into a standing
  # rectangle: people fall sideways, while the cleaning robot tilts over.
  if kind=='robot':
   fall=im.rotate(-18,resample=Image.Resampling.NEAREST,expand=True)
   fall.thumbnail((W-4,42),resample=Image.Resampling.NEAREST)
   down=Image.new('RGBA',(W,H))
   down.alpha_composite(fall,((W-fall.width)//2,59-fall.height))
  else:
   fall=im.rotate(67 if kind=='supporter' else -67,
                  resample=Image.Resampling.NEAREST,expand=True)
   fall.thumbnail((W-4,28),resample=Image.Resampling.NEAREST)
   down=Image.new('RGBA',(W,H))
   down.alpha_composite(fall,((W-fall.width)//2,59-fall.height))
  im=down
 if pose=='alert':box(ImageDraw.Draw(im),(1,4,4,10),'#f4cc4e')
 return finish_pixel_art(im).resize((W*S,H*S),Image.Resampling.NEAREST)
manifest={'cell':[W*S,H*S],'poses':list(POSES),'frames_per_pose':4,'pose_rows':6,'frame_columns':4,'art_status':'candidate_requires_user_review','enemies':{}}
for kind in COLORS:
 if kind in ('supporter','tourist'):
  from install_illustrated_enemy_candidates import install
  p=install(kind)
  manifest['enemies'][kind]={'file':str(p.relative_to(ROOT)),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'art_status':'illustrated_candidate_pending_review'}
  continue
 if kind=='robot':
  from build_approved_enemy_art import build
  p=build(kind)
  manifest['enemies'][kind]={'file':str(p.relative_to(ROOT)),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'source':'user_approved_20261031'}
  continue
 sheet=Image.new('RGBA',(W*S*4,H*S*6))
 for row,pose in enumerate(POSES):
  for col in range(4):
   sheet.alpha_composite(frame(kind,pose,col),(col*W*S,row*H*S))
 p=OUT/f'{kind}_atlas.png';sheet.save(p,optimize=True)
 manifest['enemies'][kind]={'file':str(p.relative_to(ROOT)),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
(OUT/'MANIFEST.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
print(json.dumps(manifest))
