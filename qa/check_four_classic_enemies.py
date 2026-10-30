#!/usr/bin/env python3
"""Checks master/candidate fidelity, never confuses valid PNG with art approval."""
from pathlib import Path
from PIL import Image
import hashlib,json,sys
ROOT=Path(__file__).resolve().parents[1]
report=ROOT/'qa/art_review/four_existing_enemy_polish_state.json'
if not report.is_file():
    raise SystemExit('Primero ejecutar tools/refine_four_classic_enemies.py')
state=json.loads(report.read_text(encoding='utf-8'))
count={'breakdancer':6,'bully':5,'referee':6,'rival':6}
fail=[]
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
for kind,n in count.items():
    for index in range(n):
        key=f'{kind}_{index}'
        item=state.get(key)
        if not item:
            fail.append(f'Falta {key}');continue
        source=ROOT/item['source'];candidate=ROOT/item['candidate']
        if not source.exists() or not candidate.exists():
            fail.append(f'Archivo inexistente {key}');continue
        if sha(source)!=item['original_sha256'] or sha(candidate)!=item['candidate_sha256']:
            fail.append(f'SHA no coincide {key}')
        with Image.open(source) as raw,Image.open(candidate) as revised:
            a,b=raw.convert('RGBA'),revised.convert('RGBA')
            if a.size!=b.size or a.getchannel('A').tobytes()!=b.getchannel('A').tobytes():
                fail.append(f'Silueta/escala modificada {key}')
            if a.getchannel('A').getbbox() is None:fail.append(f'Vacío {key}')
        if item['art_approved'] or item['flutter_capture_reviewed']:
            fail.append(f'Aprobación ficticia {key}')
    if not (ROOT/f'qa/art_review/{kind}_original_vs_polished.png').is_file():
        fail.append(f'Falta comparativa {kind}')
if len(state)!=sum(count.values()):fail.append('Número de candidatos incorrecto')
if fail:
    print('\n'.join('ERROR '+x for x in fail),file=sys.stderr)
    raise SystemExit(1)
print(f'PASS: {len(state)} candidatos con misma máscara y escala. NO aprobación artística.')
