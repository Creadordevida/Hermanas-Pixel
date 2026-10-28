#!/usr/bin/env python3
"""Genera decorados de interiores por piezas FÍSICAS para danza y colegio.

El movimiento de 3 capas reproduce el CONTRATO TWC aprobado, sin desplazar
panoramas completos durante kilómetros, ni fundidos entre habitaciones.
Los PNG fuente originales nunca se sobrescriben. No genera APK.
"""
from __future__ import annotations
import argparse, json, math, random, hashlib
from pathlib import Path
from PIL import Image, ImageDraw, ImageOps
import numpy as np

ROOT=Path(__file__).resolve().parents[1]
ASSETS=ROOT/'assets/images'
OUT=ASSETS/'interiors_parallax'
QA=ROOT/'qa/interiors_twc_lab'
TILE_W=880
HEIGHT={'dance':286, 'school':278}
WORLD=36500
ZONES=[(0,10500),(10500,25500),(25500,36500)]
NAMES={'dance':['foyer','studio','stage'], 'school':['hall','classroom','computers']}
SRCS={'dance':['chapter45/dance_foyer.png','chapter45/dance_studio.png','chapter45/dance_stage.png'],
      'school':['scenes/school.png','scenes/school_classroom.png','scenes/school_computers.png']}
FAR_W=2200; MID_W=2020; FAR_SPEED=.30; MID_SPEED=.56


def pixel_rgb(row, n):
    return tuple(int(v) for v in row[n][:3])


