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
SCHOOL_PANEL_VARIANTS=9
DANCE_PANEL_VARIANTS=3
# Physical rooms preserve their dominant theme, with genuine corridors
# at natural transitions. Every image comes from the three ALREADY
# APPROVED 1320x480 school illustrations; nothing is invented or redrawn.
# 0: corridor/library, 1: maths/classroom, 2: computing lab.
SCHOOL_SOURCE_PLAN=(
    (0,0,0,1,0,0,0,2,0),  # hall with occasional classroom/technology doorway
    (1,1,0,1,1,0,1,1,2),  # lessons with corridors between classroom wings
    (2,2,0,2,2,0,2,2,1),  # computers with access passages + study corner
)


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
        original=master.convert('RGB')
        # School's high windows must reveal the real city/trees rather than
        # an enlarged expanse of blue sky. Select the approved vista's
        # lower 278px; do not resize it on one axis or redraw the landscape.
        if theme=='school' and original.height >= H+102:
            original=original.crop((0,102,original.width,102+H))
        far=original.resize((FAR_W,H),Image.Resampling.LANCZOS)
    with Image.open(mid_source) as master:
        original=master.convert('RGBA')
        if theme=='school' and original.height >= H+102:
            original=original.crop((0,102,original.width,102+H))
        mid=original.resize((MID_W,H),Image.Resampling.LANCZOS)
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
        # Artwork-preserving 1:1 ASPECT crop, not stretched/scaled axes.
        # Previous source: 1672x545 -> 1650x286 (X 0.987, Y 0.525),
        # visually flattening arched doors, mirrors, dancers and furniture.
        # The new 1200x390 window -> 880x286 has identical X/Y scales.
        # Three native source positions retain detail from each of the three
        # approved 1672x941 master illustrations without mirrors or new art.
        sw,sh=1200,390
        if abs(TILE_W/sw-H/sh)>1e-10:
            raise ValueError('Dance pixels must scale proportionally')
        left=(0,236,472)[variant]
        top=175 if zone==2 else 155
        if left+sw>src.width or top+sh>src.height:
            raise ValueError('Dance source too small for authentic crop')
        wall=src.crop((left,top,left+sw,top+sh)).resize(
            (TILE_W,H),Image.Resampling.LANCZOS)
    else:
        # Colegio: cada sala emplea SU ilustración fuente; antes las tres
        # zonas repetían la misma panorámica del pasillo recoloreada.
        # Los hitos (biblioteca, pizarras) se insertan aparte en mundo 1:1.
        # Extraemos bandas amplias, sin pegar dos mitades con corte a x=440.
        # Use the actual approved source corresponding to a corridor,
        # classroom or computer lab. No tint/flip/copy from one classroom.
        source_zone=SCHOOL_SOURCE_PLAN[zone][variant]
        master=Image.open(ASSETS/SRCS['school'][source_zone]).convert('RGB')
        source_w, source_h = master.size
        if source_w < 880 or source_h < H:
            raise ValueError(f'Fuente insuficiente para colegio: {SRCS["school"][zone]}')
        # DEFECTO RC3 FIX2: crop_w era 1320 (ancho completo del original
        # 1320x480), y los tres offsets calculados eran SIEMPRE cero.
        # Las 3 variantes repetían la MISMA imagen, comprimida de 1320x480
        # a 880x278. Es la causa real del aula/pasillo clonado.
        #
        # Ahora el interior se extrae a escala nativa 1:1 del PNG original:
        # nueve ventanas espaciales distintas a lo largo de sus 440px de
        # margen horizontal. Sin estirar ventanas, pizarras ni mobiliario.
        # El entorno exterior conserva ALFA sobre los cristales.
        if source_w < TILE_W or source_h < H:
            raise ValueError('La fuente del colegio no permite recortes 1:1')
        if not 0 <= variant < SCHOOL_PANEL_VARIANTS:
            raise ValueError('Variación escolar fuera de rango')
        max_left=source_w-TILE_W
        if source_zone in (1,2):
            # Las pizarras originales de MATEMÁTICAS e INFORMÁTICA
            # ocupan aproximadamente x=330..1005. Los recortes anteriores
            # con left=0/55/385/440 las partían por el borde del módulo.
            # Para aulas usar sólo aperturas que muestran la pizarra ENTERA.
            # Conservamos una variación genuina de 9 posiciones, sin
            # deformar un solo píxel ni recortar las palabras.
            safe_left=145
            safe_right=min(max_left-15,325)
            left=round(safe_left+(safe_right-safe_left)*variant/
                       (SCHOOL_PANEL_VARIANTS-1))
        else:
            # The hall's AULAS -> sign spans x≈770..923. Allow a native
            # margin so the entire sign fits BEFORE the shared right pillar.
            left=round(65+(max_left-65)*variant/(SCHOOL_PANEL_VARIANTS-1))
        wall=master.crop((left,0,left+TILE_W,H))
        if source_zone in (1,2):
            # AULAS: los maestros originales tienen pupitres y monitores
            # parcialmente dibujados en los últimos 26px de la pared.
            # Como StagePainter añade los muebles físicos aparte, esas
            # mitades de mesa parecían flotar encima del verdadero suelo.
            # Recuperamos SOLO la base mural original del pasillo (mismos
            # 1320px y misma perspectiva), sin estirar ni crear ilustraciones.
            hall=Image.open(ASSETS/SRCS['school'][0]).convert('RGB')
            # Hall corridor signage is appropriate in corridors only.
            # In the classrooms it used to show the letters "AULAS ->"
            # severed immediately BELOW the blackboards. Inpaint only
            # the 27px wall base from a sign-free region of the ORIGINAL hall,
            # at native 1:1 scale; feather the two boundaries.
            lower=np.asarray(hall.crop((left,251,left+TILE_W,H)),
                             dtype=np.uint8).copy()
            full=np.asarray(hall,dtype=np.uint8)
            cols=np.arange(left,left+TILE_W)
            valid=(cols>=750)&(cols<=955)
            if valid.any():
                xx=cols[valid]
                fade=np.maximum(0.0,np.minimum(
                    1.0,np.minimum((xx-750)/18.0,(955-xx)/18.0)))
                replacement=full[251:H,xx+200,:]
                blend=(lower[:,valid,:].astype(np.float32)
                       *(1-fade[None,:,None])
                       +replacement.astype(np.float32)*fade[None,:,None])
                lower[:,valid,:]=np.uint8(np.rint(blend))
            wall.paste(Image.fromarray(lower,'RGB'),(0,251))
            hall.close()
        master.close()
        # Un montante fino y regular en el extremo evita que los marcos
        # queden partidos al cambiar de panel, sin falsa junta central.
        post=ImageDraw.Draw(wall)
        post.rectangle((0,0,10,H-1),fill=(143,120,102))
        post.rectangle((3,0,5,H-1),fill=(224,201,169))
        post.rectangle((TILE_W-11,0,TILE_W-1,H-1),fill=(143,120,102))
        post.rectangle((TILE_W-8,0,TILE_W-6,H-1),fill=(224,201,169))
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
    # Profundidad arquitectónica local: zócalo, línea de encuentro y sombra
    # física debajo del techo. Mantener estas bandas por DELANTE de ventanas,
    # no convertir ninguna sala en transparencia de pantalla completa.
    if theme == 'school':
        trim = ((115,94,78,255),(92,101,99,255),(80,91,111,255))[zone]
        light = ((218,196,158,255),(191,209,194,255),(178,193,219,255))[zone]
        dr.rectangle((0,8,TILE_W-1,15),fill=trim)
        dr.line((0,15,TILE_W-1,15),fill=light,width=2)
        dr.rectangle((0,H-35,TILE_W-1,H-29),fill=trim)
        dr.line((0,H-36,TILE_W-1,H-36),fill=light,width=2)
        # Las juntas de los módulos se encuentran siempre en un pilar,
        # no en el centro de una ventana o una taquilla.
    else:
        # Variar remates estructurales entre recortes, sin repetir pósteres
        # artificialmente ni colocar elementos sobre el personaje.
        metal=((145,112,67,255),(120,96,79,255),(158,117,73,255))[zone]
        dr.rectangle((0,10,TILE_W-1,15),fill=metal)
        dr.rectangle((0,H-33,TILE_W-1,H-29),fill=metal)
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
        # Una jamba COMPARTIDA de 22px entre dos módulos, no DOS
        # pilares de 22px contiguos (=44px repetidos cada 880).
        # Mitades de 11px, con bisel continuo y eje de luz coherente.
        dr.rectangle((0,0,10,H-1),fill=frame)
        dr.rectangle((0,0,2,H-1),fill=shine)
        dr.rectangle((8,0,10,H-1),fill=shade)
        dr.rectangle((TILE_W-11,0,TILE_W-1,H-1),fill=frame)
        dr.rectangle((TILE_W-11,0,TILE_W-9,H-1),fill=shine)
        dr.rectangle((TILE_W-3,0,TILE_W-1,H-1),fill=shade)
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
    # EXTRAER SILUETAS auténticas, NO pegar una baldosa con fondo.
    # El recorte viejo declaraba el 82.6% opaco: conservaba paredes y
    # baldosas a modo de rectángulo superpuesto junto con el pupitre.
    # Esta máscara conserva sólo los píxeles ORIGINALES del mueble,
    # cuadernos/lápices y sombra parcial. Probada contra el PNG real.
    desk=mathsc.crop((60,258,230,362)).convert('RGBA')
    aa=np.asarray(desk).copy()
    r=aa[:,:,0].astype('int16')
    g=aa[:,:,1].astype('int16')
    b=aa[:,:,2].astype('int16')
    y,x=np.indices(r.shape)
    wood=((r>g+21)&(g>b+7)&(r<230))|((r<115)&(g<106)&(b<103))
    paper=(y<24)&(x>=30)&(x<117)&(r>165)&(g>155)&(b>115)
    book=(y<28)&(x>75)&(x<114)&(b>r*.6)&(b>g*.7)&(r<175)
    shadow=(y>=88)&(y<102)&(r<132)&(g<119)&(b<110)
    alpha=np.zeros_like(aa[:,:,3])
    alpha[wood|paper|book]=255
    alpha[shadow & ~(wood|paper|book)]=90
    cut=Image.new('L',desk.size,0);md=ImageDraw.Draw(cut)
    md.polygon([(0,20),(140,20),(169,35),(155,43),(138,43),
                (138,93),(120,96),(118,49),(42,49),(42,92),
                (24,92),(24,42),(0,40)],fill=255)
    md.polygon([(36,4),(89,4),(119,20),(35,22)],fill=255)
    md.ellipse((3,85,163,102),fill=255)
    alpha=np.minimum(alpha,np.asarray(cut))
    # Preserve the original uninterrupted wood tabletop, including its
    # lighter highlight, instead of punching a sky-blue hole into it.
    top=Image.new('L',desk.size,0)
    ImageDraw.Draw(top).polygon(
        [(0,20),(139,20),(168,35),(156,42),(15,43),(0,35)],fill=255)
    alpha=np.maximum(alpha,np.asarray(top))
    # No opaque rectangular ground shadow between the legs.
    outside_legs=(y>=88)&~(
        ((x>=24)&(x<=44))|((x>=123)&(x<=140)))
    alpha[outside_legs]=np.minimum(alpha[outside_legs],95)
    aa[:,:,3]=alpha.astype('uint8')
    Image.fromarray(aa,'RGBA').save(out/'mesa_aula.png',optimize=True)

    # El recorte anterior del monitor contenía un rectángulo de pared azul
    # detrás. Usar marcos verdaderos del original: monitor, pedestal,
    # teclado y ratón. La ventana exterior queda a la vista alrededor.
    monitor=comp.crop((97,194,213,285)).convert('RGBA')
    mask=Image.new('L',monitor.size,0);md=ImageDraw.Draw(mask)
    md.polygon([(18,5),(76,5),(82,12),(82,59),(79,65),
                (16,65),(16,12)],fill=255)
    md.polygon([(49,62),(62,62),(62,81),(49,81)],fill=255)
    md.polygon([(0,83),(114,83),(114,89),(0,89)],fill=255)
    md.ellipse((90,79,108,88),fill=255)
    monitor.putalpha(mask)
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
            count=SCHOOL_PANEL_VARIANTS if theme=='school' else DANCE_PANEL_VARIANTS
            for variant in range(count):
                im=make_wall(theme,zone,variant)
                im.save(o/f'z{zone}_panel_{variant}.png',optimize=True)
            zone_entries.append({'id':NAMES[theme][zone],'start':ZONES[zone][0],
                                 'end':ZONES[zone][1],'panels':count,
                                 'source_sequence':list(SCHOOL_SOURCE_PLAN[zone])
                                   if theme=='school' else [zone]*count})
        passage(theme).save(o/'marco_paso.png',optimize=True)
        manifest['stages'][theme]={'height':H,'far_width':FAR_W,'mid_width':MID_W,
                                  'zones':zone_entries,
                                  'far_period':FAR_W/FAR_SPEED,'mid_period':MID_W/MID_SPEED,
                                  'assets_count':35 if theme=='school' else 12,
                                  'variants_per_zone':SCHOOL_PANEL_VARIANTS if theme=='school' else DANCE_PANEL_VARIANTS}
    extract_school_features()
    # New authored artwork is authoritative once its five-scene master is
    # present. Never mix old pixel walls into a final high-fidelity school.
    # Reuse the exact near-wall assets keys that Flutter already loads.
    from build_school_hifi_twc import main as rebuild_school_hifi
    school_master=ASSETS/'school_hifi/school_five_scenes_master.png'
    if school_master.exists():
        rebuild_school_hifi()
        from clean_school_floor_hifi import main as generate_school_floor_hifi
        generate_school_floor_hifi()
        manifest['stages']['school']['visual_source']='school_hifi/5_unique_rooms'
    else:
        raise FileNotFoundError(
            'SCHOOL FIX BLOCKING: exact user-approved master PNG missing '
            '(assets/images/school_hifi/school_five_scenes_master.png). '
            'DO NOT ship old RC4 wall art as if it were the new school.')
    manifest['protected_originals']=master_hashes
    (QA/'MANIFEST.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
    print(json.dumps({'themes':list(HEIGHT),'panels':36,'other_images':10,
        'world':WORLD,'far_period':round(FAR_W/FAR_SPEED),'mid_period':round(MID_W/MID_SPEED)},ensure_ascii=False))

if __name__=='__main__': main()
