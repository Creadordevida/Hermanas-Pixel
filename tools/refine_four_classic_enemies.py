#!/usr/bin/env python3
"""Generate NON-DESTRUCTIVE reviews of approved 16-bit classic enemy art.

No file under assets/images/enemies/ is modified. Generate 22 candidates
inside qa/art_review/candidates; inspect in actual StagePainter before adopting.
Outputs are explicitly NOT approved by this function or by its tests.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageEnhance
import hashlib, json

ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'assets/images/enemies'
REVIEW=ROOT/'qa/art_review'
STAGED=REVIEW/'candidates'
KINDS={'breakdancer':6,'bully':5,'referee':6,'rival':6}

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def subtle_review(original):
    """Return a trial color grade at SAME dimensions and EXACT same alpha."""
    image=original.convert('RGBA')
    a=image.getchannel('A')
    color=ImageEnhance.Color(image.convert('RGB')).enhance(1.018)
    color=ImageEnhance.Contrast(color).enhance(1.015)
    color.putalpha(a)
    return color

def contact(originals, candidates, kind):
    width=max(1400,len(originals)*235+20)
    output=Image.new('RGB',(width,670),'#1b2b41')
    draw=ImageDraw.Draw(output)
    draw.text((12,7),f'{kind} - MAESTRO APROBADO / REVISIÓN NO APROBADA',fill='white')
    for index, (old,new) in enumerate(zip(originals,candidates)):
        for row, picture in enumerate((old,new)):
            picture=picture.copy()
            picture.thumbnail((216,270),resample=Image.Resampling.NEAREST)
            xx=index*235+12+(216-picture.width)//2
            yy=30+row*317+270-picture.height
            output.paste(picture,(xx,yy),picture)
            draw.text((index*235+13,yy+picture.height+5),str(index),fill='white')
    output.save(REVIEW/f'{kind}_original_vs_polished.png',optimize=True)

def main():
    STAGED.mkdir(parents=True,exist_ok=True)
    log={}
    for kind,count in KINDS.items():
        before=[];after=[]
        for n in range(count):
            src=SRC/f'{kind}_{n}.png'
            with Image.open(src) as raw:
                im=raw.convert('RGBA')
            if im.getchannel('A').getbbox() is None:
                raise ValueError(f'{kind}_{n}: sprite original vacío')
            candidate=subtle_review(im)
            if candidate.size != im.size or (
                candidate.getchannel('A').tobytes()!=im.getchannel('A').tobytes()
            ):
                raise RuntimeError('Tamaño o alfa alterados sin autorización')
            dest=STAGED/f'{kind}_{n}.png'
            candidate.save(dest,optimize=True)
            log[f'{kind}_{n}']={
                'source':str(src.relative_to(ROOT)), 'original_sha256':digest(src),
                'candidate':str(dest.relative_to(ROOT)),
                'candidate_sha256':digest(dest), 'size':list(im.size),
                'art_approved':False, 'flutter_capture_reviewed':False,
            }
            before.append(im);after.append(candidate)
        contact(before,after,kind)
    report=REVIEW/'four_existing_enemy_polish_state.json'
    report.write_text(json.dumps(log,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(f'{len(log)} candidatos revisables generados; 27 originales preservados; NO aprobados.')

if __name__=='__main__':main()
