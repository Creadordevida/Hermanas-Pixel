#!/usr/bin/env python3
"""Enforce evidence for enabled NEW enemy art; no aesthetic approval by geometry.

The currently unapproved concepts stay disabled and this gate does NOT
replace qa/next_version_preflight.py --strict-assets (six required).
"""
from __future__ import annotations
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
MAIN=ROOT/'lib/main.dart'
EVIDENCE=ROOT/'qa/art_review/new_enemy_art_approved.json'
NAMES={
 'cleaning_robot':'robot',
 'rival_supporter':'supporter',
 'tipsy_tourist':'tourist',
 'navarre_king':'navarre_king',
 'estafeta_bull':'estafeta_bull',
 'sanfermin_runner':'sanfermin_runner',
}

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    text=MAIN.read_text(encoding='utf-8')
    flags=dict(re.findall(
      r"'(cleaning_robot|rival_supporter|tipsy_tourist|navarre_king|"
      r"estafeta_bull|sanfermin_runner)'\s*:\s*(true|false)",text))
    bad=[]
    if set(flags)!=set(NAMES):
        bad.append('No están los seis indicadores de aprobación en lib/main.dart')
    enabled=[name for name,flag in flags.items() if flag=='true']
    if not enabled:
        print('E: 6 enemigos aún NO APROBADOS; flags inactivos. '
              'No sustituye al preflight --strict-assets.')
        return 1 if bad else 0
    try:
        approved=json.loads(EVIDENCE.read_text(encoding='utf-8'))
    except (FileNotFoundError,ValueError):
        approved={}
        bad.append('Arte activado sin qa/art_review/new_enemy_art_approved.json')
    for kind in enabled:
        item=approved.get(kind,{})
        path=ROOT/'assets/images/enemies_new'/f'{NAMES[kind]}_atlas.png'
        shot=ROOT/item.get('flutter_capture_path','') if item else ROOT
        if not path.is_file():
            bad.append(f'{kind}: atlas no existe')
            continue
        if sha(path)!=item.get('atlas_sha256'):
            bad.append(f'{kind}: bytes del atlas distintos a los aprobados')
        if item.get('art_review')!='APROBADO' or item.get('animation_review')!='APROBADO':
            bad.append(f'{kind}: revisión artística / animación no aprobada')
        if not (shot.is_file() and shot.is_relative_to(ROOT) and
                str(shot).endswith('.png')):
            bad.append(f'{kind}: falta captura auténtica Flutter de la escena')
        elif sha(shot)!=item.get('flutter_capture_sha256'):
            bad.append(f'{kind}: captura Flutter distinta a evidencia revisada')
    if bad:
        for x in bad:print('BLOQUEADO:',x,file=sys.stderr)
        return 1
    print('Hay evidencias SHA concordantes de los personajes ACTIVADOS; '
          'sigue siendo necesaria validación de Android y revisión del usuario.')
    return 0

if __name__=='__main__':
    sys.exit(main())
