"""Simulador Python de vistas V4 usando RECURSOS REALES; no es Flutter.
Reproduce posiciones de cámara, hitos únicos, culling, atrezzo y suelo.
Nunca maquilla los cortes: registra la discontinuidad y BLOQUEA QA visual.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import math, re, json, hashlib
ROOT=Path(__file__).resolve().parents[1]
ART=ROOT/'assets/images/chapter1'
OUT=ROOT/'qa/ch1_world_v4_previews'
OUT.mkdir(parents=True,exist_ok=True)
W,H=800,450
HEIGHT=380
FLOOR_Y=390
STAGE_W=36500
DART=(ROOT/'lib/chapter_one_world_v4.dart').read_text()
SOURCE=((ROOT/'lib/neighborhood_scene_engine.dart').read_text())
# Igual que Dart: posiciones SOLO de neighborhoodSceneRegions; dimensiones
# SOLO de ch1SourceDimsV4. Ninguna segunda tabla de posiciones.
DIMS={name:(int(w),int(h)) for name,w,h in re.findall(
    r"'([^']+)':\s*\((\d+),\s*(\d+)\)",
    DART.split('const ch1SourceDimsV4 =',1)[1].split('};',1)[0])}
REGION_BLOCK=SOURCE.split('const neighborhoodSceneRegions =',1)[1].split('];',1)[0]
REGIONS=[(name,int(start),int(end)) for name,start,end in re.findall(
    r"asset: '([^']+)',\s*start: (\d+),\s*end: (\d+)",REGION_BLOCK)]
# Bloques multilínea para conexiones, con separaciones de línea variables
REGIONS=[(name,int(start),int(end)) for name,start,end in re.findall(
    r"asset: '([^']+)'[^\]]*?start:\s*(\d+)\s*,\s*end:\s*(\d+)", REGION_BLOCK)]
LANDMARKS=[(name,start,*DIMS[name]) for name,start,end in REGIONS]

PROP_RECTS=[tuple(map(int,t)) for t in re.findall(r'\[(\d+),(\d+),(\d+),(\d+)\]',DART.split('const ch1PropRectsV4 =',1)[1].split('];',1)[0])]
IMAGES={name:Image.open(ART/(name+'.png')).convert('RGB') for name,*_ in LANDMARKS}
ATLAS=Image.open(ART/'park_props_atlas.png').convert('RGBA')
CLOUDS=Image.open(ART/'clouds_v4_experimental.png').convert('RGBA')
GROUND=Image.open(ROOT/'assets/images/ground/stage_0.png').convert('RGB')
HERO0=Image.open(ROOT/'assets/images/frames/bailarina_walk_0.png').convert('RGBA')
HERO1=Image.open(ROOT/'assets/images/frames/bailarina_walk_1.png').convert('RGBA')
LANDMARK_WIDTH={name:w*HEIGHT/sh for name,x,w,sh in LANDMARKS}
LANDMARK_ENDS=[(x,x+LANDMARK_WIDTH[name]) for name,x,*_ in LANDMARKS]


def prop_is_safe(x,width):
    return (x>=0 and x+width<=STAGE_W and not any(
      x<b+120 and x+width>a-120 for a,b in LANDMARK_ENDS))


def props():
    result=[]
    n=0
    for block in range(math.ceil(STAGE_W/470)):
        sector=(block*470)//4600
        offset=(block*47+sector*79)%155
        x=block*470.0+offset
        scheme=(block*13+sector*5)%9
        cases={
          0:[(x+32,2,170),(x+318,9,62)],
          1:[(x+61,8,109),(x+220,5,78)],
          2:[(x+22,1,175),(x+310,11,91)],
          3:[(x+61,4,148),(x+268,6,65)],
          4:[(x+85,9,62),(x+252,7,86)],
          5:[(x+59,0,170),(x+309,8,115)],
          6:[(x+40,3,174),(x+317,11,97)],
          7:[(x+90,5,91),(x+272,9,65)],
          8:[(x+49,2,172),(x+305,7,84)],
        }
        for xx,atlas_idx,height in cases[scheme]:
            r=PROP_RECTS[atlas_idx]
            width=height*r[2]/r[3]
            if prop_is_safe(xx,width):
                result.append((n,xx,atlas_idx,height))
                n+=1
    return result

PROPS=props()


def frame(cam, include_labels=False):
    assert 0<=cam<=STAGE_W-W
    im=Image.new('RGB',(W,H),(62,166,241))
    dr=ImageDraw.Draw(im)
    # Paralaje sólo en capas lejanas. Capa modular continua en W coordenadas.
    for layer in range(2):
        speed=[.18,.38][layer]
        baseline=[297,348][layer]
        col=[(103,153,182),(70,143,123)][layer]
        points=[(0,HEIGHT),(0,baseline)]
        for sx in range(0,W+9,8):
            wx=sx+cam*speed
            y=baseline-21*math.sin(wx/[251,137][layer])-11*math.sin(wx/[103,75][layer])
            points.append((sx,round(y)))
        points.extend([(W,HEIGHT),(0,HEIGHT)])
        dr.polygon(points,fill=col)
    for i in range(100):
        wx=110.0+i*500.0+(i%3)*48
        dx=wx-cam*.18
        if dx < -290 or dx>W+290:continue
        r=(8,4,480,170) if i%2==0 else (530,4,470,170)
        part=CLOUDS.crop((r[0],r[1],r[0]+r[2],r[1]+r[3]))
        part=part.resize((264,94),Image.Resampling.NEAREST)
        im.paste(part,(round(dx),35+(i%4)*19),part)
    for i in range(110):
        xx=160.0+i*335+(i%4)*55
        if not prop_is_safe(xx,(99+(i%3)*15)*PROP_RECTS[i%4][2]/PROP_RECTS[i%4][3]):continue
        idx=i%4; ht=99+(i%3)*15
        r=PROP_RECTS[idx]
        ww=round(ht*r[2]/r[3])
        part=ATLAS.crop((r[0],r[1],r[0]+r[2],r[1]+r[3]))
        part=part.resize((ww,ht),Image.Resampling.NEAREST)
        if -ww<=xx-cam<=W:
            im.paste(part,(round(xx-cam),341-ht),part)
    for name,x,sw,sh in LANDMARKS:
        width=LANDMARK_WIDTH[name]
        if x+width<=cam or x>=cam+W:continue
        art=IMAGES[name].crop((0,0,sw,sh))
        art=art.resize((round(width),HEIGHT),Image.Resampling.BICUBIC)
        im.paste(art,(round(x-cam),0))
    # Muro repetible: textura de atlas real, coordenadas físicas de mundo.
    wallR=PROP_RECTS[10]
    wallH=57
    wallW=wallH*wallR[2]/wallR[3]
    wall=ATLAS.crop((wallR[0],wallR[1],wallR[0]+wallR[2],wallR[1]+wallR[3]))
    wall=wall.resize((round(wallW),wallH),Image.Resampling.NEAREST)
    for n in range(max(0,math.floor(cam/wallW)-1),math.ceil((cam+W)/wallW)+1):
        wx=n*wallW
        if any(wx+wallW>=a-16 and wx<=b+16 for a,b in LANDMARK_ENDS):
            continue
        im.paste(wall,(round(wx-cam),325),wall)
    for i,x,atlas_idx,ht in PROPS:
        sx=x-cam
        r=PROP_RECTS[atlas_idx]
        ww=ht*r[2]/r[3]
        if sx+ww<0 or sx>=W:continue
        part=ATLAS.crop((r[0],r[1],r[0]+r[2],r[1]+r[3]))
        part=part.resize((round(ww),round(ht)),Image.Resampling.NEAREST)
        im.paste(part,(round(sx),387-round(ht)),part)
    # Original ground tile, anchored to world, not the screen.
    for k in range(math.floor(cam/GROUND.width)-1,math.ceil((cam+W)/GROUND.width)+1):
        xx=round(k*GROUND.width-cam)
        im.paste(GROUND,(xx,FLOOR_Y))
    hero=(HERO0 if int(cam/10)%2==0 else HERO1)
    hero=hero.crop(hero.getbbox())
    size=(round(hero.width*118/hero.height),118)
    hero=hero.resize(size,Image.Resampling.NEAREST)
    # shadow and feet in world floor
    dr=ImageDraw.Draw(im)
    dr.ellipse((307,385,347,392),fill='#2d2a2b')
    im.paste(hero,(327-size[0]//2,FLOOR_Y-118),hero)
    if include_labels:
        dr=ImageDraw.Draw(im)
        dr.rounded_rectangle((8,8,460,41),radius=5,fill=(8,25,49))
        dr.text((16,17),f'LAB V4 (NO APROBADO) | camara={cam:05.0f}',fill='white')
    return im


def evidence():
    cameras=[0,100,250,400,600,750,900,1000,1200,1450,2000,5300,7000,7500,9000,9200,10100,12000,16400,18600,25700,27800,35000]
    results={}
    sheet=Image.new('RGB',(4*W,math.ceil(len(cameras)/4)*H),'#182035')
    for i,cam in enumerate(cameras):
        scene=frame(cam,True)
        sheet.paste(scene,(i%4*W,i//4*H))
        if cam in [0,750,1000,1450,9200,18600,35000]:scene.save(OUT/f'camera_{cam:05}.png')
    sheet.save(OUT/'CONTACTO_23_CAMARAS_V4.png',optimize=True)
    # Physical move exact: native painting x = world - camera; no pan.
    results['cameras']=cameras
    results['landmarks']=[{'asset':name,'start':x,'end':round(x+LANDMARK_WIDTH[name],2),'natural_width':round(LANDMARK_WIDTH[name],2)} for name,x,*_ in LANDMARKS]
    results['props_count']=len(PROPS)
    results['floor_in_world']=True
    results['camera_world_shift_for_300_units']=300
    # THESE endpoints are graphically unapproved (hard cuts of flat images).
    results['artistic_seam_gate']='REJECTED_UNTIL_NATIVE_ARTISTIC_CONNECTORS'
    results['flutter_gate']='NOT_RUN_SDK_UNAVAILABLE'
    (OUT/'RESULTADOS_V4.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
    # Short clip at FIRST seam: do not hide the bad join.
    try:
        import imageio.v2 as iio
        seq=[frame(160+i*11,False) for i in range(61)]
        iio.mimsave(str(OUT/'PRIMERA_UNION_V4_DIAGNOSTICA_NO_APROBADA.mp4'),seq,fps=12,quality=6,macro_block_size=2)
    except Exception as e:
        (OUT/'VIDEO_ERROR.txt').write_text(str(e))
    return results

if __name__=='__main__':
 print(json.dumps(evidence(),ensure_ascii=False,indent=2))
