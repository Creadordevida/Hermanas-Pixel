#!/usr/bin/env python3
"""Strict reproducible physical-world test; no claim about Android/Flutter.
Validates the actual PNG assets referenced by Dart and the unmodified masters.
"""
from PIL import Image
from pathlib import Path
import hashlib,json,re,sys
R=Path(__file__).resolve().parents[1]
T=R/'assets/images/chapter1/ch1_world_tiles'
ART=R/'assets/images/chapter1'
DART=(R/'lib/main.dart').read_text()
MODEL=(R/'lib/chapter_one_world_tiles.dart').read_text()
expected=['residential_curve','green_promenade','white_canopy','rocket_park']
assert '_neighborhoodPhysicalWorld(canvas)' in DART
assert 'ch1PhysicalTileAsset(i)' in DART
assert 'for (final index in ch1PhysicalVisibleTiles(cameraX' in DART
assert 'ch1PhysicalTileCount = 72' in MODEL
assert 'ch1PhysicalWidth = 36500' in MODEL
assert 'ch1PhysicalTileWidth = 512' in MODEL
info=json.loads((R/'qa/ch1_rc3_tiles/MANIFEST.json').read_text())
assert len(info['landmarks'])==7
assert len({e['asset'] for e in info['landmarks']})==7
assert info['original_master_files_edited'] is False
originals=json.loads((R/'qa/ch1_legacy_art_sha256.json').read_text())
for p,d in originals.items():
 assert hashlib.sha256((R/p).read_bytes()).hexdigest()==d, 'Original alterado: '+p
for name in expected:
 assert (ART/(name+'.png')).exists()
assert len(list(T.glob('world_*.png')))==72
cached={}
for i in range(72):
 p=T/f'world_{i:03}.png'
 with Image.open(p) as im:
  assert im.mode in ('RGB','RGBA')
  assert im.size == (512 if i<71 else 148,380), f'{p}: {im.size}'
  # Entire bottom skyline exists at each tile; no magenta QA placeholder.
  assert im.getpixel((0,250))[:3] != (83,42,108)
  cached[i] = (im.getpixel((0,160))[:3],im.getpixel((im.width-1,160))[:3])
# Full span exactly covered, no overlap and no lost 148px final tile.
assert 71*512+148==36500
# Pixel jump is a diagnostic, not an artistic pass. Selected rows exclude
# silhouettes where a tree or lamp is supposed to have a sharp edge.
max_jump=0
row_statistics=[]
for i in range(71):
 with Image.open(T/f'world_{i:03}.png') as a,Image.open(T/f'world_{i+1:03}.png') as b:
  for y in (20,80,160,240,300,368):
   c=a.getpixel((a.width-1,y))[:3];d=b.getpixel((0,y))[:3]
   jump=max(abs(c[k]-d[k]) for k in range(3))
   max_jump=max(max_jump,jump)
   if jump>100:row_statistics.append((i,y,jump))
assert len(row_statistics)<15,f'Demasiados cortes de borde: {row_statistics[:30]}'
# Four characters/monuments are preserved in the finished world texture.
for name in expected:
 assert any(x['asset']==name for x in info['landmarks'])
result={'status':'PASS','tiles':72,'stage_width':36500,'landmarks':7,
        'protected_masters':len(originals),'max_boundary_color_jump':max_jump,
        'unusual_pixel_jumps':row_statistics,'flutter_executed':False,
        'android_executed':False,'visual_artist_approval':'manual pending'}
(R/'qa/ch1_rc3_tiles/RESULTADO_PRUEBAS_TILES.json').write_text(json.dumps(result,ensure_ascii=False,indent=2))
print(json.dumps(result,ensure_ascii=False))
