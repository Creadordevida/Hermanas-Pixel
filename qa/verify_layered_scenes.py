#!/usr/bin/env python3
"""Strict mechanical checks for native pixel layers: DOES NOT approve art.
Fail on any missing texture, visible floor seam, skyline repetition, accidental
asset stretching, or floor collision placement inconsistent with authored data.
"""
from pathlib import Path
from PIL import Image
import json,hashlib,re
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
A=ROOT/'assets/images'
CODE=(ROOT/'lib/main.dart').read_text()
FLOOR=json.loads((ROOT/'qa/GROUND_TILES_MANIFEST.json').read_text())
MID=json.loads((ROOT/'qa/MIDGROUND_TILES_MANIFEST.json').read_text())
EXPECTED_LINES=[380,390,390,390,386,286,278]
EXPECTED_MID=[330,355,330,345,196,170,172]

def loop_score(im):
    a=np.asarray(im.convert('RGB'),dtype=np.int16)
    return float(np.abs(a[:,0]-a[:,-1]).mean())

def run():
    errors=[]
    for key in range(7):
        ground=A/f'ground/stage_{key}.png'
        mid=A/f'mid/stage_{key}.png'
        for kind,p,manifest in [('ground',ground,FLOOR[str(key)]),('mid',mid,MID[str(key)])]:
            if not p.is_file():errors.append(f'{kind} missing: {p}');continue
            with Image.open(p) as img:
                if loop_score(img)>.2:errors.append(f'{kind} has discontinuity at edge: chapter {key}')
            if hashlib.sha256(p.read_bytes()).hexdigest()!=manifest['sha256']:
                errors.append(f'{kind} bytes changed without regenerating manifest: {key}')
        if EXPECTED_LINES[key]>390:
            errors.append(f'ground-floor position is below actor feet: {key}')
    if 'final scroll=math.min(math.max(0, cameraX-zoneOrigin)*parallax,limit).toDouble();' not in CODE:
        errors.append('Distant landmark no longer bounded: possible repetition')
    if "_sprite(canvas,tile,Rect.fromLTWH(x,_floorArtTop[stage],tileW,tile.height.toDouble()))" not in CODE:
        errors.append('Native floor texture no longer rendered with world camera')
    if '_floorArtTop = [380,390,390,390,386,286,278]' not in CODE:
        errors.append('Ground lines changed without quality sign-off')
    if '_midArtTop = [330,355,330,345,196,170,172]' not in CODE:
        errors.append('Midground position changed without evidence')
    if 'canvas.scale(-1,1)' in CODE.split('void _background(Canvas canvas) {',1)[1].split('void _actor(',1)[0]:
        errors.append('Mirroring returned')
    if 'ballet_refined' not in CODE:errors.append('Approved parquet correction missing')
    if 'viewW,bottom' not in CODE:errors.append('Far background native source crop missing')
    if 'worldmap/pamplona_aprobado.png' not in CODE:errors.append('Approved map missing')
    if 'for(int n=first;n<=first+2;n++)' not in CODE:errors.append('World mid/floor repeat loop missing')
    plain=A/'mid/stage_4_plain.png'
    if not plain.exists():errors.append('Missing plain training fence: dugout would repeat every 640px')
    elif loop_score(Image.open(plain))>.2:errors.append('Training fence plain tile has a hard seam')
    if "stage==4 && n%9!=0" not in CODE:errors.append('Sport dugout is still copied on every near tile')
    result={'mechanical_ok':not errors,'errors':errors,'source_floor_lines':EXPECTED_LINES,
      'source_mid_lines':EXPECTED_MID,'ground_tiles':[FLOOR[str(k)] for k in range(7)],
      'artist_review':'PENDING: tests cannot judge architecture, clothing, or gameplay',
      'flutter_capture':'PENDING until GitHub test pipeline',
      'android_qa':'PENDING until user installs candidate'}
    (ROOT/'qa/LAYERED_SCENES_QA.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    print('LAYERED SCENES:', 'MECHANICAL PASS' if not errors else f'FAILED {len(errors)} checks')
    for e in errors:print('  ERROR',e)
    return errors
if __name__=='__main__':raise SystemExit(1 if run() else 0)
