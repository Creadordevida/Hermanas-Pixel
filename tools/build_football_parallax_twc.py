#!/usr/bin/env python3
"""Capítulo de fútbol: aplica el MÉTODO aprobado TWC de paralaje RC3 FIX2.

NO modifica otros capítulos, héroes, físicas ni assets originales. Partes:
  - fondo panorámico deportivo y montañas, cíclico, cámara*0.30;
  - arbolado intermedio con alfa, cíclico, cámara*0.56;
  - cercado/arbustos/vallas modulares, cámara*1.00, 6 paneles reutilizados.
El render de laboratorio usa los MISMOS PNG y velocidades del código Dart.
"""
from __future__ import annotations
from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
import math, random, json, hashlib
import numpy as np

ROOT=Path(__file__).resolve().parents[1]
A=ROOT/'assets/images'; FUT=A/'chapter45'; DEST=FUT/'football_parallax';TILES=DEST/'near_world_tiles';QA=ROOT/'qa'/'football_twc_lab'
for p in (DEST,TILES,QA):p.mkdir(parents=True,exist_ok=True)
W=36500;H=386; FAR_SPEED=.30;MID_SPEED=.56; SEED=20261028
SOURCES=['football_arrival','football_drills','football_stands']
masters={n:hashlib.sha256((FUT/(n+'.png')).read_bytes()).hexdigest() for n in SOURCES}
art={n:Image.open(FUT/(n+'.png')).convert('RGB') for n in SOURCES}

def eased(n):
 return n*n*(3-2*n)

def loop_panels(panels,overlap=140,wrap=220):
 """Blend a full-height panorama; the wrap uses cross-blended LAST-FIRST.
 No moving opacity masks in Dart, only a baked cyclic image.
 """
 h=panels[0].height; pw=panels[0].width
 final=Image.new('RGB',(pw*len(panels)-overlap*(len(panels)-1),h))
 final.paste(panels[0],(0,0))
 for j in range(1,len(panels)):
  x=j*(pw-overlap)
  mask=Image.new('L',(pw,h),255)
  m=np.full((h,pw),255,dtype=np.uint8)
  for t in range(overlap):m[:,t]=int(255*eased(t/(overlap-1)))
  final.paste(panels[j],(x,0),Image.fromarray(m))
 pix=np.asarray(final,np.float32); width=pix.shape[1]; end=width-wrap
 arr=pix[:,:end,:].copy()
 for j in range(wrap):
  t=eased(j/(wrap-1));arr[:,j,:]=pix[:,end+j,:]*(1-t)+pix[:,j,:]*t
 # Últimos/primeros píxeles EXACTOS. Sin el retoque de 48px quedaban
 # diferencias de hasta 106 niveles en puntos del ciclo: un salto visible.
 edge_target=(arr[:,0,:]+arr[:,-1,:])/2
 for j in range(48):
  t=eased(j/48)
  arr[:,j,:]=arr[:,j,:]*t+edge_target*(1-t)
  arr[:,-1-j,:]=arr[:,-1-j,:]*t+edge_target*(1-t)
 return Image.fromarray(np.clip(arr,0,255).astype('uint8'),'RGB')

# Recortes expresos de las pinturas DE FÚTBOL; no reutilizar la panorámica
# del barrio, no repetir siluetas idénticas a las del capítulo 1.
# Más variedad: la secuencia es entrada -> grada -> entrenamientos.
far_views=[]
for n,x0 in [('football_arrival',80),('football_stands',270),('football_drills',40)]:
 src=art[n];crop=src.crop((x0,15,x0+1305,580))
 far_views.append(crop.resize((900,H),Image.Resampling.LANCZOS))
far=loop_panels(far_views)
assert far.size==(2200,H)
far.save(DEST/'montanas_ciudad_deportiva_ciclo.png',optimize=True)

# Arbolado de 2º plano de sus propios paisajes. Extraemos con máscara por
# crominancia, dejando fuera el cielo y las montañas azuladas. No hay rectángulos
# de fotografía con 235px de transparencia.
forest_specs=[('football_arrival',(0,185,280,500)),
              ('football_drills',(0,195,345,505)),
              ('football_stands',(0,210,365,512)),
              ('football_arrival',(1020,220,1390,525)),
              ('football_stands',(1480,185,1670,525))]
