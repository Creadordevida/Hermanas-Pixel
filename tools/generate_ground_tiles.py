#!/usr/bin/env python3
"""Extract real pavement, turf and parquet into horizontally repeating world tiles.
Tile imagery is cropped from the accepted stage art, never procedurally redrawn.
Preserves all approved originals unchanged. Pixel edges are checked for seams.
"""
from PIL import Image
from pathlib import Path
import numpy as np,json,hashlib
ROOT=Path(__file__).resolve().parents[1]
A=ROOT/'assets/images';OUT=A/'ground';OUT.mkdir(exist_ok=True)
SOURCES=['level_pixel.png','level_ayuntamiento.png','level_estafeta.png','level_plaza_castillo.png','scenes/football.png','scenes/ballet_refined.png','scenes/school.png']
LINES=[380,390,390,390,386,286,278]
# Body feet remain fixed at world y=390; art rows 390-480 show the contact
# surface and front edge while sky/building scenery may parallax independently.
# For stone keep the exact same source approved for each chapter.
def loop_tile(src,horizon):
    ar=np.asarray(src.convert('RGB'),dtype=np.float32)
    floor=ar[horizon:,:,:]
    size=540
    # Find a low-discontinuity tile boundary in the approved art, subject to
    # full source coverage and near-regular paving pattern.
    best=(float('inf'),0)
    step=2
    for start in range(0,ar.shape[1]-size,step):
        left=floor[:,start,:];right=floor[:,start+size-1,:]
        mismatch=float(np.mean(np.abs(left-right)))
        if mismatch<best[0]:best=(mismatch,start)
    start=best[1]
    tile=floor[:,start:start+size,:].copy()
    # Only the closest 12px to the seam are feathered to avoid a hard mortar
    # line; the vast majority of each original texture remains pixel-exact.
    blend=13
    common=(tile[:,0]+tile[:,-1])*.5
    for d in range(blend):
        w=(1-d/(blend-1))**2
        tile[:,d]=tile[:,d]*(1-w)+common*w
        tile[:,-1-d]=tile[:,-1-d]*(1-w)+common*w
    tile=np.uint8(np.clip(tile,0,255))
    return Image.fromarray(tile,'RGB'),best

manifest={}
for i,(source,horizon) in enumerate(zip(SOURCES,LINES)):
    src=Image.open(A/source)
    assert src.size==(1320,480)
    tile,match=loop_tile(src,horizon)
    path=OUT/f'stage_{i}.png';tile.save(path)
    aa=np.asarray(tile).astype(np.int16)
    side=float(np.abs(aa[:,0]-aa[:,-1]).mean())
    assert side<.001,(i,side)
    manifest[str(i)]={'source':source,'source_floor_row':horizon,'width':tile.width,
       'edge_mae':side,'raw_edge_mismatch':round(match[0],2),'source_offset_x':match[1],
       'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
(ROOT/'qa/GROUND_TILES_MANIFEST.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2))
print('Built native-pixel looping world-floor tiles:',len(manifest))
