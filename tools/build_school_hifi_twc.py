#!/usr/bin/env python3
"""Exact user-supplied school reference -> 27 playable 880x278 RGBA panels.

Five different artwork scenes; gallery labels removed, NO demo characters.
Interior walls remain physical world sprites; only window GLASS is alpha,
preserving the existing far .30 and mid .56 parallax behind glass.
No generated APK. Never silently fall back to rejected RC4 walls.
"""
from __future__ import annotations
import hashlib,json,math
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np

ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'assets/images/school_hifi/school_five_scenes_master.png'
OUT=ROOT/'assets/images/interiors_parallax/school'
QA=ROOT/'qa/school_hifi_lab'
W,H=880,278
BANDS=((0,204),(218,405),(420,610),(624,817),(832,1006))
ROOMS=('pasillo','aula','informatica','biblioteca','taquillas')
PLAN=(
 (0,4,0,4,3,0,4,3,0),
 (1,1,0,1,3,1,1,0,3),
 (2,2,4,2,3,2,2,4,2),
)
VIEW=(0,.35,.76,1,.56,.17,.94,.43,.68)
GLASS=(
 ((346,32,459,120),(486,32,580,122),(717,35,818,117),
  (838,34,940,122),(991,31,1040,109)),
 ((380,246,478,332),(502,244,594,335),(628,243,737,336)),
 ((504,448,584,512),(596,448,673,515),(703,447,783,518),
  (794,448,871,516),(915,449,986,516),(994,449,1084,519)),
 ((570,647,667,730),(698,647,824,732),(862,647,971,735),
  (980,648,1050,733)),
 ((1078,857,1127,922),(1144,857,1187,921)),
)

def sha(p):
 return hashlib.sha256(Path(p).read_bytes()).hexdigest()

def render(master,zone,variant):
 room=PLAN[zone][variant]
 y0,y1=BANDS[room]
 scale=H/(y1-y0)
 source_w=math.ceil(W/scale)
 available=master.width-source_w
 left=round(VIEW[variant]*available)
 left=max(0,min(available,left+(zone*37+variant*17)%41-20))
 wall=master.crop((left,y0,left+source_w,y1)).convert('RGBA')
 a=np.asarray(wall.getchannel('A')).copy()
 for xa,ya,xb,yb in GLASS[room]:
  x0=max(xa,left); x1=min(xb,left+source_w)
  lo=max(ya,y0); hi=min(yb,y1)
  if x1-x0>=10 and hi-lo>=15:
   a[lo-y0:hi-y0,x0-left:x1-left]=4
 wall.putalpha(Image.fromarray(a,'L'))
 wall=wall.resize((W,H),Image.Resampling.LANCZOS)
 d=ImageDraw.Draw(wall,'RGBA')
 for x in (0,W-8):
  d.rectangle((x,0,x+7,H-1),fill=(95,91,93,255))
  d.line((x+2,0,x+2,H-1),fill=(210,188,157,255),width=1)
  d.line((x+6,0,x+6,H-1),fill=(58,56,69,255),width=1)
 return wall,room,(left,y0,left+source_w,y1),scale

def main():
 # This historical generator must never overwrite the reviewed, alpha-fixed
 # panel bytes. The immutable accepted ZIP remains the recovery source.
 protected=QA/'SCHOOL_HIFI_MANIFEST.json'
 if protected.is_file():
  prior=json.loads(protected.read_text(encoding='utf-8'))
  if prior.get('glass_alpha_method'):
   raise RuntimeError('Protected approved school art: legacy rebuild forbidden')
 if not SRC.is_file():
  raise FileNotFoundError(
   'REQUIRED exact 5-scene source PNG missing: '+str(SRC)+
   ' (do NOT silently regenerate old school art)')
 original=Image.open(SRC).convert('RGBA')
 if original.size!=(1448,1086):
  raise ValueError('Wrong user-supplied master dimensions: '+str(original.size))
 # Remove gallery headings from the upper ceiling of EACH scene by using
 # genuine neighbouring ceiling pixels; the artwork has NO demo characters.
 for room,(top,bottom) in enumerate(BANDS):
  n=(261,224,302,384,400)[room]
  patch=original.crop((600,top,600+n,top+39))
  original.paste(patch,(0,top))
 OUT.mkdir(parents=True,exist_ok=True); QA.mkdir(parents=True,exist_ok=True)
 entries=[]
 for zone in range(3):
  for variant in range(9):
   wall,room,box,scale=render(original,zone,variant)
   path=OUT/f'z{zone}_panel_{variant}.png'
   wall.save(path,optimize=True)
   a=np.asarray(wall.getchannel('A'))
   entries.append({
    'zone':zone,'variant':variant,'room':ROOMS[room],
    'source_rect':list(box),'scale':round(scale,6),
    'sha256':sha(path),'transparent_pixels':int((a<128).sum()),
    'size':[W,H]})
 if len(set(x['sha256'] for x in entries))!=27:
  raise AssertionError('Panels repeat exactly')
 if {x['room'] for x in entries}!=set(ROOMS):
  raise AssertionError('Missing school room type')
 if sum(x['transparent_pixels']>1000 for x in entries)<15:
  raise AssertionError('Too few exterior-moving window panels')
 manifest={'source':'EXACT uploaded reference, no protagonists',
    'master_sha256':sha(SRC),'panel_size':[W,H],
    'windows':'RGBA < 128, far .30 / mid .56 behind glass',
    'parallax_speeds':[.30,.56,1.0],
    'status':'candidate, Flutter and device inspection required',
    'panels':entries}
 (QA/'SCHOOL_HIFI_MANIFEST.json').write_text(
  json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 print('27 reference-accurate school tiles, five room types, 23 glass panels')

if __name__=='__main__': main()
