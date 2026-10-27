"""Physical-frame comparison: nonmoving panoramas cannot pass silently.

Does NOT claim SNES-quality artistic acceptance. It uses only screenshots
captured by the real Flutter StagePainter under controlled camera positions.
"""
from pathlib import Path
from PIL import Image
import numpy as np

RENDER=Path(__file__).resolve().parent/'rendered_from_flutter'

def pixels(name):
    file=RENDER/f'{name}.png'
    if not file.is_file():
        raise SystemExit(f'Falta captura real Flutter de cámara: {file.name}')
    with Image.open(file) as im:
        if im.size != (800,450):
            raise SystemExit(f'Dimensiones incoherentes: {name} {im.size}')
        return np.asarray(im.convert('RGB'),dtype=np.int16)

for baseline in ['barrio_residencial','barrio_paseo']:
    a,b=(pixels(baseline),pixels(baseline+'_avance'))
    # Ignore HUD top, ground below y=380, sprites and buttons below y=370.
    diff=float(np.abs(a[55:305]-b[55:305]).mean())
    if diff < 9:
        raise SystemExit(f'FONDO CASI FIJO: {baseline}, diferencia {diff:.2f}.')
    print(f'CAMERA_MOTION real {baseline}: diferencia={diff:.2f} (umbral 9)')
print('Movimiento de fondos detectado en capturas reales; sin aprobación artística.')
