#!/usr/bin/env python3
"""Artist-authored school interior replacement (27 physical 880x278 panels).

Requires assets/images/school_hifi/school_five_scenes_master.png, the reviewed
five-zone original art, *not* the three obsolete wall panoramas. No APK.
Existing exterior landscape images are untouched. The windows become alpha
so the live StagePainter keeps its .30/.56 moving view.
"""
from __future__ import annotations
import hashlib,json
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'assets/images/school_hifi/school_five_scenes_master.png'
OUT=ROOT/'assets/images/interiors_parallax/school'
QA=ROOT/'qa/school_hifi_lab'
BANDS=[(5,203),(217,407),(422,616),(630,819),(835,1013)]
ROOMS=['pasillo','aula','informatica','biblioteca','taquillas']
PLANS=[[0,4,0,3,4,0,3,4,0],[1,1,0,1,3,1,0,1,1],[2,2,4,2,3,2,4,2,2]]
WINDOWS={
 0:[(385,25,631,153),(805,25,1097,151)],
 1:[(444,251,529,347),(575,250,645,342),(694,247,782,343)],
 2:[(547,452,723,565),(742,454,976,567),(992,451,1162,565)],
 3:[(573,651,698,762),(734,650,855,758),(872,648,990,759)],
 4:[(1128,859,1266,947)],
}
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def render(master,zone,variant):
    room=PLANS[zone][variant]
    y0,y1=BANDS[room]
    left=350+((zone*87+variant*113+room*79)%294)
    source=master.crop((left,y0,left+880,y1)).convert('RGBA')
    H=source.height
    dst=Image.new('RGBA',(880,278),(0,0,0,255))
    dst.paste(source.crop((0,4,880,18)).resize((880,30),
        Image.Resampling.NEAREST),(0,0))
    dst.paste(source,(0,32))
    base_y=32+H
    if base_y<278:
        dst.paste(source.crop((0,max(0,H-10),880,H)).resize(
            (880,278-base_y),Image.Resampling.NEAREST),(0,base_y))
    draw=ImageDraw.Draw(dst,'RGBA')
    for sy,color in [(0,(50,49,57,210)),(25,(33,39,47,90)),
                     (base_y-2,(61,56,50,160))]:
        draw.line((0,sy,879,sy),fill=color,width=2)
    pixels=np.asarray(dst).copy()
    for x1,wy1,x2,wy2 in WINDOWS[room]:
        xa=max(0,x1-left+7);xb=min(880,x2-left-7)
        ya=max(0,wy1-y0+32+8);yb=min(278,wy2-y0+32-10)
        if xb-xa<18 or yb-ya<18:continue
        interior=x2-x1-14
        step=0 if interior<150 else (xb-xa)//2
        for start,end in ([(xa,xb)] if not step else
                          [(xa,xa+step-3),(xa+step+5,xb)]):
            if end-start>12:pixels[int(ya):int(yb),int(start):int(end),3]=5
    dst=Image.fromarray(pixels,'RGBA')
    draw=ImageDraw.Draw(dst)
    for x in (0,870):
        draw.rectangle((x,0,x+9,277),fill=(82,77,76,255))
        draw.line((x+2,4,x+2,272),fill=(183,158,122,255),width=2)
        draw.line((x+7,5,x+7,271),fill=(39,41,50,255),width=2)
    return dst,room,left
def main():
    if not SRC.exists():raise FileNotFoundError(
       f'Required genuine school artwork missing: {SRC}. '
       'Do NOT silently regenerate the rejected RC4 school walls.')
    master=Image.open(SRC).convert('RGB')
    if master.size!=(1536,1024):
        raise ValueError(f'Unexpected master size {master.size}')
    OUT.mkdir(parents=True,exist_ok=True);QA.mkdir(parents=True,exist_ok=True)
    entries=[]
    for zone in range(3):
        for variant in range(9):
            im,room,left=render(master,zone,variant)
            p=OUT/f'z{zone}_panel_{variant}.png'
            im.save(p,optimize=True)
            entries.append({'zone':zone,'variant':variant,
                'room':ROOMS[room],'source_left':left,
                'sha256':digest(p),
                'transparent_pixels':int((np.asarray(im)[:,:,3]<15).sum())})
    if len(set(e['sha256'] for e in entries))!=27:
        raise AssertionError('School modules not unique')
    if set(x['room'] for x in entries)!=set(ROOMS):
        raise AssertionError('School lacks distinct room families')
    result={'status':'pixel-art candidate: Flutter/mobile artistic sign-off pending',
            'master_sha256':digest(SRC),'panel_size':[880,278],
            'window_rule':'outside moves, walls stay at world speed 1.00',
            'panels':entries}
    (QA/'SCHOOL_HIFI_MANIFEST.json').write_text(
        json.dumps(result,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
    print(f'Generated 27 individual school PNGs in {OUT}; all five room types.')
if __name__=='__main__':main()
