#!/usr/bin/env python3
"""Comprobaciones técnicas del atlas REAL generado; NO son aprobación artística.

La revisión artística necesita capturas del juego ejecutándose en Flutter.
"""
from pathlib import Path
from PIL import Image
import sys

root=Path(__file__).resolve().parents[1]
folder=root/"assets/images/enemies_new"
required={
 "robot":(144,192),
 "supporter":(144,192),
 "tourist":(144,192),
 "navarre_king":(168,216),
 "estafeta_bull":(270,192),
 "sanfermin_runner":(156,210),
}
problems=[]
for kind,(w,h) in required.items():
 p=folder/f"{kind}_atlas.png"
 if not p.exists():
  problems.append(f"{kind}: archivo no generado")
  continue
 im=Image.open(p).convert("RGBA")
 if im.size!=(w*4,h*6):
  problems.append(f"{kind}: dimensiones {im.size}, esperadas {(w*4,h*6)}")
  continue
 fingerprints=[]
 for row in range(6):
  poses=[]
  for col in range(4):
   frame=im.crop((col*w,row*h,(col+1)*w,(row+1)*h))
   bbox=frame.getchannel("A").getbbox()
   if bbox is None:
    problems.append(f"{kind}: fotograma vacío en fila {row}, columna {col}")
   elif bbox[3] < h*.35:
    problems.append(f"{kind}: silueta excesivamente baja en {row}/{col}")
   poses.append(frame.tobytes())
  fingerprints.append(poses)
 if len(set(v[0] for v in fingerprints))<4:
  problems.append(f"{kind}: faltan poses gráficas diferenciadas")
 moving=[1,2,3,4]
 if sum(len(set(fingerprints[row]))>1 for row in moving)<2:
  problems.append(f"{kind}: los fotogramas animados son idénticos")
 print(f"{kind}: atlas inspeccionado {im.size} (sólo geometría y variación)")
if problems:
 print("\n".join("ERROR: "+x for x in problems),file=sys.stderr)
 raise SystemExit(1)
print("PASS técnico: la calidad artística visual y la escena REAL siguen PENDIENTES")