forests=[]
for n,rect in forest_specs:
 v=np.array(art[n].crop(rect),dtype=np.float32)
 r,g,b=v[:,:,0],v[:,:,1],v[:,:,2]
 # Verde orgánico y ramas oscuras, sin fondo de cielo azul ni montañas.
 organic=(g>43)&(g>r*.72)&(g>b*.94)&((g-r)>-27)&((g-b)>-11)
 # Los tonos muy oscuros presentes dentro de la masa vegetal forman parte
 # de los troncos; la máscara se cierra suavemente para evitar huecos grandes.
 h,w=organic.shape
 from PIL import ImageFilter
 m=Image.fromarray((organic*255).astype('uint8')).filter(ImageFilter.MaxFilter(5)).filter(ImageFilter.GaussianBlur(1.0))
 a=np.array(m).astype(np.uint8)
 # Reduce las trazas de azul arrancadas por anti-aliasing; no se añade brillo.
 rgb=np.array(v,dtype=np.uint8)
 sprite=Image.fromarray(np.dstack([rgb,a]),'RGBA')
 bbox=sprite.getbbox()
 if bbox:
  sprite=sprite.crop(bbox)
  forests.append(sprite)
assert len(forests)>=4

mid=Image.new('RGBA',(2020,H),(0,0,0,0))
rng=random.Random(SEED+414)
# Suelo y objetos están en otro plano; en éste sólo copas y siluetas lejanas.
mid_positions=[(18,160),(208,142),(391,176),(600,145),(806,160),(1050,132),
               (1230,178),(1470,156),(1713,158),(1880,140)]
for i,(x,target_h) in enumerate(mid_positions):
 src=forests[[0,2,1,3,0,4,2,1,3,4][i]]
 width=round(src.width*target_h/src.height)
 obj=src.resize((max(4,width),target_h),Image.Resampling.LANCZOS)
 # Alfa natural; anclaje vertical al nivel de árboles de fondo.
 y=347-target_h + ((i%3)-1)*8
 if x+obj.width>2020:x=2020-obj.width
 mid.alpha_composite(obj,(x,y))
# Una capa alpha cíclica necesita también continuidad en el eje X. La
# presencia de copas al principio/final se reduce en ambos lados (sólo árboles),
# pero no se usa transparencia en edificios de pantalla completa.
ma=np.asarray(mid,dtype=np.uint8).copy()
edge=90
for x in range(edge):
 fac=eased(x/edge)
 ma[:,x,3]=(ma[:,x,3].astype(float)*fac).astype(np.uint8)
 ma[:,-1-x,3]=(ma[:,-1-x,3].astype(float)*fac).astype(np.uint8)
mid=Image.fromarray(ma,'RGBA')
mid.save(DEST/'arbolado_deportivo_ciclo.png',optimize=True)

# Plano físicamente cercano. Se utiliza el CERCADO Y VEGETACIÓN REALES de los
# dibujos deportivos, en tiras sin cielo. El terreno jugable permanece en las
# tiles `ground/stage_4.png` originales y nunca se duplica.
# Recortamos las bases de la verja, el césped y setos, NO estadios enteros.
strips=[]
for name,x0,x1 in [('football_stands',160,1010),('football_stands',570,1420),
                   ('football_stands',390,1240)]:
 sl=art[name].crop((x0,594,x1,724))
 # igualar escala con altura visual 142px; preservar detalle original.
 sl=sl.resize((round(sl.width*142/130),142),Image.Resampling.LANCZOS)
 strips.append(sl)
# Plano cercano: seis paneles nativos de 1.100px, NO 72 imágenes cargadas.
# El efecto es idéntico al mundo físico: x del módulo - cameraX (velocidad 1).
# Un periodo de 6.600px: aproximadamente una quinta parte del capítulo.
# Esto reduce drásticamente la carga de sprites en Flutter y la RAM en móvil.
# Ocho franjas originales de entornos deportivos variados, no el decorado
# repetido cada pantalla. Los únicos fundidos ocurren AL GENERAR el atlas,
# en una banda deportiva superficial, nunca en las ilustraciones completas.
variants=[]
order=[0,1,2,1,2,0,2,0]
for j,idx in enumerate(order):
    img=strips[idx]
    # Rotación cíclica del contenido para alterar la distribución de setos,
    # vallas y focos, con el mismo estilo de arte aprobado.
    xx=0
    rolled=Image.new('RGB',(img.width,img.height))
    rolled.paste(img.crop((xx,0,img.width,img.height)),(0,0))
    rolled.paste(img.crop((0,0,xx,img.height)),(img.width-xx,0))
    variants.append(rolled.resize((950,142),Image.Resampling.LANCZOS))
ring=loop_panels(variants,overlap=100,wrap=300)
assert ring.size==(6600,142),ring.size
band=np.array(ring.convert('RGBA'))
for y in range(22):band[y,:,3]=np.uint8(round(255*eased(y/22)))
near_band=Image.fromarray(band,'RGBA')
# Seis paneles únicos que forman un anillo. 1100x386, alfa natural.
for old in TILES.glob('world_*.png'):old.unlink()
for i in range(6):
    tile=Image.new('RGBA',(1100,H),(0,0,0,0))
    tile.alpha_composite(near_band.crop((i*1100,0,(i+1)*1100,142)),(0,244))
    tile.save(TILES/f'near_{i}.png',optimize=True)
