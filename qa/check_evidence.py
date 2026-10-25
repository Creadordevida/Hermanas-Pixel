#!/usr/bin/env python3
"""Evidence must be captured from the installed Android game.

This validates bytes, provenance, coverage, and timing submissions. Human visual
judgment and physical playtesting remain mandatory, outside this algorithm.
"""
from __future__ import annotations
import hashlib, json, sys, re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
QA=ROOT/'qa'
SPEC=json.loads((QA/'specification_090.json').read_text())
ENEMY_IDS=set(SPEC['enemies'])
SCREENS={'title','map','title_logo'} | {f'chapter_{i}_{part}'
    for i in range(1,8) for part in ('start','middle','finish')}
ENEMY_SCREENSHOTS={f'enemy_{kind}_{action}' for kind in ENEMY_IDS
    for action in ('idle','attack','hit','defeat')}
REQUIRED_CAPTURES=SCREENS|ENEMY_SCREENSHOTS
REQUIRED_RECORDINGS={f'chapter_{i}_run' for i in range(1,8)} | {
    f'enemy_{kind}_animation' for kind in ENEMY_IDS}

def sha(path:Path)->str:
    return hashlib.sha256(path.read_bytes()).hexdigest()

def check_approval_evidence():
    manifest=ROOT/'evidence/manifest.json'
    if not manifest.exists():
        return ['No hay evidencia de ejecución REAL en Android (evidence/manifest.json)']
    try:data=json.loads(manifest.read_text())
    except (OSError,json.JSONDecodeError) as exc:return [f'Manifiesto ilegible: {exc}']
    errors=[]
    apkn=data.get('apk_file','')
    apk=(ROOT/apkn).resolve() if apkn else ROOT/'NO_APK'
    if not apk.is_relative_to(ROOT.resolve()):errors.append('APK externo al proyecto, no verificable')
    elif not apk.is_file() or sha(apk)!=data.get('apk_sha256'):
        errors.append('Falta APK o hash SHA256 no coincide')
    if data.get('capture_method')!='adb exec-out screencap -p':
        errors.append('Método de captura no verificado: debe ser ADB real')
    if data.get('app_package')!='com.example.hermanas_aventura':
        errors.append('No se ha vinculado la captura al paquete de juego previsto')
    captures=data.get('screenshots',{})
    for key in sorted(REQUIRED_CAPTURES):
        item=captures.get(key)
        if item is None:errors.append(f'Falta captura del APK: {key}');continue
        path=(ROOT/item.get('file','')).resolve()
        if not path.is_relative_to(ROOT.resolve()) or not path.is_file():
            errors.append(f'Captura ausente o fuera del proyecto: {key}');continue
        if not path.read_bytes().startswith(b'\x89PNG\r\n\x1a\n') or sha(path)!=item.get('sha256'):
            errors.append(f'Captura dañada o hash distinto: {key}')
        if item.get('apk_sha256')!=data.get('apk_sha256'):
            errors.append(f'Captura pertenece a otro APK: {key}')
        if item.get('foreground_package')!=data.get('app_package'):
            errors.append(f'No hay prueba de aplicación activa: {key}')
    recordings=data.get('recordings',{})
    for key in sorted(REQUIRED_RECORDINGS):
        item=recordings.get(key)
        if item is None:errors.append(f'Falta vídeo del juego real: {key}');continue
        path=(ROOT/item.get('file','')).resolve()
        if not path.is_relative_to(ROOT.resolve()) or not path.is_file() or sha(path)!=item.get('sha256'):
            errors.append(f'Vídeo no verificable: {key}')
        if item.get('apk_sha256')!=data.get('apk_sha256'):
            errors.append(f'Vídeo vinculado a otro APK: {key}')
        if key.startswith('chapter_') and float(item.get('measured_elapsed_seconds',0))<240:
            errors.append(f'Capítulo sin tiempo total cronometrado >= 4 min: {key}')
    return errors

verify=check_approval_evidence
if __name__=='__main__':
    errors=check_approval_evidence()
    if errors:
        print(f'NO APROBADO: {len(errors)} incidencias de evidencias reales Android')
        for err in errors[:30]:print(' -',err)
        if len(errors)>30:print(' ... y',len(errors)-30,'más')
        sys.exit(1)
    print('EVIDENCIAS FORMALMENTE VÁLIDAS; PENDIENTE VALORACIÓN ARTÍSTICA Y JUGABLE')
