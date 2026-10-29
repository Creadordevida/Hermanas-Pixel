#!/usr/bin/env python3
"""Extract the precise visible bounding box for every ENEMY sprite pose.
This doesn't fix missing body parts in source art. It avoids position jumps
caused by different canvas padding in each frame and retains natural scale.
"""
from pathlib import Path
from PIL import Image
import json,hashlib
ROOT=Path(__file__).resolve().parents[1]
ASSETS=ROOT/'assets/images/enemies'
TARGET=ROOT/'lib/sprite_bounds.g.dart'
REPORT=ROOT/'qa/ENEMY_VISIBLE_BOUNDS.json'
characters=['goalkeeper','rival','referee','novice','breakdancer','pigeon','cat','rat','bully','teacher','statue']
all_data={}
for character in characters:
 # Referee and breakdancer have authentic sixth 'hit' illustrations.
 for frame in range(6 if character in ('referee','breakdancer') else 5):
  file=ASSETS/f'{character}_{frame}.png'
  with Image.open(file) as im:
   im=im.convert('RGBA')
   box=im.getchannel('A').getbbox()
   if box is None:raise ValueError('Empty pose: '+str(file))
   x0,y0,x1,y1=box
   key=f'{character}_{frame}'
   if key in all_data: raise ValueError(f'Duplicate sprite key during export: {key}')
   all_data[key]={
     'bounds':[x0,y0,x1-x0,y1-y0],
     'image_size':list(im.size),'sha256':hashlib.sha256(file.read_bytes()).hexdigest(),
     'canvas_edge_touch':bool(x0==0 or y0==0 or x1==im.width or y1==im.height),
   }
lines=["// Generated from the REAL PNG alpha channels by tools/export_sprite_bounds.py.",
       "// Never hand-edit: QA checks SHA256 of every source frame.",
       "import 'dart:ui';", "const Map<String, Rect> enemyVisibleBounds = {"]
for key, entry in all_data.items():
 a,b,c,d=entry['bounds']
 lines.append(f"  '{key}': Rect.fromLTWH({float(a):.1f}, {float(b):.1f}, {float(c):.1f}, {float(d):.1f}),")
lines.append('};')
TARGET.write_text('\n'.join(lines)+'\n')
REPORT.write_text(json.dumps(all_data,indent=2,ensure_ascii=False)+'\n')
print('Exported',len(all_data),'exact visible pose rectangles; cropped-at-edge warnings:',sum(v['canvas_edge_touch'] for v in all_data.values()))
