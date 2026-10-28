#!/usr/bin/env python3
"""RC3 FIX2: construye fondos de paralaje decorativos y 72 piezas RGBA del
mismo mundo físico ya jugable. Nunca cambia los maestros originales.
Regeneración: python3 tools/build_ch1_parallax.py
"""
from pathlib import Path
import json, random, math, hashlib
import numpy as np
from PIL import Image, ImageDraw, ImageFilter
ROOT=Path(__file__).resolve().parents[1]
A=ROOT/'assets/images/chapter1'
OUT=A/'ch1_world_tiles'; PAR=A/'ch1_parallax'; QA=ROOT/'qa/ch1_rc3_parallax'
for p in (OUT,PAR,QA):p.mkdir(parents=True, exist_ok=True)
W,H,TW=36500,380,512
SEED=20261028

# Panorama elaborado a partir de vistas lejanas de los tres campos que ya
# agradaban al usuario. Se seleccionan franjas SIN porterías ni gradas.
football=ROOT/'assets/images/chapter45'
sources=[('football_arrival',330,1060),('football_drills',350,1100),('football_stands',350,1090)]
scenes=[]
for name,x0,x1 in sources:
    src=Image.open(football/(name+'.png')).convert('RGB')
    scene=src.crop((x0,0,x1,395)).resize((900,H),Image.Resampling.LANCZOS)
    scenes.append(scene)
# Fundido espacial en zonas lejanas, no en los hitos ni en la cámara.
overlap=140
pan=Image.new('RGB',(900*3-overlap*2,H))
pan.paste(scenes[0],(0,0))
for index in (1,2):
    x=index*(900-overlap)
    # solapamiento fijo de la textura, no fundidos temporales al moverse
    mask=Image.new('L',(900,H),255)
    md=ImageDraw.Draw(mask)
    for j in range(overlap):
        t=j/max(1,overlap-1);e=t*t*(3-2*t)
        md.line((j,0,j,H),fill=round(255*e))
    pan.paste(scenes[index],(x,0),mask)
# Cierre de anillo mediante SOLAPAMIENTO CIRCULAR auténtico:
# se funden los últimos 220 px sobre los primeros 220 px y se recorta
# esa cola. La última columna resultante y la primera son VECINAS del
# mismo origen, por lo que no hay bandas horizontales ni saltos de horizonte.
width0=pan.width
wrap=220
pixels=np.asarray(pan,dtype=np.float32)
result=pixels[:,:width0-wrap,:].copy()
for i in range(wrap):
    t=i/max(1,wrap-1);s=t*t*(3-2*t)
    result[:,i,:]=pixels[:,width0-wrap+i,:]*(1-s)+pixels[:,i,:]*s
pan=Image.fromarray(np.clip(result,0,255).astype('uint8'),'RGB')
pan_path=PAR/'montanas_ciudad_ciclo.png'
pan.save(pan_path,optimize=True)

# Segunda profundidad independiente: arbolado de parque en alfa, más próximo
# que las montañas; misma calidad/paleta que el atlas original del capítulo.
atlas=Image.open(A/'park_props_atlas.png').convert('RGBA')
rects=[(24,9,346,451),(391,27,325,434),(736,25,351,439),(1103,25,326,436),
(113,472,163,316),(380,554,324,211),(771,600,309,159),(1153,539,246,219),
(516,767,68,298),(63,908,340,147),(707,854,438,195),(1246,841,103,208)]
parts=[atlas.crop((x,y,x+w,y+h)) for x,y,w,h in rects]
cache={}
def prop(i,h):
    key=(i,h)
    if key not in cache:
        p=parts[i];w=round(p.width*h/p.height)
        cache[key]=p.resize((max(1,w),h),Image.Resampling.LANCZOS)
    return cache[key]
midw=2020
mid=Image.new('RGBA',(midw,H),(0,0,0,0))
rng=random.Random(SEED)
for i in range(11):
    kind=[0,1,3,2,1,0,2,3,0,1,2][i]
    ht=[151,118,145,104,135,114,158,125,112,139,109][i]
    im=prop(kind,ht)
    x=30+i*186+(-28 if i%3==0 else 14)
    y=365-ht+(i%3)*3
    # mid layer deliberately moderate density so buildings stay visible.
    im=im.copy()
    al=im.getchannel('A').point(lambda a:round(a*.78))
    im.putalpha(al)
    mid.alpha_composite(im,(x,y))
# transparent ends: never show vertical bars when wrapped
mid.save(PAR/'arbolado_medio_ciclo.png',optimize=True)

# Camino, muros y objetos cercanos siguen clavados al mundo en 72 piezas.
# YA NO se pintan aquí las colinas simples o las nubes rectangulares.
base=Image.new('RGBA',(W,H),(0,0,0,0))
# El atlas es el mismo del código anterior para conservar identidad visual.
# Arbolado de cercanía, banco, vallas, sin duplicación de la imagen de fondo.
for i in range(179):
    x=210+i*205+rng.randrange(-45,45)
    kind=rng.randrange(4);ht=rng.randrange(83,151)
    p=prop(kind,ht);base.alpha_composite(p,(round(x),328-ht))
for i in range(math.ceil(W/179)):
    p=prop(10,65)
    base.alpha_composite(p,(i*179,312))
for i in range(133):
    x=140+i*272+rng.randrange(-50,50)
    kind=[4,5,6,5,7,6,4,7][i%8]
    ht={4:95,5:75,6:53,7:70}[kind]+rng.randrange(-7,9)
    p=prop(kind,ht);base.alpha_composite(p,(x,371-ht))
