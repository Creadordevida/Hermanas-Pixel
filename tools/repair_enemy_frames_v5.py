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

# Referee complete illustrated poses are now committed. Never reconstruct them
# from obsolete coordinate patches or erase their uniform.
print("Recovered novice and breakdancer; preserved complete referee poses.")