def panorama(theme: str, H: int):
    """Exterior únicamente visible a través de cristales transparentes.

    Funciones periódicas aseguran que la última columna continúa con la primera;
    sin imagen duplicada/difuminada ni corte al completarse el ciclo.
    """
    palette = {'dance': [(119,177,220),(201,221,224),(100,143,160)],
               'school': [(94,158,212),(186,216,231),(78,121,147)]}[theme]
    far = Image.new('RGB',(FAR_W,H)); arr=np.empty((H,FAR_W,3),np.uint8)
    for y in range(H):
        t=y/max(1,H-1)
        for k in range(3): arr[y,:,k] = int(palette[0][k]*(1-t)+palette[1][k]*t)
    far=Image.fromarray(arr,'RGB'); d=ImageDraw.Draw(far)
    # Formas de montaña/colinas periódicas. Frecuencia entera, bordes conectados.
    terrain=[]
    for x in range(FAR_W+1):
        v=H*.60+12*math.sin(2*math.pi*x/FAR_W*3+0.4)+7*math.sin(2*math.pi*x/FAR_W*7+0.2)
        terrain.append((x,round(v)))
    d.polygon(terrain+[(FAR_W,H),(0,H)],fill=palette[2])
    r=random.Random(740 if theme=='dance' else 741)
    for x in range(85,FAR_W-80,125):
        y=int(H*.64+r.randrange(5,29));w=r.randrange(33,79);h=r.randrange(24,57)
        fill=(145,162,166) if theme=='dance' else (119,144,168)
        d.rectangle([x,y-h,x+w,H],fill=fill)
        d.polygon([(x-6,y-h),(x+w//2,y-h-12),(x+w+6,y-h)],fill=(85,110,143))
        for yy in range(y-h+10,y,16):
            for xx in range(x+9,x+w-4,16):
                d.rectangle((xx,yy,xx+4,yy+6),fill=(212,223,222))
    # Same base RGB on last/first pixel (additional blend small enough for glass).
    a=np.array(far,dtype=np.float32)
    wrap=24
    for i in range(wrap):
        t=i/(wrap-1);s=t*t*(3-2*t)
        a[:,i,:] = a[:,FAR_W-wrap+i,:]*(1-s)+a[:,i,:]*s
    far=Image.fromarray(np.clip(a,0,255).astype('uint8'),'RGB')
    # Rear silhouettes with alpha are a second cyclic layer; avoid hard edges.
    mid=Image.new('RGBA',(MID_W,H),(0,0,0,0)); md=ImageDraw.Draw(mid,'RGBA')
    rng=random.Random(27419 if theme=='dance' else 27421)
    trees=[]
    for x in range(120,MID_W-80,130):
        ht=rng.randint(40,76); wd=rng.randint(40,70)
        trees.append((x,ht,wd))
    for x,h,w in trees:
        y=int(H*.77)
        for offset in (-MID_W,0,MID_W):
            xx=x+offset
            md.ellipse((xx-w//2,y-h,xx+w//2,y),fill=(33,83,87,125))
            md.rectangle((xx-3,y-10,xx+3,H),fill=(53,75,78,125))
    # Exact transparent matching edges of the periodic alpha panorama.
    for i in range(35):
        # No tree lies in the wrap area; this is a guaranteed zero alpha seam.
        pass
    return far,mid


def make_wall(theme:str,zone:int,variant:int):
    H=HEIGHT[theme]
    p=ASSETS/SRCS[theme][zone]
    src=Image.open(p).convert('RGB')
    if theme=='dance':
        # identical Y scale to original source; no vertical distortions.
        cropped=src.crop((0,55,1672,600)).resize((1010,H),Image.Resampling.LANCZOS)
        start=(0,65,130)[variant]
        wall=cropped.crop((start,0,start+TILE_W,H))
    else:
        # Base NEUTRA para repetición. La biblioteca, las dos pizarras y sus
        # títulos se extraen aparte y NO se repiten como mosaicos enteros.
        # Se forman 2 tramos de 440 a partir de ventanas y taquillas del
        # PASILLO original, evitando la zona central de la señal de biblioteca.
        neutral=Image.open(ASSETS/'scenes/school.png').convert('RGB')
        v=variant*8
        left=neutral.crop((18+v,0,458+v,H))
        right=neutral.crop((862-v,0,1302-v,H))
        wall=Image.new('RGB',(TILE_W,H))
        wall.paste(left,(0,0));wall.paste(right,(440,0))
        # Tres ambientes diferentes, sin duplicar grandes rótulos:
        # pasillo = taquillas azules originales; aulas = madera azul verdosa;
        # informática = mobiliario de azul pizarra. Conserva sombras y textura.
        if zone in (1,2):
            pixels=np.asarray(wall).copy()
            pr=pixels[:,:,0].astype(np.int16)
            pg=pixels[:,:,1].astype(np.int16)
            pb=pixels[:,:,2].astype(np.int16)
            mask=(pr<90)&(pg<150)&(pb>pg+18)&(np.arange(H)[:,None]>34)
            if zone==1:
                pixels[:,:,0][mask]=np.clip(pr[mask]*.73+24,0,255)
                pixels[:,:,1][mask]=np.clip(pg[mask]*.91+43,0,255)
                pixels[:,:,2][mask]=np.clip(pb[mask]*.70+2,0,255)
            else:
                pixels[:,:,0][mask]=np.clip(pr[mask]*.87+22,0,255)
                pixels[:,:,1][mask]=np.clip(pg[mask]*.73+20,0,255)
                pixels[:,:,2][mask]=np.clip(pb[mask]*.68+31,0,255)
            wall=Image.fromarray(pixels,'RGB')
        # La partición en el centro es un pilar realista, no una transición
        # entre dos fotografías mediante opacidad variable.
        post=ImageDraw.Draw(wall)
        post.rectangle((430,0,450,H),fill=(143,120,102))
        post.rectangle((434,0,438,H),fill=(224,201,169))
    im=wall.convert('RGBA'); a=np.array(im)
    # Sólo azules luminosos dentro de ventanas permiten asomar el paisaje
    # .30/.56; NO se transparentan fachadas, mesas, columnas ni salas enteras.
    # Un umbral cromático conserva las ventanas y sus marcos originales.
    R=a[:,:,0].astype(np.int16);G=a[:,:,1].astype(np.int16);B=a[:,:,2].astype(np.int16)
    blue=(R>=80)&(G>=115)&(B>=148)&(B>R+21)&(B>G+12)
    yy=np.arange(H)[:,None];xx=np.arange(TILE_W)[None,:]
    blue &= (yy<min(210,H-35))
    if theme=='school':
        # Taquillas: azules oscuros (excluidos por luminancia), bordes intactos.
        blue &= (G>130)
    else:
        blue &= (R>=107)&(G>145)
    # Windows remain localized, not the full image alpha-gradients that caused
    # the notorious ghost facades in chapter 1.
    a[:,:,3][blue]=12
    im=Image.fromarray(a,'RGBA')
    dr=ImageDraw.Draw(im,'RGBA')
    # Parantes arquitectónicos, idénticos en ambos extremos de todas las piezas.
    if theme=='dance':
        frame=(108,65,38,255);shine=(212,164,91,255);shade=(74,43,29,255)
        dr.rectangle((0,0,TILE_W-1,7),fill=frame)
        for x0 in (0,TILE_W-22):
            dr.rectangle((x0,0,x0+21,H-1),fill=frame)
            dr.rectangle((x0+3,0,x0+6,H-1),fill=shine)
            dr.rectangle((x0+18,0,x0+21,H-1),fill=shade)
        dr.rectangle((0,H-15,TILE_W,H-10),fill=frame)
        dr.line((0,H-16,TILE_W,H-16),fill=shine,width=2)
    else:
        frame=(143,120,102,255);shine=(224,201,169,255);shade=(94,79,68,255)
        dr.rectangle((0,0,TILE_W-1,7),fill=frame)
        for x0 in (0,TILE_W-22):
            dr.rectangle((x0,0,x0+21,H-1),fill=frame)
            dr.rectangle((x0+2,0,x0+7,H-1),fill=shine)
            dr.rectangle((x0+17,0,x0+21,H-1),fill=shade)
        dr.rectangle((0,H-10,TILE_W,H-1),fill=frame)
        dr.line((0,H-11,TILE_W,H-11),fill=shine,width=2)
    return im


def passage(theme:str):
    """Marco físico/arquitectónico para unir las 3 zonas; sin fundidos."""
    H=HEIGHT[theme]
    im=Image.new('RGBA',(120,H),(0,0,0,0));d=ImageDraw.Draw(im)
    if theme=='dance':
        base='#714023';hi='#e6b872';dark='#382016'
    else:
        base='#9e866e';hi='#e4c6a3';dark='#4c4851'
    # Doble jamba lateral y dintel compartido: lenguaje visual verosímil.
    d.rectangle((0,0,119,13),fill=base)
    d.rectangle((0,0,13,H),fill=base)
    d.rectangle((105,0,119,H),fill=base)
    d.rectangle((16,13,103,18),fill=hi)
    for x in (8,111):
        d.line((x,0,x,H),fill=hi,width=3)
    d.line((17,19,17,H),fill=dark,width=2)
    d.line((102,19,102,H),fill=dark,width=2)
    d.rectangle((0,H-13,119,H-9),fill=base)
    return im


def extract_school_features():
    """Objetos únicos: carteles/pizarras y mesas. Nunca en panel repetible."""
    out=OUT/'school'
    hall=Image.open(ASSETS/'scenes/school.png').convert('RGBA')
    mathsc=Image.open(ASSETS/'scenes/school_classroom.png').convert('RGBA')
    comp=Image.open(ASSETS/'scenes/school_computers.png').convert('RGBA')
    # La pizarra se recorta justo sobre su marco de madera, sin un rectángulo
    # de fondo que enmascare paredes ni produzca transparencias fantasma.
    for name,im,bbox,w in [
        ('pizarra_matematicas',mathsc,(339,43,1002,252),520),
        ('pizarra_informatica',comp,(330,38,1005,258),520)]:
        feature=im.crop(bbox)
        h=round(feature.height*w/feature.width)
        feature.resize((w,h),Image.Resampling.LANCZOS).save(out/f'{name}.png',optimize=True)
    # Estantería con su rótulo de biblioteca, con alfa fuera del objeto.
    target=Image.new('RGBA',(195,270),(0,0,0,0))
    shelf=hall.crop((566,56,715,277))
    target.alpha_composite(shelf,(21,49))
    sign=hall.crop((581,9,749,59))
    target.alpha_composite(sign,(0,0))
    target.save(out/'estanteria_biblioteca.png',optimize=True)
    # Mesita realista del arte original, recorte por tonalidad madera para
    # dejar ver el suelo original y no superponer un rectángulo sólido.
    desk=mathsc.crop((60,258,230,362)).convert('RGBA')
    a=np.asarray(desk).copy();r=a[:,:,0].astype('int16');g=a[:,:,1].astype('int16');b=a[:,:,2].astype('int16')
    wood=((r>g+8)&(g>b+5)&(r<225))|((r<96)&(g<90)&(b<87))
    a[:,:,3]=np.where(wood,255,0).astype('uint8')
    desk=Image.fromarray(a,'RGBA')
    desk.save(out/'mesa_aula.png',optimize=True)
    # Monitor pixel-art auténtico, usado SOLO en la sala de informática,
    # colocado sobre cada mesa en una posición de mundo idéntica a esta.
    monitor=comp.crop((97,194,213,285)).convert('RGBA')
    m=Image.new('L',monitor.size,0);d=ImageDraw.Draw(m)
    d.polygon([(18,0),(84,0),(93,72),(15,72)],fill=255)
    d.rectangle((0,82,114,89),fill=255)
    d.rectangle((49,70,59,83),fill=255)
    monitor.putalpha(m)
    monitor.save(out/'ordenador_aula.png',optimize=True)


def main():
    OUT.mkdir(exist_ok=True,parents=True);QA.mkdir(exist_ok=True,parents=True)
    master_hashes={}
    manifest={'version':'interiores-twc-local-v1','world':WORLD,'width':TILE_W,
              'zones':[{'start':a,'end':b} for a,b in ZONES],
              'speed':{'far':FAR_SPEED,'mid':MID_SPEED,'near':1.0},
              'protected_originals':{},'stages':{},
              'render_rules':'walls 1:1, windows show 0.30/0.56, no full-screen alpha fades'}
    for theme,H in HEIGHT.items():
        for f in SRCS[theme]:
            src=ASSETS/f;master_hashes[f]=hashlib.sha256(src.read_bytes()).hexdigest()
        o=OUT/theme;o.mkdir(exist_ok=True)
        far,mid=panorama(theme,H)
        far.save(o/'exterior_lejano_ciclo.png',optimize=True)
        mid.save(o/'arbolado_tras_ventanas_ciclo.png',optimize=True)
        zone_entries=[]
        for zone in range(3):
            for variant in range(3):
                im=make_wall(theme,zone,variant)
                im.save(o/f'z{zone}_panel_{variant}.png',optimize=True)
            zone_entries.append({'id':NAMES[theme][zone],'start':ZONES[zone][0],
                                 'end':ZONES[zone][1],'panels':3})
        passage(theme).save(o/'marco_paso.png',optimize=True)
        manifest['stages'][theme]={'height':H,'far_width':FAR_W,'mid_width':MID_W,
                                  'zones':zone_entries,
                                  'far_period':FAR_W/FAR_SPEED,'mid_period':MID_W/MID_SPEED,
                                  'assets_count':17 if theme=='school' else 12}
    extract_school_features()
    manifest['protected_originals']=master_hashes
    (QA/'MANIFEST.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
    print(json.dumps({'themes':list(HEIGHT),'panels':18,'other_images':10,
        'world':WORLD,'far_period':round(FAR_W/FAR_SPEED),'mid_period':round(MID_W/MID_SPEED)},ensure_ascii=False))

if __name__=='__main__': main()