for i in range(86):
    x=350+i*420+rng.randrange(-80,80)
    kind=9 if i%3 else 8;ht=48 if kind==9 else 105
    p=prop(kind,ht);base.alpha_composite(p,(x,375-ht))
# Lugares emblemáticos NO repetidos, conservados intactos en la carpeta.
originals=[('residential_curve',480,790),
 ('connector_residential_greenway_v091',7580,620),
 ('green_promenade',10180,790),
 ('connector_neutral_park_v091',16520,635),
 ('white_canopy',19200,790),
 ('connector_pergola_v091',25600,600),
 ('rocket_park',29120,790)]
features=[]
for name,x,cut in originals:
    art=Image.open(A/(name+'.png')).convert('RGBA')
    ow=round(art.width*H/cut)
    img=art.crop((0,0,art.width,cut)).resize((ow,H),Image.Resampling.LANCZOS)
    # Paisaje único flotando sobre cielo persistente: en los bordes se reduce
    # el alfa físico de la pieza, nunca se cambia de fondo de forma abrupta.
    wing=min(235,ow//3)
    mask=Image.new('L',(ow,1));pixels=mask.load()
    for j in range(ow):
        d=min(j,ow-1-j);t=min(1,d/wing);s=t*t*(3-2*t)
        pixels[j,0]=round(255*s)
    img.putalpha(mask.resize((ow,H)))
    base.alpha_composite(img,(x,0))
    features.append({'asset':name,'x':x,'width':ow,'right':x+ow,'edge_blend':wing,'source_height':cut})
# Piezas 1:1 no estiradas y ahora en RGBA para mostrar el fondo lejano.
for i in range(math.ceil(W/TW)):
    x=i*TW
    tile=base.crop((x,0,min(x+TW,W),H))
    tile.save(OUT/f'world_{i:03}.png',optimize=True)
# Vista diagnóstica fiel a la lógica de repetición y velocidades de Flutter.
FAR_SPEED=.30 # 2.20k / .30 ~= 7.33k u, aproximadamente 1/5.
MID_SPEED=.56
sara=Image.open(ROOT/'assets/images/frames/bailarina_walk_0.png').convert('RGBA')
sara=sara.resize((round(sara.width*112/sara.height),112),Image.Resampling.LANCZOS)
floor=Image.open(ROOT/'assets/images/ground/stage_0.png').convert('RGBA')

def repeat_image(dst, src,cam,speed):
    shift=(cam*speed)%src.width
    x=-shift
    while x<dst.width:
        # redondeo entero para simular FilterQuality.none de Flutter
        dst.alpha_composite(src,(round(x),0)) if src.mode=='RGBA' else dst.paste(src,(round(x),0))
        x+=src.width

def render(cam):
    cam=min(W-800,max(0,int(cam)))
    frame=Image.new('RGBA',(800,450),'#69ade5')
    repeat_image(frame,pan,cam,FAR_SPEED)
    repeat_image(frame,mid,cam,MID_SPEED)
    for n in range(max(0,(cam//TW)-1),min(72,((cam+800)//TW)+2)):
        p=base.crop((n*TW,0,min((n+1)*TW,W),H))
        frame.alpha_composite(p,(n*TW-cam,0))
    for x in range(-(cam%floor.width),800,floor.width):
        frame.alpha_composite(floor,(x,380))
    frame.alpha_composite(sara,(327-sara.width//2,390-112))
    return frame.convert('RGB')

samples=[0,740,1140,2000,5600,7440,8150,9850,10450,16500,19250,25500,29100,32000,35600]
contact=Image.new('RGB',(1600,450*math.ceil(len(samples)/2)))
for i,cam in enumerate(samples):
    frame=render(cam)
    frame.save(QA/f'camera_{cam:05}.jpg',quality=92)
    contact.paste(frame,((i%2)*800,(i//2)*450))
contact.save(QA/'CONTACTO_15_CAMARAS.jpg',quality=90)
# generar una secuencia breve para inspección de continuidad y paralaje.
sequence=QA/'frames';sequence.mkdir(exist_ok=True)
for j in range(80):
    cam=500+int(1000*j/79)
    render(cam).save(sequence/f'frame_{j:03}.png')
meta={'version':'RC3 FIX2','stage_width':W,'world_height':H,'tile_width':TW,
      'tiles':72,'landmarks':features,'original_master_files_edited':False,
      'far_parallax_speed':FAR_SPEED,'mid_parallax_speed':MID_SPEED,
      'far_texture_width':pan.width,'mid_texture_width':mid.width,
      'far_world_repeat_interval':pan.width/FAR_SPEED,
      'parallax_assets':[str(pan_path.relative_to(ROOT)),str((PAR/'arbolado_medio_ciclo.png').relative_to(ROOT))],
      'preview_cameras':samples,
      'architecture':'far terrain+city cyclic parallax, middle trees cyclic parallax, near world RGBA 1:1'}
(QA/'MANIFEST.json').write_text(json.dumps(meta,ensure_ascii=False,indent=2))
# Maintain older baseline manifest structure for legacy regression tools.
legacy=ROOT/'qa/ch1_rc3_tiles/MANIFEST.json'
old=json.loads(legacy.read_text());old.update({'landmarks':features,'original_master_files_edited':False,'background_type':'RGBA transparency over multidepth parallax'});
legacy.write_text(json.dumps(old,ensure_ascii=False,indent=2))
print(json.dumps({'generated_tiles':72,'parallax_period_world':round(meta['far_world_repeat_interval']),
                  'samples':len(samples),'contact':str(QA/'CONTACTO_15_CAMARAS.jpg')},ensure_ascii=False))
