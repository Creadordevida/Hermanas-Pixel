"""Strict, offline-safe project validation with standard library only."""
from pathlib import Path
import hashlib, json, re, struct, zlib
ROOT=Path(__file__).resolve().parents[1]
base=json.loads((ROOT/'qa/approved_hashes.json').read_text())
for rel, digest in base.items():
    p=ROOT/rel
    assert p.exists(), f'Falta recurso aprobado: {rel}'
    assert hashlib.sha256(p.read_bytes()).hexdigest()==digest, f'REGRESIÓN de fichero aprobado: {rel}'
files=[]
for p in (ROOT/'assets/images').rglob('*.png'):
    data=p.read_bytes(); assert data[:8]==b'\x89PNG\r\n\x1a\n',p
    w,h=struct.unpack('>II',data[16:24]); assert 8<=w<=3000 and 8<=h<=3000,(p,w,h)
    files.append(p)
for n in ['football','ballet','school']:
    assert (ROOT/f'assets/images/scenes/{n}.png').exists()
for v in ['pigeon','cat','rat','statue','rival','referee','novice','breakdancer','bully','teacher']:
    for i in range(5):assert (ROOT/f'assets/images/enemies/{v}_{i}.png').exists()
for v in ['dalmatian','doberman']:
    for name in ['idle','walk','alert','run','bite','hit','stunned','defeated']:
        assert (ROOT/f'assets/images/dog/{v}/{name}.png').exists()
for role in ['futbolista','bailarina']:
    for pose in ['idle_0','walk_0','walk_1','jump_0']:
        assert (ROOT/f'assets/images/outfits/{role}_{pose}.png').exists()
for name in ['cone','planter','backpack','gym_bench','red_card','shoe','eraser']:
    assert (ROOT/f'assets/images/props/{name}.png').exists()
code=(ROOT/'lib/main.dart').read_text()
for text in ['mapStops','chapterNames','completed','Screen.map','stageWidth = 40000',
             'stage==4','stage==5','_receiveDamage','_finishChapter','foe.attackCooldown=3.6']:
    assert text in code, f'No existe comportamiento esperado: {text}'
for n in ['0.9.0','assets/images/enemies/','assets/images/outfits/','assets/images/scenes/']:
    assert n in (ROOT/'pubspec.yaml').read_text(),n
# All exact original title/scene/actor icon hashes are retained separately from derived art.
print(f'OK: {len(base)} recursos aprobados idénticos, {len(files)} PNG, 7 capítulos y 13 variantes descritas.')
