#!/usr/bin/env python3
"""Build the actual playable ballet-background PNG using approved source art.
The parquet is sampled from the approved in-game enemy artwork, not synthesized
as a flat polygon and not enlarged from a generic pattern.
"""
from pathlib import Path
from PIL import Image, ImageEnhance
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
BASE=ROOT/'assets/images/scenes/ballet.png'
REF=ROOT/'reference/approved_ballet_enemy_scene.png'
OUT=ROOT/'assets/images/scenes/ballet_refined.png'

def make_seamless(tile,feather=34):
    # feather only overlaps existing high-resolution wood source pixels
    ar=np.asarray(tile.convert('RGB'),dtype=np.float32)
    h,w,_=ar.shape
    for x in range(feather):
        mix=x/(feather-1) if feather>1 else 0
        left=ar[:,x].copy();right=ar[:,w-feather+x].copy()
        avg=left*(1-mix)+right*mix
        ar[:,x]=avg;ar[:,w-feather+x]=avg
    return Image.fromarray(np.clip(ar,0,255).astype('uint8'),'RGB')

def rebuild():
    src=Image.open(BASE).convert('RGBA')
    ref=Image.open(REF).convert('RGB')
    assert src.size==(1320,480) and ref.size==(1290,726)
    # Unobstructed polished horizontal parquet from an approved ballet screenshot.
    wood=ref.crop((745,555,995,710))
    wood=make_seamless(wood,24)
    result=src.copy()
    floor_line=286
    # Original walls, barres, mirrors and foliage are untouched. Replace only
    # the fake vertical-board lower region with horizontal polished parquet.
    tile_h=wood.height;tile_w=wood.width
    floor=Image.new('RGB',(src.width,src.height-floor_line))
    for y in range(0,floor.height,tile_h):
        for x in range(0,floor.width,tile_w):
            floor.paste(wood,(x,y))
    # Apply a gentle stage-lighting falloff using the approved wood texture.
    pixels=np.asarray(floor,dtype=np.float32)
    ys=np.arange(floor.height,dtype=np.float32)
    # Subtle floor depth darkening; no geometrical scaling of wall or character.
    depth=(1-.055*(ys/floor.height))[:,None,None]
    pixels=np.uint8(np.clip(pixels*depth,0,255))
    floor=Image.fromarray(pixels,'RGB')
    result.paste(floor,(0,floor_line))
    # Four-pixel baseboard preserves hard 16-bit boundaries and communicates ground.
    from PIL import ImageDraw
    d=ImageDraw.Draw(result)
    d.rectangle((0,floor_line,src.width-1,floor_line+2), fill=(95,51,25,255))
    d.line((0,floor_line+3,src.width-1,floor_line+3),fill=(198,126,66,255),width=1)
    result.save(OUT)
    print('Created playable parquet with wall alignment:',OUT,OUT.stat().st_size)
if __name__=='__main__':rebuild()
