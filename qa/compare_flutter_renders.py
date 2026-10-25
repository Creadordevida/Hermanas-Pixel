#!/usr/bin/env python3
"""Comparar píxel a píxel CAPTURAS REALES del widget de Flutter.

This is a sensitive *regression detector*, NOT an artistic quality judge.
Both source and candidate must be rendered by test/qa_render_capture_test.dart
at the same deterministic resolution. It intentionally returns a failure when
any required baseline screenshot is missing. Baselines must come from v0.8.0.
"""
from __future__ import annotations
import argparse, json
from pathlib import Path
import numpy as np
from PIL import Image

NAMES=['titulo_base_080_flutter'] + [f'capitulo_{i}_base_080_flutter' for i in range(1,5)]

def compare(base:Path, candidate:Path) -> dict:
    with Image.open(base) as b, Image.open(candidate) as c:
        if b.size != c.size:
            raise ValueError(f'Dimensiones diferentes: {b.size} != {c.size}')
        if b.size!=(800,450):
            raise ValueError(f'Render no normalizado a 800x450: {b.size}')
        x=np.asarray(b.convert('RGB'),dtype=np.int16)
        y=np.asarray(c.convert('RGB'),dtype=np.int16)
    diff=np.abs(x-y)
    changed=int(np.count_nonzero(np.any(diff>3,axis=2)))
    return {'pixels_changed':changed,'pixels_changed_pct':round(float(changed * 100 / (800*450)),6),
            'mean_color_change':round(float(diff.mean()),3),
            'max_color_change':int(diff.max()),
            'exact_match':bool(np.array_equal(x,y))}

def check(base_dir:Path,candidate_dir:Path, allowed_pct:float=0.0)->dict:
    errors=[];frames={}
    for name in NAMES:
        ref=base_dir/(name+'.png'); cur=candidate_dir/(name+'.png')
        if not ref.is_file() or not cur.is_file():
            errors.append(f'Falta comparación de render real {name}: base={ref.is_file()}, actual={cur.is_file()}')
            continue
        try:
            metric=compare(ref,cur)
            frames[name]=metric
            if metric['pixels_changed_pct']>allowed_pct:
                errors.append(f'{name}: diferencia {metric["pixels_changed_pct"]}% excede {allowed_pct}%')
        except Exception as exc:
            errors.append(f'{name}: {exc}')
    return {'passed':not errors,'errors':errors,'renders':frames,
            'warning':'Una coincidencia visual no demuestra jugabilidad ni calidad de los elementos añadidos'}

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--base',type=Path,required=True)
    parser.add_argument('--candidate',type=Path,required=True)
    parser.add_argument('--allow-changed-pct',type=float,default=0.)
    args=parser.parse_args()
    result=check(args.base,args.candidate,args.allow_changed_pct)
    print(json.dumps(result,ensure_ascii=False,indent=2))
    raise SystemExit(0 if result['passed'] else 1)
