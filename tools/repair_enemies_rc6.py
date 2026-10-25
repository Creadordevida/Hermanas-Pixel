"""Recover incomplete limbs using exact existing/source pixels. Reversible backups.
No generative replacement of enemies, no artistic sign-off implied.
"""
from PIL import Image,ImageDraw,ImageFilter
from pathlib import Path
import numpy as np, shutil
BASE=Path(__file__).resolve().parents[1]
R=BASE/'assets/images/enemies'
BACKUP=BASE/'qa/enemy_originals_rc5';BACKUP.mkdir(parents=True,exist_ok=True)
for file in R.glob('*.png'):
 b=BACKUP/file.name
 if not b.exists():shutil.copy2(file,b)

def crop_pad(img,pad=6):
 rect=img.getchannel('A').getbbox()
 if not rect: raise ValueError('empty alpha')
 cr=img.crop(rect)
 out=Image.new('RGBA',(cr.width+2*pad,cr.height+2*pad))
 out.alpha_composite(cr,(pad,pad));return out

# Soccer rival: frames 1-3 lost back foot at LEFT EDGE during sheet extraction.
# Restore only the trailing left leg from the untouched complete approved pose,
# UNDER the original motion pose; the moving frontal foot remains unchanged.
original=Image.open(BACKUP/'rival_0.png').convert('RGBA')
base_leg=original.crop((0,66,27,101))
for pose,offset,dy in [(1,18,65),(2,25,66),(3,20,65)]:
 src=Image.open(BACKUP/f'rival_{pose}.png').convert('RGBA')
 out=Image.new('RGBA',(src.width+offset+6,max(src.height,108)))
 leg=base_leg.copy()
 # slight back-leg rotation for faster running; never synthesize a new face.
 if pose==3:leg=leg.rotate(-11,Image.Resampling.NEAREST,expand=True)
 out.alpha_composite(leg,(0,dy));out.alpha_composite(src,(offset,0))
 crop_pad(out).save(R/f'rival_{pose}.png')

# Referee: restore underlying WHOLE uniform from the intact pose. Overlay only
# red-card arm from the source, not the old composited black square artifacts.
master=Image.open(BACKUP/'referee_0.png').convert('RGBA')
reference=Image.open(BACKUP/'referee_2.png').convert('RGBA')
# original raised arm and card isolated with a polygon in original sprite px
for idx in [2,3]:
 out=Image.new('RGBA',(95,122))
 out.alpha_composite(master,(12,17))
 # Arm/card from approved source: x31..64 y3..72. Polygon traces card, fist,
 # forearm, excluding the solid black rectangles at lower right of old sprite.
 arm=reference.copy()
 m=Image.new('L',arm.size);d=ImageDraw.Draw(m)
 d.polygon([(40,5),(54,5),(55,20),(55,27),(57,31),(56,37),(53,42),(51,48),(45,49),(42,43),(43,38),(44,32),(44,26),(40,24)],fill=255)
 arm.putalpha(Image.fromarray(np.minimum(np.array(arm.getchannel('A')),np.array(m)).astype('uint8'),'L'))
 out.alpha_composite(arm,(16,12 if idx==2 else 10))
 crop_pad(out).save(R/f'referee_{idx}.png')


print("Restored rival trailing leg and referee card arm.")
