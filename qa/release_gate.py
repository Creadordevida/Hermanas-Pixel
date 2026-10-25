#!/usr/bin/env python3
"""Strong baseline and sign-off gate. Pillow required only for --audit-art.

Runs on frozen v0.8.0. A new version must receive explicit approval for
all new art and Android evidence before claiming a verified release.
"""
from __future__ import annotations
import argparse
from pathlib import Path
import hashlib, json, sys, re
ROOT=Path(__file__).resolve().parents[1]
QA=ROOT/'qa'

def sha(p:Path)->str: return hashlib.sha256(p.read_bytes()).hexdigest()

def frozen_check():
    manifest=json.loads((QA/'baseline_080_sha256.json').read_text())
    errors=[]
    for rel,key in [('qa/baseline_080_source/main.dart','main_dart_sha256'), ('qa/baseline_080_source/pubspec.yaml','pubspec_sha256')]:
        path=ROOT/rel
        if not path.is_file() or sha(path)!=manifest[key]:errors.append(f'ORIGINAL SOURCE CHANGED: {rel}')
    for rel,expect in manifest['frozen_assets'].items():
        p=ROOT/rel
        if not p.is_file():errors.append(f'MISSING BASE: {rel}')
        elif sha(p)!=expect:errors.append(f'BASE CHANGED: {rel}')
    return errors

def _metrics(path):
    # imported only for author-side visual analysis; no Pillow for GitHub's baseline hash test
    from PIL import Image
    import numpy as np
    with Image.open(path) as pic:
        pic=pic.convert('RGB').resize((640,320))
        a=np.asarray(pic,dtype=np.float32)
        diff=float((np.abs(np.diff(a,axis=0)).mean()+np.abs(np.diff(a,axis=1)).mean())/2)
        entropy=sum(pic.getchannel(j).entropy() for j in range(3))/3
        return {'detail_index':round(diff,2),'color_entropy':round(entropy,2)}

def art_audit(candidate:Path):
    ref=[_metrics(ROOT/f'assets/images/{p}.png') for p in
       ('level_pixel','level_ayuntamiento','level_estafeta','level_plaza_castillo')]
    # deliberately cautious heuristic. Requires manual comparison EVEN IF numbers pass.
    detail_min=min(x['detail_index'] for x in ref)*0.70
    entropy_min=min(x['color_entropy'] for x in ref)*0.92
    items=[]
    for rel in ['assets/images/scenes/football.png','assets/images/scenes/ballet.png',
                'assets/images/scenes/school.png','assets/images/map_pamplona.png']:
        p=candidate/rel
        if not p.exists(): continue
        metric=_metrics(p)
        items.append({'file':rel,**metric,
          'automatic_warning':metric['detail_index']<detail_min or metric['color_entropy']<entropy_min})
    return ref,items,{'minimum_detail_index':round(detail_min,2),'minimum_color_entropy':round(entropy_min,2)}

def signoff_check():
    from check_evidence import check_approval_evidence
    data=json.loads((QA/'acceptance_090.json').read_text())
    errors=check_approval_evidence()
    # A check-mark is NOT proof: every new art resource must exist in the release
    # with a hash specifically approved for that exact byte sequence.
    manifest=QA/'approved_asset_manifest.json'
    if not manifest.is_file():
        errors.append('Falta manifiesto de arte aprobado, no se admiten aprobaciones ficticias')
    else:
        try:
            approved=json.loads(manifest.read_text())
            for item in data['items']:
                asset=approved.get(item)
                if not asset or not asset.get('files'):
                    errors.append(f'{item}: no hay archivos aprobados vinculados')
                    continue
                for file_info in asset['files']:
                    path=(ROOT/file_info.get('path','')).resolve()
                    if not path.is_relative_to(ROOT.resolve()) or not path.is_file():
                        errors.append(f'{item}: archivo ausente o fuera del proyecto')
                    elif sha(path)!=file_info.get('sha256'):
                        errors.append(f'{item}: SHA256 no coincide con aprobación')
        except (ValueError,TypeError,KeyError) as exc:
            errors.append(f'Manifiesto artístico dañado: {exc}')
    if data['release_status']!='APROBADO':errors.append('La versión no tiene aprobación explícita')
    for key,value in data['items'].items():
        for field in ('graphic_review','animation_review','functional_review','runtime_evidence'):
            if value[field]!='APROBADO': errors.append(f'{key}: {field}={value[field]}')
        approved=value.get('approved_asset_sha256')
        if not approved:errors.append(f'{key}: sin vinculación a recursos visuales aprobados')
    for key,v in data['qa_runs'].items():
        if v!='APROBADO': errors.append(f'{key}: {v}')
    return errors

def process(argv=None):
    parser=argparse.ArgumentParser()
    parser.add_argument('--strict',action='store_true',help='bloquear si falta aprobación, prueba o evidencia')
    parser.add_argument('--audit-art',type=Path,metavar='DIR_090_FALLIDA',help='comparar fondos del candidato con la 0.8.0')
    parser.add_argument('--json',action='store_true')
    args=parser.parse_args(argv)
    frozen=frozen_check()
    pending=signoff_check() if args.strict else []
    if args.audit_art:
        try: ref,items,limits=art_audit(args.audit_art)
        except (ImportError,FileNotFoundError) as e:
            print(f'No se pudo auditar arte: {e}',file=sys.stderr)
            return 3
    else: ref=items=limits=None
    result={'baseline_ok':not frozen,'baseline_errors':frozen,'release_approved':not pending if args.strict else None,
        'pending_count':len(pending),'pending':pending,'art_reference':ref,'art_candidates':items,'art_heuristic_limits':limits,
        'note':'Métricas visuales orientativas; nunca demuestran calidad ni sustituyen inspección del APK'}
    if args.json:print(json.dumps(result,indent=2,ensure_ascii=False))
    else:
        print(f'BASELINE 0.8.0: {"INTACTO" if not frozen else "RECHAZADO"}')
        if items:
            print('AUDITORÍA DE FONDOS (aviso heurístico, NO aceptación automática)')
            for item in items:print('  ',item['file'],item['detail_index'],item['color_entropy'],
                'RECHAZAR PARA REVISIÓN' if item['automatic_warning'] else 'REVISIÓN HUMANA NECESARIA')
        if args.strict:print('ENTREGA:', 'APROBADA' if not pending else f'BLOQUEADA ({len(pending)} comprobaciones pendientes)')
        if frozen:print('\n'.join(frozen[:10]))
    return 1 if frozen or (args.strict and pending) else 0

if __name__=='__main__':raise SystemExit(process())
