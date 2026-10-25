"""Recover COMPLETE, already-approved poses from original game art.

Novice and breakdancer defeat pictures in the RC4 were cropped by extraction.
Their extra source sheets contain the complete figures. For the referee, the
black uniform merged with an earlier background and had holes; reconstruct
using the complete idle uniform, adding the existing original card arm.
"""
from PIL import Image
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1]/'assets/images/enemies'

def crop_alpha(im,pad=5):
 box=im.getchannel('A').getbbox()
 if box is None:raise ValueError('Transparent image')
 l,t,r,b=box
 target=Image.new('RGBA',(r-l+2*pad,b-t+2*pad),(0,0,0,0))
 target.alpha_composite(im.crop(box),(pad,pad))
 return target

# Complete novice seated on the ground in approved sprite-strip source.
original=Image.open(ROOT/'novice_5.png').convert('RGBA')
# Right hand seated rival has x=98..230, y~37..134; no dancer on left.
seated=crop_alpha(original.crop((97,34,232,141)),pad=7)
seated.save(ROOT/'novice_4.png')
# Complete crouching breakdancer in existing source (same exact design).
full=Image.open(ROOT/'breakdancer_7.png').convert('RGBA')
crop_alpha(full,pad=8).save(ROOT/'breakdancer_4.png')

# Rebuild referee frames with complete original uniform. Black-kit erasure in
# imported art affected attack frame 2 and 3, not just transparent padding.
master=Image.open(ROOT/'referee_0.png').convert('RGBA')
cardpose=Image.open(ROOT/'referee_2.png').convert('RGBA')
# Reuse the authentic red card and bent forearm, not generated geometry.
card_arm=cardpose.crop((26,0,47,47))
for idx in (2,3):
 canvas=Image.new('RGBA',(97,128),(0,0,0,0))
 # Remove original right arm hanging down: attach arm in its raised position.
 base=np.array(master).copy()
 # The rightmost arm is at x=43..50 from y=48..82 in master.
 for yy in range(44,min(88,base.shape[0])):
  for xx in range(44,base.shape[1]):
   # Remove the original hanging arm, not the torso and legs.
   if yy<84: base[yy,xx,3]=0
 canvas.alpha_composite(Image.fromarray(base,'RGBA'),(20,27))
 if idx==2:
  canvas.alpha_composite(card_arm,(56,27))
 else:
  # Slight rightward follow-through uses original card/arm, anchored to
  # shoulder; the projectile itself is drawn by the game engine.
  rotated=card_arm.rotate(-18,expand=True,resample=Image.Resampling.BICUBIC)
  canvas.alpha_composite(rotated,(57,24))
 crop_alpha(canvas,pad=5).save(ROOT/f'referee_{idx}.png')
print('Recovered original complete ballet/breakdance poses; rebuilt 2 referee actions.')
