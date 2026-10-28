"""Prueba aislada de empalme con candidato generado: jamás modifica fuentes."""
from PIL import Image,ImageDraw
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'qa/ch1_world_v4_previews'
ART=ROOT/'assets/images/chapter1/residential_curve.png'
NEW=Path(__file__).resolve().parents[1]/'assets/images/chapter1/connector_candidate_draft_v4_NOT_APPROVED.png'
orig=Image.open(ART).convert('RGB').crop((0,0,1672,690)).resize((921,380),Image.Resampling.BICUBIC)
ground=Image.open(ROOT/'assets/images/ground/stage_0.png').convert('RGB')
hero=Image.open(ROOT/'assets/images/frames/bailarina_walk_0.png').convert('RGBA')
hero=hero.crop(hero.getbbox())
hero=hero.resize((round(hero.width*118/hero.height),118),Image.Resampling.NEAREST)
new=Image.open(NEW).convert('RGB').crop((0,0,2172,610)).resize((1353,380),Image.Resampling.BICUBIC)
world=Image.new('RGB',(2100,380),'#4da9ed')
world.paste(orig,(0,0))
# se superpone desde 650; transición temporal/espacial entre 740 y 830.
for pos in range(650,2003):
    if pos<740:continue
    alpha=min(1.0,max(0.0,(pos-740)/90))
    arr_old=np.asarray(world.crop((pos,0,pos+1,380)),dtype=np.float32)
    arr_new=np.asarray(new.crop((pos-650,0,pos-650+1,380)),dtype=np.float32)
    mixed=(arr_old*(1-alpha)+arr_new*alpha).clip(0,255).astype('uint8')
    world.paste(Image.fromarray(mixed),(pos,0))
# producir tres fotogramas de lo realmente compositado
contact=Image.new('RGB',(1600,900))
for i,cam in enumerate((460,620,740,900)):
    frame=Image.new('RGB',(800,450),'#479ae5')
    frame.paste(world.crop((cam,0,cam+800,380)),(0,0))
    for tx in range(-(cam%ground.width)-ground.width,800,ground.width):
        frame.paste(ground,(tx,390))
    frame.paste(hero,(327-hero.width//2,390-118),hero)
    dr=ImageDraw.Draw(frame)
    dr.text((8,10),f'PRUEBA DE ARTE, NO APROBADA cam={cam}',fill='white')
    contact.paste(frame,(i%2*800,i//2*450))
contact.save(OUT/'CANDIDATA_CONEXION_GENERADA_REVISION.png')
