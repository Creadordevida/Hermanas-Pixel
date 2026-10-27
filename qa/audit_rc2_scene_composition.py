"""RC2 final sector audit: generated PNGs are diagnostic, NEVER Flutter renders.

The original artwork is kept byte-for-byte. No claimed art approval: the 230px
spatial seam must be observed in the real running game on Android.
"""
import hashlib
import json
import re
from pathlib import Path
from collections import Counter
import numpy as np
from PIL import Image

ROOT=Path(__file__).resolve().parents[1]
ENGINE=(ROOT/'lib/neighborhood_scene_engine.dart').read_text()
ASSETS=ROOT/'assets/images/chapter1'
FOUR=('residential_curve','green_promenade','white_canopy','rocket_park')
SCENE_HEIGHT={'residential_curve':690,'green_promenade':690,'white_canopy':690,
'rocket_park':690,'connector_residential_greenway_v091':530,
'connector_neutral_park_v091':530,'connector_pergola_v091':490}


def authored_panels():
    """Parse the actual region manifest that constructs runtime backdrop panels."""
    pattern=r"id: '([^']+)', asset: '([^']+)',\s*start: (\d+), end: (\d+)"
    found=re.findall(pattern,ENGINE)
    return [(asset,float(start),float(end),asset in FOUR) for _,asset,start,end in found]


def source_view(asset, world_x, start, end, vw=800, vh=380):
    im=Image.open(ASSETS/f'{asset}.png').convert('RGB')
    sh=SCENE_HEIGHT[asset];sw=vw*sh/vh
    assert sw<=im.width,(asset,sw,im.width)
    t=max(0,min(1,(world_x-start)/max(1,end-start-vw)))
    left=(im.width-sw)*t
    return im.crop((int(left),0,int(left+sw),sh)).resize((vw,vh),Image.Resampling.BILINEAR)


def join_sample(left,right, boundary, vw=800, vh=380, half=48):
    """Simulate a join at camera positioned with the seam mid-screen."""
    cam=boundary-vw/2
    a=source_view(left[0],cam,left[1],left[2]);b=source_view(right[0],cam,right[1],right[2])
    arr=np.asarray(a).astype(np.float32).copy()
    rr=np.asarray(b).astype(np.float32)
    cut=vw//2
    xx=np.arange(vw,dtype=np.float32)
    w=np.clip((xx-(cut-half))/(2*half),0,1)[None,:,None]
    arr=arr*(1-w)+rr*w
    return Image.fromarray(np.uint8(np.clip(arr,0,255)))


def audit():
    panels=authored_panels()
    assert panels and panels[0][1]==0 and panels[-1][2]==36500
    assert all(left[2]==right[1] for left,right in zip(panels,panels[1:]))
    counts=Counter(x[0] for x in panels)
    assert len(panels)==len(counts)==7
    records=[]
    sample_dir=ROOT/'qa/rc2_simulated_seams'
    sample_dir.mkdir(parents=True,exist_ok=True)
    for i,(a,b) in enumerate(zip(panels,panels[1:]),start=1):
        image=join_sample(a,b,a[2]);path=sample_dir/f'union_{i:02}.png';image.save(path)
        array=np.asarray(image).astype(np.float32)
        differences=np.abs(array[:,1:,:]-array[:,:-1,:]).mean(axis=(0,2))
        records.append({'world_x':int(a[2]),'from':a[0],'to':b[0],
                        'simulated_render':str(path.relative_to(ROOT)),
                        'peak_horizontal_pixel_delta':round(float(differences.max()),1),
                        'mean_horizontal_pixel_delta':round(float(differences.mean()),1)})
    return {'type':'PIL simulation of image joins, NOT real Flutter frame',
      'authored_regions':len(panels),'unique_region_artworks':len(counts),
      'connector_repetitions':{k:c for k,c in counts.items() if k not in FOUR},
      'original_sha256':{name:hashlib.sha256((ASSETS/f'{name}.png').read_bytes()).hexdigest() for name in FOUR},
      'seam_width_world_pixels':96,'seams':records,
      'quality_status':'PENDING Flutter captures, motion inspection, Android device QA'}

if __name__=='__main__':
 data=audit();dest=ROOT/'qa/RC2_SCENE_AUDIT_FINAL.json'
 dest.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
 print('RC2 regions',data['authored_regions'],'distinct',data['unique_region_artworks'],
       'seams',len(data['seams']),'ARTISTIC PASS: NOT CLAIMED')
