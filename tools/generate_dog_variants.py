#!/usr/bin/env python3
"""Recolorea SOLO la capa opaca del perro APROBADO 0.8.0 sin cambiar geometría.
   El pelaje sigue siendo el mismo modelo exacto y el alfa queda idéntico."""
from PIL import Image,ImageDraw
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1]/'assets/images/dog'
POSES=['idle','walk','alert','run','bite','hit','stunned','defeated']
for variant in ('dalmatian','doberman'):
    (ROOT/variant).mkdir(exist_ok=True)
    for pose in POSES:
        original=Image.open(ROOT/f'{pose}.png').convert('RGBA')
        p=np.asarray(original).copy().astype(np.float32)
        a=p[:,:,3]>12
        rgb=p[:,:,:3]
        r,g,b=rgb[:,:,0],rgb[:,:,1],rgb[:,:,2]
        # brown-orange pixels of fur: leaves white markings/eyes/black outlines untouched.
        brown=a & (r>g*1.31)&(r>b*1.18)&(r>45)&(g>13)
        if variant=='dalmatian':
            lum=.25*r+.58*g+.17*b
            v=np.clip(lum*.53+145,125,246)
            for ch,off in enumerate((0,0,4)):
                rgb[:,:,ch]=np.where(brown,np.clip(v+off,0,255),rgb[:,:,ch])
            # spots are cut by already recolored torso and never escape the original contour
            yy,xx=np.where(a)
            x0,x1,y0,y1=xx.min(),xx.max(),yy.min(),yy.max()
            mask=Image.new('L',original.size);d=ImageDraw.Draw(mask)
            ww=x1-x0;hh=y1-y0
            for u,v,s in [(.25,.56,.055),(.39,.65,.07),(.51,.52,.05),(.30,.75,.045),(.47,.78,.04)]:
                cx=x0+ww*u;cy=y0+hh*v;rad=max(2,round(s*ww))
                d.ellipse((cx-rad,cy-rad,cx+rad,cy+rad*1.2),fill=255)
            spots=(np.asarray(mask)>0)&brown
            for ch,target in enumerate((32,36,43)):
                rgb[:,:,ch]=np.where(spots,target,rgb[:,:,ch])
        else:
            # deep black-brown fur, retain original highlights, preserve tan muzzle/paws/eyebrows.
            lum=.31*r+.5*g+.19*b
            val=np.clip(lum*.29+18,13,105)
            for ch,scale in enumerate((1.0,1.05,1.22)):
                rgb[:,:,ch]=np.where(brown,np.clip(val*scale,0,255),rgb[:,:,ch])
            yy,xx=np.where(a);x0,x1,y0,y1=xx.min(),xx.max(),yy.min(),yy.max();w=x1-x0;h=y1-y0
            xgrid=np.arange(original.width)[None,:]
            ygrid=np.arange(original.height)[:,None]
            muzzle=(xgrid>x0+.70*w)&(ygrid>y0+.38*h)&(ygrid<y0+.69*h)
            feet=(ygrid>y0+.75*h)&(xgrid>x0+.23*w)
            tan=brown & (muzzle|feet)
            for ch,base in enumerate((151,87,42)):
                rgb[:,:,ch]=np.where(tan,np.clip(base*(.7+lum/500),0,255),rgb[:,:,ch])
        p[:,:,:3]=rgb
        p[:,:,3]=np.asarray(original)[:,:,3]
        result=Image.fromarray(np.uint8(np.clip(p,0,255)),'RGBA')
        result.save(ROOT/variant/f'{pose}.png')
        assert result.size==original.size
        assert np.array_equal(np.array(result)[:,:,3],np.array(original)[:,:,3])
print('16 variaciones a partir del perro aprobado; 16 canales alfa comprobados')
