"""Measurable background regression checks for the RC4 three-plane renderer.
Does not pretend to judge artistic coherence. Original assets are frozen.
No photograph is substituted for a real Flutter screenshot.
"""
from pathlib import Path
import json,hashlib,sys
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
MAIN=(ROOT/'lib/main.dart').read_text()
BASE=ROOT/'assets/images'
MAP=BASE/'worldmap/pamplona_aprobado.png'
EXACT_SHA='0bb7bf217d14fdd98ecc436e873748c892afc644f66b103132d36498dc99b030'

def mirror_detect(text):
    part=text.split('void _background(Canvas canvas) {',1)[1].split('void _actor(',1)[0]
    return ('canvas.scale(-1' in part or 'n.isOdd' in part or 'tileWorldWidth = 1570' in part)

def stretch_detect(text):
    part=text.split('void _background(Canvas canvas) {',1)[1].split('void _actor(',1)[0]
    return 'tileWorldWidth' in part or 'Rect.fromLTWH(dx, 0, tileWorldWidth' in part

def seam_score(path):
    p=np.asarray(Image.open(path).convert('RGB'),dtype=np.float32)
    return float(np.abs(p[:,0]-p[:,-1]).mean())

def run():
    assert MAP.exists(),'Missing approved map'
    assert hashlib.sha256(MAP.read_bytes()).hexdigest()==EXACT_SHA,'Approved city map changed'
    assert not mirror_detect(MAIN),'Mirroring introduced in landscape rendering'
    assert not stretch_detect(MAIN),'Unapproved world stretching'
    assert 'mapHitboxesOriginal' in MAIN,'Approved map not clickable'
    assert '_floorArtTop' in MAIN and '_midArtTop' in MAIN,'Three-plane scene missing'
    assert 'final scroll=math.min(math.max(0, cameraX-zoneOrigin)*parallax,limit).toDouble();' in MAIN,'Landscape can repeat'
    assert 'final tile=images[\'ground_$stage\'];' in MAIN,'Shared world floor missing'
    # The RC3 panoramas do NOT need compatible first/last columns any longer:
    # they are drawn as bounded landscapes once, not infinitely wallpapered.
    former=[BASE/f for f in [
      'level_pixel.png','level_ayuntamiento.png','level_estafeta.png','level_plaza_castillo.png',
      'scenes/football.png','scenes/ballet.png','scenes/school.png']]
    source_diffs={p.stem:round(seam_score(p),2) for p in former}
    actual_ground={f'stage_{i}':round(seam_score(BASE/f'ground/stage_{i}.png'),3) for i in range(7)}
    actual_mid={f'stage_{i}':round(seam_score(BASE/f'mid/stage_{i}.png'),3) for i in range(7)}
    assert all(v<.2 for v in actual_ground.values()),'World floor seam visible'
    assert all(v<.2 for v in actual_mid.values()),'Midground seam visible'
    report={'approved_map_sha256':EXACT_SHA,'no_horizontal_mirroring':True,
      'no_world_stretch':True,'bounded_landmark_background':True,
      'native_world_ground_tiles':actual_ground,'native_world_midground_tiles':actual_mid,
      'legacy_original_edge_differences_NOT_USED_AS_TILES':source_diffs,
      'artist_review':'PENDING: tile repetition, garment naturalness and all enemy poses need human QA',
      'android_execution':'PENDING: Flutter not installed in author environment'}
    (ROOT/'qa/SCENE_SEAMS_REPORT.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    print('Layered scenery technical checks PASS (NOT artistic approval)')
    return report
if __name__=='__main__':run()
