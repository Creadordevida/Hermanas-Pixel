"""Render de LABORATORIO con assets reales: primer tramo, sin empalmes.
No pretende simular Flutter ni validar un capítulo de 36.500 px.
Una zona de arte ausente se considera ERROR, no se estira ni oculta.
"""
from PIL import Image, ImageDraw, ImageFont
from pathlib import Path
import json, math, hashlib, sys

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'qa/ch1_v3_previews'
OUT.mkdir(parents=True,exist_ok=True)
W,H=800,450
GROUND=390
ART_H=380
SOURCE_H=690
LANDMARK_W=1672*ART_H/SOURCE_H
landmark=Image.open(ROOT/'assets/images/chapter1/residential_curve.png').convert('RGB')
landmark=landmark.crop((0,0,1672,690)).resize((round(LANDMARK_W),ART_H),Image.Resampling.BICUBIC)
hero=Image.open(ROOT/'assets/images/frames/bailarina_walk_0.png').convert('RGBA')
rgba_bounds=hero.getbbox()
hero=hero.crop(rgba_bounds)
actor_h=118
hero=hero.resize((round(hero.width*actor_h/hero.height),actor_h),Image.Resampling.NEAREST)
ground=Image.open(ROOT/'assets/images/ground/stage_0.png').convert('RGB')


def draw_frame(camera_x, step=0, hero_jump=0, label=True):
    if camera_x+W>LANDMARK_W+1e-5:
        raise ValueError(f'ARTE_INCOMPLETO: cámara {camera_x}: faltan {camera_x+W-LANDMARK_W:.1f} px')
    frame=Image.new('RGB',(W,H),'#4da9ed')
    frame.paste(landmark,(-round(camera_x),0))
    # Físicas: una sola superficie y=390; suelo artístico por debajo.
    for x in range(-round(camera_x)%ground.width-ground.width,W,ground.width):
        frame.paste(ground,(x,GROUND))
    # No se duplica el suelo de la ilustración: su recorte acaba antes del pavimento.
    d=ImageDraw.Draw(frame)
    actor_screen_x=327
    d.ellipse((actor_screen_x-20,GROUND-6,actor_screen_x+20,GROUND),fill=(29,36,38))
    sprite_x=actor_screen_x-hero.width//2
    sprite_y=GROUND-actor_h-hero_jump
    frame.paste(hero,(sprite_x,sprite_y),hero)
    if label:
        d=ImageDraw.Draw(frame)
        d.rounded_rectangle((12,10,380,46),radius=5,fill=(11,29,54))
        d.text((20,16),f'LAB RC3 | camara={camera_x:0.0f} | hito anclado', fill=(241,241,242))
    return frame


def main():
    from PIL import ImageDraw
    camera_path=[i*120/30 for i in range(31)]
    frames=[draw_frame(x,i) for i,x in enumerate(camera_path)]
    for cam in [0,40,80,120]:
        draw_frame(cam).save(OUT/f'fotograma_cam{cam:03d}.png')
    # Vídeo corto real del simulador, no mockup artístico.
    try:
        import imageio.v2 as iio
        iio.mimsave(str(OUT/'sara_mundo_120px.mp4'),frames,fps=12,quality=7,macro_block_size=2)
    except Exception as exc:
        (OUT/'VIDEO_NO_DISPONIBLE.txt').write_text(str(exc))
    contact=Image.new('RGB',(1600,900),'#141a27')
    for i,cam in enumerate([0,40,80,120]):
        contact.paste(draw_frame(cam),(i%2*800,i//2*450))
    contact.save(OUT/'CONTROL_CUATRO_CAMARAS.png')
    result={
        'camera_path':[float(x) for x in camera_path],
        'camera_shift':120,
        'landmark_move_in_screen':120,
        'character_screen_x':327,
        'ground_y':GROUND,
        'native_landmark_width':LANDMARK_W,
        'uncovered_at_camera_120':max(0,120+800-LANDMARK_W),
        'uncovered_at_camera_600':max(0,600+800-LANDMARK_W),
        'original_sha256':hashlib.sha256((ROOT/'assets/images/chapter1/residential_curve.png').read_bytes()).hexdigest(),
        'qa_status_first_120':'OK_FOR_SIMULATION_ONLY',
        'qa_status_seam':'REJECTED_NOT_AUTHORED',
        'qa_status_flutter':'NOT_TESTED',
    }
    (OUT/'metricas.json').write_text(json.dumps(result,indent=2,ensure_ascii=False)+'\n')
    print(json.dumps(result,indent=2,ensure_ascii=False))

if __name__=='__main__':
    main()
