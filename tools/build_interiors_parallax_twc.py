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
    """Paisajes de CALIDAD del método aprobado RC3 FIX2, solo tras ventanas.

    No dibujar rectángulos, elipses o edificios geométricos provisionales:
    esos fondos de baja resolución visual son el fallo observado en Android.
    Reutilizamos las texturas maestras detalladas del capítulo 1, sin alterarlas.
    El desplazamiento sigue a 0.30 / 0.56 y los ciclos siguen cerrados.
    """
    src = ASSETS / 'chapter1/ch1_parallax'
    far_source = src / 'montanas_ciudad_ciclo.png'
    mid_source = src / 'arbolado_medio_ciclo.png'
    if not far_source.is_file() or not mid_source.is_file():
        raise FileNotFoundError('Faltan los paisajes aprobados RC3 FIX2; no generar sustitutos simples')
    with Image.open(far_source) as master:
        far = master.convert('RGB').resize((FAR_W, H), Image.Resampling.LANCZOS)
    with Image.open(mid_source) as master:
        mid = master.convert('RGBA').resize((MID_W, H), Image.Resampling.LANCZOS)
    # El colegio y la academia deben mostrar distintas ventanas del paisaje,
    # sin espejar ni duplicar incorrectamente piezas de arquitectura cercana.
    shift_far = 0 if theme == 'school' else 731
    shift_mid = 0 if theme == 'school' else 407
    far = Image.fromarray(np.roll(np.asarray(far), shift_far, axis=1), 'RGB')
    mid = Image.fromarray(np.roll(np.asarray(mid), shift_mid, axis=1), 'RGBA')
    # Empalme cíclico de las texturas maestras: igualar una franja corta de
    # extremos en lugar de fundir panorámicas enteras en tiempo de juego.
    def close_cycle(image, band=32):
        a = np.asarray(image).copy()
        for j in range(band):
            k = (band - j) / band
            target = ((a[:, j, :].astype(np.float32) +
                       a[:, -1-j, :].astype(np.float32)) / 2)
            a[:, j, :] = np.uint8(np.clip(a[:, j, :] * (1-k) + target*k, 0, 255))
            a[:, -1-j, :] = np.uint8(np.clip(a[:, -1-j, :] * (1-k) + target*k, 0, 255))
        a[:, -1, :] = a[:, 0, :]
        return Image.fromarray(a, image.mode)
    return close_cycle(far), close_cycle(mid)


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
