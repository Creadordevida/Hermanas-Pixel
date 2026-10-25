#!/usr/bin/env python3
"""Prepare near parallax layers from ACTUAL approved scenery.
Pixel scale = 1:1. No mirror, flat artificial wall, or stretched image.
Tiles contain fences/barres/bushes/lockers, not city landmarks or cars.
"""
from pathlib import Path
from PIL import Image
import numpy as np,hashlib,json
R=Path(__file__).resolve().parents[1];A=R/'assets/images';O=A/'mid';O.mkdir(exist_ok=True)
# Source and safe horizontal crop, upper edge of near layer, ground texture line
CONFIG={
 0:('level_pixel.png',310,950,330,380),
 1:('level_pixel.png',310,950,355,390), # town hall not repeated
 2:('level_estafeta.png',260,900,330,390),
 3:('level_pixel.png',310,950,345,390), # plaza landmark once in far distance
 4:('scenes/football.png',205,845,196,386),
 5:('scenes/ballet_refined.png',280,920,170,286),
 6:('scenes/school.png',280,920,172,278),
}
manifest={}
for stage,(file,l,r,start,bottom) in CONFIG.items():
  src=Image.open(A/file).convert('RGB')
  img=np.asarray(src)[start:bottom,l:r,:].astype('float32')
  assert img.shape[1]==640
  h,w,_=img.shape
  # Repeatable edge: feather ONLY the first/last 10 pixels (asset artwork
  # in-between is byte-identical to the approved scene).
  half=(img[:,0,:]+img[:,-1,:])/2
  feather=14
  for d in range(feather):
    weight=(1-d/(feather-1))**2
    img[:,d,:]=img[:,d,:]*(1-weight)+half*weight
    img[:,-1-d,:]=img[:,-1-d,:]*(1-weight)+half*weight
  out=np.zeros((h,w,4),dtype='uint8')
  out[:,:,:3]=np.uint8(np.clip(img,0,255))
  # Transparent top fringe blends perspective smoothly over the scenery.
  for y in range(h):
    out[y,:,3]=min(255,int(255*y/22))
  image=Image.fromarray(out,'RGBA')
  path=O/f'stage_{stage}.png';image.save(path)
  manifest[str(stage)]={'file':str(path.relative_to(A)),'source':file,'source_crop':[l,start,r,bottom],
     'y_start':start,'y_end':bottom,'width':w,'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),
     'edge_mae':float(np.mean(np.abs(out[:,0,:3].astype('float32')-out[:,-1,:3].astype('float32'))))}
  assert manifest[str(stage)]['edge_mae']<=.01
# The classroom and computer room use their own detailed midground art.
for phase, file in [('classroom','scenes/school_classroom.png'),('computers','scenes/school_computers.png')]:
  source=np.asarray(Image.open(A/file).convert('RGB'))
  img=source[172:278,280:920,:].astype('float32')
  common=(img[:,0,:]+img[:,-1,:])/2
  for d in range(14):
    w=(1-d/13)**2
    img[:,d]=img[:,d]*(1-w)+common*w
    img[:,-1-d]=img[:,-1-d]*(1-w)+common*w
  out=np.zeros((106,640,4),dtype='uint8')
  out[:,:,:3]=np.uint8(np.clip(img,0,255))
  for y in range(106):out[y,:,3]=min(255,int(255*y/22))
  path=O/f'school_{phase}.png';Image.fromarray(out,'RGBA').save(path)
  manifest['school_'+phase]={'file':str(path.relative_to(A)),'source':file,'source_crop':[280,172,920,278],
                            'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
(R/'qa/MIDGROUND_TILES_MANIFEST.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False))
print('Prepared',len(manifest),'high-detail reusable midground layers')
