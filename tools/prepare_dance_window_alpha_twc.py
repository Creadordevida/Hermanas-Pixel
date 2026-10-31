#!/usr/bin/env python3
"""Alpha-only panes for approved dance art. NEVER alters original PNGs or RGB."""
from pathlib import Path
from PIL import Image
import hashlib

ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'assets/images/interiors_parallax/dance/hifi'
OUT=ROOT/'assets/images/interiors_parallax/dance/hifi_glass'
BOXES={
 '01_recepcion.png':[(95,70,205,240)],
 '02_estudio.png':[(50,60,240,238),(365,65,701,240)],
 '03_escenario.png':[(0,40,90,233)],
 '04_pasillo.png':[(0,45,100,280),(1050,40,1168,280)],
 '05_vestuario.png':[(745,35,925,270)],
}

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    for name,boxes in BOXES.items():
        original=Image.open(SRC/name).convert('RGB')
        output=original.convert('RGBA')
        source=original.load()
        pixels=output.load()
        hits=0
        for x0,y0,x1,y1 in boxes:
            for y in range(max(0,y0),min(original.height,y1)):
                for x in range(max(0,x0),min(original.width,x1)):
                    r,g,b=source[x,y]
                    # Only light blue sky between existing real frames;
                    # dark wood, mirror borders, signs and foliage remain opaque.
                    if b>r+15 and g>r+12 and b>g+3 and b>145 and r>85:
                        pixels[x,y]=(r,g,b,166)
                        hits+=1
        destination=OUT/name
        output.save(destination)
        check=Image.open(destination).convert('RGBA')
        assert check.size==original.size
        assert check.convert('RGB').tobytes()==original.tobytes(),name
        assert all(a in (166,255) for a in check.getchannel('A').getdata()),name
        print('DANCE_GLASS_RGB_IDENTICAL',name,'alpha_pixels',hits,
            'original_sha256',hashlib.sha256((SRC/name).read_bytes()).hexdigest())
    print('5 APPROVED DANCE PNGs preserved exactly; runtime copies differ only in alpha')

if __name__=='__main__':
    main()