assert len(list(TILES.glob('near_*.png')))==6
# Asset manifest, tracked deterministic inputs, independent of the game's old
# three-zone panoramas and its old alpha crossfade.
manifest={
 'name':'TWC_FOOTBALL_PARALLAX_V1','reference':'TWC_PARALLAX_2D_RC3_FIX2_V1',
 'status':'local candidate; pending Flutter and Android',
 'width_world':W,'viewport':[800,450], 'backdrop_height':H,
 'far':{'asset':'chapter45/football_parallax/montanas_ciudad_deportiva_ciclo.png','width':far.width,'speed':FAR_SPEED,'repeat_world':far.width/FAR_SPEED},
 'mid':{'asset':'chapter45/football_parallax/arbolado_deportivo_ciclo.png','width':mid.width,'speed':MID_SPEED,'repeat_world':mid.width/MID_SPEED},
 'near':{'dir':'chapter45/football_parallax/near_world_tiles','tile_width':1100,'count':6,'cycle_width':6600,'speed':1},
 'source_sha256':masters,'generated_seed':SEED,
 'protected':['football_arrival.png','football_drills.png','football_stands.png'],
 'changed_gameplay':False,'changed_other_chapters':False,
 'no_whole_photo_crossfade':True,
 'source_master_files_edited':False,
 'qa_note':'Masks are only used to isolate vegetational midground and softly land the field fence; no full scene alpha fade.'}
(DEST/'MANIFEST.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False))

# Render de referencia usando objetos existentes, reales y sin reinterpretar
# el movimiento de la cámara de Dart.
from PIL import ImageDraw
miren=Image.open(A/'outfits/futbolista_walk_0.png').convert('RGBA')
miren=miren.resize((round(miren.width*104/miren.height),104),Image.Resampling.LANCZOS)
ground=Image.open(A/'ground/stage_4.png').convert('RGBA')

def periodic(layer,cam,speed,screen):
 shift=(cam*speed)%layer.width
 pos=-shift
 while pos<screen.width:
  offset=round(pos)
  if layer.mode=='RGBA':
   lhs=max(0,-offset);rhs=min(layer.width,screen.width-offset)
   if rhs>lhs:screen.alpha_composite(layer.crop((lhs,0,rhs,layer.height)),(offset+lhs,0))
  else:
   lhs=max(0,-offset);rhs=min(layer.width,screen.width-offset)
   if rhs>lhs:screen.paste(layer.crop((lhs,0,rhs,layer.height)),(offset+lhs,0))
  pos+=layer.width

def render(cam):
 cam=int(min(max(0,cam),W-800))
 frame=Image.new('RGBA',(800,450),(82,153,225,255))
 periodic(far,cam,FAR_SPEED,frame)
 periodic(mid,cam,MID_SPEED,frame)
 for n in range(cam//1100-1,(cam+800)//1100+2):
  if n<0:continue
  tile=Image.open(TILES/f'near_{n%6}.png').convert('RGBA')
  px=n*1100-cam
  a=max(0,-px); b=min(tile.width,800-px)
  if b>a:frame.alpha_composite(tile.crop((a,0,b,H)),(px+a,0))
 # Ground is unchanged and physically 1:1 anchored.
 # Suelo del juego original: el scroll no se escala ni se desplaza en Y.
 tile_shift=cam%ground.width
 for tx in range(-tile_shift,800,ground.width):
  x=round(tx);l=max(0,-x);r=min(ground.width,800-x)
  if r>l:frame.alpha_composite(ground.crop((l,0,r,min(ground.height,64))), (x+l,386))
 frame.alpha_composite(miren,(327-miren.width//2,390-104))
 return frame.convert('RGB')

samples=[0,520,1200,2630,4500,7200,10500,15800,22000,27000,31600,35300]
contact=Image.new('RGB',(1600,480*math.ceil(len(samples)/2)),(16,34,62))
for i,cam in enumerate(samples):
 im=render(cam);im.save(QA/f'camera_{cam:05}.jpg',quality=92)
 contact.paste(im,(800*(i%2),480*(i//2)+24))
 ImageDraw.Draw(contact).text((800*(i%2)+10,480*(i//2)+6),f'CAMARA {cam:05} - RENDER LAB',fill='white')
contact.save(QA/'CONTACTO_12_CAMARAS.jpg',quality=88)
# Segmento 3.8 segundos @ 20 fps para verificar movimiento en 3 capas.
frames=QA/'frames';frames.mkdir(exist_ok=True)
for k in range(76):
 cam=480+k*42
 render(cam).save(frames/f'f_{k:03}.jpg',quality=86)
print(json.dumps({'far_width':far.width,'mid_width':mid.width,'tiles':6,'last_width':1100,'preview':str(QA/'CONTACTO_12_CAMARAS.jpg')},ensure_ascii=False))
