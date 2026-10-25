#!/usr/bin/env python3
"""Rechaza saltos geométricamente imposibles ANTES de ejecutar un capítulo.

Modelo conservador de alcance horizontal: velocidad del juego 169 unidades/s,
impulso de salto 410 u/s, gravedad 960 u/s². Las plataformas deben registrar
colisión REAL del motor, no rectángulos pintados decorativos.

Una ruta alcanzable por este modelo no prueba que el nivel sea jugable: faltan
verificar enemigos, obstáculos, pulsaciones, cámara y recorrido real.
"""
from __future__ import annotations
import argparse,json,math
from pathlib import Path

RUN_SPEED=169.0
JUMP_SPEED=410.0
GRAVITY=960.0
MAX_JUMP_HEIGHT=JUMP_SPEED**2/(2*GRAVITY)

def edge_reachable(start:dict, destination:dict) -> bool:
    """Can player land on destination from start (without considering enemies)?"""
    delta_up=float(start['y'])-float(destination['y'])
    disc=JUMP_SPEED**2-2*GRAVITY*delta_up
    if disc < 0: return False
    airtime=(JUMP_SPEED+math.sqrt(disc))/GRAVITY
    gap=max(float(destination['left'])-float(start['right']),
            float(start['left'])-float(destination['right']), 0.0)
    return gap <= airtime*RUN_SPEED + 1.e-6

def check_map(data:dict)->dict:
    failures=[]
    if data.get('physics') != {'run_speed':RUN_SPEED,'jump_speed':JUMP_SPEED,'gravity':GRAVITY}:
        failures.append('Los parámetros de física no coinciden con la versión base')
    surfaces=data.get('surfaces',[])
    if not surfaces: return {'reachable':False,'errors':['No hay superficies de colisión reales registradas']}
    by_id={}
    for obj in surfaces:
        if not all(k in obj for k in ('id','left','right','y')):
            failures.append('Plataforma sin id, left, right o y');continue
        if obj['id'] in by_id:failures.append(f'Superficie duplicada: {obj["id"]}')
        if not (float(obj['left'])<float(obj['right'])):
            failures.append(f'Superficie con anchura nula: {obj["id"]}')
        by_id[obj['id']]=obj
    initial=data.get('start_surface')
    finish=data.get('finish_surface')
    if initial not in by_id or finish not in by_id:
        failures.append('Inicio o meta no corresponde a una superficie');return {'reachable':False,'errors':failures}
    visited={initial};queue=[initial]; route={initial:None}
    while queue:
        current=queue.pop(0)
        for name,surface in by_id.items():
            if name in visited:continue
            if edge_reachable(by_id[current],surface):
                visited.add(name);queue.append(name);route[name]=current
    if finish not in visited:failures.append('Meta físicamente inaccesible desde inicio con el salto aprobado')
    chain=[]
    if finish in visited:
        p=finish
        while p is not None:chain.append(p);p=route[p]
        chain.reverse()
    return {'reachable':not failures,'path':chain,'errors':failures,
      'disclaimer':'Esta prueba no sustituye comprobar la partida completa en Android'}

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('level_json',type=Path)
    args=p.parse_args()
    result=check_map(json.loads(args.level_json.read_text()))
    print(json.dumps(result,indent=2,ensure_ascii=False))
    raise SystemExit(0 if result['reachable'] else 1)
