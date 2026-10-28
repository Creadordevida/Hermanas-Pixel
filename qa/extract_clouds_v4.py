"""Convierte arte nuevo de cielo en sprites aislados (recortes + máscara).
Mantiene intactos todos los originales aprobados. No 'arregla' fachadas.
"""
from PIL import Image
from pathlib import Path
import numpy as np
SOURCE=Path(__file__).resolve().parents[1]/'assets/images/chapter1/connector_candidate_draft_v4_NOT_APPROVED.png'
OUT=Path(__file__).resolve().parents[1]/'assets/images/chapter1/clouds_v4_experimental.png'
im=np.asarray(Image.open(SOURCE).convert('RGB'))
result=Image.new('RGBA',(1024,220))
for left,top,right,bottom,dx,dy in [(550,15,1030,185,8,4),(1190,15,1660,185,530,4)]:
    arr=im[top:bottom,left:right].copy()
    # El fondo azul tiene R bajo, la nube pixelada tiene R alto.
    # Mantener rampas parciales para borde sin halo duro.
    R=arr[:,:,0].astype('float32')
    B=arr[:,:,2].astype('float32')
    alpha=np.clip((R-100)/110*255,0,255).astype('uint8')
    # La parte muy saturada suele ser azul del cielo, no nube.
    alpha=np.where((B-R)>95,(alpha*.23).astype('uint8'),alpha)
    rgba=np.concatenate([arr,alpha[:,:,None]],axis=2)
    result.alpha_composite(Image.fromarray(rgba,'RGBA'),(dx,dy))
result.save(OUT)
print(OUT,OUT.stat().st_size)
