"""Fail closed AFTER Flutter has captured the genuine football/dance scenes.

These image comparisons are never passed off as artistic approval.
"""
from pathlib import Path
from PIL import Image
import numpy as np

ROOT=Path(__file__).resolve().parents[1]
RENDER=ROOT/'qa/rendered_from_flutter'
TERMS=['zona_entrada','zona_central','zona_final',
       'union_1_antes','union_1_despues','union_2_antes','union_2_despues']

def image(name):
    file=RENDER/f'{name}.png'
    if not file.is_file():
        raise RuntimeError(f'Falta captura REAL Flutter: {file.name}')
    with Image.open(file) as im:
        if im.size!=(800,450):
            raise RuntimeError(f'Captura {file.name} debe medir 800x450, mide {im.size}')
        return np.asarray(im.convert('RGB'),dtype=np.int16)

for chapter in ('futbol','danza'):
    screenshots={term:image(f'{chapter}_{term}') for term in TERMS}
    # The scene itself differs: ignore foreground floor and HUD overlay.
    scenic_height=310 if chapter=='futbol' else 245
    zone_images=[screenshots[f'zona_{key}'][:scenic_height]
                 for key in ('entrada','central','final')]
    for label,frame in zip(('entrada','central','final'),zone_images):
        colors=np.unique((frame[::7,::7]//16).reshape(-1,3),axis=0)
        if len(colors)<110:
            raise RuntimeError(f'{chapter}/{label}: fondo plano o vacío ({len(colors)} tonos)')
    for i in range(2):
        difference=float(np.abs(zone_images[i]-zone_images[i+1]).mean())
        if difference<7:
            raise RuntimeError(f'{chapter}: zonas {i} y {i+1} prácticamente idénticas ({difference:.2f})')
    for seam in (1,2):
        before=screenshots[f'union_{seam}_antes'][:scenic_height]
        after=screenshots[f'union_{seam}_despues'][:scenic_height]
        difference=float(np.abs(before-after).mean())
        if difference>92:
            raise RuntimeError(f'{chapter}: corte gráfico extremo en unión {seam} ({difference:.2f})')
    print(f'{chapter}: 7 capturas Flutter presentes, zonas distinguibles; revisión humana pendiente')

print('14 capturas del motor Flutter validadas mecánicamente. NO aprobación visual.')
