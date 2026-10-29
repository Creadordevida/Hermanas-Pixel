#!/usr/bin/env python3
"""Vista Python fiel a 0.30/0.56/1.00 de las 2 habitaciones.
NO sustituye el render Flutter y no es prueba de Android."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageOps
import math,json,sys
ROOT=Path(__file__).resolve().parents[1]
A=ROOT/'assets/images';Q=ROOT/'qa/interiors_twc_lab';W,H=800,450
Z=[0,10500,25500,36500];T=880
frames={}
for theme in ['dance','school']:
  p=A/'interiors_parallax'/theme
  frames[theme]={'far':Image.open(p/'exterior_lejano_ciclo.png').convert('RGBA'),
    'mid':Image.open(p/'arbolado_tras_ventanas_ciclo.png').convert('RGBA'),
    'passage':Image.open(p/'marco_paso.png').convert('RGBA'),
    'features':{name:Image.open(p/f'{name}.png').convert('RGBA') for name in (['pizarra_matematicas','pizarra_informatica','estanteria_biblioteca','mesa_aula','ordenador_aula'] if theme=='school' else [])},
    'wall':[[Image.open(p/f'z{z}_panel_{v}.png').convert('RGBA') for v in range(9 if theme=='school' else 3)] for z in range(3)],
    'floor':Image.open(A/'ground'/f'stage_{5 if theme=="dance" else 6}.png').convert('RGBA'),
    'hero':Image.open(A/('outfits/bailarina_walk_0.png' if theme=='dance' else 'frames/futbolista_walk_0.png')).convert('RGBA')}
  ht=286 if theme=='dance' else 278
  frames[theme]['height']=ht
  frames[theme]['hero']=ImageOps.contain(frames[theme]['hero'],(104,112))

def cyc(im,offset,base):
  imw=im.width; s=(offset%imw);x=-s
  while x<base.width:
    base.alpha_composite(im,(int(x),0));x+=imw

def render(theme,cam,exterior_cam=None):
  c=max(0,min(int(cam),35700));d=frames[theme];height=d['height']
  outside=c if exterior_cam is None else int(exterior_cam)
  target=Image.new('RGBA',(W,H),'#cde7f5')
  far=Image.new('RGBA',(W,height),'#b1dcf1')
  cyc(d['far'],int(outside*.30),far);cyc(d['mid'],int(outside*.56),far)
  target.alpha_composite(far,(0,0))
  for z in range(3):
    start,end=Z[z:z+2]
    if end<=c or start>=c+W:continue
    first=max(0,int(math.floor((c-start)/T))-1)
    last=int(math.floor((c+W-start)/T))+1
    for n in range(first,last+1):
      world=start+n*T
      if world>=end:break
      x=world-c
      if x>=W or x+T<=0:continue
      variant=(n*5+z*2)%9 if theme=='school' else n%3
      source=d['wall'][z][variant]
      src_l=max(0,-x,start-world)
      src_r=min(T,W-x,end-world)
      if src_r<=src_l:continue
      cropped=source.crop((src_l,0,src_r,height))
      target.alpha_composite(cropped,(x+src_l,0))
  if theme=='school':
    for name,xx,yy in [('estanteria_biblioteca',1720,0),('pizarra_matematicas',15320,52),('pizarra_informatica',29820,51)]:
      image=d['features'][name];x=xx-c
      if -image.width<x<W:target.alpha_composite(image,(x,yy))
  transitions=list(Z[1:-1])
  if theme=='school':
    source_plan=(
      (0,0,0,1,0,0,0,2,0),
      (1,1,0,1,1,0,1,1,2),
      (2,2,0,2,2,0,2,2,1),
    )
    for zone in range(3):
      lo,hi=Z[zone:zone+2]
      for n in range(1,100):
        world=lo+n*T
        if world>=hi-120:break
        v=(n*5+zone*2)%9
        previous=((n-1)*5+zone*2)%9
        if source_plan[zone][v]!=source_plan[zone][previous]:
          transitions.append(world)
  for edge in transitions:
    x=edge-c-60
    if -120<x<W:target.alpha_composite(d['passage'],(x,0))
  floor=d['floor']
  for x in range(-(c%floor.width),W,floor.width):
    target.alpha_composite(floor,(x,height))
  if theme=='school':
    desk=d['features']['mesa_aula']
    patterns=((270,590),(),(390,),(190,580),(490,),(240,600),())
    for zone in (1,2):
      lo,hi=Z[zone:zone+2]
      first=max(0,(c-lo)//T-1)
      last=(c+W-lo)//T+1
      for n in range(first,last+1):
        start=lo+n*T
        if start>=hi:break
        for dx in patterns[(n+zone*3)%len(patterns)]:
          xx=start+dx
          if xx+desk.width>hi:continue
          x=xx-c
          if -desk.width<x<W:
            target.alpha_composite(desk,(x,286))
            if zone==2:
              target.alpha_composite(d['features']['ordenador_aula'],(x+34,198))
  hero=d['hero'];target.alpha_composite(hero,(327-hero.width//2,390-hero.height))
  return target.convert('RGB')

def contact(theme, cams, name, columns=3):
  ww=W*columns;rows=math.ceil(len(cams)/columns)
  out=Image.new('RGB',(ww,rows*(H+24)),'#1d2533');draw=ImageDraw.Draw(out)
  for k,c in enumerate(cams):
    x=k%columns*W;y=k//columns*(H+24)
    out.paste(render(theme,c),(x,y));draw.text((x+8,y+H+3),f'{theme.upper()} | camX={c} | zona {next((i+1 for i,z in enumerate(Z[1:]) if c<z),3)}',fill='white')
  out.save(Q/name,quality=90)

if __name__=='__main__':
  Q.mkdir(exist_ok=True)
  cams=[0,400,1280,2460,5100,10090,10475,10530,12300,15000,24320,25460,25560,27000,31900,35700]
  for theme in ('school','dance'):
    contact(theme,cams,f'CONTACTO_{theme.upper()}_16_CAMARAS.jpg',columns=4)
  # Explicitly sample nine different classroom modules: this is a Python
  # rendering of authentic generated resources, NOT a Flutter screenshot.
  sample=[10500+880*n+40 for n in range(9)]
  contact('school',sample,'CONTACTO_COLEGIO_9_VARIANTES_REALES_PYTHON.jpg',columns=3)
    for c in [0,600,10475,10530,25460,25560,31900]:
      render(theme,c).save(Q/f'{theme}_{c:05}.png')
  # Parallax test: move across 1200 world pixels, 72 frames, one per 16.7px.
  mov=Q/'motion_frames';mov.mkdir(exist_ok=True)
  for j in range(72):
    cam=550+j*19
    r=render('school',cam) if j<36 else render('dance',cam)
    r.save(mov/f'{j:03}.png')
  print('Contact sheets: school, dance and 72 motion frames')
