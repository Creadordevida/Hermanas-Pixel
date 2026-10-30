#!/usr/bin/env python3
"""Check every asset path loaded by lib/main.dart; do NOT call this visual QA."""
import sys,hashlib,json
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
P=ROOT/'assets/images'
files=[
 'title_approved.png','brand_logo_twc.png','worldmap/pamplona_aprobado.png','scenes/ballet_refined.png',
 *[f'ground/stage_{i}.png' for i in range(7)],
 *[f'mid/stage_{i}.png' for i in range(7)],
 'mid/stage_4_plain.png',
 'mid/school_classroom.png','mid/school_computers.png',
 *[f'{k}.png' for k in ['level_pixel','level_ayuntamiento','level_estafeta','level_plaza_castillo','crate','coin','ball','comb']],
 *[f'scenes/{k}.png' for k in ['football','ballet','school','school_classroom','school_computers']],
 *[f'props/{k}.png' for k in ['cone','planter','backpack','gym_bench','red_card','shoe','eraser']],
 *[f'frames/{r}_{pose}.png' for r in ['futbolista','bailarina','padre'] for pose in ['idle_0','walk_0','walk_1','jump_0']],
 *[f'outfits/{r}_{pose}.png' for r in ['futbolista','bailarina'] for pose in ['idle_0','walk_0','walk_1','jump_0','attack_0']],
 *[f'dog/{prefix}{pose}.png' for prefix in ['', 'dalmatian/','doberman/'] for pose in ['idle','walk','alert','run','bite','hit','stunned','defeated']],
 *[f'enemies/{r}_{i}.png' for r in ['rival','referee','novice','breakdancer','pigeon','cat','rat','bully','teacher','statue'] for i in range(5)],
 'enemies/rival_5.png','enemies/referee_5.png','enemies/breakdancer_5.png',
]
errors=[];output={}
for rel in files:
 path=P/rel
 if not path.is_file():errors.append('Falta: '+rel);continue
 try:
  with Image.open(path) as im:
   if im.format!='PNG':errors.append('No es PNG: '+rel)
   if im.width<9 or im.height<9:errors.append('Dimensiones minúsculas: '+rel)
   if 'enemies/' in rel or 'outfits/' in rel:
    if im.mode!='RGBA':errors.append('Falta canal alfa: '+rel)
    if im.getbbox() is None:errors.append('Sprite vacío: '+rel)
   output[rel]={'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'size':[im.width,im.height]}
 except Exception as e:errors.append(f'PNG inválido {rel}: {e}')
# Destination is a factual INVENTORY, not proof of artistic approval.
(ROOT/'qa/CANDIDATE_ASSET_INVENTORY.json').write_text(json.dumps(output,ensure_ascii=False,indent=2)+'\n')
print(f'Inventario: {len(files)} referencias de recursos, {len(output)} válidas, {len(errors)} errores')
for err in errors:print('ERROR:',err)
raise SystemExit(1 if errors else 0)
